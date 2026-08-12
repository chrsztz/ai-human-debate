"""把一个回合切成若干片段，每片单独取 embedding。

为什么不是定长切片：语义差分投影对片段的语法完整性很敏感，
"我上周真的因为这件事一晚"这种被腰斩的片段，投到"具身"轴上的读数基本是噪声。
按标点切子句能拿到同样细的时间分辨率，但每片都是完整的语义单元。

定长模式仍然保留（SEGMENT_MODE=fixed），方便你自己对比两种切法的读数差异。
"""

from __future__ import annotations

import re
import unicodedata

STRONG = "。！？!?；;…\n"
WEAK = "，,、：:—–~"
CLOSERS = "”』）)》」\"'"


def char_width(ch: str) -> int:
    """全角/宽字符算 2，其余算 1 —— 让中英文的阈值可以用同一套数字。"""
    return 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1


def width(s: str) -> int:
    return sum(char_width(c) for c in s)


def _split_keep(text: str, delims: str) -> list[str]:
    """在 delims 处切开，标点跟着前一片走；紧随其后的右引号/右括号也一并带上。"""
    out: list[str] = []
    buf: list[str] = []
    i, n = 0, len(text)
    while i < n:
        ch = text[i]
        buf.append(ch)
        i += 1
        if ch in delims:
            # 把紧随其后的右引号/右括号吸进来，别让它们单独起头
            while i < n and text[i] in CLOSERS:
                buf.append(text[i])
                i += 1
            out.append("".join(buf))
            buf = []
    if buf:
        out.append("".join(buf))
    return [p for p in out if p.strip()]


def _hard_cut(piece: str, max_width: int) -> list[str]:
    out, buf, w = [], [], 0
    for ch in piece:
        buf.append(ch)
        w += char_width(ch)
        if w >= max_width:
            out.append("".join(buf))
            buf, w = [], 0
    if buf:
        out.append("".join(buf))
    return out


def _atoms(text: str, max_width: int) -> list[str]:
    """先按强标点切，过长的再按弱标点切，还过长就硬切。"""
    atoms: list[str] = []
    for strong in _split_keep(text, STRONG):
        if width(strong) <= max_width:
            atoms.append(strong)
            continue
        for weak in _split_keep(strong, WEAK):
            if width(weak) <= max_width:
                atoms.append(weak)
            else:
                atoms.extend(_hard_cut(weak, max_width))
    return atoms


def segment(
    text: str,
    mode: str = "clause",
    target_width: int = 56,
    min_width: int = 16,
    max_width: int = 120,
) -> list[str]:
    text = re.sub(r"[ \t]+", " ", (text or "")).strip()
    if not text:
        return []

    if mode == "fixed":
        return [s.strip() for s in _hard_cut(text, target_width) if s.strip()]

    atoms = _atoms(text, max_width)
    if not atoms:
        return []

    # 贪心合并：攒到 target 就收，攒过 max 就提前收
    segs: list[str] = []
    buf: list[str] = []
    w = 0
    for a in atoms:
        aw = width(a)
        if buf and w + aw > max_width:
            segs.append("".join(buf))
            buf, w = [], 0
        buf.append(a)
        w += aw
        if w >= target_width:
            segs.append("".join(buf))
            buf, w = [], 0
    if buf:
        segs.append("".join(buf))

    # 结尾太短的碎片并回上一段，避免出现只有两个字的片段
    if len(segs) > 1 and width(segs[-1]) < min_width:
        segs[-2] += segs[-1]
        segs.pop()

    return [s.strip() for s in segs if s.strip()]
