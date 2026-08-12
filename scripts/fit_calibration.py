#!/usr/bin/env python
"""从排练日志拟合校准参数，写出 data/calibration.json。

    python -m scripts.fit_calibration                 # 用 data/logs 下所有 session
    python -m scripts.fit_calibration data/logs/session-2026*.jsonl

拟合完把 .env 里的 CALIB_MODE 改成 fitted。

⚠️ mu/sigma 一定是人和 AI 合并算的。分开归一化会把"AI 更去身、人更具身"这个
   对比压平 —— 那正好是作品要展示的东西。脚本会另外打印两边的均值差，
   那个数只是给你看，不进 calibration.json。
"""

from __future__ import annotations

import glob
import json
import math
import statistics as st
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from server.config import CFG  # noqa: E402


def collect(paths: list[Path]) -> tuple[dict[str, list[float]], dict[str, dict[str, list[float]]], list[str]]:
    combined: dict[str, list[float]] = {}
    by_speaker: dict[str, dict[str, list[float]]] = {"human": {}, "ai": {}}
    axis_ids: list[str] = []
    for p in paths:
        for line in p.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            rec = json.loads(line)
            if rec.get("type") == "header":
                # MOCK 跑出来的读数是噪声，混进去会毁掉整套校准
                if rec.get("mock"):
                    print(f"跳过 {p.name}（MOCK 会话）")
                    break
                axis_ids = axis_ids or rec.get("axes", [])
                continue
            if rec.get("type") != "turn":
                continue
            spk = rec["speaker"]
            for s in rec["segments"]:
                for aid, v in s["axes"].items():
                    combined.setdefault(aid, []).append(v["raw"])
                    by_speaker.setdefault(spk, {}).setdefault(aid, []).append(v["raw"])
    return combined, by_speaker, axis_ids


def main() -> None:
    args = sys.argv[1:]
    files = [Path(p) for a in args for p in glob.glob(a)] if args else sorted(CFG.log_dir.glob("session-*.jsonl"))
    files = [f for f in files if f.exists()]
    if not files:
        sys.exit(f"没找到日志。先跑几场辩论，日志会落在 {CFG.log_dir}")

    combined, by_speaker, axis_ids = collect(files)
    if not combined:
        sys.exit("日志里没有任何片段读数。")
    axis_ids = axis_ids or sorted(combined)

    n_total = len(next(iter(combined.values())))
    print(f"读入 {len(files)} 个 session，{n_total} 个片段\n")

    out = {}
    cohen = "Cohen's d"
    print(f"{'轴':<16} {'n':>6} {'mu':>9} {'sigma':>9} {'p5':>9} {'p95':>9} {'人-AI 均值差':>14} {cohen:>11}")
    print("-" * 92)
    for aid in axis_ids:
        vals = combined.get(aid, [])
        if len(vals) < 2:
            continue
        mu, sigma = st.fmean(vals), st.stdev(vals)
        out[aid] = {"mu": round(mu, 6), "sigma": round(sigma, 6), "n": len(vals)}

        h = by_speaker.get("human", {}).get(aid, [])
        a = by_speaker.get("ai", {}).get(aid, [])
        if len(h) > 1 and len(a) > 1:
            pooled = math.sqrt(((len(h) - 1) * st.stdev(h) ** 2 + (len(a) - 1) * st.stdev(a) ** 2) / (len(h) + len(a) - 2))
            delta = st.fmean(h) - st.fmean(a)
            dstr, cstr = f"{delta:>14.4f}", f"{(delta / pooled if pooled else 0):>11.2f}"
        else:
            dstr, cstr = f"{'—':>14}", f"{'—':>11}"

        srt = sorted(vals)
        p5 = srt[int(0.05 * (len(srt) - 1))]
        p95 = srt[int(0.95 * (len(srt) - 1))]
        print(f"{aid:<16} {len(vals):>6} {mu:>9.4f} {sigma:>9.4f} {p5:>9.4f} {p95:>9.4f}{dstr}{cstr}")

    payload = {
        "fitted_at": datetime.now().isoformat(timespec="seconds"),
        "n_segments": n_total,
        "sources": [str(f) for f in files],
        "embed_model": CFG.embed_model,
        "embed_dims": CFG.embed_dims,
        "note": "mu/sigma 由人类与 AI 合并拟合，绝不可分说话人归一化",
        "axes": out,
    }
    CFG.calibration_file.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n已写入 {CFG.calibration_file}")
    print("把 .env 里的 CALIB_MODE 改成 fitted 再重启服务即可生效。")
    print("\nCohen's d 就是作品论点的量化读数：|d| > 0.8 说明两边在这条轴上真的分开了。")


if __name__ == "__main__":
    main()
