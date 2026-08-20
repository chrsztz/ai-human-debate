"""集中配置。所有可调项都能用 .env 覆盖，方便排练时改参数不改代码。"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")


def _s(key: str, default: str) -> str:
    v = os.getenv(key)
    return default if v is None or v == "" else v


def _i(key: str, default: int) -> int:
    return int(_s(key, str(default)))


def _f(key: str, default: float) -> float:
    return float(_s(key, str(default)))


def _b(key: str, default: bool) -> bool:
    return _s(key, "1" if default else "0").strip().lower() in ("1", "true", "yes", "on")


@dataclass
class Config:
    # ---- OpenAI ----------------------------------------------------------
    api_key: str = field(default_factory=lambda: _s("OPENAI_API_KEY", ""))
    chat_model: str = field(default_factory=lambda: _s("OPENAI_CHAT_MODEL", "gpt-4o"))
    embed_model: str = field(default_factory=lambda: _s("OPENAI_EMBED_MODEL", "text-embedding-3-large"))
    # text-embedding-3-large 原生 3072 维；截到 1024 对语义差分投影没有可感损失，
    # 缓存体积小 3 倍。要用全维就把 OPENAI_EMBED_DIMS 设成 0。
    embed_dims: int = field(default_factory=lambda: _i("OPENAI_EMBED_DIMS", 1024))
    max_tokens: int = field(default_factory=lambda: _i("CHAT_MAX_TOKENS", 400))
    temperature: float = field(default_factory=lambda: _f("CHAT_TEMPERATURE", 1.0))

    # ---- prompt：两个槽是分开的，别混 --------------------------------------
    #
    # debate_frame  = 任务约束（辩题 + 立场）。不给立场，模型只会顺着人的话往下写，
    #                 两边论证同一边。这跟长度约束同类，不是人格注入。
    # system_prompt = 人格注入。v1 留空 —— 要测的就是"没有人格"时的基线语域。
    #
    # 两者物理上都进 system message，但分开存、分开记日志、UI 上分开显示，
    # 任何时候都能审计到底往 prompt 里放了什么。
    debate_frame: str = field(
        default_factory=lambda: _s(
            "DEBATE_FRAME",
            "这是一场辩论。\n辩题：{motion}\n你的立场：{side}。\n请始终从这个立场发言，不要替对方论证。",
        )
    )
    system_prompt: str = field(default_factory=lambda: _s("CHAT_SYSTEM_PROMPT", ""))
    # 长度约束不是人格调整，是格式约束；但它确实进了 prompt，所以 UI 里会原样显示。
    length_hint: str = field(
        default_factory=lambda: _s("CHAT_LENGTH_HINT", "（请用不超过 120 字回应，直接进入论点，不要罗列条目。）")
    )

    # 辩题写成陈述句（"微信聊天应该用句号"），正/反方才没有歧义
    debate_motion: str = field(default_factory=lambda: _s("DEBATE_MOTION", ""))
    # random = 抽签定边（默认）。人自己选的话一定选自己真信的那边，
    # 于是 AI 永远是唱反调的那个 —— 这会在每一场里对 affiliation 轴造成同向偏差。
    side_assign: str = field(default_factory=lambda: _s("SIDE_ASSIGN", "random"))
    # 强制指定 AI 的立场：pro / con。留空则按 side_assign 决定
    ai_side: str = field(default_factory=lambda: _s("AI_SIDE", ""))

    # 没有 key 也能把整条链路跑起来：伪 embedding + 伪回复，用来验证 UI 和统计。
    mock: bool = field(default_factory=lambda: _b("MOCK_OPENAI", False))

    # ---- 切片 ------------------------------------------------------------
    # clause = 按标点切子句（默认，推荐）；fixed = 定长切片
    segment_mode: str = field(default_factory=lambda: _s("SEGMENT_MODE", "clause"))
    # 宽度单位：中日韩全角字符算 2，拉丁字符算 1
    seg_target_width: int = field(default_factory=lambda: _i("SEG_TARGET_WIDTH", 56))
    seg_min_width: int = field(default_factory=lambda: _i("SEG_MIN_WIDTH", 16))
    seg_max_width: int = field(default_factory=lambda: _i("SEG_MAX_WIDTH", 120))

    # ---- 轴 --------------------------------------------------------------
    # 把 2/3/4 轴中能被前面的轴解释掉的分量减掉。四个旋钮如果高度相关，
    # 听感上就是"一个旋钮"，正交化能救回这一点，代价是轴的语义变成"残差"。
    orthogonalize: bool = field(default_factory=lambda: _b("AXES_ORTHOGONALIZE", False))

    # ---- 校准 ------------------------------------------------------------
    # fixed   = 用下面的先验 sigma（第一次排练之前用这个）
    # fitted  = 用 data/calibration.json（跑完 scripts/fit_calibration.py 之后用这个）
    # running = 在线自适应（做实验可以，演出别用，映射会在过程中漂移）
    calib_mode: str = field(default_factory=lambda: _s("CALIB_MODE", "fixed"))
    calib_prior_sigma: float = field(default_factory=lambda: _f("CALIB_PRIOR_SIGMA", 0.08))
    calib_prior_mu: float = field(default_factory=lambda: _f("CALIB_PRIOR_MU", 0.0))
    # tanh 增益：z=±2 时输出约 0.94/0.06。调大 = 更容易撞满量程。
    calib_gain: float = field(default_factory=lambda: _f("CALIB_GAIN", 0.7))

    # ---- OSC → Max/MSP ---------------------------------------------------
    osc_enabled: bool = field(default_factory=lambda: _b("OSC_ENABLED", True))
    osc_host: str = field(default_factory=lambda: _s("OSC_HOST", "127.0.0.1"))
    osc_port: int = field(default_factory=lambda: _i("OSC_PORT", 7400))
    # 片段时长 = 宽度 × ms_per_width × time_scale，再夹到 [min, max]。
    # 90 ms/宽度 ≈ 一个 56 宽的子句 5 秒左右，接近朗读速度
    osc_ms_per_width: float = field(default_factory=lambda: _f("OSC_MS_PER_WIDTH", 90.0))
    osc_min_seg_ms: int = field(default_factory=lambda: _i("OSC_MIN_SEG_MS", 800))
    osc_max_seg_ms: int = field(default_factory=lambda: _i("OSC_MAX_SEG_MS", 8000))
    # 片段时长里有多少用来滑向新值（剩下的保持）。越大越连续、越像一个空间里的移动
    osc_ramp_fraction: float = field(default_factory=lambda: _f("OSC_RAMP_FRACTION", 0.4))
    osc_time_scale: float = field(default_factory=lambda: _f("OSC_TIME_SCALE", 1.0))
    # 新回合撞上正在播的回合怎么办。queue = 排队（默认）；preempt = 抢占。
    # 千万别默认 preempt：AI 的回复几秒就到，会把人那一轮砍在第一个片段上，人基本听不见
    osc_on_overlap: str = field(default_factory=lambda: _s("OSC_ON_OVERLAP", "queue"))
    osc_queue_max: int = field(default_factory=lambda: _i("OSC_QUEUE_MAX", 4))
    # 静默期心跳
    osc_idle_hz: float = field(default_factory=lambda: _f("OSC_IDLE_HZ", 4.0))

    # ---- 开合 ------------------------------------------------------------
    # 不发声的一方保留的音量。绝不能是 0：交叉那一刻只有两个声音同时在场才听得见，
    # 人耳对相隔几十秒的音色做不了比较。
    osc_residue_level: float = field(default_factory=lambda: _f("OSC_RESIDUE_LEVEL", 0.01))
    osc_tail_ms: int = field(default_factory=lambda: _i("OSC_TAIL_MS", 4000))
    # 残留期四个轴向 0.5 漂移的时长 —— 说话者的身份特征在沉默里溶解。
    # 这一步不需要 Max 加逻辑：就是一条 ramp 很长、全部指向 0.5 的 seg 消息
    osc_dissolve_ms: int = field(default_factory=lambda: _i("OSC_DISSOLVE_MS", 14000))
    # 基线漂移的 EMA 系数。越小漂得越慢，整场辩论才看得出走势
    osc_baseline_alpha: float = field(default_factory=lambda: _f("OSC_BASELINE_ALPHA", 0.18))

    # ---- 声部位置的长时漂移（人越来越人 / 机器越来越机器）------------------
    # 证据里离散度占多少。人的读数铺得开、AI 挤在中间 —— 这个差异比均值差大得多，
    # 而且方差本身就是"活体感"的字面定义
    drift_dispersion_weight: float = field(default_factory=lambda: _f("DRIFT_DISPERSION_WEIGHT", 0.65))
    drift_gain: float = field(default_factory=lambda: _f("DRIFT_GAIN", 1.6))
    # 置信度 n/(n+k)：轮数越多越敢让证据说话。放大观察，不替代观察
    drift_confidence_k: float = field(default_factory=lambda: _f("DRIFT_CONFIDENCE_K", 4.0))
    # 纯轮数斜坡的权重。这一项跟谁说了什么无关，是彻头彻尾的断言 ——
    # 单独拎出来就是为了让你随时知道自己用了多少。展览要保证效果时调它
    drift_hard_weight: float = field(default_factory=lambda: _f("DRIFT_HARD_WEIGHT", 0.25))
    drift_full_turns: int = field(default_factory=lambda: _i("DRIFT_FULL_TURNS", 12))

    # ---- 打字层（第三个声部）----------------------------------------------
    # 人打字那段时间不是要遮盖的死区，是全作品最"人"的信号。
    # AI 那侧的对应物是"没有" —— 文本瞬间成块到达，无过程、无犹豫。
    typing_enabled: bool = field(default_factory=lambda: _b("TYPING_ENABLED", True))
    # 停顿超过这个值开始持续播报，让声音有"卡住了"的实时反馈
    typing_pause_ms: int = field(default_factory=lambda: _i("TYPING_PAUSE_MS", 1200))

    # ---- 路径 ------------------------------------------------------------
    root: Path = ROOT
    anchors_file: Path = ROOT / "anchors" / "axes.yaml"
    data_dir: Path = ROOT / "data"

    @property
    def axes_file(self) -> Path:
        return self.data_dir / "axes.npz"

    @property
    def cache_file(self) -> Path:
        return self.data_dir / "cache" / "embeddings.jsonl"

    @property
    def calibration_file(self) -> Path:
        return self.data_dir / "calibration.json"

    @property
    def log_dir(self) -> Path:
        return self.data_dir / "logs"

    def ensure_dirs(self) -> None:
        for p in (self.data_dir, self.cache_file.parent, self.log_dir):
            p.mkdir(parents=True, exist_ok=True)


CFG = Config()
CFG.ensure_dirs()
