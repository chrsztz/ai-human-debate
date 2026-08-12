#!/usr/bin/env python
"""重建轴向量并打印质量报告。改完 anchors/axes.yaml 就跑一次。

    python -m scripts.build_axes

看两个数：
  d'    两极分离度（留一法，没有自我印证）。>2.0 好用；1.0~2.0 勉强；<1.0 回去改锚句。
  cos   轴之间的相关。|cos|>0.5 的两条轴在听感上会一起动，要么改锚句拉开两极，
        要么 AXES_ORTHOGONALIZE=1 把后面的轴变成残差。
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from server.axes import build  # noqa: E402
from server.config import CFG  # noqa: E402
from server.embed import Embedder  # noqa: E402


def main() -> None:
    emb = Embedder(CFG)
    print(f"锚句文件 : {CFG.anchors_file}")
    print(f"embedding: {'mock' if CFG.mock else CFG.embed_model} ({CFG.embed_dims or '原生'} 维)")
    print(f"正交化   : {'开' if CFG.orthogonalize else '关'}\n")

    model = build(CFG, emb)
    model.save(CFG.axes_file)

    diag = model.diagnostics
    print(f"{'轴':<16} {'名称':<14} {'d′':>7} {'正极均值':>10} {'负极均值':>10} {'锚句 sd':>9}")
    print("-" * 72)
    for d in model.defs:
        s = diag["per_axis"][d.id]
        flag = "  ← 太弱" if s["d_prime"] < 1.0 else ""
        print(
            f"{d.id:<16} {d.name_zh:<14} {s['d_prime']:>7.2f} {s['pos_mean']:>10.4f} "
            f"{s['neg_mean']:>10.4f} {s['anchor_sd']:>9.4f}{flag}"
        )

    print("\n轴间余弦（对角线是 1）")
    ids = diag["axis_ids"]
    print(" " * 16 + "".join(f"{i[:10]:>11}" for i in ids))
    worst = 0.0
    for i, row in zip(ids, diag["axis_cosine"]):
        print(f"{i:<16}" + "".join(f"{v:>11.3f}" for v in row))
        for j, v in zip(ids, row):
            if i != j:
                worst = max(worst, abs(v))
    print(f"\n最大非对角相关: {worst:.3f}", end="  ")
    if worst > 0.5:
        print("← 偏高。这四个旋钮会一起动，考虑改锚句或开 AXES_ORTHOGONALIZE=1")
    else:
        print("← 可以")

    print(f"\n已写入 {CFG.axes_file}  (fingerprint {model.fingerprint})")
    print(f"embedding 缓存 {len(emb._cache)} 条，本次 API 调用 {emb.calls} 次")


if __name__ == "__main__":
    main()
