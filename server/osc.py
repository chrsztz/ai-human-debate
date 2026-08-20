"""OSC 发送层 —— Python 排时间表，Max 管声音。

**为什么时序在 Python 这边：** 一个回合切成 N 个片段就是 N 组参数。全部瞬间发出去，
Max 在 1 毫秒内收到四条消息，之后什么都没有 —— 没有可播放的时间轨迹。
片段的时长来自片段宽度，那是 Python 侧的事实，再复制一份到 Max 里重新推导只会多出错误面。

**为什么插值在 Max 那边：** Python 只发「目标值 + 用多久滑过去」，由 Max 的 [line] 去插。
Python 不做 100Hz 的插值推送 —— 那是把 Max 最擅长的事挪到最不适合做它的地方。

**为什么按说话人分地址：** 这个作品就是两个声部。`[route /debate/human/seg /debate/ai/seg]`
接完就分好了，不用再解包一个 speaker 字段再分流。

    /debate/{human,ai}/turn   turn_id(i)  side(i 0=正 1=反)  n_segments(i)  total_ms(i)
    /debate/{human,ai}/seg    index(i)  embodiment(f) certainty(f) concreteness(f) affiliation(f)  ramp_ms(i)  hold_ms(i)
    /debate/{human,ai}/end    turn_id(i)  interrupted(i 0/1)
    /debate/idle              ms_since_last(i)

**时间参数为什么放在最后：** Max 的 [unpack] 从右往左出。ramp_ms 排在四个轴值右边，
就会先于它们到达 [line] 的右入口（设置滑行时间），四个轴值随后进左入口触发滑行 ——
顺序天然是对的，patch 里不需要 [trigger] 兜一圈。放在前面的话每次滑行都会用上一个片段的时长。

发的是 unit（0~1，已校准），不是 raw。校准层存在的意义就是产出这个值，
在 Max 里再缩放一次等于有两个地方管校准 —— 到时候没人说得清参数为什么不对。
"""

from __future__ import annotations

import threading
import time
from collections import deque

TICK = 0.02  # 打断检查的粒度


class OscSender:
    def __init__(self, cfg, axis_ids: list[str]):
        self.cfg = cfg
        self.axis_ids = list(axis_ids)
        self.enabled = bool(cfg.osc_enabled)
        self.sent = 0
        self.errors = 0
        self.dropped = 0
        self.last: dict | None = None
        self.playing: str | None = None

        self._client = None
        self._queue: deque = deque()
        self._gen = 0
        self._stop = False
        self._cv = threading.Condition()
        self._last_event = time.time()

        if self.enabled:
            from pythonosc.udp_client import SimpleUDPClient

            # UDP 不建连接，这里不会因为 Max 没开而失败 —— 消息只是没人收
            self._client = SimpleUDPClient(cfg.osc_host, cfg.osc_port)
            threading.Thread(target=self._run, daemon=True).start()

    # ---- 对外 ------------------------------------------------------------
    def _enqueue(self, payload: dict, preempt: bool) -> None:
        with self._cv:
            if preempt:
                self._queue.clear()
                self._gen += 1  # 让正在播的那个自己中止
            self._queue.append(payload)
            # 积压说明声音已经远远落后于辩论进度，这时候补播旧回合不如跳过
            while len(self._queue) > max(1, self.cfg.osc_queue_max):
                self._queue.popleft()
                self.dropped += 1
            self._cv.notify()

    def play_turn(self, turn, side: str) -> None:
        """默认排队，不抢占。

        抢占看着更"实时"，实际上是灾难：AI 的回复几秒钟就到，会把人那一轮的声音
        砍在第一个片段上 —— 人基本听不见。而这个作品讲的就是人和 AI 的关系，
        人的声部被系统性掐掉是最不能接受的失败。

        排队会不会越积越多？不会：一个回合的音频约十几秒，而人打一轮字要几十秒，
        队列的增长被人的打字速度天然压住。真积压到 osc_queue_max 以上时说明
        节奏已经失控，那时丢掉最旧的几轮反而是对的。
        """
        if not self.enabled or not turn.segments:
            return
        payload = {
            "speaker": turn.speaker,
            "id": turn.id,
            "side": 0 if side == "pro" else 1,
            "segments": [
                {
                    "index": s.index,
                    "ramp_ms": s.ramp_ms,
                    "hold_ms": max(s.dur_ms - s.ramp_ms, 0),
                    "units": [round(float(s.axes[a]["unit"]), 5) for a in self.axis_ids],
                }
                for s in turn.segments
            ],
            "total_ms": sum(s.dur_ms for s in turn.segments),
        }
        self._enqueue(payload, preempt=(self.cfg.osc_on_overlap == "preempt"))

    def sweep(self) -> None:
        """把每条轴单独从 0 扫到 1 再回来 —— 用来对着一个已知信号 patch Max。

        辩论的输出是零散的，拿它调合成器等于盲调。先用这个把四条链路接对，
        看到四个数在动、动的是对的那一个，再去跑真辩论。
        """
        if not self.enabled:
            return
        n = len(self.axis_ids)
        step_ms = 100
        # 步数必须是奇数，三角波才会正好踩到 1.0 —— 偶数步的峰值是 0.957，
        # 而校准信号的意义就在于确认量程两端都对得上
        steps = 25  # 每条轴 0→1→0 约 2.5 秒
        segs = []
        idx = 0
        for k in range(n):
            for t in range(steps):
                v = 1.0 - abs(2.0 * t / (steps - 1) - 1.0)  # 0→1→0 三角波
                units = [0.5] * n
                units[k] = round(v, 4)
                segs.append({"index": idx, "ramp_ms": step_ms, "hold_ms": 0, "units": units})
                idx += 1
        payload = {"speaker": "human", "id": -1, "side": 0, "segments": segs,
                   "total_ms": len(segs) * step_ms}
        self._enqueue(payload, preempt=True)  # 测试信号永远插队

    def send_now(self, address: str, args: list) -> None:
        """绕开回合调度器直接发。打字事件是实时的，排进队列就没有意义了。"""
        if self.enabled:
            self._send(address, args)

    def set_baseline(self, speaker: str, base: dict[str, float]) -> None:
        """缓慢漂移的基线 = 该说话人 embodiment 等四轴的移动平均。

        位置 = 固定基线（声部身份）+ 缓慢漂移（这个）+ 瞬时偏移（当前片段）。
        三个时间尺度里只有第一个是设计的，后两个完全由读数决定 ——
        人越说越具身他的合成器就越活，AI 一直 hedging 它就越僵，
        两条线靠近或者交叉都不是安排出来的。
        """
        if self.enabled:
            self._send(f"/debate/{speaker}/base", [round(float(base.get(a, 0.5)), 5) for a in self.axis_ids])

    def send_vitality(self, v: dict) -> None:
        """两个声部在"活体度"轴上的位置 —— 整个作品的头号参数。

        一个数就够：Max 那边接一个 [r human.vitality] 去顶 vocality 的基线即可。
        confidence 一并送出，想让早期的漂移更收敛可以再乘一次。
        """
        if not self.enabled:
            return
        for spk in ("human", "ai"):
            self._send(f"/debate/{spk}/vitality", [float(v[spk]), float(v["confidence"]), int(v["turns"])])

    def status(self) -> dict:
        return {
            "enabled": self.enabled,
            "target": f"{self.cfg.osc_host}:{self.cfg.osc_port}" if self.enabled else None,
            "sent": self.sent,
            "errors": self.errors,
            "dropped": self.dropped,
            "queued": len(self._queue),
            "on_overlap": self.cfg.osc_on_overlap,
            "playing": self.playing,
            "last": self.last,
            "schedule": {
                "ms_per_width": self.cfg.osc_ms_per_width,
                "min_seg_ms": self.cfg.osc_min_seg_ms,
                "max_seg_ms": self.cfg.osc_max_seg_ms,
                "ramp_fraction": self.cfg.osc_ramp_fraction,
                "time_scale": self.cfg.osc_time_scale,
            },
            "axis_order": self.axis_ids,
        }

    def shutdown(self) -> None:
        with self._cv:
            self._stop = True
            self._cv.notify()

    # ---- 内部 ------------------------------------------------------------
    def _send(self, address: str, args: list) -> None:
        try:
            self._client.send_message(address, args)
            self.sent += 1
            self.last = {"t": time.time(), "address": address, "args": args}
            self._last_event = time.time()
        except Exception as e:
            self.errors += 1
            self.last = {"t": time.time(), "address": address, "error": f"{type(e).__name__}: {e}"}

    def _interrupted(self, gen: int) -> bool:
        return self._stop or self._gen != gen

    def _wait(self, seconds: float, gen: int) -> bool:
        """可打断的 sleep。返回 True 表示被打断。"""
        end = time.monotonic() + seconds
        while True:
            if self._interrupted(gen):
                return True
            left = end - time.monotonic()
            if left <= 0:
                return False
            time.sleep(min(TICK, left))

    def _run(self) -> None:
        idle_period = 1.0 / max(self.cfg.osc_idle_hz, 0.1)
        while not self._stop:
            with self._cv:
                if not self._queue:
                    self._cv.wait(timeout=idle_period)
                payload = self._queue.popleft() if self._queue else None
                gen = self._gen
            if self._stop:
                break
            if payload is not None:
                self._play(payload, gen)
            elif self.cfg.osc_idle_hz > 0:
                self._send("/debate/idle", [int((time.time() - self._last_event) * 1000)])

    def _gate(self, spk: str, speaking: bool) -> None:
        """开合。不发声的一方降到 residue_level，不是 0 —— 见 config 里的说明。"""
        if speaking:
            self._send(f"/debate/{spk}/gate", [1, 1.0, 800])
        else:
            self._send(f"/debate/{spk}/gate", [0, self.cfg.osc_residue_level, self.cfg.osc_tail_ms])

    def _dissolve(self, spk: str) -> None:
        """残留期：四个轴全部缓慢漂向 0.5 —— 身份特征在沉默里化掉。

        复用 seg 消息，Max 那边不需要任何新逻辑：它本来就会按 ramp_ms 滑过去。
        """
        n = len(self.axis_ids)
        self._send(f"/debate/{spk}/seg", [-1, *([0.5] * n), self.cfg.osc_dissolve_ms, 0])

    def _play(self, p: dict, gen: int) -> None:
        spk = p["speaker"]
        other = "ai" if spk == "human" else "human"
        self.playing = spk
        self._send(f"/debate/{spk}/turn", [p["id"], p["side"], len(p["segments"]), p["total_ms"]])
        self._gate(spk, True)
        self._gate(other, False)          # 保证任何时刻只有一方在前景

        interrupted = 0
        for s in p["segments"]:
            if self._interrupted(gen):
                interrupted = 1
                break
            self._send(f"/debate/{spk}/seg", [s["index"], *s["units"], s["ramp_ms"], s["hold_ms"]])
            if self._wait((s["ramp_ms"] + s["hold_ms"]) / 1000.0, gen):
                interrupted = 1
                break

        if p["id"] >= 0:                  # sweep（id=-1）不参与开合，否则测试信号会被压掉
            self._gate(spk, False)
            self._dissolve(spk)

        self._send(f"/debate/{spk}/end", [p["id"], interrupted])
        self.playing = None
