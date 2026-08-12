"""OpenAI embedding 客户端 + 磁盘缓存。

缓存很重要：锚句每次启动都要重新算 160 条，排练时同一句话也常常重复分析。
缓存键 = sha1(model|dims|text)，改模型或改维度会自动失效。
"""

from __future__ import annotations

import base64
import hashlib
import json
import threading
from pathlib import Path

import numpy as np

BATCH = 128


def _l2(a: np.ndarray) -> np.ndarray:
    n = np.linalg.norm(a, axis=-1, keepdims=True)
    return a / np.where(n == 0, 1.0, n)


class Embedder:
    def __init__(self, cfg):
        self.cfg = cfg
        self.path: Path = cfg.cache_file
        self._cache: dict[str, np.ndarray] = {}
        self._lock = threading.Lock()
        self._client = None
        self.calls = 0
        self.hits = 0
        self._load()

    # ---- 缓存 ------------------------------------------------------------
    def _load(self) -> None:
        if not self.path.exists():
            return
        with self.path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = json.loads(line)
                    self._cache[rec["k"]] = np.frombuffer(base64.b64decode(rec["v"]), dtype=np.float32)
                except Exception:
                    continue  # 半行/损坏行直接跳过，缓存不是真相来源

    def _append(self, key: str, vec: np.ndarray) -> None:
        rec = {"k": key, "v": base64.b64encode(vec.astype(np.float32).tobytes()).decode("ascii")}
        with self.path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(rec) + "\n")

    def _key(self, text: str) -> str:
        # mock 向量必须和真向量分开存，否则空跑一次就会把缓存污染掉
        model = "MOCK" if self.cfg.mock else self.cfg.embed_model
        raw = f"{model}|{self.cfg.embed_dims}|{text}"
        return hashlib.sha1(raw.encode("utf-8")).hexdigest()

    # ---- 取向量 ----------------------------------------------------------
    @property
    def client(self):
        if self._client is None:
            from openai import OpenAI

            self._client = OpenAI(api_key=self.cfg.api_key)
        return self._client

    def _fetch(self, texts: list[str]) -> list[np.ndarray]:
        if self.cfg.mock:
            return [self._mock_vec(t) for t in texts]
        kwargs = {"model": self.cfg.embed_model, "input": texts}
        if self.cfg.embed_dims:
            kwargs["dimensions"] = self.cfg.embed_dims
        resp = self.client.embeddings.create(**kwargs)
        self.calls += 1
        return [np.asarray(d.embedding, dtype=np.float32) for d in sorted(resp.data, key=lambda d: d.index)]

    def _mock_vec(self, text: str) -> np.ndarray:
        """无 API key 时的占位向量：确定性伪随机，纯粹用来验证链路，语义上是噪声。"""
        d = self.cfg.embed_dims or 1024
        seed = int.from_bytes(hashlib.sha256(text.encode("utf-8")).digest()[:8], "big") % (2**32)
        return np.random.default_rng(seed).standard_normal(d).astype(np.float32)

    def embed(self, texts: list[str]) -> np.ndarray:
        """返回 (n, d) 的 L2 归一化向量。"""
        if not texts:
            return np.zeros((0, self.cfg.embed_dims or 1024), dtype=np.float32)

        keys = [self._key(t) for t in texts]
        with self._lock:
            missing = [(k, t) for k, t in zip(keys, texts) if k not in self._cache]
            # 同一批里的重复文本只算一次
            seen: dict[str, str] = {}
            for k, t in missing:
                seen.setdefault(k, t)
            todo = list(seen.items())

            for i in range(0, len(todo), BATCH):
                chunk = todo[i : i + BATCH]
                vecs = self._fetch([t for _, t in chunk])
                for (k, _), v in zip(chunk, vecs):
                    self._cache[k] = v
                    self._append(k, v)

            self.hits += len(texts) - len(todo)
            out = np.stack([self._cache[k] for k in keys])

        return _l2(out.astype(np.float32))
