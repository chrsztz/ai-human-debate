#!/usr/bin/env python
"""监听 OSC 并逐条打印 —— 用来确认 Python 这边发对了，不用先把 Max 搭起来。

    python scripts/osc_monitor.py            # 听 7400
    python scripts/osc_monitor.py 7401       # 听别的端口

⚠️ 同一个端口只能被一个程序占用。要么先关掉 Max 再跑这个，
   要么让它听 7401，同时把 .env 里的 OSC_PORT 也改成 7401。

排查顺序（十次里有九次是前两条）：
  1. 这里什么都没有  → Python 没在发。看 /api/osc 的 sent 计数、OSC_ENABLED 是不是 0
  2. 这里有、Max 没有 → 端口被占 / Max 的 udpreceive 端口号不对 / 防火墙
  3. 两边都有但数字不动 → Max 那边 route 或 unpack 接错了
"""

from __future__ import annotations

import sys
import time
from datetime import datetime

from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer

AXES = ("具身", "确定", "具体", "亲和")


def main() -> None:
    # 这是个实时监视工具，管道/重定向时也必须逐行出来，不然看着像没在收
    sys.stdout.reconfigure(line_buffering=True)
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7400
    state = {"n": 0, "t0": time.time(), "last_idle": 0.0}

    def on_seg(address, *args):
        state["n"] += 1
        idx, *rest = args
        units, ramp, hold = rest[:4], rest[4], rest[5]
        bars = "  ".join(
            f"{name} {v:.3f} {'█' * int(v * 12):<12}" for name, v in zip(AXES, units)
        )
        who = "人 " if "/human/" in address else "AI "
        print(f"{datetime.now():%H:%M:%S.%f} {who} seg{idx:>3}  ramp{ramp:>5}ms hold{hold:>5}ms  {bars}")

    def on_turn(address, *args):
        state["n"] += 1
        who = "人 " if "/human/" in address else "AI "
        tid, side, n, total = args
        print(f"\n{datetime.now():%H:%M:%S.%f} {who} ▶ turn #{tid} "
              f"{'正方' if side == 0 else '反方'} · {n} 片段 · {total / 1000:.1f}s")

    def on_end(address, *args):
        state["n"] += 1
        who = "人 " if "/human/" in address else "AI "
        tid, interrupted = args
        print(f"{datetime.now():%H:%M:%S.%f} {who} ■ turn #{tid}"
              f"{'（被抢占）' if interrupted else ''}\n")

    def on_idle(address, *args):
        state["n"] += 1
        # 心跳每秒好几条，别刷屏，一秒摘一条
        now = time.time()
        if now - state["last_idle"] < 1.0:
            return
        state["last_idle"] = now
        # 终端里用 \r 原地刷新；重定向到文件时就老老实实换行，不然日志糊成一坨
        print(f"{datetime.now():%H:%M:%S} · idle {args[0] / 1000:.1f}s", end="\r" if sys.stdout.isatty() else "\n")

    def on_other(address, *args):
        state["n"] += 1
        print(f"{datetime.now():%H:%M:%S.%f} ? {address} {args}")

    d = Dispatcher()
    d.map("/debate/*/seg", on_seg)
    d.map("/debate/*/turn", on_turn)
    d.map("/debate/*/end", on_end)
    d.map("/debate/idle", on_idle)
    d.set_default_handler(on_other)

    srv = BlockingOSCUDPServer(("0.0.0.0", port), d)
    print(f"监听 0.0.0.0:{port} —— Ctrl-C 退出\n")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        dt = time.time() - state["t0"]
        print(f"\n\n收到 {state['n']} 条消息，{dt:.0f} 秒，平均 {state['n'] / max(dt, 1):.1f} 条/秒")


if __name__ == "__main__":
    main()
