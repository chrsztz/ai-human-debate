# ai-human-debate

人和 AI 辩论，两边的文字都实时投影到四条语义轴上，轴的读数最终会成为 Max/MSP 的音频控制参数。

作品要探讨的是：AI 在技术层面本该是去身份的，但企业正在通过 prompt 和 post-training
让它越来越像人；而人因为过度依赖 AI，反而越来越"人机感"。所以两边的音色不是预先分配的，
而是每一句话在同一个连续空间里的位置 —— 交换如果发生，观众是听着它发生的。

**当前进度：第一步（分析链路 + 界面）已完成。音频/OSC 还没接。**

```
文本 → 切子句 → embedding → 减质心 → 4 次点积（语义差分投影）
    → 校准（tanh(z) → 0~1）→ [今天到这里] → OSC → Max/MSP
```

---

## 跑起来

```bash
conda env create -f environment.yml
```

```bash
cp .env.example .env
```

把 `OPENAI_API_KEY` 填进 `.env`，然后：

```bash
conda run -n ai-human-debate uvicorn server.main:app --reload --port 8848
```

打开 http://localhost:8848 。首次启动会自动算一次轴向量（160 条锚句，一次 embedding 调用，
结果缓存在 `data/`），之后启动是秒开。

没有 key 想先看界面：在 `.env` 里写 `MOCK_OPENAI=1`。向量是噪声，读数没有语义意义，
但整条链路（切片 / 投影 / 校准 / 统计 / 落盘）都是真的走一遍。

---

## 四条轴

定义在 [anchors/axes.yaml](anchors/axes.yaml)，每条轴两极各约 20 条锚句，中英混写。

| 轴 | 两极 | 为什么是它 |
|---|---|---|
| `embodiment` | 具身 ↔ 去身 | 作品的主轴。第一人称/身体/情绪 ↔ 无说话人的制度语域 |
| `certainty` | 确定 ↔ 对冲 | LLM 的 hedging 语癖在这条轴上几乎是指纹 |
| `concreteness` | 具体 ↔ 抽象 | 可感的物与数字 ↔ 概念范畴 |
| `affiliation` | 亲和 ↔ 对抗 | 辩论的社交温度；人被反驳时会明显甩向负极 |

算法：`axis = normalize(mean(正极) − mean(负极))`，投影 `score = cos(emb(句子) − centroid, axis)`。

减质心这一步不能省 —— OpenAI 的 embedding 有一个很强的公共方向，不去掉的话所有句子的
余弦相似度都挤在 0.7~0.9，四条轴之间也会高度相关，听感上就是四个旋钮一起动。

改完锚句跑：

```bash
conda run -n ai-human-debate python scripts/build_axes.py
```

它会打印每条轴的 **d′**（留一法算的两极分离度，没有自我印证）和 **轴间余弦**。
`d′ > 2.0` 好用，`< 1.0` 说明这条轴基本是噪声，回去改锚句。
`|cos| > 0.5` 说明两条轴在测同一件事。同样的数字在界面的「轴诊断」页里也看得到。

---

## 校准 —— 这一步决定"能听出区别"还是"听不出区别"

原始投影分数不会铺满 `[-1, 1]`，实际上通常挤在 `[-0.15, 0.2]` 这种窄带里。
所以要先知道分数在真实素材上的分布，再拉成 0~1：

```
z = (raw − mu) / sigma        unit = 0.5 · (1 + tanh(gain · z))
```

`mu/sigma` 从哪来，取决于 `CALIB_MODE`：

- **`fixed`**（默认，第一次排练之前用）：用 `.env` 里的先验 `sigma=0.08`。
- **`fitted`**（正式用这个）：从排练日志拟合。
- **`running`**：在线自适应。做实验可以，**演出别用** —— 同一句话在第 2 分钟和第 20 分钟
  听起来会不一样，映射会在过程中漂移。

**排练本身就是语料来源，你不用另外写。** 每个片段的原始分数都写进了 `data/logs/session-*.jsonl`。
跑 3~4 场完整辩论（60~100 个人类回合）之后：

```bash
conda run -n ai-human-debate python scripts/fit_calibration.py
```

然后把 `.env` 的 `CALIB_MODE` 改成 `fitted` 重启。界面「统计」页会一直显示
"在用 sigma" 和 "实测 sigma" 的比值，差过一倍就该重新拟合了。

> ⚠️ **人和 AI 共用同一套 mu/sigma。** 分开归一化等于强行把两边拉到同一个分布中心，
> "AI 更去身、人更具身"这个对比会被数学抹平 —— 那正好是作品的论点。
> 代码里 `params_for()` 只读合并统计，per-speaker 统计纯粹用于展示。

「统计」页里每条轴的 **Cohen's d** 就是这个论点的量化读数：`|d| > 0.8` 说明两边真的分开了。

---

## 界面

顶部填辩题、选分边方式，点「开新一场」。立场条显示本场的辩题和两边的立场；
**没设辩题时会显示红字警告** —— 那种情况下 AI 拿不到立场，会顺着人的话往下写，两边论证同一边。

左边是辩论，每个回合下面挂四个小量表；右边四个页签：

- **本轮** —— 回合级双极量表 + 片段轨迹 + 片段读数表格 + 实际发给模型的 user message
- **统计** —— 人 vs AI 的原始分数分布对比（p10–p90 区间 + 均值）、Cohen's d、校准状态
- **轴诊断** —— d′ 和轴间余弦，排练时用来判断轴还能不能用
- **配置** —— 本次运行的全部参数、轴指纹、日志路径

极性由几何表示（相对中线向左/向右），颜色只表示说话人 —— 蓝 = 人，橙 = AI。

---

## 分边：抽签，人先说

辩题写成**陈述句**（`微信聊天应该用句号`，不是"该不该用句号"），正/反方才没有歧义。
`SIDE_ASSIGN=random` 时 AI 抽签定边、人拿另一边、人先说。界面顶部的立场条会显示抽签结果。

不建议让人先选：人一定选自己真信的那边，于是 **AI 永远是唱反调的那个** ——
这在每一场里都对 `affiliation` 轴造成同向偏差，"AI 更对抗"里就混进了分配机制的贡献。

抽签还有个副作用正好是要的：有时候人会被分到自己不信的一边。**一个人替自己不认同的
立场辩护时，`embodiment` 轴的读数非常值得看** —— 那是"人在说不属于自己的话"，
跟机器说话的状态之间的距离，比人真情实感时小得多。

立场条上那个「抽签 / 人选的边 / 配置写死」的标记如实反映本场的实际来源。
它是给观众看的一个断言，不能撒谎。

> **别加"不许被说服"这类防倒戈指令。** 如果 AI 在被反驳后转向对方立场，那不是 bug，
> 那正是这个作品要展示的东西 —— 它没有立场可失去。让它自然发生，`affiliation` 轴会记下来。

## prompt 的两个槽是分开的

| 槽 | 内容 | v1 状态 |
|---|---|---|
| `DEBATE_FRAME` | 任务约束：辩题 + 立场 | **有** —— 不给立场模型只会顺着人的话往下写 |
| `CHAT_LENGTH_HINT` | 任务约束：长度 | **有** |
| `CHAT_SYSTEM_PROMPT` | 人格注入 | **空** |

`辩题 X，你是反方` 跟长度约束同类；`你是温暖的、有自己看法的` 才是人格注入。
两者物理上都进 system message，但分开存、分开记日志、UI 上分开显示，随时可审计。
立场必须常驻 system message —— 只拼在第一条 user message 前面的话，到第十轮就被淹没了。

⚠️ **要如实记住的一个混淆：指定立场会把 AI 的 `affiliation` 往对抗端推、`certainty`
往断言端推。** 所以这两条轴的 Cohen's d 有一部分是指令造成的，不能当语域证据。
`embodiment` 和 `concreteness` 相对干净 —— **作品的主证据轴仍然是 `embodiment`**，
另外两条读作质感。

还有："没有 system prompt" ≠ "没有人格"。那些 hedging、那种平衡感、那种礼貌的对抗性，
全是 post-training 装进去的，不在 prompt 里。这反而让作品的论点更锋利 ——
企业给 AI 装身份主要发生在训练阶段，system prompt 只是最表层、最容易被看见的那一层。

做 A/B 对照版本时（刻意人格化 vs 刻意去人格化）填 `CHAT_SYSTEM_PROMPT`。

---

## 已经在记、但今天还没用的数据

人打字的那段时间不是需要遮盖的死区，那是全作品最人的信号 —— 停顿、犹豫、退格重写，
AI 没有这个东西，AI 的输出是瞬间成块的。前端已经在记每个人类回合的
`typing_ms / keystrokes / backspaces / pauses_over_2s / max_pause_ms` 并写进 JSONL。
今天不用它，但等做"停顿即信号"那套设计时，历史排练数据就已经在了，不用重排。

---

## 目录

```
anchors/axes.yaml      锚句集（唯一需要手工调的内容文件）
server/
  config.py            全部可调项，.env 覆盖
  segment.py           按标点切子句（宽度单位：全角 2，拉丁 1）
  embed.py             OpenAI embedding + 磁盘缓存
  axes.py              轴构造、投影、留一法诊断
  calibrate.py         归一化 + 在线统计
  chat.py              AI 辩手
  store.py             回合、统计、JSONL 落盘
  main.py              FastAPI
web/                   前端（无构建步骤，原生 JS）
scripts/
  build_axes.py        重建轴 + 质量报告
  fit_calibration.py   从排练日志拟合 mu/sigma
data/                  缓存 / 轴 / 校准 / 日志（gitignore）
```

## 下一步

1. 用真实 key 跑几场，看 AI 基线落在 `embodiment` 轴的什么位置
2. 按 d′ 和轴间余弦回头调锚句
3. `fit_calibration` → `CALIB_MODE=fitted`
4. 加 OSC 发送层：四个轴 → vocality / roughness / brightness / gridness 宏控制 → Max/MSP
