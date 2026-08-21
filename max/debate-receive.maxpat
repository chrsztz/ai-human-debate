{
 "patcher": {
  "fileversion": 1,
  "appversion": {
   "major": 9,
   "minor": 0,
   "revision": 9,
   "architecture": "x64",
   "modernui": 1
  },
  "classnamespace": "box",
  "rect": [
   686.0,
   95.0,
   792.0,
   790.0
  ],
  "gridsize": [
   15.0,
   15.0
  ],
  "boxes": [
   {
    "box": {
     "id": "obj-53",
     "maxclass": "toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      652.0,
      613.0,
      24.0,
      24.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-51",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      700.0,
      601.0,
      35.0,
      22.0
     ],
     "text": "open"
    }
   },
   {
    "box": {
     "id": "obj-47",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      683.0,
      638.0,
      69.0,
      22.0
     ],
     "text": "sfrecord~ 2"
    }
   },
   {
    "box": {
     "id": "obj-45",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      772.0,
      521.0,
      66.0,
      22.0
     ],
     "text": "receive~ R"
    }
   },
   {
    "box": {
     "id": "obj-15",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      683.0,
      527.0,
      64.0,
      22.0
     ],
     "text": "receive~ L"
    }
   },
   {
    "box": {
     "id": "obj-50",
     "maxclass": "toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      716.0,
      1586.0,
      24.0,
      24.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-48",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      516.0,
      1645.0,
      109.0,
      22.0
     ],
     "text": "3458"
    }
   },
   {
    "box": {
     "id": "obj-46",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      125.0,
      1592.0,
      109.0,
      22.0
     ],
     "text": "91 1674"
    }
   },
   {
    "box": {
     "id": "obj-44",
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      655.0,
      1614.0,
      50.0,
      22.0
     ],
     "text": "0"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-19",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      278.0,
      359.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-56",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      154.0,
      365.0,
      50.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "fontsize": 18.0,
     "id": "obj-1",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      15.0,
      300.0,
      32.0
     ],
     "text": "人机辩论 · OSC 接收"
    }
   },
   {
    "box": {
     "id": "obj-2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      40.0,
      1095.0,
      23.0
     ],
     "text": "四个轴的值 = unit，0~1，已经在 Python 侧校准过，这里不要再缩放。  ramp_ms 走 [line] 右入口（它在 unpack 里排在轴值右边，所以先到）。  turn / end / idle 都进右边的 [print debate]，看 Max 控制台。"
    }
   },
   {
    "box": {
     "id": "obj-3",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      76.0,
      900.0,
      23.0
     ],
     "text": "先跑  python scripts/osc_sweep.py  —— 四条轴会依次 0→1→0，下面八个数必须一个一个亮起来，顺序和终端打印的一致。对上了再去跑辩论。"
    }
   },
   {
    "box": {
     "id": "obj-4",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      30.0,
      112.0,
      130.0,
      22.0
     ],
     "text": "udpreceive 7400"
    }
   },
   {
    "box": {
     "id": "obj-5",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 3,
     "outlettype": [
      "",
      "",
      ""
     ],
     "patching_rect": [
      30.0,
      150.0,
      300.0,
      22.0
     ],
     "text": "route /debate/human/seg /debate/ai/seg"
    }
   },
   {
    "box": {
     "id": "obj-6",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      350.0,
      190.0,
      90.0,
      22.0
     ],
     "text": "print debate"
    }
   },
   {
    "box": {
     "fontsize": 14.0,
     "id": "obj-7",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      230.0,
      220.0,
      26.0
     ],
     "text": "人   /debate/human/seg"
    }
   },
   {
    "box": {
     "id": "obj-8",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 7,
     "outlettype": [
      "int",
      "float",
      "float",
      "float",
      "float",
      "int",
      "int"
     ],
     "patching_rect": [
      30.0,
      258.0,
      190.0,
      22.0
     ],
     "text": "unpack 0 0. 0. 0. 0. 0 0"
    }
   },
   {
    "box": {
     "id": "obj-9",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "具身 ↔ 去身"
    }
   },
   {
    "box": {
     "id": "obj-10",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      30.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-11",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      30.0,
      364.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-12",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      20.0,
      400.0,
      124.0,
      22.0
     ],
     "text": "s human.embodiment"
    }
   },
   {
    "box": {
     "id": "obj-13",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      155.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "确定 ↔ 对冲"
    }
   },
   {
    "box": {
     "id": "obj-14",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      155.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "id": "obj-16",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      154.0,
      400.0,
      110.0,
      22.0
     ],
     "text": "s human.certainty"
    }
   },
   {
    "box": {
     "id": "obj-17",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      280.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "具体 ↔ 抽象"
    }
   },
   {
    "box": {
     "id": "obj-18",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      280.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "id": "obj-20",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      280.0,
      392.0,
      129.0,
      22.0
     ],
     "text": "s human.concreteness"
    }
   },
   {
    "box": {
     "id": "obj-21",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      405.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "亲和 ↔ 对抗"
    }
   },
   {
    "box": {
     "id": "obj-22",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      405.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-23",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      406.0,
      351.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-24",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      405.0,
      380.0,
      110.0,
      22.0
     ],
     "text": "s human.affiliation"
    }
   },
   {
    "box": {
     "fontsize": 14.0,
     "id": "obj-25",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      560.0,
      230.0,
      220.0,
      22.0
     ],
     "text": "AI   /debate/ai/seg"
    }
   },
   {
    "box": {
     "id": "obj-26",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 7,
     "outlettype": [
      "int",
      "float",
      "float",
      "float",
      "float",
      "int",
      "int"
     ],
     "patching_rect": [
      560.0,
      258.0,
      190.0,
      22.0
     ],
     "text": "unpack 0 0. 0. 0. 0. 0 0"
    }
   },
   {
    "box": {
     "id": "obj-27",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      560.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "具身 ↔ 去身"
    }
   },
   {
    "box": {
     "id": "obj-28",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      560.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-29",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      560.0,
      359.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-30",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      560.0,
      388.0,
      110.0,
      22.0
     ],
     "text": "s ai.embodiment"
    }
   },
   {
    "box": {
     "id": "obj-31",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      685.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "确定 ↔ 对冲"
    }
   },
   {
    "box": {
     "id": "obj-32",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      685.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-33",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      685.0,
      352.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-34",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      685.0,
      388.0,
      110.0,
      22.0
     ],
     "text": "s ai.certainty"
    }
   },
   {
    "box": {
     "id": "obj-35",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      810.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "具体 ↔ 抽象"
    }
   },
   {
    "box": {
     "id": "obj-36",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      810.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-37",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      812.0,
      355.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-38",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      810.0,
      380.0,
      110.0,
      22.0
     ],
     "text": "s ai.concreteness"
    }
   },
   {
    "box": {
     "id": "obj-39",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      935.0,
      300.0,
      110.0,
      23.0
     ],
     "text": "亲和 ↔ 对抗"
    }
   },
   {
    "box": {
     "id": "obj-40",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "patching_rect": [
      935.0,
      324.0,
      60.0,
      22.0
     ],
     "text": "line"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-41",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      936.0,
      357.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-42",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      935.0,
      388.0,
      110.0,
      22.0
     ],
     "text": "s ai.affiliation"
    }
   },
   {
    "box": {
     "id": "obj-43",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      30.0,
      424.0,
      1110.0,
      23.0
     ],
     "text": "接下去：把 [r human.embodiment] / [r ai.embodiment] … 拿到你的合成器那边，扇出到 formant 深度、vibrato 量、breath noise、jitter/shimmer 等等。轴 → 宏控制的映射放在 Max 这边改，不用重启 Python。"
    }
   },
   {
    "box": {
     "id": "obj-401",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40.0,
      1166.0,
      460.0,
      23.0
     ],
     "text": "── 开合 / 基线 / 每句触发 / 打字层 ──────────"
    }
   },
   {
    "box": {
     "id": "obj-402",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 3,
     "outlettype": [
      "",
      "",
      ""
     ],
     "patching_rect": [
      40.0,
      1280.0,
      338.0,
      22.0
     ],
     "text": "route /debate/human/gate /debate/ai/gate"
    }
   },
   {
    "box": {
     "id": "obj-403",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "int",
      "float",
      "int"
     ],
     "patching_rect": [
      45.0,
      1310.0,
      122.0,
      22.0
     ],
     "text": "unpack 0 0. 0"
    }
   },
   {
    "box": {
     "id": "obj-404",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      -30.0,
      1358.0,
      162.0,
      22.0
     ],
     "text": "s human.gate.state"
    }
   },
   {
    "box": {
     "id": "obj-405",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      150.0,
      1348.0,
      106.0,
      22.0
     ],
     "text": "pack 0. 100"
    }
   },
   {
    "box": {
     "id": "obj-406",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      150.0,
      1381.0,
      162.0,
      22.0
     ],
     "text": "s human.gate.level"
    }
   },
   {
    "box": {
     "id": "obj-407",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "outlettype": [
      "int",
      "float",
      "int"
     ],
     "patching_rect": [
      290.0,
      1310.0,
      122.0,
      22.0
     ],
     "text": "unpack 0 0. 0"
    }
   },
   {
    "box": {
     "id": "obj-408",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      290.0,
      1340.0,
      138.0,
      22.0
     ],
     "text": "s ai.gate.state"
    }
   },
   {
    "box": {
     "id": "obj-409",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      400.0,
      1340.0,
      106.0,
      22.0
     ],
     "text": "pack 0. 100"
    }
   },
   {
    "box": {
     "id": "obj-410",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      400.0,
      1370.0,
      138.0,
      22.0
     ],
     "text": "s ai.gate.level"
    }
   },
   {
    "box": {
     "id": "obj-411",
     "linecount": 2,
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      540.0,
      1310.0,
      521.0,
      37.0
     ],
     "text": "gate.level 是 [目标, 滑行ms] 的列表，直接喂 [line~] → 总线 [*~]。不发声的一方降到 0.12 而不是 0：交叉那一刻要两个声音同时在场才听得见。"
    }
   },
   {
    "box": {
     "id": "obj-424",
     "maxclass": "newobj",
     "numinlets": 5,
     "numoutlets": 5,
     "outlettype": [
      "",
      "",
      "",
      "",
      ""
     ],
     "patching_rect": [
      40.0,
      1554.0,
      634.0,
      22.0
     ],
     "text": "route /debate/type/key /debate/type/back /debate/type/pause /debate/type/gate"
    }
   },
   {
    "box": {
     "id": "obj-425",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      40.0,
      1600.0,
      98.0,
      22.0
     ],
     "text": "unpack 0 0"
    }
   },
   {
    "box": {
     "id": "obj-426",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      10.5,
      1634.0,
      105.0,
      22.0
     ],
     "text": "s type.key.dt"
    }
   },
   {
    "box": {
     "id": "obj-427",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      126.0,
      1634.0,
      107.0,
      22.0
     ],
     "text": "s type.key.elapsed"
    }
   },
   {
    "box": {
     "id": "obj-428",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      40.0,
      1673.0,
      46.0,
      22.0
     ],
     "text": "t b"
    }
   },
   {
    "box": {
     "id": "obj-429",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40.0,
      1709.0,
      98.0,
      22.0
     ],
     "text": "s type.key"
    }
   },
   {
    "box": {
     "id": "obj-430",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "int",
      "int"
     ],
     "patching_rect": [
      270.0,
      1600.0,
      98.0,
      22.0
     ],
     "text": "unpack 0 0"
    }
   },
   {
    "box": {
     "id": "obj-431",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      270.0,
      1630.0,
      105.0,
      22.0
     ],
     "text": "s type.back.depth"
    }
   },
   {
    "box": {
     "id": "obj-432",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      380.0,
      1630.0,
      115.0,
      22.0
     ],
     "text": "s type.back.elapsed"
    }
   },
   {
    "box": {
     "id": "obj-433",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      270.0,
      1673.0,
      46.0,
      22.0
     ],
     "text": "t b"
    }
   },
   {
    "box": {
     "id": "obj-434",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      270.0,
      1709.0,
      106.0,
      22.0
     ],
     "text": "s type.back"
    }
   },
   {
    "box": {
     "id": "obj-435",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      501.0,
      1600.0,
      114.0,
      22.0
     ],
     "text": "s type.pause"
    }
   },
   {
    "box": {
     "id": "obj-436",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      739.0,
      1677.0,
      106.0,
      22.0
     ],
     "text": "s type.gate"
    }
   },
   {
    "box": {
     "id": "obj-437",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40.0,
      1720.0,
      1036.0,
      23.0
     ],
     "text": "打字层 = 第三个声部，不是加在前两个上的效果。它不是人的『声音』，是人的『身体』—— 组织语言时的挣扎。AI 那侧没有这条通道，而且永远不会有：文本瞬间成块到达，无过程、无犹豫。"
    }
   },
   {
    "box": {
     "id": "obj-501",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      40.0,
      1200.0,
      46.0,
      22.0
     ],
     "text": "t b"
    }
   },
   {
    "box": {
     "id": "obj-502",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40.0,
      1228.0,
      114.0,
      22.0
     ],
     "text": "s human.trig"
    }
   },
   {
    "box": {
     "id": "obj-503",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      110.0,
      1200.0,
      654.0,
      23.0
     ],
     "text": "human: 一个片段 = 一个子句 = 说了一句。vocal 那种采样层用它重触发，其余层继续走连续值 —— 不需要新的 OSC 消息"
    }
   },
   {
    "box": {
     "id": "obj-504",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      290.0,
      1200.0,
      46.0,
      22.0
     ],
     "text": "t b"
    }
   },
   {
    "box": {
     "id": "obj-505",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      290.0,
      1228.0,
      90.0,
      22.0
     ],
     "text": "s ai.trig"
    }
   },
   {
    "box": {
     "id": "obj-506",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      360.0,
      1200.0,
      627.0,
      23.0
     ],
     "text": "ai: 一个片段 = 一个子句 = 说了一句。vocal 那种采样层用它重触发，其余层继续走连续值 —— 不需要新的 OSC 消息"
    }
   },
   {
    "box": {
     "id": "obj-601",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40.0,
      1526.0,
      420.0,
      23.0
     ],
     "text": "── 声部位置（作品的头号参数）──────────"
    }
   },
   {
    "box": {
     "id": "obj-701",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      40,
      1526,
      440,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "── 音色交叉渐变（作品的头号参数）─────────"
    }
   },
   {
    "box": {
     "id": "obj-702",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 3,
     "patching_rect": [
      40,
      1560,
      354,
      22
     ],
     "outlettype": [
      "",
      "",
      ""
     ],
     "text": "route /debate/human/xfade /debate/ai/xfade"
    }
   },
   {
    "box": {
     "id": "obj-703",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "patching_rect": [
      40,
      1590,
      58,
      22
     ],
     "outlettype": [
      "",
      ""
     ],
     "text": "t f f"
    }
   },
   {
    "box": {
     "id": "obj-704",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      40,
      1620,
      194,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "expr cos($f1 * 1.5708)"
    }
   },
   {
    "box": {
     "id": "obj-705",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      40,
      1648,
      114,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "pack 0. 3000"
    }
   },
   {
    "box": {
     "id": "obj-706",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      40,
      1676,
      154,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "s human.w.machine"
    }
   },
   {
    "box": {
     "id": "obj-707",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      250,
      1620,
      194,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "expr sin($f1 * 1.5708)"
    }
   },
   {
    "box": {
     "id": "obj-708",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      250,
      1648,
      114,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "pack 0. 3000"
    }
   },
   {
    "box": {
     "id": "obj-709",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      250,
      1676,
      138,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "s human.w.voice"
    }
   },
   {
    "box": {
     "id": "obj-710",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 2,
     "patching_rect": [
      470,
      1590,
      58,
      22
     ],
     "outlettype": [
      "",
      ""
     ],
     "text": "t f f"
    }
   },
   {
    "box": {
     "id": "obj-711",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      470,
      1620,
      194,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "expr cos($f1 * 1.5708)"
    }
   },
   {
    "box": {
     "id": "obj-712",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      470,
      1648,
      114,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "pack 0. 3000"
    }
   },
   {
    "box": {
     "id": "obj-713",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      470,
      1676,
      130,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "s ai.w.machine"
    }
   },
   {
    "box": {
     "id": "obj-714",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      680,
      1620,
      194,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "expr sin($f1 * 1.5708)"
    }
   },
   {
    "box": {
     "id": "obj-715",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      680,
      1648,
      114,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "pack 0. 3000"
    }
   },
   {
    "box": {
     "id": "obj-716",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      680,
      1676,
      114,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "s ai.w.voice"
    }
   },
   {
    "box": {
     "id": "obj-717",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      40,
      1706,
      900,
      40
     ],
     "text": "xfade：0 = 全合成器音色，1 = 全人声采样音色。每个说话人两台引擎同时跑，这里换算成等功率的 cos/sin 权重（中段不塌音量坑，叠加感是『两个都在』）。已打包 [目标, 3000ms]，引擎里直接喂 [line~]。"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "destination": [
      "obj-11",
      0
     ],
     "source": [
      "obj-10",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-12",
      0
     ],
     "source": [
      "obj-11",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-56",
      0
     ],
     "source": [
      "obj-14",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-47",
      0
     ],
     "source": [
      "obj-15",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-19",
      0
     ],
     "source": [
      "obj-18",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-20",
      0
     ],
     "source": [
      "obj-19",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-23",
      0
     ],
     "source": [
      "obj-22",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-24",
      0
     ],
     "source": [
      "obj-23",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-28",
      1
     ],
     "order": 3,
     "source": [
      "obj-26",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-28",
      0
     ],
     "source": [
      "obj-26",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-32",
      1
     ],
     "order": 2,
     "source": [
      "obj-26",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-32",
      0
     ],
     "source": [
      "obj-26",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-36",
      1
     ],
     "order": 1,
     "source": [
      "obj-26",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-36",
      0
     ],
     "source": [
      "obj-26",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-40",
      1
     ],
     "order": 0,
     "source": [
      "obj-26",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-40",
      0
     ],
     "source": [
      "obj-26",
      4
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-504",
      0
     ],
     "source": [
      "obj-26",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-29",
      0
     ],
     "source": [
      "obj-28",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-30",
      0
     ],
     "source": [
      "obj-29",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-33",
      0
     ],
     "source": [
      "obj-32",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-34",
      0
     ],
     "source": [
      "obj-33",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-37",
      0
     ],
     "source": [
      "obj-36",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-38",
      0
     ],
     "source": [
      "obj-37",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-402",
      0
     ],
     "order": 3,
     "source": [
      "obj-4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-424",
      0
     ],
     "order": 1,
     "source": [
      "obj-4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-5",
      0
     ],
     "order": 4,
     "source": [
      "obj-4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-41",
      0
     ],
     "source": [
      "obj-40",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-403",
      0
     ],
     "source": [
      "obj-402",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-407",
      0
     ],
     "source": [
      "obj-402",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-404",
      0
     ],
     "source": [
      "obj-403",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-405",
      1
     ],
     "source": [
      "obj-403",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-405",
      0
     ],
     "source": [
      "obj-403",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-406",
      0
     ],
     "source": [
      "obj-405",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-408",
      0
     ],
     "source": [
      "obj-407",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-409",
      1
     ],
     "source": [
      "obj-407",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-409",
      0
     ],
     "source": [
      "obj-407",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-410",
      0
     ],
     "source": [
      "obj-409",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-42",
      0
     ],
     "source": [
      "obj-41",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-425",
      0
     ],
     "order": 1,
     "source": [
      "obj-424",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-430",
      0
     ],
     "source": [
      "obj-424",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-435",
      0
     ],
     "order": 1,
     "source": [
      "obj-424",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-436",
      0
     ],
     "order": 0,
     "source": [
      "obj-424",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-44",
      1
     ],
     "order": 2,
     "source": [
      "obj-424",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-46",
      1
     ],
     "order": 0,
     "source": [
      "obj-424",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-48",
      1
     ],
     "order": 0,
     "source": [
      "obj-424",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-50",
      0
     ],
     "order": 1,
     "source": [
      "obj-424",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-426",
      0
     ],
     "source": [
      "obj-425",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-427",
      0
     ],
     "source": [
      "obj-425",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-429",
      0
     ],
     "source": [
      "obj-428",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-431",
      0
     ],
     "source": [
      "obj-430",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-432",
      0
     ],
     "source": [
      "obj-430",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-434",
      0
     ],
     "source": [
      "obj-433",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-47",
      1
     ],
     "source": [
      "obj-45",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-26",
      0
     ],
     "source": [
      "obj-5",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-6",
      0
     ],
     "source": [
      "obj-5",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-8",
      0
     ],
     "source": [
      "obj-5",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-502",
      0
     ],
     "source": [
      "obj-501",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-505",
      0
     ],
     "source": [
      "obj-504",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-47",
      0
     ],
     "source": [
      "obj-51",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-47",
      0
     ],
     "source": [
      "obj-53",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-16",
      0
     ],
     "source": [
      "obj-56",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-10",
      1
     ],
     "order": 3,
     "source": [
      "obj-8",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-10",
      0
     ],
     "source": [
      "obj-8",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-14",
      1
     ],
     "order": 2,
     "source": [
      "obj-8",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-14",
      0
     ],
     "source": [
      "obj-8",
      2
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-18",
      1
     ],
     "order": 1,
     "source": [
      "obj-8",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-18",
      0
     ],
     "source": [
      "obj-8",
      3
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-22",
      1
     ],
     "order": 0,
     "source": [
      "obj-8",
      5
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-22",
      0
     ],
     "source": [
      "obj-8",
      4
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-501",
      0
     ],
     "source": [
      "obj-8",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-702",
      0
     ],
     "source": [
      "obj-4",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-703",
      0
     ],
     "source": [
      "obj-702",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-704",
      0
     ],
     "source": [
      "obj-703",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-705",
      0
     ],
     "source": [
      "obj-704",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-706",
      0
     ],
     "source": [
      "obj-705",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-707",
      0
     ],
     "source": [
      "obj-703",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-708",
      0
     ],
     "source": [
      "obj-707",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-709",
      0
     ],
     "source": [
      "obj-708",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-710",
      0
     ],
     "source": [
      "obj-702",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-711",
      0
     ],
     "source": [
      "obj-710",
      1
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-712",
      0
     ],
     "source": [
      "obj-711",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-713",
      0
     ],
     "source": [
      "obj-712",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-714",
      0
     ],
     "source": [
      "obj-710",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-715",
      0
     ],
     "source": [
      "obj-714",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-716",
      0
     ],
     "source": [
      "obj-715",
      0
     ]
    }
   }
  ],
  "dependency_cache": [],
  "autosave": 0
 }
}