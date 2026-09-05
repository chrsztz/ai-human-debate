"""FastAPI 服务：辩论界面 + 实时轴读数 + 统计面板。

    GET  /                      前端
    GET  /api/state             配置 / 轴定义 / 轴质量诊断 / 全部回合 / 统计
    POST /api/turn/human        提交人类回合 -> 立刻返回该回合的轴读数
    POST /api/turn/ai           让 AI 接一轮 -> 返回 AI 回合的轴读数
    POST /api/analyze           只分析不入库（试探某句话落在轴的什么位置）
    POST /api/session/reset     开新一场（统计和日志一起重置）
    GET  /api/stats             只要统计
"""

from __future__ import annotations

import random
from contextlib import asynccontextmanager
from dataclasses import asdict

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from .axes import load_or_build
from .calibrate import Calibrator
from .chat import Debater
from .config import CFG
from .embed import Embedder
from .osc import OscSender
from .store import Session

STATE: dict = {}


def _draw_side(requested: str = "") -> tuple[str, str]:
    """决定 AI 站哪一边。

    默认抽签。让人先选的话，人一定选自己真信的那边，于是 AI 永远是唱反调的那个 ——
    这会在每一场里对 affiliation 轴造成同向偏差，测出来的"AI 更对抗"里就混进了
    分配机制的贡献。抽签还有个副作用正好是要的：有时候人会被分到自己不信的一边。
    """
    if requested in ("pro", "con"):
        return requested, "chosen"
    if CFG.ai_side in ("pro", "con"):
        return CFG.ai_side, "config"
    return random.choice(("pro", "con")), "drawn"


def _new_session(motion: str = "", ai_side: str = "") -> Session:
    calib = Calibrator(CFG, STATE["axes"].ids)
    STATE["calib"] = calib
    side, source = _draw_side(ai_side)
    STATE["session"] = Session(CFG, STATE["embedder"], STATE["axes"], calib, motion, side, source)
    return STATE["session"]


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not CFG.api_key and not CFG.mock:
        raise RuntimeError("没有 OPENAI_API_KEY。把 .env.example 复制成 .env 填上 key，或者用 MOCK_OPENAI=1 空跑链路。")
    STATE["embedder"] = Embedder(CFG)
    STATE["axes"] = load_or_build(CFG, STATE["embedder"])  # 缺失或锚句变了会自动重建
    STATE["debater"] = Debater(CFG)
    STATE["osc"] = OscSender(CFG, STATE["axes"].ids)
    _new_session(CFG.debate_motion)
    yield
    STATE["osc"].shutdown()


app = FastAPI(title="ai-human-debate", lifespan=lifespan)


class TextIn(BaseModel):
    text: str
    # 前端会带上打字过程的时序（时长/退格/停顿）。今天不用它，但它是后面
    # "停顿即信号"那套设计唯一的素材来源，现在开始记就不用重排。
    meta: dict = {}


class AnalyzeIn(BaseModel):
    text: str
    speaker: str = "human"


class ResetIn(BaseModel):
    motion: str = ""
    ai_side: str = ""  # "" = 抽签；pro / con = 指定


def _config_view() -> dict:
    return {
        "chat_model": "mock" if CFG.mock else CFG.chat_model,
        "embed_model": "mock" if CFG.mock else CFG.embed_model,
        "embed_dims": CFG.embed_dims,
        "segment_mode": CFG.segment_mode,
        "seg_target_width": CFG.seg_target_width,
        "calib_mode": CFG.calib_mode,
        "orthogonalize": CFG.orthogonalize,
        "side_assign": CFG.side_assign,
        # 任务约束 vs 人格注入，两个槽分开显示
        "debate_frame": STATE["debater"].frame_text(STATE["session"].motion, STATE["session"].ai_side) or None
        if "session" in STATE
        else None,
        "system_prompt": CFG.system_prompt or None,
        "length_hint": CFG.length_hint or None,
        "mock": CFG.mock,
        "log_path": str(STATE["session"].log_path) if "session" in STATE else None,
        "cache": {"entries": len(STATE["embedder"]._cache), "api_calls": STATE["embedder"].calls}
        if "embedder" in STATE
        else None,
    }


def _axes_view() -> dict:
    m = STATE["axes"]
    return {
        "defs": [asdict(d) for d in m.defs],
        "fingerprint": m.fingerprint,
        "diagnostics": m.diagnostics,
    }


@app.get("/api/state")
def state():
    s: Session = STATE["session"]
    return {
        "config": _config_view(),
        "axes": _axes_view(),
        "motion": s.motion,
        "ai_side": s.ai_side,
        "human_side": s.human_side,
        "side_source": s.side_source,
        "turns": [t.to_dict() for t in s.turns],
        "stats": s.stats(),
        "osc": STATE["osc"].status(),
    }


@app.get("/api/osc")
def osc_status():
    return STATE["osc"].status()


@app.post("/api/osc/test")
def osc_test():
    """每条轴单独 0→1→0 扫一遍。辩论输出是零散的，拿它调合成器等于盲调 ——
    先用一个已知信号把四条链路接对。"""
    if not STATE["osc"].enabled:
        raise HTTPException(400, "OSC 没开（OSC_ENABLED=0）")
    STATE["osc"].sweep()
    return {"ok": True, "osc": STATE["osc"].status()}


@app.websocket("/ws/typing")
async def ws_typing(ws: WebSocket):
    """按键事件的实时通道 —— 第三个声部的素材来源。

    为什么必须是实时的：原来的 typing_ms / backspaces 是回合结束后随文本一起送上来的
    汇总。用打完字之后才到的数据做不出"正在犹豫"的声音 —— 那是事后统计，不是信号。

    为什么是 WebSocket：按键 5~10 次/秒，每次一个 HTTP 请求是拿错了工具。

    AI 那侧没有对应的通道，而且永远不会有。文本瞬间成块到达，无过程、无犹豫、无退格。
    这个空缺是结构性的，不是映射出来的。
    """
    await ws.accept()
    osc = STATE["osc"]
    try:
        while True:
            e = await ws.receive_json()
            if not CFG.typing_enabled:
                continue
            t = e.get("t")
            if t == "key":
                osc.send_now("/debate/type/key", [int(e.get("dt", 0)), int(e.get("elapsed", 0))])
            elif t == "back":
                # 退格是"收回已经说出口的话"，声音上该是一个反向手势
                osc.send_now("/debate/type/back", [int(e.get("depth", 1)), int(e.get("elapsed", 0))])
            elif t == "pause":
                osc.send_now("/debate/type/pause", [int(e.get("ms", 0))])
            elif t in ("start", "end"):
                osc.send_now("/debate/type/gate", [1 if t == "start" else 0])
    except WebSocketDisconnect:
        pass
    except Exception:
        pass
    finally:
        # 断线不能把打字层永远卡在开着的状态
        osc.send_now("/debate/type/gate", [0])


@app.get("/api/stats")
def stats():
    return STATE["session"].stats()


@app.post("/api/turn/human")
def turn_human(body: TextIn):
    text = body.text.strip()
    if not text:
        raise HTTPException(400, "空输入")
    s: Session = STATE["session"]
    turn = s.add_turn(text, "human", body.meta)
    STATE["osc"].play_turn(turn, s.human_side)
    st = s.stats()
    STATE["osc"].send_xfade(st["drift"])
    return {"turn": turn.to_dict(), "stats": st, "osc": STATE["osc"].status()}


@app.post("/api/turn/ai")
def turn_ai():
    s: Session = STATE["session"]
    if not any(t.speaker == "human" for t in s.turns):
        raise HTTPException(400, "还没有人类发言，AI 没得接")
    try:
        ai_turn = sum(1 for t in s.turns if t.speaker == "ai")
        text, meta = STATE["debater"].reply(s.history(), s.motion, s.ai_side, ai_turn)
    except Exception as e:  # 把上游报错原样送到前端，别让它变成一个沉默的 500
        raise HTTPException(502, f"{type(e).__name__}: {e}")
    if not text:
        raise HTTPException(502, "模型返回了空内容（多半是 max_tokens 太小）")
    turn = s.add_turn(text, "ai", meta)
    STATE["osc"].play_turn(turn, s.ai_side)
    st = s.stats()
    STATE["osc"].send_xfade(st["drift"])
    return {"turn": turn.to_dict(), "stats": st, "osc": STATE["osc"].status()}


@app.post("/api/analyze")
def analyze(body: AnalyzeIn):
    """只投影不入库，也不进统计 —— 用来试探某句话落在轴的什么位置。"""
    text = body.text.strip()
    if not text:
        raise HTTPException(400, "空输入")
    s: Session = STATE["session"]
    from . import segment as seg

    parts = seg.segment(text, CFG.segment_mode, CFG.seg_target_width, CFG.seg_min_width, CFG.seg_max_width)
    embs = STATE["embedder"].embed(parts)
    raw = STATE["axes"].project(embs)
    calib = STATE["calib"]
    segments = [
        {"index": i, "text": p, "width": seg.width(p), "axes": calib.normalize({a: float(v) for a, v in zip(STATE["axes"].ids, row)})}
        for i, (p, row) in enumerate(zip(parts, raw))
    ]
    total = sum(x["width"] for x in segments) or 1
    turn_raw = {
        aid: sum(x["axes"][aid]["raw"] * x["width"] for x in segments) / total for aid in STATE["axes"].ids
    }
    return {"segments": segments, "axes": calib.normalize(turn_raw)}


@app.post("/api/session/reset")
def reset(body: ResetIn):
    s = _new_session(body.motion.strip() or CFG.debate_motion, body.ai_side)
    return {
        "ok": True,
        "motion": s.motion,
        "ai_side": s.ai_side,
        "human_side": s.human_side,
        "side_source": s.side_source,
        "log_path": str(s.log_path),
    }


WEB = CFG.root / "web"


@app.get("/")
def index():
    return FileResponse(WEB / "index.html")


@app.get("/live")
def live():
    """演出界面：只有气泡和粒子球，没有任何数字。排练调参仍用 / 那个工作界面。"""
    return FileResponse(WEB / "live.html")


app.mount("/static", StaticFiles(directory=WEB), name="static")
