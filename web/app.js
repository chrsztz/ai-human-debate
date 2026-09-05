'use strict';

const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const el = (tag, cls, txt) => { const n = document.createElement(tag); if (cls) n.className = cls; if (txt != null) n.textContent = txt; return n; };
const add = (parent, node) => { parent.append(node); return node; };          // 返回子节点，方便链式设置
const note = (parent, html) => { add(parent, el('div', 'note')).innerHTML = html; };
const fx = (v, n = 3) => (v == null || Number.isNaN(v) ? '—' : Number(v).toFixed(n));

const ST = { state: null, sel: null, busy: false };
const SIDE = { pro: '正方', con: '反方' };
const sideOf = spk => (spk === 'human' ? ST.state.human_side : ST.state.ai_side);

/* ── 请求 ──────────────────────────────────────────────── */
async function api(path, body) {
  const opt = body === undefined ? {} : { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
  const r = await fetch(path, opt);
  if (!r.ok) {
    let msg = r.statusText;
    try { msg = (await r.json()).detail || msg; } catch { /* 非 JSON 错误体 */ }
    throw new Error(msg);
  }
  return r.json();
}

let toastTimer;
function toast(msg) {
  const t = $('#toast');
  t.textContent = msg; t.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { t.hidden = true; }, 6000);
}

/* ── 悬停浮层 ──────────────────────────────────────────── */
const tip = $('#tip');
document.addEventListener('mouseover', e => {
  const t = e.target.closest('[data-tip]');
  if (!t) return;
  tip.textContent = t.dataset.tip;
  tip.hidden = false;
});
document.addEventListener('mousemove', e => {
  if (tip.hidden) return;
  const pad = 14, r = tip.getBoundingClientRect();
  let x = e.clientX + pad, y = e.clientY + pad;
  if (x + r.width > innerWidth - 8) x = e.clientX - r.width - pad;
  if (y + r.height > innerHeight - 8) y = e.clientY - r.height - pad;
  tip.style.left = x + 'px'; tip.style.top = y + 'px';
});
document.addEventListener('mouseout', e => {
  if (e.target.closest('[data-tip]')) tip.hidden = true;
});

/* ── 图元：双极量表 ────────────────────────────────────── */
// 极性由几何表示（相对中线向左/向右），颜色只表示说话人 —— 蓝/橙不表示正负。
function meter(def, a, color, big) {
  const wrap = el('div', 'meter' + (big ? ' big' : ''));
  wrap.style.setProperty('--c', color);
  const pct = Math.max(0, Math.min(1, a.unit)) * 100;
  const left = Math.min(50, pct), w = Math.abs(pct - 50);

  if (big) {
    const row = el('div', 'meter-row');
    row.append(el('span', 'meter-name', def.name_zh), el('span', 'meter-val', `${fx(a.unit, 3)}`));
    wrap.append(row);
  }
  const track = el('div', 'meter-track');
  const fill = el('div', 'meter-fill');
  fill.style.left = left + '%';
  fill.style.width = Math.max(w, 0.6) + '%';
  // 数据端 4px 圆角，贴中线那端保持方角
  fill.style.borderRadius = pct >= 50 ? '0 4px 4px 0' : '4px 0 0 4px';
  track.append(fill);
  wrap.append(track);

  if (big) {
    const ends = el('div', 'meter-ends');
    ends.append(el('span', null, '← ' + def.neg_label), el('span', null, def.pos_label + ' →'));
    wrap.append(ends);
  }
  wrap.dataset.tip = `${def.name_zh}\nunit ${fx(a.unit, 3)}   z ${fx(a.z, 2)}\nraw ${fx(a.raw, 4)}`;
  return wrap;
}

/* ── 图元：片段轨迹（离散片段 → 双极条，不是折线） ────── */
function trajectory(segments, axisId, def, color) {
  const box = el('div', 'traj');
  box.style.setProperty('--c', color);
  segments.forEach(s => {
    const a = s.axes[axisId];
    const bar = el('div', 'traj-bar');
    const i = el('i');
    const d = a.unit - 0.5;
    if (d >= 0) { i.style.bottom = '50%'; i.style.height = (d * 100) + '%'; i.style.borderRadius = '4px 4px 0 0'; }
    else { i.style.top = '50%'; i.style.height = (-d * 100) + '%'; i.style.borderRadius = '0 0 4px 4px'; }
    bar.append(i);
    bar.dataset.tip = `片段 ${s.index + 1} · ${def.name_zh}\nunit ${fx(a.unit, 3)}   z ${fx(a.z, 2)}\n\n${s.text}`;
    box.append(bar);
  });
  return box;
}

/* ── 立场条 ────────────────────────────────────────────── */
function renderStance() {
  const box = $('#stance');
  box.innerHTML = '';
  const m = ST.state.motion;
  if (!m) {
    box.append(el('span', 'stance-warn', '⚠ 没有设辩题 —— AI 拿不到立场，会顺着你的话往下写，两边论证同一边。在上面填辩题后点「开新一场」。'));
    return;
  }
  box.append(el('span', 'stance-motion', m));
  [['human', '人'], ['ai', 'AI']].forEach(([spk, name]) => {
    const chip = el('span', 'stance-chip');
    chip.style.setProperty('--c', spk === 'human' ? 'var(--human)' : 'var(--ai)');
    chip.append(el('i'), el('span', null, name + ' '), el('b', null, SIDE[sideOf(spk)] || '?'));
    chip.dataset.tip = spk === 'ai'
      ? `AI 的立场常驻在 system message 里（配置页可见原文）`
      : `${SIDE[ST.state.human_side]}：${ST.state.human_side === 'pro' ? '支持' : '反对'}「${m}」`;
    box.append(chip);
  });
  // 这个标记是给观众看的一个断言，必须反映实际情况
  const SRC = {
    drawn: ['抽签', '立场由抽签决定，不是任何一方选的。\n人自己选的话一定选自己真信的那边，AI 就永远是唱反调的那个 —— 那会在 affiliation 轴上造成同向偏差。'],
    chosen: ['人选的边', '这一场的立场是人在界面上选的，不是抽签。\n注意：人一定选自己真信的那边，所以 AI 恒为反调方，affiliation 轴上会有同向偏差。'],
    config: ['配置写死', '立场来自 .env 的 AI_SIDE，每一场都一样。'],
  };
  const src = SRC[ST.state.side_source];
  if (src) {
    const t = el('span', 'stance-chip', src[0]);
    t.dataset.tip = src[1];
    box.append(t);
  }
}

/* ── 对话 ──────────────────────────────────────────────── */
function renderTranscript() {
  const box = $('#transcript');
  const turns = ST.state.turns;
  box.innerHTML = '';
  if (!turns.length) {
    box.append(el('div', 'empty', '还没有发言。先说一句，AI 会接话；每个回合会被切成子句，逐句投影到四条语义轴上。'));
    return;
  }
  const defs = ST.state.axes.defs;
  turns.forEach(t => {
    const color = t.speaker === 'human' ? 'var(--human)' : 'var(--ai)';
    const n = el('div', `turn ${t.speaker}` + (ST.sel === t.id ? ' sel' : ''));
    const head = el('div', 'turn-head');
    head.append(
      el('span', 'turn-who', t.speaker === 'human' ? '人' : 'AI'),
      el('span', null, `#${t.id}`),
    );
    // 每个回合的立场取自本场分配（不是逐回合存的），换场重置
    const sd = SIDE[t.speaker === 'ai' && t.meta && t.meta.ai_side ? t.meta.ai_side : sideOf(t.speaker)];
    if (ST.state.motion && sd) head.append(el('span', null, sd));
    head.append(el('span', null, `${t.segments.length} 片段`));
    if (t.meta && t.meta.latency_ms) head.append(el('span', null, `${t.meta.latency_ms}ms`));
    if (t.meta && t.meta.typing_ms) head.append(el('span', null, `输入 ${(t.meta.typing_ms / 1000).toFixed(1)}s`));
    n.append(head, el('div', 'turn-text', t.text));

    const mini = el('div', 'turn-mini');
    defs.forEach(d => {
      const cell = el('div');
      cell.append(el('div', 'mini-label', d.name_zh), meter(d, t.axes[d.id], color, false));
      mini.append(cell);
    });
    n.append(mini);
    n.onclick = () => { ST.sel = t.id; renderTranscript(); renderTurnPane(); };
    box.append(n);
  });
  box.scrollTop = box.scrollHeight;
}

function pending(on) {
  $('#transcript .pending')?.remove();
  if (!on) return;
  const p = el('div', 'pending');
  p.append(el('span', 'pulse'), el('span', null, 'AI 正在生成…'));
  $('#transcript').append(p);
  $('#transcript').scrollTop = $('#transcript').scrollHeight;
}

/* ── 面板：本轮 ────────────────────────────────────────── */
function renderTurnPane() {
  const pane = $('#pane-turn');
  pane.innerHTML = '';
  const turns = ST.state.turns;
  const t = turns.find(x => x.id === ST.sel) || turns[turns.length - 1];
  if (!t) {
    pane.append(el('div', 'empty', '还没有回合可以分析。'));
    return;
  }
  ST.sel = t.id;
  const color = t.speaker === 'human' ? 'var(--human)' : 'var(--ai)';
  const defs = ST.state.axes.defs;

  const card = el('div', 'card');
  const head = el('div', 'card-head');
  const totalMs = t.segments.reduce((a, s) => a + (s.dur_ms || 0), 0);
  head.append(
    el('h3', null, `#${t.id} · ${t.speaker === 'human' ? '人' : 'AI'} · ${t.segments.length} 片段`),
    el('span', 'muted mono', `${t.text.length} 字${totalMs ? ` · OSC ${(totalMs / 1000).toFixed(1)}s` : ''}`),
  );
  card.append(head);

  defs.forEach(d => {
    const b = el('div', 'axis-block');
    b.append(meter(d, t.axes[d.id], color, true));
    // 少于 3 个片段画不出"轨迹"，两根宽条只会看起来像一条横线
    if (t.segments.length >= 3) {
      b.append(trajectory(t.segments, d.id, d, color));
      const cap = el('div', 'traj-cap');
      cap.append(el('span', null, '片段轨迹 →'), el('span', null, `中线 = 0.5 · ${t.segments.length} 片段`));
      b.append(cap);
    }
    if (d.note) b.append(el('div', 'axis-note', d.note.split('\n')[0]));
    card.append(b);
  });
  pane.append(card);

  // 表格视图 —— 上面每一根条在这里都有对应数字
  const tcard = el('div', 'card');
  tcard.append(el('h3', null, '片段读数（unit，0~1）'));
  const wrap = el('div', 'scroll-x');
  const tb = el('table', 'data');
  const thead = el('thead'); const hr = el('tr');
  hr.append(el('th', null, '#'), el('th', null, '片段'));
  defs.forEach(d => hr.append(el('th', null, d.name_zh.split(' ')[0])));
  hr.append(el('th', null, '时长'));
  thead.append(hr); tb.append(thead);
  const body = el('tbody');
  t.segments.forEach(s => {
    const tr = el('tr');
    tr.append(el('td', null, String(s.index + 1)), el('td', 't', s.text));
    defs.forEach(d => {
      const td = el('td', null, fx(s.axes[d.id].unit, 3));
      td.dataset.tip = `raw ${fx(s.axes[d.id].raw, 4)}   z ${fx(s.axes[d.id].z, 2)}`;
      tr.append(td);
    });
    const dt = el('td', null, s.dur_ms ? `${(s.dur_ms / 1000).toFixed(1)}s` : '—');
    if (s.dur_ms) dt.dataset.tip = `宽度 ${s.width} → ${s.dur_ms}ms\n其中 ${s.ramp_ms}ms 用来滑向新值，${s.dur_ms - s.ramp_ms}ms 保持`;
    tr.append(dt);
    body.append(tr);
  });
  tb.append(body); wrap.append(tb); tcard.append(wrap);
  pane.append(tcard);

  if (t.meta && t.meta.sent_user_message) {
    const m = el('div', 'card');
    m.append(el('h3', null, '这一轮实际发出去的 prompt'));
    if (t.meta.debate_frame) {
      m.append(el('div', 'axis-note', '辩论框架（任务约束，常驻 system message）'));
      m.append(el('pre', 'snippet', t.meta.debate_frame));
    }
    if (t.meta.persona_prompt) {
      m.append(el('div', 'axis-note', '人格注入（system prompt）'));
      m.append(el('pre', 'snippet', t.meta.persona_prompt));
    }
    m.append(el('div', 'axis-note', '最后一条 user message'));
    m.append(el('pre', 'snippet', t.meta.sent_user_message));
    m.append(el('div', 'note', t.meta.persona_prompt
      ? '当前有人格注入，这一版不是“无人格”的基线。'
      : '没有人格注入 —— 上面那段辩论框架是任务约束（辩题+立场），跟长度约束同类。' +
        '注意”没有 system prompt”也不等于”没有人格”：hedging、平衡感、礼貌的对抗性都是 post-training 装进去的，不在 prompt 里。'));
    pane.append(m);
  }
}

/* ── 面板：统计 ────────────────────────────────────────── */
function distRow(label, s, lo, hi, color) {
  const row = el('div', 'dist-row');
  row.append(el('span', 'dist-lab', label));
  const d = el('div', 'dist');
  d.style.setProperty('--c', color);
  const X = v => ((v - lo) / (hi - lo || 1)) * 100;
  if (s.n) {
    const w = el('div', 'whisk');
    w.style.left = X(s.min) + '%'; w.style.width = (X(s.max) - X(s.min)) + '%';
    const b = el('div', 'box');
    b.style.left = X(s.p10) + '%'; b.style.width = Math.max(X(s.p90) - X(s.p10), 0.8) + '%';
    const m = el('div', 'mean');
    m.style.left = `calc(${X(s.mean)}% - 1.5px)`;
    const z = el('div', 'zero'); z.style.left = X(0) + '%';
    d.append(z, w, b, m);
    d.dataset.tip = `${label}  n=${s.n}\n均值 ${fx(s.mean, 4)}   sd ${fx(s.sd, 4)}\np10–p90 ${fx(s.p10, 4)} … ${fx(s.p90, 4)}\n极值 ${fx(s.min, 4)} … ${fx(s.max, 4)}`;
  }
  row.append(d, el('span', 'dist-lab mono', s.n ? `${fx(s.mean, 3)} (n=${s.n})` : 'n=0'));
  return row;
}

function renderStatsPane() {
  const pane = $('#pane-stats');
  pane.innerHTML = '';
  const st = ST.state.stats, defs = ST.state.axes.defs;

  const lg = el('div', 'card');
  const lh = el('div', 'card-head');
  const legend = el('div', 'legend');
  const a = el('span'); a.innerHTML = '<i style="background:var(--human)"></i>人';
  const b = el('span'); b.innerHTML = '<i style="background:var(--ai)"></i>AI';
  legend.append(a, b);
  lh.append(el('h3', null, `原始分数分布 · 人 ${st.turns.human} 轮 / ${st.segments.human} 片段 · AI ${st.turns.ai} 轮 / ${st.segments.ai} 片段`), legend);
  lg.append(lh);

  defs.forEach(d => {
    const h = st.per_speaker.human[d.id], ai = st.per_speaker.ai[d.id], c = st.combined[d.id];
    const sep = st.separation[d.id];
    const blk = el('div', 'axis-block');

    const hd = el('div', 'card-head');
    const left = el('div');
    left.append(el('span', 'meter-name', d.name_zh));
    hd.append(left);
    if (sep.cohens_d != null) {
      const ad = Math.abs(sep.cohens_d);
      const p = el('span', 'pill ' + (ad >= 0.8 ? 'ok' : ad >= 0.4 ? 'warn' : 'bad'), `d = ${sep.cohens_d.toFixed(2)}`);
      p.dataset.tip = `Cohen's d（人 − AI）\n|d| ≥ 0.8 两边真的分开了\n0.4–0.8 有倾向但重叠很大\n< 0.4 这条轴分不开两个说话人\n均值差 ${fx(sep.delta, 4)}`;
      hd.append(p);
    }
    blk.append(hd);

    if (c.n) {
      const lo = Math.min(h.n ? h.min : c.min, ai.n ? ai.min : c.min, 0);
      const hi = Math.max(h.n ? h.max : c.max, ai.n ? ai.max : c.max, 0);
      const pad = (hi - lo) * 0.06 || 0.01;
      blk.append(distRow('人', h, lo - pad, hi + pad, 'var(--human)'));
      blk.append(distRow('AI', ai, lo - pad, hi + pad, 'var(--ai)'));
      const scale = el('div', 'dist-scale');
      const ends = el('div', 'meter-ends');
      ends.append(el('span', null, `← ${d.neg_label}  ${fx(lo - pad, 3)}`), el('span', null, `${fx(hi + pad, 3)}  ${d.pos_label} →`));
      scale.append(el('span'), ends, el('span'));
      blk.append(scale);
    } else {
      blk.append(el('div', 'axis-note', '还没有数据'));
    }
    lg.append(blk);
  });
  pane.append(lg);

  // 声部位置 —— 作品的头号参数
  const dr = st.drift;
  if (dr) {
    const xf = dr.xfade || { human: dr.human, ai: dr.ai };
    const c = el('div', 'card');
    const h = el('div', 'card-head');
    h.append(el('h3', null, '音色位置 · 合成器 ↔ 人声'),
      el('span', 'pill' + (dr.turns >= 4 ? ' ok' : ''), `${dr.turns} 轮 · 置信 ${fx(dr.confidence, 2)}`));
    c.append(h);

    // 每个说话人 = 两台引擎的等功率混合，这条线上的位置就是混合比。
    // 人从合成器端出发、AI 从人声端出发，相向而行 —— 交叉就发生在这条线上
    const lane = el('div', 'dist');
    lane.style.height = '26px';
    [['human', xf.human], ['ai', xf.ai]].forEach(([spk, v]) => {
      const m = el('div', 'mean');
      m.style.setProperty('--c', spk === 'human' ? 'var(--human)' : 'var(--ai)');
      m.style.left = `calc(${v * 100}% - 1.5px)`;
      m.style.width = '4px';
      m.dataset.tip = `${spk === 'human' ? '人' : 'AI'}  xfade ${fx(v, 3)}\n0 = 全合成器引擎\n1 = 全人声采样引擎`;
      lane.append(m);
    });
    const z = el('div', 'zero'); z.style.left = '50%'; lane.append(z);
    c.append(lane);
    const ends = el('div', 'meter-ends');
    ends.append(el('span', null, '← 合成器音色'),
      el('span', null, `人 ${fx(xf.human, 2)} · AI ${fx(xf.ai, 2)}`),
      el('span', null, '人声音色 →'));
    c.append(ends);

    // 效果里有多少是观察、多少是断言 —— 这个比例要一直看得见
    const tot = Math.abs(dr.soft) + Math.abs(dr.hard) || 1;
    const bar = el('div', 'dist');
    bar.style.height = '10px';
    const s1 = el('div', 'box');
    s1.style.cssText = `left:0;width:${(Math.abs(dr.soft) / tot) * 100}%;opacity:.9;background:var(--human)`;
    s1.dataset.tip = `观察 ${fx(dr.soft, 3)}\n离散度之比 ${fx(dr.dispersion.ratio, 2)}（人 ${fx(dr.dispersion.human, 3)} / AI ${fx(dr.dispersion.ai, 3)}）\nembodiment 均值 人 ${fx(dr.embodiment_mean.human, 3)} / AI ${fx(dr.embodiment_mean.ai, 3)}`;
    const s2 = el('div', 'box');
    s2.style.cssText = `left:${(Math.abs(dr.soft) / tot) * 100}%;width:${(Math.abs(dr.hard) / tot) * 100}%;opacity:.9;background:var(--warn)`;
    s2.dataset.tip = `断言 ${fx(dr.hard, 3)}\n纯轮数斜坡，跟谁说了什么无关。\nDRIFT_HARD_WEIGHT 调它。`;
    bar.append(s1, s2);
    c.append(el('div', 'axis-note', '效果的来源'), bar);
    const lg = el('div', 'meter-ends');
    lg.append(el('span', null, `观察 ${Math.round(Math.abs(dr.soft) / tot * 100)}%`),
      el('span', null, `断言 ${Math.round(Math.abs(dr.hard) / tot * 100)}%`));
    c.append(lg);
    note(c, '离散度就是活体感 —— <b>人的读数铺得开、AI 挤在中间</b>，这个差异比均值差大得多。' +
      'LLM 的低方差是 post-training 的产物，不是采样不够。<br>' +
      '轮数只放大证据（置信度），不决定方向；黄色那段才是纯断言。');
    pane.append(c);
  }

  // 校准
  const cal = ST.state.stats.calibration;
  const cc = el('div', 'card');
  const ch = el('div', 'card-head');
  ch.append(el('h3', null, '校准'), el('span', 'pill', cal.mode));
  cc.append(ch);

  const tb = el('table', 'data');
  const hr = el('tr');
  hr.append(el('th', null, '轴'), el('th', null, '在用 mu'), el('th', null, '在用 sigma'), el('th', null, '实测 sigma'), el('th', null, '比值'));
  add(add(tb, el('thead')), hr);
  const bd = el('tbody');
  defs.forEach(d => {
    const inuse = cal.in_use[d.id], sug = cal.suggestion[d.id];
    const ratio = sug ? sug.sigma / inuse.sigma : null;
    const tr = el('tr');
    tr.append(el('td', 't', d.name_zh), el('td', null, fx(inuse.mu, 4)), el('td', null, fx(inuse.sigma, 4)),
      el('td', null, sug ? fx(sug.sigma, 4) : '—'));
    const rc = el('td');
    if (ratio) {
      const off = ratio > 2 || ratio < 0.5;
      rc.append(el('span', 'pill ' + (off ? 'warn' : 'ok'), ratio.toFixed(2) + '×'));
      rc.dataset.tip = off
        ? '在用的 sigma 和实测差了一倍以上：参数要么撞满量程，要么全挤在中间。\n跑 scripts/fit_calibration.py 之后把 CALIB_MODE 改成 fitted。'
        : '在用的 sigma 和实测量级一致。';
    } else rc.textContent = '—';
    tr.append(rc);
    bd.append(tr);
  });
  tb.append(bd);
  const sw = el('div', 'scroll-x'); sw.append(tb); cc.append(sw);
  note(cc,
    '<b>人和 AI 共用同一套 mu/sigma。</b>分开归一化会把两边强行拉到同一个分布中心，' +
    '“AI 更去身、人更具身”这个对比会被数学抹平 —— 那正好是作品的论点。' +
    `<br>来源：${cal.source}`);
  pane.append(cc);
}

/* ── 面板：轴诊断 ──────────────────────────────────────── */
function divergeColor(v) {
  const t = Math.min(1, Math.abs(v));
  return `color-mix(in oklab, ${v >= 0 ? 'var(--pos)' : 'var(--neg)'} ${Math.round(t * 82)}%, var(--neutral))`;
}

function renderDiagPane() {
  const pane = $('#pane-diag');
  pane.innerHTML = '';
  const dg = ST.state.axes.diagnostics, defs = ST.state.axes.defs;
  if (!dg || !dg.per_axis) { pane.append(el('div', 'empty', '没有诊断数据，跑一次 scripts/build_axes.py')); return; }

  const c1 = el('div', 'card');
  c1.append(el('h3', null, '两极分离度 d′（留一法）'));
  const t1 = el('table', 'data');
  const h1 = el('tr');
  h1.append(el('th', null, '轴'), el('th', null, '锚句'), el('th', null, 'd′'), el('th', null, '正极均值'), el('th', null, '负极均值'), el('th', null, ''));
  add(add(t1, el('thead')), h1);
  const b1 = el('tbody');
  defs.forEach(d => {
    const s = dg.per_axis[d.id];
    const tr = el('tr');
    const q = s.d_prime >= 2 ? ['ok', '好用'] : s.d_prime >= 1 ? ['warn', '勉强'] : ['bad', '基本是噪声'];
    tr.append(el('td', 't', d.name_zh), el('td', null, String(s.n_anchors)), el('td', null, s.d_prime.toFixed(2)),
      el('td', null, fx(s.pos_mean, 4)), el('td', null, fx(s.neg_mean, 4)));
    const qc = el('td'); qc.append(el('span', 'pill ' + q[0], q[1])); tr.append(qc);
    b1.append(tr);
  });
  t1.append(b1);
  const w1 = el('div', 'scroll-x'); w1.append(t1); c1.append(w1);
  note(c1,
    'd′ 用留一法算：把每条锚句从轴的构造里剔掉再投影，所以没有自我印证。' +
    '<b>&gt;2.0 好用；1.0–2.0 勉强；&lt;1.0 回去改锚句</b>（改 <code>anchors/axes.yaml</code> 后跑 <code>python scripts/build_axes.py</code>）。');
  pane.append(c1);

  const c2 = el('div', 'card');
  const ids = dg.axis_ids, mat = dg.axis_cosine;
  let worst = 0;
  ids.forEach((i, a) => ids.forEach((j, b) => { if (a !== b) worst = Math.max(worst, Math.abs(mat[a][b])); }));
  const h2 = el('div', 'card-head');
  h2.append(el('h3', null, '轴间余弦'), el('span', 'pill ' + (worst > 0.5 ? 'warn' : 'ok'), `最大非对角 ${worst.toFixed(2)}`));
  c2.append(h2);

  const t2 = el('table', 'data');
  const hr2 = el('tr'); hr2.append(el('th', null, ''));
  defs.forEach(d => hr2.append(el('th', null, d.name_zh.split(' ')[0])));
  add(add(t2, el('thead')), hr2);
  const b2 = el('tbody');
  ids.forEach((id, a) => {
    const tr = el('tr');
    tr.append(el('td', 't', defs[a].name_zh));
    ids.forEach((jd, b) => {
      const v = mat[a][b];
      const td = el('td', null, v.toFixed(2));
      if (a !== b) { td.style.background = divergeColor(v); td.style.color = 'var(--text-1)'; }
      td.dataset.tip = `${defs[a].name_zh} × ${defs[b].name_zh}\ncos = ${v.toFixed(3)}`;
      tr.append(td);
    });
    b2.append(tr);
  });
  t2.append(b2);
  const w2 = el('div', 'scroll-x'); w2.append(t2); c2.append(w2);
  note(c2,
    '蓝 = 正相关，红 = 负相关，灰 = 无关。<b>|cos| &gt; 0.5 的两条轴在听感上会一起动</b>，' +
    '等于四个旋钮只剩一个。解决办法：把两极锚句拉开，或者 <code>AXES_ORTHOGONALIZE=1</code>（后面的轴变成前面轴的残差）。');
  pane.append(c2);
}

/* ── 面板：配置 ────────────────────────────────────────── */
function renderConfPane() {
  const pane = $('#pane-conf');
  pane.innerHTML = '';
  const c = ST.state.config;
  const card = el('div', 'card');
  card.append(el('h3', null, '本次运行'));
  const dl = el('dl', 'kv');
  const rows = [
    ['对话模型', c.chat_model],
    ['embedding', `${c.embed_model} · ${c.embed_dims || '原生'} 维`],
    ['切片方式', c.segment_mode === 'clause' ? 'clause（按标点切子句）' : `fixed（定长 ${c.seg_target_width} 宽）`],
    ['校准模式', c.calib_mode],
    ['轴正交化', c.orthogonalize ? '开' : '关'],
    ['轴指纹', ST.state.axes.fingerprint],
    ['embedding 缓存', c.cache ? `${c.cache.entries} 条 · 本次 API 调用 ${c.cache.api_calls} 次` : '—'],
    ['日志', c.log_path],
  ];
  rows.forEach(([k, v]) => { dl.append(el('dt', null, k), el('dd', null, String(v))); });
  card.append(dl);
  pane.append(card);

  const p = el('div', 'card');
  p.append(el('h3', null, 'prompt · 两个槽是分开的'));
  const dl2 = el('dl', 'kv');
  dl2.append(el('dt', null, '辩论框架（任务约束）'), el('dd', null, c.debate_frame || '（无 —— 没设辩题）'));
  dl2.append(el('dt', null, '长度约束'), el('dd', null, c.length_hint || '（无）'));
  dl2.append(el('dt', null, '人格注入'), el('dd', null, c.system_prompt || '（无）'));
  dl2.append(el('dt', null, '分边方式'), el('dd', null, c.side_assign === 'random' ? 'random（抽签）' : c.side_assign));
  p.append(dl2);
  note(p,
    '<b>给立场是任务约束，不是人格注入。</b>“辩题 X，你是反方”跟长度约束同类；' +
    '“你是温暖的、有自己看法的”才是人格。两者物理上都进 system message，但分开存、分开记日志，随时可审计。' +
    '<br><br>要如实记住的一个混淆：<b>指定立场会把 AI 的 affiliation 往对抗端推、certainty 往断言端推</b>，' +
    '所以这两条轴的 Cohen\'s d 有一部分是指令造成的，不能当语域证据。作品的主证据轴仍然是 <b>embodiment</b>。');
  pane.append(p);

  pane.append(oscCard());

  const l = el('div', 'card');
  l.append(el('h3', null, '排练即语料'));
  note(l,
    '每个片段的原始分数都写进了上面那个 JSONL。跑几场之后执行 ' +
    '<code>python scripts/fit_calibration.py</code>，把 <code>CALIB_MODE</code> 改成 <code>fitted</code> 再重启，' +
    '参数就会真正铺满可听范围 —— 这一步是“能听出区别”和“听不出区别”的分界。');
  pane.append(l);
}

/* ── OSC → Max/MSP ─────────────────────────────────────── */
function oscCard() {
  const o = ST.state.osc || { enabled: false };
  const card = el('div', 'card');
  const head = el('div', 'card-head');
  head.append(el('h3', null, 'OSC → Max/MSP'));
  head.append(el('span', 'pill ' + (o.enabled ? (o.errors ? 'bad' : 'ok') : 'warn'),
    o.enabled ? o.target : 'OSC_ENABLED=0'));
  card.append(head);

  if (o.enabled) {
    const dl = el('dl', 'kv');
    dl.append(el('dt', null, '已发消息'), el('dd', null, `${o.sent}${o.errors ? ` · ${o.errors} 个错误` : ''}`));
    const q = el('dd', null,
      `${o.playing ? (o.playing === 'human' ? '人' : 'AI') : '空闲'}` +
      `${o.queued ? ` · 排队 ${o.queued}` : ''}${o.dropped ? ` · 已丢弃 ${o.dropped}` : ''}`);
    if (o.dropped) q.dataset.tip = '队列超过上限，最旧的回合被丢掉了。\n声音已经远远落后于辩论进度 —— 调小 OSC_TIME_SCALE，或者放慢发言节奏。';
    dl.append(el('dt', null, `正在播（${o.on_overlap === 'queue' ? '排队' : '抢占'}）`), q);
    dl.append(el('dt', null, '片段时长'), el('dd', null,
      `宽度 × ${o.schedule.ms_per_width}ms × ${o.schedule.time_scale}，夹在 ${o.schedule.min_seg_ms}~${o.schedule.max_seg_ms}ms`));
    dl.append(el('dt', null, '滑行占比'), el('dd', null, `${Math.round(o.schedule.ramp_fraction * 100)}%（其余保持）`));
    dl.append(el('dt', null, '轴顺序'), el('dd', null, o.axis_order.join('  ')));
    if (o.last) {
      dl.append(el('dt', null, '最后一条'), el('dd', null,
        o.last.error ? `${o.last.address} ⚠ ${o.last.error}` : `${o.last.address}  ${(o.last.args || []).join(' ')}`));
    }
    card.append(dl);

    const btn = el('button', 'btn ghost', '测试扫描（四条轴依次 0→1→0，约 10 秒）');
    btn.style.marginTop = '10px';
    btn.onclick = async () => {
      btn.disabled = true;
      try { await api('/api/osc/test', {}); toast('已开始扫描 —— 看 Max 里四个数是不是一个一个亮起来'); }
      catch (e) { toast('测试失败：' + e.message); }
      finally { setTimeout(() => { btn.disabled = false; }, 10500); }
    };
    card.append(btn);
  }

  note(card,
    '发的是 <b>unit（0~1，已校准）</b>，不是 raw —— 校准层存在的意义就是产出这个值，' +
    '在 Max 里再缩放一次等于有两个地方管校准。<br>' +
    'Python 排时间表（片段时长来自片段宽度），Max 只管声音：收到「目标值 + 滑行多久」，用 <code>[line]</code> 插值。' +
    '<br><br><code>/debate/{human,ai}/seg</code> &nbsp; index &nbsp; ' + (o.axis_order || []).join(' ') + ' &nbsp; ramp_ms &nbsp; hold_ms' +
    '<br>时间参数排在轴值右边，是因为 Max 的 <code>[unpack]</code> 从右往左出 —— 这样 ramp_ms 会先到 <code>[line]</code> 的右入口。');
  return card;
}

/* ── 打字层：实时按键流 ────────────────────────────────────
   这不是给统计用的，是第三个声部的素材。停顿、犹豫、退格重写 —— AI 没有这个东西，
   它的输出瞬间成块到达。所以这条通道只有人这一侧有，而且必须实时：
   回合结束后才送上来的汇总做不出"正在犹豫"的声音。                        */
const typing = { start: 0, last: 0, keys: 0, backspaces: 0, pauses: 0, maxPause: 0, backRun: 0 };

const wire = {
  ws: null, ready: false, pauseTimer: null,
  open() {
    try {
      const w = new WebSocket(`ws://${location.host}/ws/typing`);
      w.onopen = () => { wire.ready = true; };
      w.onclose = () => { wire.ready = false; wire.ws = null; setTimeout(wire.open, 2000); };
      w.onerror = () => { };
      wire.ws = w;
    } catch { /* 打字层断了不该影响辩论本身 */ }
  },
  send(o) { if (wire.ready) { try { wire.ws.send(JSON.stringify(o)); } catch { } } },
};
wire.open();

// 停顿要在"卡住的当下"持续播报，不能等这一轮结束才知道停过
function armPause() {
  clearInterval(wire.pauseTimer);
  wire.pauseTimer = setInterval(() => {
    if (!typing.start) return;
    const gap = performance.now() - typing.last;
    if (gap > 1200) wire.send({ t: 'pause', ms: Math.round(gap) });
  }, 250);
}
function resetTyping() {
  clearInterval(wire.pauseTimer);
  if (typing.start) wire.send({ t: 'end' });
  Object.assign(typing, { start: 0, last: 0, keys: 0, backspaces: 0, pauses: 0, maxPause: 0, backRun: 0 });
  paintTyping();
}
function paintTyping() {
  const n = $('#typing');
  if (!typing.start) { n.textContent = ''; return; }
  const secs = ((performance.now() - typing.start) / 1000).toFixed(1);
  const bits = [`输入 ${secs}s`];
  if (typing.backspaces) bits.push(`退格 ${typing.backspaces}`);
  if (typing.pauses) bits.push(`停顿 ${typing.pauses} 次 / 最长 ${(typing.maxPause / 1000).toFixed(1)}s`);
  n.textContent = bits.join(' · ');
}
function typingMeta() {
  if (!typing.start) return {};
  return {
    typing_ms: Math.round(performance.now() - typing.start),
    keystrokes: typing.keys, backspaces: typing.backspaces,
    pauses_over_2s: typing.pauses, max_pause_ms: Math.round(typing.maxPause),
  };
}
setInterval(() => { if (typing.start) paintTyping(); }, 250);

/* ── 动作 ──────────────────────────────────────────────── */
function setBusy(b) {
  ST.busy = b;
  $('#send').disabled = b; $('#aiturn').disabled = b; $('#reset').disabled = b;
}

function applyTurn(res) {
  ST.state.turns.push(res.turn);
  ST.state.stats = res.stats;
  if (res.osc) ST.state.osc = res.osc;
  ST.sel = res.turn.id;
  renderAll(false);
}

async function aiTurn() {
  pending(true);
  try {
    applyTurn(await api('/api/turn/ai', {}));
  } catch (e) {
    toast('AI 回合失败：' + e.message);
  } finally {
    pending(false);
  }
}

async function send() {
  const box = $('#input');
  const text = box.value.trim();
  if (!text || ST.busy) return;
  setBusy(true);
  try {
    applyTurn(await api('/api/turn/human', { text, meta: typingMeta() }));
    box.value = ''; resetTyping();
    if ($('#auto').checked) await aiTurn();
  } catch (e) {
    toast('提交失败：' + e.message);
  } finally {
    setBusy(false);
    box.focus();
  }
}

/* ── 渲染 ──────────────────────────────────────────────── */
function renderAll(full = true) {
  if (full) {
    $('#mockbadge').hidden = !ST.state.config.mock;
    $('#motion').value = ST.state.motion || '';
  }
  renderStance();
  renderTranscript();
  renderTurnPane();
  renderStatsPane();
  if (full) renderDiagPane();
  renderConfPane();
}

async function boot() {
  try {
    ST.state = await api('/api/state');
  } catch (e) {
    toast('无法连接后端：' + e.message);
    return;
  }
  renderAll(true);

  $('#send').onclick = send;
  $('#aiturn').onclick = async () => { if (ST.busy) return; setBusy(true); await aiTurn(); setBusy(false); };
  $('#reset').onclick = async () => {
    if (ST.state.turns.length && !confirm('开新一场？当前统计会清空（日志已经落盘，不会丢）。')) return;
    setBusy(true);
    try {
      await api('/api/session/reset', { motion: $('#motion').value.trim(), ai_side: $('#sidepick').value });
      ST.state = await api('/api/state'); ST.sel = null; renderAll(true);
    } catch (e) { toast('重置失败：' + e.message); } finally { setBusy(false); }
  };

  const inp = $('#input');
  inp.addEventListener('keydown', e => {
    const now = performance.now();
    if (!typing.start) { typing.start = now; typing.last = now; wire.send({ t: 'start' }); armPause(); }
    const gap = now - typing.last;
    if (gap > 2000) { typing.pauses++; typing.maxPause = Math.max(typing.maxPause, gap); }
    typing.last = now; typing.keys++;

    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); return; }

    const elapsed = Math.round(now - typing.start);
    if (e.key === 'Backspace' || e.key === 'Delete') {
      typing.backspaces++;
      typing.backRun++;   // 连按退格 = 整句推翻重写，声音上该越擦越狠
      wire.send({ t: 'back', depth: typing.backRun, elapsed });
    } else {
      typing.backRun = 0;
      wire.send({ t: 'key', dt: Math.round(Math.min(gap, 4000)), elapsed });
    }
  });

  $$('#tabs .tab').forEach(t => {
    t.onclick = () => {
      $$('#tabs .tab').forEach(x => x.classList.toggle('active', x === t));
      $$('.tabpane').forEach(p => p.classList.toggle('active', p.id === 'pane-' + t.dataset.tab));
    };
  });

  inp.focus();
}

boot();
