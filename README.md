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

两套界面共用同一个后端和同一场辩论：

- **`/` 工作界面** —— 全部数字、四个页签、校准与诊断。排练调参用这个。
- **`/live` 演出界面** —— 观众看的。深色、英文、只有气泡和粒子球，没有任何数字。
  每条消息旁一个粒子球代替头像：那一方的声音在播时球在动，静默时冻结。
  球的**运动性格**跟着 xfade 走 —— 人的球开场像机械（转动一格一格地跳），
  越辩越松弛成有机体；AI 的球反向。没人告诉观众这件事，它只是发生。
  打字的过程也在场上：开始输入时人的一侧出现一个无字的气泡，球随打字而动。

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

## OSC → Max/MSP

**Python 排时间表，Max 管声音。** 一个回合切成 N 个片段就是 N 组参数，全部瞬间发出去的话
Max 在 1 毫秒内收完、之后什么都没有 —— 没有可播放的时间轨迹。片段时长来自片段宽度，
那是 Python 侧的事实。反过来，插值必须在 Max 那边：Python 只发「目标值 + 滑行多久」，
由 `[line]` 去插，不做 100Hz 的推送。

发的是 **unit（0~1，已校准）**，不是 raw。校准层存在的意义就是产出这个值，
在 Max 里再缩放一次等于有两个地方管校准。轴 → 宏控制（vocality / roughness / …）
的映射放在 Max 这边，改起来不用重启 Python。

### 消息

| 地址 | 参数 |
|---|---|
| `/debate/{human,ai}/turn` | `turn_id` `side`(0=正 1=反) `n_segments` `total_ms` |
| `/debate/{human,ai}/seg` | `index` `embodiment` `certainty` `concreteness` `affiliation` `ramp_ms` `hold_ms` |
| `/debate/{human,ai}/end` | `turn_id` `interrupted`(0/1) |
| `/debate/idle` | `ms_since_last` |

按说话人分地址是因为这个作品就是两个声部 —— `[route /debate/human/seg /debate/ai/seg]`
接完就分好了。**时间参数排在四个轴值右边**是故意的：Max 的 `[unpack]` 从右往左出，
这样 `ramp_ms` 会先到 `[line]` 的右入口设好滑行时间，四个轴值随后进左入口触发滑行。
放前面的话每次滑行都会用上一个片段的时长。

### 调试顺序

**先跑扫描信号，再跑辩论。** 辩论输出是零散的、值域窄的，拿它调合成器等于盲调 ——
分不清"听不出变化"是映射没接对还是参数根本没动。

```bash
conda run -n ai-human-debate python scripts/osc_sweep.py
```

四条轴依次 0→1→0（三角波，端点正好踩到 0 和 1），Max 里四个数必须一个一个亮起来，
顺序和终端打印一致。对上了再跑辩论。服务跑起来之后，「配置」页也有一个「测试扫描」按钮。

确认 Python 这边发对了、不用先搭 Max：

```bash
conda run -n ai-human-debate python scripts/osc_monitor.py
```

同一个端口只能被一个程序占。要么先关 Max，要么让 monitor 听 7401 并把 `OSC_PORT` 也改成 7401。

- 监视器什么都没有 → Python 没发。看「配置」页的已发消息数、`OSC_ENABLED`
- 监视器有、Max 没有 → 端口被占 / `udpreceive` 端口号不对 / 防火墙
- 两边都有但数字不动 → Max 里 `route` 或 `unpack` 接错了

### Max patch

[max/debate-receive.maxpat](max/debate-receive.maxpat) 是一个最小接收端：
`udpreceive` → `route` → 两路 `unpack` → 每条轴一个 `[line]` + 数字框 + `[s human.embodiment]` 之类。
turn / end / idle 进 `[print debate]`，在 Max 控制台看。

## 整体结构：音色交叉渐变

**每个说话人 = 两台引擎（人机合成器 + 人声采样）的等功率混合，四台实例同时跑**：

```
人:  [人机合成器 ← human.*] ──┐
                              ├─ 交叉渐变(xfade) → 开合 → 输出
     [人声采样   ← human.*] ──┘

AI:  [人声采样   ← ai.*] ──┐
                            ├─ 交叉渐变(反向) → 开合 → 输出
     [人机合成器 ← ai.*] ──┘
```

不是在一个固定音色上做特征化妆，是**音色本体的交叉**：人从合成器出发，中段是两种音色的
叠加，终点完全是人声那套引擎；AI 镜像反向。中段某一刻两个说话人都处在半合成器半人声的
状态 —— **短暂地无法分辨谁是谁**，那正是这个作品要的画面。

### xfade —— 作品的头号参数

`/debate/{spk}/xfade`：0 = 全合成器音色，1 = 全人声音色。人从 `XFADE_START`（0.1）出发向 1 走，
AI 从 0.9 出发向 0 走，移动量 = drift 的 trend × `XFADE_GAIN`（3.0）。

接收 patch 把它换算成**等功率的 cos/sin 权重**（中段不塌音量坑，叠加感是"两个都在"），
以 `s {spk}.w.machine` / `s {spk}.w.voice` 分发，各引擎里 `[r] → [line~] → [*~]`
乘在开合增益上。每台引擎带 `loadmess` 默认权重（主引擎 0.99 / 另一半 0.16），
消息到达前就是开场状态。

移动量来自 drift（`server/drift.py`）：

```
trend = (1−HARD) × 置信度(轮数) × 证据 + HARD × 轮数斜坡
证据  = 0.65 × (离散度之比 − 0.5) + 0.35 × (embodiment 均值差 / 2)
```

离散度是主证据：人的读数铺得开（sd ≈ 0.18）、AI 挤在中间（sd ≈ 0.06）——
LLM 的低方差是 post-training 的产物，不是采样不够。方向由数据定；置信度只放大观察；
纯轮数斜坡（`DRIFT_HARD_WEIGHT`，默认 0.25）是断言，「统计」页会显示效果里
观察和断言各占多少。模拟走势（12 轮）：第 1 轮 0.14/0.86，第 4 轮进入"半半"叠加区，
第 10 轮后各自到达对方的音色。交叉太早/太晚调 `XFADE_GAIN` 和 `DRIFT_CONFIDENCE_K`。

四个引擎文件：

| 文件 | 角色 | 开场权重 |
|---|---|---|
| `human-machine-voice.maxpat` | 人的合成器引擎 | 0.99 |
| `human-voice-sample.maxpat` | 人的人声引擎（克隆） | 0.16 |
| `machine-human-voice-wired.maxpat` | AI 的人声引擎 | 0.99 |
| `ai-machine-voice.maxpat` | AI 的合成器引擎（克隆） | 0.16 |

四台同时打开才有交叉渐变。克隆版与原版共享 `r onoff` 和 `send~ L/R` 总线 ——
一个总开关同时启动两台人声引擎，输出自然混在同一个 master。

只有第一项是设计的 —— 为了观众三十秒内抓得住谁是谁。后两项完全由读数决定：
人越说越具身，他的合成器就越活；AI 一直 hedging，它的采样声就越僵。两条线靠近还是交叉，
是数据说了算，不是编出来的规则。**刻意没有加「上升慢下降快」之类的不对称** ——
那会把观察重新变回断言。

### 开合

任何时刻只有一方在前景，但**不发声的一方绝不静音**：降到 `OSC_RESIDUE_LEVEL`（默认 0.12，约 −18dB）。
交叉那一刻只有两个声音同时在场才听得见 —— 人耳对相隔几十秒的音色做不了比较。

残留期四条轴缓慢漂向 0.5（`OSC_DISSOLVE_MS`，默认 14 秒）：**说话者的身份特征在沉默里溶解，
只有持续说话才维持得住「你是谁」**。实现上不需要 Max 加逻辑 —— 就是一条 `index = -1`、
四轴全 0.5、`ramp_ms` 很长的 seg 消息，复用已有的 `line`。

| 消息 | 参数 |
|---|---|
| `/debate/{spk}/gate` | state(i 1=前景 0=残留) level(f) ramp_ms(i) |
| `/debate/{spk}/xfade` | 音色位置(f)：0=全合成器 1=全人声 |
| `/debate/{spk}/seg` 且 index = −1 | 溶解（四轴 0.5 + 长 ramp） |

### 每句触发：不需要新信号

`/debate/{spk}/seg` **本来就是一句一条** —— 一个片段就是一个子句。接收 patch 里已经加了
`[s human.trig]` / `[s ai.trig]`，是从 seg 的 unpack 第一个出口取的 bang。
vocal 那种「说了一句话」的采样层用它重触发，其它层继续走连续值。

副作用正好用得上：片段时长 800–8000ms，说短句时 bang 会挤在一起，采样叠加变密 ——
**语速直接变成密度**，不用额外映射。

### 打字层：第三个声部

[max/typing-layer.maxpat](max/typing-layer.maxpat)。**它不是加在另外两个声部上的效果。**
它不是人的「声音」，是人的**身体** —— 组织语言时的挣扎。挂到人的合成器上会把
「说了什么」和「多难说出口」混成一件事。而且它天然占着独立的时间槽：人打字时两个声部都在残留。

| 消息 | 声音 |
|---|---|
| `/debate/type/key` dt, elapsed | 一次按键一颗粒；间隔决定音高，打得快则紧而高 |
| `/debate/type/back` depth, elapsed | 下行的反向手势；连按越多起点越高越狠 |
| `/debate/type/pause` ms | 悬停的共振缓慢浮起并失谐，整层同时失焦 |
| `/debate/type/gate` 0/1 | 开始打字 / 按下发送 |

停顿不用猜阈值，也不会「到点了 pad 咣一下进来」—— 音量按停顿时长连续上浮，短停顿自然听不见。

> 通道是 WebSocket（`/ws/typing`），必须实时。原来的 `typing_ms` / `backspaces` 是回合结束后
> 随文本一起送上来的**汇总**，用打完字之后才到的数据做不出「正在犹豫」的声音。
>
> **AI 那侧没有这条通道，而且永远不会有。** 文本瞬间成块到达，无过程、无犹豫、无退格。
> 这个空缺是结构性的，不是映射出来的。

### 人声部：人机感合成器

[max/human-machine-voice.maxpat](max/human-machine-voice.maxpat)。和接收 patch 同时开着
（它靠 `[r human.*]` 拿值），点右下角喇叭开 DSP。

**这个声部的基线是机器**，只有当人说出真正有身体的话时才短暂地活过来 —— 那一刻就是作品要让人听见的东西。
所以 vocality 不是直接等于 embodiment，中间有一道阈值：

```
vocality = clip((embodiment − 0.45) × 2.2, 0, 1)
```

embodiment 到 0.45 以上才开始有活体感，0.9 才接近满值。人的读数大部分时间落在阈值以下，
声音就一直是机器；偶尔冲高的那一两个片段会明显"喘一口气"。这两个数写死在 patch 的 `expr` 里，
双击就能改 —— **这是全场最该用耳朵调的一个参数**，等你有了几场真实排练的 embodiment 分布再定。

四个宏：

| 宏 | 来源 | 作用 |
|---|---|---|
| vocality | embodiment（带阈值） | jitter、shimmer、滑音时间、锯齿嗡鸣量、降采样深度 |
| roughness | 1 − affiliation | FM 调制指数 + 调制比（整数谐波 → 非整数金属声） |
| brightness | concreteness | 音高高低、共振峰上移、低通截止（指数曲线 300Hz–12kHz） |
| gridness | certainty | 音高量化程度：锁半音 ↔ 自由滑 |

信号链：`音高（量化+滑音）→ jitter → 2-op FM + 锯齿层 → 三个静止共振峰 → 低通 → degrade~ → shimmer → 输出`

几个关键点：

- **微观不稳定就是活体感的全部。** 合成音之所以"死"，主要不是波形不对，是完全没有 jitter/shimmer。
  vocality=0 时这两段整个归零，音高变成绝对稳定 —— 那就是"人机"。
- **滑音时间也是人机线索**：机器 4ms 直接跳到新音高，活体 300ms 滑过去。
- **共振峰是静止的。** 真人说话时共振峰一直在动，这里只在片段边界跳一次。所以
  `OSC_RAMP_FRACTION` 本身就是一个人机旋钮 —— 调小 = 更机械的阶跃，调大 = 更连续的滑移。
- **FM 的两端都不是人声。** roughness=0 是整数谐波（电子管风琴般僵硬），=1 是非整数金属声，
  人声在中间那条窄带里。这正好对应"两种非人"。

现在是**持续的 drone**，没有按回合开合。这是故意的：连续音色空间更适合盲调，而且和
`/debate/idle` 那条静默线索是一路的。要做按回合起停，在接收 patch 里给 `/debate/human/turn`
和 `/end` 加一对 `[s human.gate]`，再在这边接一个包络。

### AI 声部：采样 + pfft~ 移调

[max/machine-human-voice-wired.maxpat](max/machine-human-voice-wired.maxpat)。
三层 `sfplay~` → `pfft~ pitch_shift` → `selector~`，第三个入口收**半音数**（内部 `/12` → `pow 2` 变成移调比）。

轴的接法：

| 轴 | 接到 |
|---|---|
| embodiment | 第一层音高（那组音阶不动），这一层始终满音量 |
| certainty | 第二层音高（`0 2 5 7 9 12 14 16 19 21`） |
| concreteness | 第三层音高（`-12 -10 -7 -5 -3 0 2 5 7 9`） |
| affiliation | 二、三层之间的平衡（对抗端第二层在前，亲和端第三层在前） |

连续值 → 索引的链路是 `[* 10.] → [int] → [clip 0 9] → [sel 0 1 … 9]`。
**`sel 0.1 0.2 …` 是精确匹配，OSC 来的 0.5734 永远命中不了** —— 必须先落到整数索引上。

两组音阶是同一个集合的不同子集（保持在调内，又不会三层平行移动），是起点，按耳朵改。

> 还有一个没用上的控制面：`[p]` 里的 `selector~ 5 1` 在五个不同 FFT 尺寸的 `pfft~` 之间切换
> （512 / 1024 / 2048 / 4096 / 8192）。小 FFT 保瞬态但颗粒感重、偏机械；大 FFT 平滑但相位涂抹。
> **这本身就是一条人↔机的赝像轴**，值得也挂到 embodiment 上 —— 同一条轴同时管音高和赝像质地，
> 比四条轴各管一摊更有说服力。要做的话在每个 `[p]` 里加一个 `[r ai.fft]` 接到那个 number，
> 父 patch 里 `embodiment → [* 4.] → [int] → [+ 1] → [s ai.fft]`。
> 注意切 `selector~` 会有跳变，是否可接受要听。

> 两个 patch 都是程序生成的，对象、端口号、连线都校验过（无孤立对象、无悬空输出），
> 但**我这边没有 Max，没法真正打开听**。声音上的取值（FM 指数 7、共振峰 620/1180/2600、
> 抖动 0.6%、shimmer 30%）是按经验给的起点，**一定要用耳朵调**。
> 最快的调法：先不开 OSC，直接拖那四个 flonum 从 0 拉到 1，听每一个单独在干什么。

### 时序

片段时长 = `宽度 × OSC_MS_PER_WIDTH × OSC_TIME_SCALE`，夹在 `[OSC_MIN_SEG_MS, OSC_MAX_SEG_MS]`。
默认 90ms/宽度 ≈ 一个 56 宽的子句 5 秒，接近朗读速度；嫌慢调 `OSC_TIME_SCALE`。
「本轮」页的片段表有每一片的实际时长，回合标题上有总时长。

**新回合撞上正在播的回合默认排队，不抢占**（`OSC_ON_OVERLAP=queue`）。抢占看着更实时，
实际是灾难：AI 的回复几秒就到，会把人那一轮的声音砍在第一个片段上 —— 人基本听不见，
而这个作品讲的就是人和 AI 的关系。队列不会无限涨：一个回合的音频十几秒，人打一轮字要几十秒。
真积压到 `OSC_QUEUE_MAX` 以上说明节奏已经失控，那时丢掉最旧的几轮反而是对的，
「配置」页会显示排队数和丢弃数。

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
  osc.py               OSC 发送 + 回合时间表（排队/抢占、静默心跳）
scripts/
  build_axes.py        重建轴 + 质量报告
  fit_calibration.py   从排练日志拟合 mu/sigma
  osc_sweep.py         四条轴依次 0→1→0，用来对着已知信号 patch Max
  osc_monitor.py       监听 OSC 并打印，确认 Python 发对了
max/
  debate-receive.maxpat      OSC 接收端（两个声部共用）
  human-machine-voice.maxpat 人声部的人机感合成器
data/                  缓存 / 轴 / 校准 / 日志（gitignore）
```

## 下一步

1. ~~跑 `osc_sweep.py`，在 Max 里把四条链路接对~~ ✓
2. ~~人声部的人机感合成器~~ ✓ —— 还需要用耳朵调参数
3. AI 声部：一个"特别像人"的音色。和人声部共用同一套宏，但基线落在轴的另一端 ——
   vocality 的阈值反过来（默认就活着，只有 embodiment 掉到很低才显出机械），
   加 breath noise、共振峰随片段移动、软起音
4. 跑几场真辩论，看 AI 基线落在 `embodiment` 轴的什么位置，据此定两边的阈值
5. `fit_calibration` → `CALIB_MODE=fitted`，让参数真正铺满可听范围
6. 接 `/debate/idle` + 打字时序，做"停顿即信号"那一层
