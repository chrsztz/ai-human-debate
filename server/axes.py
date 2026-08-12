"""语义差分轴：从锚句集算出轴向量，再把任意句子投影到轴上。

    axis  = normalize( mean(positive) - mean(negative) )
    score = cosine( emb(句子) - centroid , axis )

centroid 是全体锚句 embedding 的均值。减掉它这一步不能省：OpenAI 的 embedding
有一个很强的公共方向，不去掉的话所有句子的余弦相似度都挤在 0.7~0.9，
四条轴之间也会高度相关 —— 听感上就是四个旋钮一起动，等于只有一个旋钮。
（注意 centroid 在 mean(pos)-mean(neg) 里会被抵消，所以它只影响查询侧。）
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, asdict
from pathlib import Path

import numpy as np
import yaml


@dataclass
class AxisDef:
    id: str
    name_zh: str
    name_en: str
    pos_label: str
    neg_label: str
    note: str = ""


def _l2(a: np.ndarray) -> np.ndarray:
    n = np.linalg.norm(a, axis=-1, keepdims=True)
    return a / np.where(n == 0, 1.0, n)


def load_anchor_spec(path: Path) -> tuple[list[AxisDef], dict[str, dict[str, list[str]]]]:
    spec = yaml.safe_load(path.read_text(encoding="utf-8"))
    defs, anchors = [], {}
    for a in spec["axes"]:
        defs.append(
            AxisDef(
                id=a["id"],
                name_zh=a.get("name_zh", a["id"]),
                name_en=a.get("name_en", a["id"]),
                pos_label=a.get("pos_label", "+"),
                neg_label=a.get("neg_label", "-"),
                note=(a.get("note") or "").strip(),
            )
        )
        poles = {"positive": list(a["positive"]), "negative": list(a["negative"])}
        for pole, items in poles.items():
            for it in items:
                # 冒号后跟空格的英文锚句会被 YAML 解析成 dict，静默变成一条坏锚句。
                # 与其让它一路传到 embedding 层才崩，不如在这里报清楚。
                if not isinstance(it, str):
                    raise ValueError(
                        f"锚句必须是字符串，但 {a['id']}/{pole} 里有一条被解析成了 {type(it).__name__}：{it!r}\n"
                        f"多半是句子里有「冒号+空格」，用双引号把整句括起来即可。"
                    )
        anchors[a["id"]] = poles
    return defs, anchors


def fingerprint(cfg) -> str:
    raw = cfg.anchors_file.read_bytes()
    model = "MOCK" if cfg.mock else cfg.embed_model
    tag = f"{model}|{cfg.embed_dims}|{int(cfg.orthogonalize)}".encode()
    return hashlib.sha1(raw + tag).hexdigest()[:16]


class AxisModel:
    def __init__(self, defs: list[AxisDef], centroid: np.ndarray, vectors: np.ndarray, fp: str, diag: dict | None = None):
        self.defs = defs
        self.ids = [d.id for d in defs]
        self.centroid = centroid.astype(np.float32)
        self.vectors = _l2(vectors.astype(np.float32))  # (k, d)
        self.fingerprint = fp
        self.diagnostics = diag or {}

    def project(self, embs: np.ndarray) -> np.ndarray:
        """(n, d) 归一化 embedding -> (n, k) 原始轴分数，范围大致 [-0.4, 0.4]。"""
        if embs.size == 0:
            return np.zeros((0, len(self.ids)), dtype=np.float32)
        centered = _l2(embs.astype(np.float32) - self.centroid)
        return centered @ self.vectors.T

    def project_one(self, emb: np.ndarray) -> dict[str, float]:
        s = self.project(emb.reshape(1, -1))[0]
        return {aid: float(v) for aid, v in zip(self.ids, s)}

    # ---- 持久化 ----------------------------------------------------------
    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        np.savez(
            path,
            centroid=self.centroid,
            vectors=self.vectors,
            defs=json.dumps([asdict(d) for d in self.defs], ensure_ascii=False),
            fingerprint=self.fingerprint,
            diagnostics=json.dumps(self.diagnostics, ensure_ascii=False),
        )

    @staticmethod
    def load(path: Path) -> "AxisModel":
        z = np.load(path, allow_pickle=False)
        defs = [AxisDef(**d) for d in json.loads(str(z["defs"]))]
        diag = json.loads(str(z["diagnostics"])) if "diagnostics" in z else {}
        return AxisModel(defs, z["centroid"], z["vectors"], str(z["fingerprint"]), diag)


def build(cfg, embedder) -> AxisModel:
    """算轴向量。160 条锚句，带缓存的话几秒钟；这一步不需要任何辩论语料。"""
    defs, anchors = load_anchor_spec(cfg.anchors_file)

    flat: list[str] = []
    span: dict[str, dict[str, tuple[int, int]]] = {}
    for aid, poles in anchors.items():
        span[aid] = {}
        for pole in ("positive", "negative"):
            start = len(flat)
            flat.extend(poles[pole])
            span[aid][pole] = (start, len(flat))

    embs = embedder.embed(flat)
    centroid = embs.mean(axis=0)

    vecs = []
    for d in defs:
        ps, pe = span[d.id]["positive"]
        ns, ne = span[d.id]["negative"]
        vecs.append(embs[ps:pe].mean(axis=0) - embs[ns:ne].mean(axis=0))
    vectors = _l2(np.stack(vecs))

    if cfg.orthogonalize:
        vectors = _gram_schmidt(vectors)

    model = AxisModel(defs, centroid, vectors, fingerprint(cfg))
    model.diagnostics = diagnose(model, embs, span)
    return model


def _gram_schmidt(v: np.ndarray) -> np.ndarray:
    out = []
    for row in v:
        for prev in out:
            row = row - np.dot(row, prev) * prev
        out.append(row / max(np.linalg.norm(row), 1e-9))
    return np.stack(out).astype(np.float32)


def diagnose(model: AxisModel, embs: np.ndarray, span: dict) -> dict:
    """轴的质量报告。两个数决定这条轴能不能用：

    d'   —— 留一法算的两极分离度（把该锚句从轴的构造里剔掉再投影，避免自我印证）。
            > 2.0 好用；1.0~2.0 勉强；< 1.0 这条轴基本是噪声，回去改锚句。
    corr —— 轴之间的余弦。|corr| > 0.5 的两条轴在听感上会一起动，
            要么改锚句拉开，要么打开 AXES_ORTHOGONALIZE。
    """
    centered = _l2(embs - model.centroid)
    per_axis = {}

    for k, d in enumerate(model.defs):
        ps, pe = span[d.id]["positive"]
        ns, ne = span[d.id]["negative"]
        P, N = embs[ps:pe], embs[ns:ne]
        sp, sn = P.sum(axis=0), N.sum(axis=0)
        np_, nn = len(P), len(N)

        pos_scores, neg_scores = [], []
        for i in range(np_):  # 留一：把第 i 条正极锚句从均值里拿掉再建轴
            v = (sp - P[i]) / (np_ - 1) - sn / nn
            v /= max(np.linalg.norm(v), 1e-9)
            pos_scores.append(float(centered[ps + i] @ v))
        for j in range(nn):
            v = sp / np_ - (sn - N[j]) / (nn - 1)
            v /= max(np.linalg.norm(v), 1e-9)
            neg_scores.append(float(centered[ns + j] @ v))

        pa, na = np.array(pos_scores), np.array(neg_scores)
        pooled = float(np.sqrt((pa.var(ddof=1) + na.var(ddof=1)) / 2)) or 1e-9
        per_axis[d.id] = {
            "d_prime": round(float(pa.mean() - na.mean()) / pooled, 2),
            "pos_mean": round(float(pa.mean()), 4),
            "neg_mean": round(float(na.mean()), 4),
            "anchor_sd": round(pooled, 4),
            "n_anchors": np_ + nn,
        }

    corr = (model.vectors @ model.vectors.T).round(3).tolist()
    return {"per_axis": per_axis, "axis_cosine": corr, "axis_ids": model.ids}


def load_or_build(cfg, embedder, force: bool = False) -> AxisModel:
    want = fingerprint(cfg)
    if not force and cfg.axes_file.exists():
        try:
            m = AxisModel.load(cfg.axes_file)
            if m.fingerprint == want:
                return m
        except Exception:
            pass
    m = build(cfg, embedder)
    m.save(cfg.axes_file)
    return m
