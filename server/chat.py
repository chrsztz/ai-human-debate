"""AI 辩手。

v1 刻意不加 system prompt —— 要测的就是"没有人格注入"时的默认语域。
注意"不加 system prompt" ≠ "没有人格"：那些 hedging、那种平衡感、那种礼貌的
对抗性全是 post-training 装进去的，不在 prompt 里。第一版跑出来的基线读数
落在"具身↔去身"轴的哪个位置，本身就是这个作品的一个发现。

唯一注入的是长度约束。它不是人格调整，但它确实进了 prompt，
所以每个回合都会把实际发出去的 user message 原样记进 meta，UI 里可以看到。
"""

from __future__ import annotations

import time

SIDE_LABEL = {
    "pro": "正方（支持该辩题）",
    "con": "反方（反对该辩题）",
}
SIDE_SHORT = {"pro": "正方", "con": "反方"}


def other_side(side: str) -> str:
    return "con" if side == "pro" else "pro"


MOCK_REPLIES = [
    "在某种程度上你的担忧是可以理解的，不过值得注意的是，这里可能存在一些需要区分的层面。"
    "从技术实现的角度看，所谓的身份更多是一种交互界面上的约定，而非系统内部的属性。",
    "这个说法大体上没错，只是需要一些限定。相关研究表明，用户对拟人化程度的偏好差异很大，"
    "很难一概而论。或许更准确的说法是，两者都有一部分道理。",
    "我理解你为什么会这么想。不过从制度设计的角度考虑，把责任归于某一方可能过于简化了，"
    "这里涉及的因素比表面上看起来要多。",
]


class Debater:
    def __init__(self, cfg):
        self.cfg = cfg
        self._client = None
        self._mock_i = 0

    @property
    def client(self):
        if self._client is None:
            from openai import OpenAI

            self._client = OpenAI(api_key=self.cfg.api_key)
        return self._client

    def frame_text(self, motion: str, ai_side: str) -> str:
        """辩论框架。立场必须常驻 system message —— 只拼在第一条 user message 前面
        的话，到第十轮早就被淹没了，模型会退回"顺着对方往下写"。"""
        if not motion.strip() or not self.cfg.debate_frame.strip():
            return ""
        return self.cfg.debate_frame.format(motion=motion.strip(), side=SIDE_LABEL.get(ai_side, ai_side))

    def build_messages(self, history: list[dict], motion: str, ai_side: str) -> list[dict]:
        frame = self.frame_text(motion, ai_side)
        persona = self.cfg.system_prompt.strip()
        parts = [p for p in (frame, persona) if p]
        msgs: list[dict] = [{"role": "system", "content": "\n\n".join(parts)}] if parts else []

        conv = [dict(m) for m in history]
        last_user = next((m for m in reversed(conv) if m["role"] == "user"), None)
        if self.cfg.length_hint.strip() and last_user is not None:
            last_user["content"] = f"{last_user['content']}\n\n{self.cfg.length_hint.strip()}"

        return msgs + conv

    def reply(self, history: list[dict], motion: str = "", ai_side: str = "con") -> tuple[str, dict]:
        msgs = self.build_messages(history, motion, ai_side)
        t0 = time.time()

        if self.cfg.mock:
            text = MOCK_REPLIES[self._mock_i % len(MOCK_REPLIES)]
            self._mock_i += 1
            usage = None
        else:
            resp = self.client.chat.completions.create(
                model=self.cfg.chat_model,
                messages=msgs,
                max_tokens=self.cfg.max_tokens,
                temperature=self.cfg.temperature,
            )
            text = (resp.choices[0].message.content or "").strip()
            u = resp.usage
            usage = {"prompt": u.prompt_tokens, "completion": u.completion_tokens} if u else None

        meta = {
            "model": "mock" if self.cfg.mock else self.cfg.chat_model,
            "latency_ms": int((time.time() - t0) * 1000),
            "usage": usage,
            "ai_side": ai_side,
            # 两个槽分开记：frame = 任务约束，persona = 人格注入
            "debate_frame": self.frame_text(motion, ai_side) or None,
            "persona_prompt": self.cfg.system_prompt.strip() or None,
            "sent_user_message": msgs[-1]["content"] if msgs else "",
        }
        return text, meta
