#!/usr/bin/env python
"""不用起服务、不用跑辩论，直接对着一个已知信号 patch Max。

    python scripts/osc_sweep.py                  # 四条轴依次 0→1→0，循环
    python scripts/osc_sweep.py --once           # 只扫一遍
    python scripts/osc_sweep.py --axis 0         # 只扫第一条轴
    python scripts/osc_sweep.py --speaker ai     # 走 /debate/ai/* 那一路
    python scripts/osc_sweep.py --port 7401

**先跑这个，再跑辩论。** 辩论的输出是零散的、值域窄的，拿它调合成器等于盲调 ——
你分不清"听不出变化"是因为映射没接对，还是因为参数根本没动。
用三角波扫过来，四个数在 Max 里必须一个一个亮起来，而且亮的顺序和这里打印的一致。
"""

from __future__ import annotations

import argparse
import time

from pythonosc.udp_client import SimpleUDPClient

AXES = ["embodiment", "certainty", "concreteness", "affiliation"]
ZH = ["具身↔去身", "确定↔对冲", "具体↔抽象", "亲和↔对抗"]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=7400)
    ap.add_argument("--speaker", default="human", choices=("human", "ai"))
    ap.add_argument("--axis", type=int, default=-1, help="只扫第几条轴（0-3），默认全扫")
    ap.add_argument("--step-ms", type=int, default=100)
    ap.add_argument("--steps", type=int, default=25, help="每条轴 0→1→0 用多少步（会取奇数）")
    ap.add_argument("--once", action="store_true")
    a = ap.parse_args()

    # 奇数步三角波才正好踩到 1.0；偶数步的峰值是 0.957，量程两端就验不了
    if a.steps % 2 == 0:
        a.steps += 1

    c = SimpleUDPClient(a.host, a.port)
    which = range(len(AXES)) if a.axis < 0 else [a.axis]
    per_axis_ms = a.steps * a.step_ms

    print(f"→ {a.host}:{a.port}  /debate/{a.speaker}/*")
    print(f"  每条轴 {per_axis_ms / 1000:.1f}s，其余三条固定在 0.5")
    print(f"  轴顺序（Max 里 unpack 出来的先后）：{'  '.join(ZH)}\n")

    n = 0
    try:
        while True:
            c.send_message(f"/debate/{a.speaker}/turn", [-1, 0, len(list(which)) * a.steps, len(list(which)) * per_axis_ms])
            idx = 0
            for k in which:
                print(f"  扫 {ZH[k]}  ({AXES[k]})")
                for t in range(a.steps):
                    v = 1.0 - abs(2.0 * t / (a.steps - 1) - 1.0)  # 三角波 0→1→0
                    units = [0.5] * len(AXES)
                    units[k] = round(v, 4)
                    c.send_message(f"/debate/{a.speaker}/seg", [idx, *units, a.step_ms, 0])
                    n += 1
                    idx += 1
                    time.sleep(a.step_ms / 1000.0)
            c.send_message(f"/debate/{a.speaker}/end", [-1, 0])
            if a.once:
                break
            print("  ——— 循环 ———")
    except KeyboardInterrupt:
        pass
    print(f"\n共发出 {n} 条 seg 消息")


if __name__ == "__main__":
    main()
