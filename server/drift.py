"""声部位置的长时漂移 —— 人越来越人、机器越来越机器的那条线。

## 为什么不是均值

第一版拿"该说话人 embodiment 的移动平均"当漂移，实测几乎不动：AI 均值 0.5、
人均值 0.55，差 0.05，听不出来。原因是 LLM 输出的低方差是 post-training 的产物 ——
它被训练成语域稳定，再跑一百轮也一样，不是采样不够。

## 换成离散度

真正巨大且稳定的差异是：**人的读数铺得开、AI 挤在中间**。人的 sd 可能 0.18，AI 0.07。
而且这正好是"人机感"的字面定义 —— 参数一直在动的声音听起来是活的，
参数坐着不动的听起来是死的。方差就是活体感，不需要再转译一次。

## 一硬一软

    vitality = 0.5 ± [ (1-HARD) × 置信度(轮数) × 证据
                     +   HARD   × 轮数斜坡 ]

软的那项：证据 = 离散度之比 + embodiment 均值差，**方向完全由数据决定**。
如果哪一场人比 AI 更去身、更单调，两个声部就会往反方向走 —— 那是真实发现，不是 bug。

硬的那项分两层，区别很重要：
  - 置信度 n/(n+k)：轮数越多越敢让证据说话。弧线是硬的、单调的、保证发生的，
    但它放大的是观察，不替代观察。第一轮两个声部几乎重合，到第十轮拉开。
  - HARD 兜底：纯轮数斜坡，跟谁说了什么无关。这一项是彻头彻尾的断言，
    单独拎出来就是为了让你随时知道自己用了多少。展览要保证效果时调它。
"""

from __future__ import annotations


def _clip(v: float, lo: float, hi: float) -> float:
    return lo if v < lo else hi if v > hi else v


def compute(calib, axis_ids: list[str], turns: dict[str, int], cfg) -> dict:
    """返回两个声部在"活体度"轴上的位置，以及各成分的拆解（供界面显示和调参）。"""
    st = calib.stats
    # 有效轮数取两边的较小值：只有一方说过话时没有可比性
    n = min(turns.get("human", 0), turns.get("ai", 0))

    def disp(spk: str) -> float:
        vals = [st[spk][a].sd for a in axis_ids if st[spk][a].n > 1]
        return sum(vals) / len(vals) if vals else 0.0

    sd_h, sd_a = disp("human"), disp("ai")
    # 用比值而不是差值：无量纲，不受校准尺度影响
    rel_disp = sd_h / (sd_h + sd_a) if (sd_h + sd_a) > 1e-6 else 0.5

    emb = axis_ids[0]  # 主证据轴
    m_h, m_a = st["human"][emb].mean, st["ai"][emb].mean
    rel_emb = _clip(0.5 + (m_h - m_a) / 2.0, 0.0, 1.0)

    w = _clip(cfg.drift_dispersion_weight, 0.0, 1.0)
    evidence = w * (rel_disp - 0.5) + (1.0 - w) * (rel_emb - 0.5)   # [-0.5, 0.5]
    soft = _clip(evidence * cfg.drift_gain, -0.5, 0.5)

    conf = n / (n + max(cfg.drift_confidence_k, 0.1)) if n else 0.0
    hard = min(1.0, n / max(cfg.drift_full_turns, 1))
    hw = _clip(cfg.drift_hard_weight, 0.0, 1.0)

    trend = (1.0 - hw) * conf * soft + hw * hard * 0.5

    # 音色交叉渐变的位置（0 = 全合成器，1 = 全人声采样）。
    # 人从 xfade_start 出发向 1 走，AI 从 1−xfade_start 出发向 0 走 ——
    # 两条线相向而行，可能在中段交叉。
    x0 = _clip(cfg.xfade_start, 0.0, 0.5)
    k = cfg.xfade_gain
    xfade = {
        "human": round(_clip(x0 + trend * k, 0.0, 1.0), 4),
        "ai": round(_clip(1.0 - x0 - trend * k, 0.0, 1.0), 4),
    }

    return {
        "human": round(_clip(0.5 + trend, 0.0, 1.0), 4),
        "ai": round(_clip(0.5 - trend, 0.0, 1.0), 4),
        "xfade": xfade,
        "turns": n,
        "confidence": round(conf, 3),
        "trend": round(trend, 4),
        # 拆解：让你随时看得见效果里有多少是观察、多少是断言
        "soft": round((1.0 - hw) * conf * soft, 4),
        "hard": round(hw * hard * 0.5, 4),
        "evidence": round(evidence, 4),
        "dispersion": {"human": round(sd_h, 4), "ai": round(sd_a, 4), "ratio": round(rel_disp, 3)},
        "embodiment_mean": {"human": round(m_h, 4), "ai": round(m_a, 4)},
    }
