"""一场辩论的状态：回合、片段级读数、统计、落盘。

落盘这件事今天就要做对。第一版不做校准，但今天不把每个片段的原始分数写进 JSONL，
排练就白排了 —— 校准统计量只能从真实素材上拟合，而排练本身就是素材来源。
"""

from __future__ import annotations

import json
import math
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

from . import segment as seg


@dataclass
class Segment:
    index: int
    text: str
    width: int
    axes: dict[str, dict[str, float]]  # axis_id -> {raw, z, unit}


@dataclass
class Turn:
    id: int
    speaker: str  # "human" | "ai"
    text: str
    ts: float
    segments: list[Segment]
    axes: dict[str, dict[str, float]]  # 回合级：按片段宽度加权
    meta: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        d = asdict(self)
        d["segments"] = [asdict(s) if not isinstance(s, dict) else s for s in self.segments]
        return d


class Session:
    def __init__(self, cfg, embedder, axis_model, calibrator, motion: str = "", ai_side: str = "con",
                 side_source: str = "drawn"):
        self.cfg = cfg
        self.embedder = embedder
        self.axes = axis_model
        self.calib = calibrator
        self.motion = motion or cfg.debate_motion
        self.ai_side = ai_side
        self.human_side = "con" if ai_side == "pro" else "pro"
        # drawn = 抽签，chosen = 人在界面上选的，config = .env 里写死的。
        # 界面上的"抽签"标记必须反映实际情况 —— 那是给观众看的一个断言，不能撒谎
        self.side_source = side_source
        self.turns: list[Turn] = []
        self.started = datetime.now()
        self.log_path: Path = cfg.log_dir / f"session-{self.started:%Y%m%d-%H%M%S}.jsonl"
        self._write_header()

    # ---- 分析 ------------------------------------------------------------
    def analyze(self, text: str, speaker: str) -> tuple[list[Segment], dict]:
        parts = seg.segment(
            text,
            mode=self.cfg.segment_mode,
            target_width=self.cfg.seg_target_width,
            min_width=self.cfg.seg_min_width,
            max_width=self.cfg.seg_max_width,
        )
        if not parts:
            return [], {aid: {"raw": 0.0, "z": 0.0, "unit": 0.5} for aid in self.axes.ids}

        embs = self.embedder.embed(parts)
        raw = self.axes.project(embs)  # (n, k)

        segments: list[Segment] = []
        for i, (p, row) in enumerate(zip(parts, raw)):
            r = {aid: float(v) for aid, v in zip(self.axes.ids, row)}
            self.calib.observe(r, speaker)
            segments.append(Segment(index=i, text=p, width=seg.width(p), axes=self.calib.normalize(r)))

        # 回合级 = 片段的宽度加权平均（长句子说了算），在 raw 层做平均再归一化
        total = sum(s.width for s in segments) or 1
        turn_raw = {
            aid: sum(s.axes[aid]["raw"] * s.width for s in segments) / total
            for aid in self.axes.ids
        }
        return segments, self.calib.normalize(turn_raw)

    def add_turn(self, text: str, speaker: str, meta: dict | None = None) -> Turn:
        segments, turn_axes = self.analyze(text, speaker)
        turn = Turn(
            id=len(self.turns) + 1,
            speaker=speaker,
            text=text,
            ts=time.time(),
            segments=segments,
            axes=turn_axes,
            meta=meta or {},
        )
        self.turns.append(turn)
        self._append(turn)
        return turn

    # ---- 统计 ------------------------------------------------------------
    def stats(self) -> dict:
        per_speaker = {}
        for scope in ("human", "ai"):
            per_speaker[scope] = {
                aid: self.calib.stats[scope][aid].summary() for aid in self.axes.ids
            }
        combined = {aid: self.calib.stats["all"][aid].summary() for aid in self.axes.ids}

        # 两个说话人之间的分离度（Cohen's d）—— 这就是作品论点的量化读数
        separation = {}
        for aid in self.axes.ids:
            h, a = self.calib.stats["human"][aid], self.calib.stats["ai"][aid]
            if h.n > 1 and a.n > 1:
                pooled = math.sqrt(((h.n - 1) * h.sd**2 + (a.n - 1) * a.sd**2) / (h.n + a.n - 2))
                separation[aid] = {
                    "delta": round(h.mean - a.mean, 4),
                    "cohens_d": round((h.mean - a.mean) / pooled, 2) if pooled > 1e-9 else 0.0,
                }
            else:
                separation[aid] = {"delta": None, "cohens_d": None}

        return {
            "per_speaker": per_speaker,
            "combined": combined,
            "separation": separation,
            "turns": {
                "human": sum(1 for t in self.turns if t.speaker == "human"),
                "ai": sum(1 for t in self.turns if t.speaker == "ai"),
            },
            "segments": {
                "human": sum(len(t.segments) for t in self.turns if t.speaker == "human"),
                "ai": sum(len(t.segments) for t in self.turns if t.speaker == "ai"),
            },
            "calibration": self.calib.report(),
        }

    def history(self) -> list[dict]:
        return [{"role": "user" if t.speaker == "human" else "assistant", "content": t.text} for t in self.turns]

    # ---- 落盘 ------------------------------------------------------------
    def _write_header(self) -> None:
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        head = {
            "type": "header",
            "started": self.started.isoformat(timespec="seconds"),
            "motion": self.motion,
            "ai_side": self.ai_side,
            "human_side": self.human_side,
            "side_source": self.side_source,
            "embed_model": "MOCK" if self.cfg.mock else self.cfg.embed_model,
            "embed_dims": self.cfg.embed_dims,
            "chat_model": self.cfg.chat_model,
            "segment_mode": self.cfg.segment_mode,
            "axes": self.axes.ids,
            "axes_fingerprint": self.axes.fingerprint,
            "calib_mode": self.cfg.calib_mode,
            # 分开记：frame 是任务约束（辩题+立场），persona 是人格注入
            "debate_frame": self.cfg.debate_frame if self.motion else "",
            "persona_prompt": self.cfg.system_prompt,
            "mock": self.cfg.mock,
        }
        with self.log_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(head, ensure_ascii=False) + "\n")

    def _append(self, turn: Turn) -> None:
        rec = {"type": "turn", **turn.to_dict()}
        with self.log_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")
