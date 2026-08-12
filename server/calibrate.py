"""把原始轴分数拉成 0~1 的可控参数。

这一层不能省。语义差分投影出来的原始分数不会铺满 [-1, 1]，实际上通常挤在
[-0.15, 0.2] 这种窄带里。直接接到合成器参数上，结果就是全场听起来一个样。

    z    = (raw - mu) / sigma
    unit = 0.5 * (1 + tanh(gain * z))        -> (0, 1)

⚠️ 人和 AI 必须共用同一套 mu/sigma。分开归一化等于强行把两边拉到同一个分布中心，
   "AI 更去身、人更具身"这个对比会被数学抹平 —— 正好把作品的论点抹掉。
   所以下面的 params_for() 只读 combined 统计，per-speaker 统计纯粹用于展示。
"""

from __future__ import annotations

import json
import math
from pathlib import Path

SPEAKERS = ("human", "ai")


class Welford:
    """在线均值/方差，同时留一份原始值用来算分位数（排练规模下完全够用）。"""

    __slots__ = ("n", "_mean", "_m2", "vals")

    def __init__(self) -> None:
        self.n = 0
        self._mean = 0.0
        self._m2 = 0.0
        self.vals: list[float] = []

    def push(self, x: float) -> None:
        self.n += 1
        d = x - self._mean
        self._mean += d / self.n
        self._m2 += d * (x - self._mean)
        if len(self.vals) < 20000:
            self.vals.append(x)

    @property
    def mean(self) -> float:
        return self._mean if self.n else 0.0

    @property
    def sd(self) -> float:
        return math.sqrt(self._m2 / (self.n - 1)) if self.n > 1 else 0.0

    def pct(self, q: float) -> float:
        if not self.vals:
            return 0.0
        s = sorted(self.vals)
        i = min(len(s) - 1, max(0, int(round(q * (len(s) - 1)))))
        return s[i]

    def summary(self) -> dict:
        if not self.n:
            return {"n": 0}
        return {
            "n": self.n,
            "mean": round(self.mean, 4),
            "sd": round(self.sd, 4),
            "min": round(min(self.vals), 4),
            "p10": round(self.pct(0.10), 4),
            "p50": round(self.pct(0.50), 4),
            "p90": round(self.pct(0.90), 4),
            "max": round(max(self.vals), 4),
        }


class Calibrator:
    def __init__(self, cfg, axis_ids: list[str]):
        self.cfg = cfg
        self.axis_ids = list(axis_ids)
        self.mode = cfg.calib_mode
        self.gain = cfg.calib_gain
        self.source = "prior"
        self.fitted: dict[str, dict[str, float]] = {}
        self.stats = {
            scope: {aid: Welford() for aid in self.axis_ids}
            for scope in ("all", *SPEAKERS)
        }
        if self.mode == "fitted":
            self.load()

    # ---- 参数 ------------------------------------------------------------
    def params_for(self, axis_id: str) -> tuple[float, float]:
        if self.mode == "fitted" and axis_id in self.fitted:
            p = self.fitted[axis_id]
            return float(p["mu"]), max(float(p["sigma"]), 1e-6)
        if self.mode == "running":
            w = self.stats["all"][axis_id]  # 只用合并统计，绝不分说话人
            if w.n >= 8 and w.sd > 1e-6:
                return w.mean, w.sd
        return self.cfg.calib_prior_mu, max(self.cfg.calib_prior_sigma, 1e-6)

    def normalize(self, raw: dict[str, float]) -> dict[str, dict[str, float]]:
        out = {}
        for aid in self.axis_ids:
            x = float(raw.get(aid, 0.0))
            mu, sigma = self.params_for(aid)
            z = (x - mu) / sigma
            out[aid] = {
                "raw": round(x, 5),
                "z": round(z, 3),
                "unit": round(0.5 * (1.0 + math.tanh(self.gain * z)), 4),
            }
        return out

    def observe(self, raw: dict[str, float], speaker: str) -> None:
        for aid in self.axis_ids:
            x = float(raw.get(aid, 0.0))
            self.stats["all"][aid].push(x)
            if speaker in self.stats:
                self.stats[speaker][aid].push(x)

    # ---- 报告 ------------------------------------------------------------
    def suggestion(self) -> dict:
        """从当前已观测到的合并分布反推一套 mu/sigma，供 fit_calibration 之前先看一眼。"""
        out = {}
        for aid in self.axis_ids:
            w = self.stats["all"][aid]
            if w.n >= 8 and w.sd > 1e-6:
                out[aid] = {"mu": round(w.mean, 5), "sigma": round(w.sd, 5), "n": w.n}
        return out

    def report(self) -> dict:
        return {
            "mode": self.mode,
            "gain": self.gain,
            "source": self.source,
            "in_use": {aid: dict(zip(("mu", "sigma"), [round(v, 5) for v in self.params_for(aid)])) for aid in self.axis_ids},
            "suggestion": self.suggestion(),
        }

    # ---- 持久化 ----------------------------------------------------------
    def load(self, path: Path | None = None) -> bool:
        path = path or self.cfg.calibration_file
        if not path.exists():
            self.source = "prior (calibration.json 还不存在)"
            return False
        data = json.loads(path.read_text(encoding="utf-8"))
        self.fitted = data.get("axes", {})
        self.source = f"fitted ({data.get('n_segments', '?')} 片段, {data.get('fitted_at', '?')})"
        return True
