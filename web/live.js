'use strict';

/* Performance view — the design canvas (Live.dc.html) wired to the real backend.
   The canvas faked xfade with a slider and canned replies; here every position
   comes from the server's drift computation and every bubble is a real turn.

   One rule inherited from the whole piece: no numbers reach the audience.
   The crossing is the picture — each speaker keeps ONE orb that travels the
   synthetic↔voiced rail as xfade drifts, so the two swap places and briefly
   overlap mid-debate. Nothing on screen explains it. */

const $ = (s, r = document) => r.querySelector(s);
const el = (t, c, x) => { const n = document.createElement(t); if (c) n.className = c; if (x != null) n.textContent = x; return n; };

const PAD = 7, SPAN = 100 - PAD * 2;   // keep the orbs off the rail's faded ends
const ST = { xfade: { human: 0.1, ai: 0.9 }, trail: [], busy: false };

async function api(path, body) {
  const opt = body === undefined ? {} : { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
  const r = await fetch(path, opt);
  if (!r.ok) {
    let m = r.statusText;
    try { m = (await r.json()).detail || m; } catch { }
    throw new Error(m);
  }
  return r.json();
}

let toastTimer;
function toast(msg) {
  $('.toast')?.remove();
  const t = el('div', 'toast', msg);
  document.body.append(t);
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.remove(), 6000);
}

/* ── orbs ────────────────────────────────────────────────
   Fibonacci sphere. organic = that speaker's xfade:
   0 → lattice, rotation snaps in ticks, particles hold rank;
   1 → each particle breathes on its own phase, rotation flows. */
const PTS = [];
{
  const N = 150, ga = Math.PI * (3 - Math.sqrt(5));
  for (let i = 0; i < N; i++) {
    const y = 1 - (i / (N - 1)) * 2, r = Math.sqrt(1 - y * y), th = ga * i;
    PTS.push({ x: Math.cos(th) * r, y, z: Math.sin(th) * r, ph: Math.random() * Math.PI * 2, fr: 0.6 + Math.random() * 1.1 });
  }
}

function makeOrb(canvas, color) {
  const size = 104, dpr = Math.min(devicePixelRatio || 1, 2);
  canvas.width = size * dpr; canvas.height = size * dpr;
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  return {
    color, organic: 0, until: 0, angle: Math.random() * Math.PI * 2, _last: 0, _static: false,
    speak(ms) { this.until = Math.max(this.until, performance.now() + ms); this._static = false; },
    draw(now) {
      const spk = now < this.until, t = now / 1000, o = this.organic;
      if (spk) {
        const dt = this._last ? Math.min((now - this._last) / 1000, 0.1) : 0.016;
        this.angle += dt * (0.5 + 0.4 * o);
      }
      this._last = now;
      const tick = Math.round(this.angle / 0.42) * 0.42;
      const a = tick * (1 - o) + this.angle * o, cs = Math.cos(a), sn = Math.sin(a);
      const R = 38 * (spk ? 1 + 0.05 * Math.sin(t * 2 * Math.PI * 1.3) * (0.4 + 0.6 * o) : 1);
      ctx.clearRect(0, 0, size, size);
      const cx = size / 2, cy = size / 2;
      for (const p of PTS) {
        const x3 = p.x * cs + p.z * sn, z3 = -p.x * sn + p.z * cs;
        const br = spk ? 1 + o * 0.16 * Math.sin(t * p.fr * 2 * Math.PI + p.ph) : 1;
        const persp = 1 / (1 + z3 * 0.28);
        const px = cx + x3 * R * br * persp, py = cy + p.y * R * br * persp;
        const depth = (1 - z3) / 2;
        ctx.globalAlpha = 0.12 + depth * (spk ? 0.68 : 0.38);
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(px, py, (0.6 + depth * 1.1) * (spk ? 1.1 : 1), 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
    },
  };
}

const ORB = {};

function placeOrbs() {
  for (const [spk, node] of [['human', $('#t-human')], ['ai', $('#t-ai')]]) {
    node.style.left = (PAD + ST.xfade[spk] * SPAN).toFixed(2) + '%';
    if (ORB[spk]) { ORB[spk].organic = ST.xfade[spk]; ORB[spk]._static = false; }
  }
}

/* where each orb has been — the drift leaves a wake */
function markTrail() {
  ST.trail.push({ left: PAD + ST.xfade.human * SPAN, color: 'var(--human)' });
  ST.trail.push({ left: PAD + ST.xfade.ai * SPAN, color: 'var(--ai)' });
  ST.trail = ST.trail.slice(-28);
  const box = $('#trail');
  box.innerHTML = '';
  ST.trail.forEach((m, i) => {
    const d = el('i');
    d.style.left = m.left.toFixed(2) + '%';
    d.style.background = m.color;
    d.style.opacity = Math.max(0.12, 0.5 - (ST.trail.length - i) * 0.03);
    box.append(d);
  });
}

/* ── keystroke ticks: the typing layer, made visible ────── */
const ticks = [];
function drawTicks(now) {
  const cv = $('#ticks');
  const dpr = Math.min(devicePixelRatio || 1, 2), w = cv.clientWidth, h = 22;
  if (cv.width !== Math.round(w * dpr)) { cv.width = Math.round(w * dpr); cv.height = h * dpr; cv.getContext('2d').scale(dpr, dpr); }
  const ctx = cv.getContext('2d');
  ctx.clearRect(0, 0, w, h);
  for (let i = 0; i < ticks.length; i++) {
    const k = ticks[i], age = (now - k.t) / 4200;
    if (age > 1) continue;
    const x = 1 + i * 4.2;
    if (x > w) break;
    ctx.globalAlpha = (1 - age) * 0.75;
    // backspace reads in the machine's colour — taking words back is the
    // one thing the machine never does
    ctx.fillStyle = k.back ? '#ffb27a' : '#7fb3ff';
    ctx.fillRect(x, h - k.height, 2, k.height);
  }
  ctx.globalAlpha = 1;
}

function loop(now) {
  for (const spk of ['human', 'ai']) {
    const o = ORB[spk];
    if (!o) continue;
    if (now < o.until) { o.draw(now); o._static = false; }
    else if (!o._static) { o._last = 0; o.draw(now); o._static = true; }
  }
  drawTicks(now);
  requestAnimationFrame(loop);
}

/* ── stream ─────────────────────────────────────────────── */
function bubble(speaker, text) {
  const m = el('div', `msg ${speaker}`);
  m.append(el('div', 'who', speaker === 'human' ? 'human' : 'machine'));
  m.append(el('div', 'bubble', text));
  $('#stream').append(m);
  scrollDown();
  return m;
}

function pendingBubble(speaker) {
  const m = el('div', `msg ${speaker} pending`);
  m.append(el('div', 'who', speaker === 'human' ? 'human' : 'machine'));
  const b = el('div', 'bubble dots');
  m.append(b);
  $('#stream').append(m);
  scrollDown();
  return m;
}

const scrollDown = () => { const s = $('#stream'); s.scrollTop = s.scrollHeight; };

/* speaking time = exactly the OSC schedule, so the orb stops when the sound does */
const speakMs = turn =>
  Math.min((turn.segments || []).reduce((s, x) => s + (x.dur_ms || 0), 0) || 4000, 90000);

function applyTurn(res, speaker) {
  ST.xfade = res.stats?.drift?.xfade || ST.xfade;
  bubble(speaker, res.turn.text);
  ORB[speaker].speak(speakMs(res.turn));
  placeOrbs();
  markTrail();
}

/* ── typing wire (third voice) ──────────────────────────── */
const typing = { start: 0, last: 0, backRun: 0 };
const wire = {
  ws: null, ready: false,
  open() {
    try {
      const w = new WebSocket(`ws://${location.host}/ws/typing`);
      w.onopen = () => { wire.ready = true; };
      w.onclose = () => { wire.ready = false; wire.ws = null; setTimeout(wire.open, 2000); };
      wire.ws = w;
    } catch { }
  },
  send(o) { if (wire.ready) { try { wire.ws.send(JSON.stringify(o)); } catch { } } },
};
wire.open();
setInterval(() => {
  if (!typing.start) return;
  const gap = performance.now() - typing.last;
  if (gap > 1200) wire.send({ t: 'pause', ms: Math.round(gap) });
}, 250);

/* ── flow ───────────────────────────────────────────────── */
async function send() {
  const box = $('#input');
  const text = box.value.trim();
  if (!text || ST.busy) return;
  ST.busy = true;
  $('#stream .empty')?.remove();

  const meta = typing.start ? { typing_ms: Math.round(performance.now() - typing.start) } : {};
  if (typing.start) wire.send({ t: 'end' });
  typing.start = 0; typing.backRun = 0;
  ticks.length = 0;
  box.value = ''; box.style.height = 'auto';

  try {
    applyTurn(await api('/api/turn/human', { text, meta }), 'human');
    const wait = pendingBubble('ai');
    try {
      applyTurn(await api('/api/turn/ai', {}), 'ai');
    } catch (e) {
      toast(e.message);
    } finally {
      wait.remove();
      scrollDown();
    }
  } catch (e) {
    toast(e.message);
  } finally {
    ST.busy = false;
    box.focus();
  }
}

async function boot() {
  let s;
  try { s = await api('/api/state'); }
  catch (e) { toast('backend unreachable: ' + e.message); return; }

  ORB.human = makeOrb($('#orb-human'), '#7fb3ff');
  ORB.ai = makeOrb($('#orb-ai'), '#ffb27a');

  $('#motion').textContent = s.motion || '';
  const side = x => (x === 'pro' ? 'for' : 'against');
  $('#sides').innerHTML = s.motion
    ? `<span class="h">Human <b>${side(s.human_side)}</b></span><span class="a">Machine <b>${side(s.ai_side)}</b></span>`
    : '';
  const LOT = { drawn: 'sides drawn by lot', chosen: 'sides chosen', config: 'sides fixed' };
  $('#lot-text').textContent = s.motion ? (LOT[s.side_source] || '') : '';
  $('#lot').style.visibility = s.motion ? 'visible' : 'hidden';

  ST.xfade = s.stats?.drift?.xfade || ST.xfade;
  placeOrbs();

  if (s.turns.length) {
    s.turns.forEach(t => bubble(t.speaker, t.text));
    markTrail();
  } else {
    $('#stream').append(el('div', 'empty', 'type your opening statement'));
  }

  requestAnimationFrame(loop);

  const box = $('#input');
  box.addEventListener('input', () => {
    box.style.height = 'auto';
    box.style.height = Math.min(box.scrollHeight, 150) + 'px';
  });
  box.addEventListener('keydown', e => {
    const now = performance.now();
    if ((e.key === 'Enter' || e.key === 'Return') && !e.shiftKey) { e.preventDefault(); send(); return; }

    if (!typing.start) { typing.start = now; typing.last = now; wire.send({ t: 'start' }); }
    const gap = now - typing.last;
    typing.last = now;
    const elapsed = Math.round(now - typing.start);
    const back = e.key === 'Backspace' || e.key === 'Delete';

    // the human orb stirs while its person is still composing
    ORB.human.speak(900);
    ticks.push({ t: now, back, height: back ? 6 : Math.max(3, Math.min(20, 22 - Math.min(gap, 1600) / 90)) });
    if (ticks.length > 260) ticks.splice(0, ticks.length - 260);

    if (back) { typing.backRun++; wire.send({ t: 'back', depth: typing.backRun, elapsed }); }
    else { typing.backRun = 0; wire.send({ t: 'key', dt: Math.round(Math.min(gap, 4000)), elapsed }); }
  });
  box.focus();
}

boot();
