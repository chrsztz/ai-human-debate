'use strict';

/* Performance view.
   One rule inherited from the whole piece: the screen shows no numbers.
   The only data that reaches the audience is carried by behavior —
   the orb of the current speaker moves while their sound plays, and the
   *character* of that movement follows xfade: the human's orb starts out
   ticking like a mechanism and loosens into something organic; the machine's
   starts fluid and stiffens. Nobody is told this. It just happens. */

const $ = (s, r = document) => r.querySelector(s);

const ST = { motion: '', humanSide: 'pro', aiSide: 'con', xfade: { human: 0.1, ai: 0.9 }, busy: false };

async function api(path, body) {
  const opt = body === undefined ? {} : { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
  const r = await fetch(path, opt);
  if (!r.ok) {
    let msg = r.statusText;
    try { msg = (await r.json()).detail || msg; } catch { }
    throw new Error(msg);
  }
  return r.json();
}

let toastTimer;
function toast(msg) {
  document.querySelector('.toast')?.remove();
  const t = document.createElement('div');
  t.className = 'toast'; t.textContent = msg;
  document.body.append(t);
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.remove(), 6000);
}

/* ── the orb ─────────────────────────────────────────────
   A fibonacci sphere of particles, drawn on a small canvas.
   organic = 0 → lattice: rotation snaps in ticks, particles hold rank.
   organic = 1 → each particle breathes on its own phase, rotation flows.
   speaking → slow spin + pulse; idle → one static frame, no rAF cost.   */

const N = 120;
const PTS = [];
{
  const ga = Math.PI * (3 - Math.sqrt(5));
  for (let i = 0; i < N; i++) {
    const y = 1 - (i / (N - 1)) * 2;
    const r = Math.sqrt(1 - y * y);
    const th = ga * i;
    PTS.push({
      x: Math.cos(th) * r, y, z: Math.sin(th) * r,
      ph: Math.random() * Math.PI * 2,          // per-particle breathing phase
      fr: 0.6 + Math.random() * 1.1,            // breathing rate
    });
  }
}

const orbs = new Set();

function makeOrb(canvas, color, organic) {
  const dpr = Math.min(devicePixelRatio || 1, 2);
  const size = 52;
  canvas.width = size * dpr; canvas.height = size * dpr;
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);

  const orb = {
    color, organic,
    until: 0,                    // speaking while performance.now() < until
    angle: Math.random() * Math.PI * 2,
    _last: 0, _staticDrawn: false,

    speak(ms) { this.until = Math.max(this.until, performance.now() + ms); this._staticDrawn = false; },
    hush() { this.until = 0; },

    draw(now) {
      const speaking = now < this.until;
      const t = now / 1000;
      const o = this.organic;

      if (speaking) {
        const dt = this._last ? Math.min((now - this._last) / 1000, 0.1) : 0.016;
        this.angle += dt * (0.5 + 0.4 * o);
      }
      this._last = now;

      // mechanism: rotation quantised into ticks; organism: continuous
      const tick = Math.round(this.angle / 0.42) * 0.42;
      const a = tick * (1 - o) + this.angle * o;
      const cs = Math.cos(a), sn = Math.sin(a);

      const R = 19 * (speaking ? 1 + 0.05 * Math.sin(t * 2 * Math.PI * 1.3) * (0.4 + 0.6 * o) : 1);
      ctx.clearRect(0, 0, size, size);
      const cx = size / 2, cy = size / 2;

      for (const p of PTS) {
        const x3 = p.x * cs + p.z * sn;
        const z3 = -p.x * sn + p.z * cs;
        // organic breathing: each particle drifts on its own phase; the lattice holds still
        const br = speaking ? 1 + o * 0.16 * Math.sin(t * p.fr * 2 * Math.PI + p.ph) : 1;
        const persp = 1 / (1 + z3 * 0.28);
        const px = cx + x3 * R * br * persp;
        const py = cy + p.y * R * br * persp;
        const depth = (1 - z3) / 2;                       // 0 back … 1 front
        const rad = (0.5 + depth * 0.9) * (speaking ? 1.1 : 1);
        ctx.globalAlpha = 0.14 + depth * (speaking ? 0.7 : 0.42);
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(px, py, rad, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
      return speaking;
    },
  };
  orbs.add(orb);
  orb.draw(performance.now());
  orb._staticDrawn = true;
  return orb;
}

function loop(now) {
  for (const orb of orbs) {
    if (now < orb.until) { orb.draw(now); orb._staticDrawn = false; }
    else if (!orb._staticDrawn) { orb._last = 0; orb.draw(now); orb._staticDrawn = true; }
  }
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);

/* ── stream ──────────────────────────────────────────────── */
function bubble(speaker, text) {
  const wrap = document.createElement('div');
  wrap.className = `msg ${speaker}`;
  const ow = document.createElement('div'); ow.className = 'orb-wrap';
  const cv = document.createElement('canvas'); cv.className = 'orb';
  const who = document.createElement('div'); who.className = 'who';
  who.textContent = speaker === 'human' ? 'human' : 'machine';
  ow.append(cv, who);
  const b = document.createElement('div'); b.className = 'bubble';
  b.textContent = text;
  wrap.append(ow, b);
  $('#stream').append(wrap);
  $('#stream').scrollTop = $('#stream').scrollHeight;
  const color = speaker === 'human' ? cssVar('--human') : cssVar('--ai');
  return { el: wrap, orb: makeOrb(cv, color, ST.xfade[speaker]), bubbleEl: b };
}

function presence(speaker, label) {
  const p = bubble(speaker, '');
  p.el.classList.add('presence');
  p.bubbleEl.innerHTML = `${label}<span class="dots"></span>`;
  p.orb.speak(10 * 60 * 1000);
  return p;
}

const cssVar = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
const speakMs = turn => Math.min(
  (turn.segments || []).reduce((s, x) => s + (x.dur_ms || 0), 0) || 4000, 90000);

function addTurn(turn) {
  const b = bubble(turn.speaker, turn.text);
  b.orb.speak(speakMs(turn));
  return b;
}

/* ── typing wire: the third voice (and the composing presence) ── */
const typing = { start: 0, last: 0, backRun: 0, el: null };
const wire = {
  ws: null, ready: false, timer: null,
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

function endTyping() {
  if (typing.start) wire.send({ t: 'end' });
  typing.start = 0; typing.backRun = 0;
  typing.el?.el.remove();
  if (typing.el) orbs.delete(typing.el.orb);
  typing.el = null;
}

/* ── flow ────────────────────────────────────────────────── */
async function send() {
  const box = $('#input');
  const text = box.value.trim();
  if (!text || ST.busy) return;
  ST.busy = true;
  $('#stream .empty')?.remove();
  const meta = typing.start ? { typing_ms: Math.round(performance.now() - typing.start) } : {};
  endTyping();
  box.value = ''; box.style.height = 'auto';
  try {
    const r1 = await api('/api/turn/human', { text, meta });
    ST.xfade = r1.stats?.drift?.xfade || ST.xfade;
    addTurn(r1.turn);

    const wait = presence('ai', '');
    try {
      const r2 = await api('/api/turn/ai', {});
      ST.xfade = r2.stats?.drift?.xfade || ST.xfade;
      wait.el.remove(); orbs.delete(wait.orb);
      addTurn(r2.turn);
    } catch (e) {
      wait.el.remove(); orbs.delete(wait.orb);
      toast(e.message);
    }
  } catch (e) {
    toast(e.message);
  } finally {
    ST.busy = false;
    box.focus();
  }
}

/* ── boot ────────────────────────────────────────────────── */
async function boot() {
  let s;
  try { s = await api('/api/state'); }
  catch (e) { toast('backend unreachable: ' + e.message); return; }

  ST.motion = s.motion; ST.humanSide = s.human_side; ST.aiSide = s.ai_side;
  ST.xfade = s.stats?.drift?.xfade || ST.xfade;

  $('#motion').textContent = s.motion || '';
  const side = x => (x === 'pro' ? 'for' : 'against');
  $('#sides').innerHTML = s.motion
    ? `<span class="h">human — <b>${side(s.human_side)}</b></span><span class="a">machine — <b>${side(s.ai_side)}</b></span>`
    : '';

  if (s.turns.length) s.turns.forEach(t => { bubble(t.speaker, t.text); })
  else {
    const e = document.createElement('div');
    e.className = 'empty';
    e.textContent = 'type your opening statement';
    $('#stream').append(e);
  }

  const box = $('#input');
  box.addEventListener('input', () => {
    box.style.height = 'auto';
    box.style.height = Math.min(box.scrollHeight, 140) + 'px';
  });
  box.addEventListener('keydown', e => {
    const now = performance.now();
    if ((e.key === 'Enter' || e.key === 'Return') && !e.shiftKey) { e.preventDefault(); send(); return; }
    if (!typing.start) {
      typing.start = now; typing.last = now;
      wire.send({ t: 'start' });
      $('#stream .empty')?.remove();
      typing.el = presence('human', '');
    }
    const gap = now - typing.last;
    typing.last = now;
    const elapsed = Math.round(now - typing.start);
    if (e.key === 'Backspace' || e.key === 'Delete') {
      typing.backRun++;
      wire.send({ t: 'back', depth: typing.backRun, elapsed });
    } else {
      typing.backRun = 0;
      wire.send({ t: 'key', dt: Math.round(Math.min(gap, 4000)), elapsed });
    }
  });
  box.focus();
}

boot();
