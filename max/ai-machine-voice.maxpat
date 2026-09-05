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
   34.0,
   179.0,
   886.0,
   769.0
  ],
  "gridsize": [
   15.0,
   15.0
  ],
  "boxes": [
   {
    "box": {
     "format": 6,
     "id": "obj-106",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      719.0,
      1024.0,
      50.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-99",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      445.0,
      1007.0,
      50.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-93",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      503.0,
      1176.0,
      42.0,
      22.0
     ],
     "text": "r onoff"
    }
   },
   {
    "box": {
     "id": "obj-89",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      281.0,
      1540.0,
      54.0,
      22.0
     ],
     "text": "send~ R"
    }
   },
   {
    "box": {
     "id": "obj-90",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      213.0,
      1540.0,
      52.0,
      22.0
     ],
     "text": "send~ L"
    }
   },
   {
    "box": {
     "id": "obj-101",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      983.0,
      302.0,
      39.0,
      22.0
     ],
     "text": "/ 8."
    }
   },
   {
    "box": {
     "id": "obj-102",
     "maxclass": "toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      983.0,
      217.0,
      24.0,
      24.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-103",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      983.0,
      249.0,
      63.0,
      22.0
     ],
     "text": "metro 100"
    }
   },
   {
    "box": {
     "id": "obj-104",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      983.0,
      278.0,
      66.0,
      22.0
     ],
     "text": "random 10"
    }
   },
   {
    "box": {
     "id": "obj-100",
     "linecount": 2,
     "maxclass": "message",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      628.0,
      1176.0,
      50.0,
      35.0
     ],
     "text": "0.01 4000"
    }
   },
   {
    "box": {
     "id": "obj-98",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      727.0,
      318.0,
      39.0,
      22.0
     ],
     "text": "/ 80."
    }
   },
   {
    "box": {
     "id": "obj-97",
     "maxclass": "toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      727.0,
      233.0,
      24.0,
      24.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-95",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "bang"
     ],
     "patching_rect": [
      727.0,
      265.0,
      63.0,
      22.0
     ],
     "text": "metro 100"
    }
   },
   {
    "box": {
     "id": "obj-94",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      727.0,
      294.0,
      66.0,
      22.0
     ],
     "text": "random 10"
    }
   },
   {
    "box": {
     "id": "obj-92",
     "maxclass": "toggle",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "int"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      480.0,
      1209.0,
      24.0,
      24.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-91",
     "lastchannelcount": 0,
     "maxclass": "live.gain~",
     "numinlets": 2,
     "numoutlets": 5,
     "outlettype": [
      "signal",
      "signal",
      "",
      "float",
      "list"
     ],
     "parameter_enable": 1,
     "patching_rect": [
      21.0,
      1384.0,
      48.0,
      136.0
     ],
     "saved_attribute_attributes": {
      "valueof": {
       "parameter_initial": [
        -10.508158129718337
       ],
       "parameter_initial_enable": 1,
       "parameter_longname": "live.gain~",
       "parameter_mmax": 6.0,
       "parameter_mmin": -70.0,
       "parameter_modmode": 3,
       "parameter_shortname": "live.gain~",
       "parameter_type": 0,
       "parameter_unitstyle": 4
      }
     },
     "varname": "live.gain~"
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
      24.0,
      12.0,
      320.0,
      32.0
     ],
     "text": "AI 的机器引擎 · 交叉渐变的另一半"
    }
   },
   {
    "box": {
     "id": "obj-2",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      36.0,
      1000.0,
      23.0
     ],
     "text": "接 /debate/human/* —— 需要 debate-receive.maxpat 同时开着（它负责收 OSC 并 send 出来）。点右下角喇叭开 DSP。四个宏都能手动拖，用来盲调音色。"
    }
   },
   {
    "box": {
     "id": "obj-3",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      56.0,
      1029.0,
      23.0
     ],
     "text": "这个声部的基线是机器：音高量化、无微观抖动、共振峰静止、采样率劣化。只有当人说出真正有身体的话（embodiment 冲高）时，它才短暂地“活”过来 —— 这就是作品要让人听见的那一刻。"
    }
   },
   {
    "box": {
     "fontsize": 14.0,
     "id": "obj-4",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      108.0,
      300.0,
      26.0
     ],
     "text": "宏控制（轴 → 音色）"
    }
   },
   {
    "box": {
     "id": "obj-5",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      134.0,
      250.0,
      23.0
     ],
     "text": "vocality ← embodiment（带阈值）"
    }
   },
   {
    "box": {
     "id": "obj-6",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      156.0,
      160.0,
      22.0
     ],
     "text": "r ai.embodiment"
    }
   },
   {
    "box": {
     "id": "obj-7",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      190.0,
      156.0,
      87.0,
      22.0
     ],
     "text": "loadmess 0.81"
    }
   },
   {
    "box": {
     "bgcolor": [
      0.482352941176471,
      0.431372549019608,
      0.117647058823529,
      1.0
     ],
     "format": 6,
     "id": "obj-8",
     "maxclass": "flonum",
     "maximum": 1.0,
     "minimum": 0.0,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      24.0,
      182.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-9",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      208.0,
      344.0,
      22.0
     ],
     "text": "expr min(1.\\, max(0.\\, ($f1 - 0.45) * 2.2))"
    }
   },
   {
    "box": {
     "id": "obj-10",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      190.0,
      208.0,
      681.0,
      23.0
     ],
     "text": "阈值 0.45 / 增益 2.2 —— 人的基线本来就该待在机器端，embodiment 要冲到 0.45 以上才开始活。双击这个 expr 改这两个数。"
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
      24.0,
      234.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-12",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      260.0,
      96.0,
      22.0
     ],
     "text": "pack 0. 20"
    }
   },
   {
    "box": {
     "id": "obj-13",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      24.0,
      286.0,
      56.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-14",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      330.0,
      134.0,
      250.0,
      20.0
     ],
     "text": "roughness ← 1 − affiliation"
    }
   },
   {
    "box": {
     "id": "obj-15",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      330.0,
      116.0,
      168.0,
      22.0
     ],
     "text": "r ai.affiliation"
    }
   },
   {
    "box": {
     "id": "obj-16",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      500.0,
      156.0,
      80.0,
      22.0
     ],
     "text": "loadmess 0.9"
    }
   },
   {
    "box": {
     "id": "obj-17",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "float"
     ],
     "patching_rect": [
      330.0,
      182.0,
      56.0,
      22.0
     ],
     "text": "!- 1."
    }
   },
   {
    "box": {
     "bgcolor": [
      0.482352941176471,
      0.431372549019608,
      0.117647058823529,
      1.0
     ],
     "format": 6,
     "id": "obj-18",
     "maxclass": "flonum",
     "maximum": 1.0,
     "minimum": 0.0,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      330.0,
      234.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-19",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      330.0,
      260.0,
      96.0,
      22.0
     ],
     "text": "pack 0. 20"
    }
   },
   {
    "box": {
     "id": "obj-20",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      330.0,
      286.0,
      56.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-21",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      620.0,
      134.0,
      250.0,
      20.0
     ],
     "text": "brightness ← concreteness"
    }
   },
   {
    "box": {
     "id": "obj-22",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      620.0,
      156.0,
      176.0,
      22.0
     ],
     "text": "r ai.concreteness"
    }
   },
   {
    "box": {
     "id": "obj-23",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      790.0,
      156.0,
      112.0,
      22.0
     ],
     "text": "loadmess 0."
    }
   },
   {
    "box": {
     "bgcolor": [
      0.498039215686275,
      0.517647058823529,
      0.058823529411765,
      1.0
     ],
     "format": 6,
     "id": "obj-24",
     "maxclass": "flonum",
     "maximum": 1.0,
     "minimum": 0.0,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      620.0,
      234.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-25",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      900.0,
      134.0,
      250.0,
      20.0
     ],
     "text": "gridness ← certainty"
    }
   },
   {
    "box": {
     "id": "obj-26",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      900.0,
      156.0,
      152.0,
      22.0
     ],
     "text": "r ai.certainty"
    }
   },
   {
    "box": {
     "id": "obj-27",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      1070.0,
      156.0,
      112.0,
      22.0
     ],
     "text": "loadmess 0.5"
    }
   },
   {
    "box": {
     "bgcolor": [
      0.498039215686275,
      0.517647058823529,
      0.058823529411765,
      1.0
     ],
     "format": 6,
     "id": "obj-28",
     "maxclass": "flonum",
     "maximum": 1.0,
     "minimum": 0.0,
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      900.0,
      234.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-29",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      27.5,
      338.0,
      1022.0,
      23.0
     ],
     "text": "音高：abstract→低沉，concrete→高而聚焦。gridness 决定量化程度（锁半音 ↔ 自由滑）。滑音时间由 vocality 决定：机器 4ms 直接跳，活体 300ms 滑过去 —— 这是最强的人机线索之一。"
    }
   },
   {
    "box": {
     "id": "obj-30",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      360.0,
      176.0,
      22.0
     ],
     "text": "expr 34. + $f1 * 31."
    }
   },
   {
    "box": {
     "id": "obj-31",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      386.0,
      368.0,
      22.0
     ],
     "text": "expr $f2 * int($f1 + 0.5) + (1. - $f2) * $f1"
    }
   },
   {
    "box": {
     "id": "obj-32",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      412.0,
      48.0,
      22.0
     ],
     "text": "mtof"
    }
   },
   {
    "box": {
     "id": "obj-33",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      480.0,
      386.0,
      176.0,
      22.0
     ],
     "text": "expr 4. + $f1 * 300."
    }
   },
   {
    "box": {
     "id": "obj-34",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      438.0,
      88.0,
      22.0
     ],
     "text": "pack 0. 4"
    }
   },
   {
    "box": {
     "id": "obj-35",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      24.0,
      464.0,
      56.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-36",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      72.0,
      495.0,
      1000.0,
      23.0
     ],
     "text": "微观不稳定 —— 合成音之所以“死”，主要不是波形不对，是完全没有微观抖动。vocality=0 时这一段整个归零，音高变成绝对稳定，那就是“人机”。"
    }
   },
   {
    "box": {
     "id": "obj-37",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      60.0,
      520.0,
      88.0,
      22.0
     ],
     "text": "rand~ 5.5"
    }
   },
   {
    "box": {
     "id": "obj-38",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      166.0,
      520.0,
      80.0,
      22.0
     ],
     "text": "*~ 0.006"
    }
   },
   {
    "box": {
     "id": "obj-39",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      61.0,
      548.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-40",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      60.0,
      574.0,
      56.0,
      22.0
     ],
     "text": "+~ 1."
    }
   },
   {
    "box": {
     "id": "obj-41",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      20.0,
      605.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-42",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      636.0,
      1000.0,
      23.0
     ],
     "text": "声源：2-op FM。roughness 同时推高调制指数和调制比 —— 从整数谐波（电子管风琴般僵硬）走向非整数（金属、失谐）。两端都不是人声，人声在中间那条窄带里。"
    }
   },
   {
    "box": {
     "id": "obj-43",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      660.0,
      72.0,
      22.0
     ],
     "text": "*~ 1.51"
    }
   },
   {
    "box": {
     "id": "obj-44",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      686.0,
      56.0,
      22.0
     ],
     "text": "+~ 1."
    }
   },
   {
    "box": {
     "id": "obj-45",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      712.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-46",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      738.0,
      64.0,
      22.0
     ],
     "text": "cycle~"
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
      200.0,
      686.0,
      56.0,
      22.0
     ],
     "text": "*~ 7."
    }
   },
   {
    "box": {
     "id": "obj-48",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      200.0,
      738.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-49",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      200.0,
      764.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-50",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      790.0,
      46.0,
      22.0
     ],
     "text": "+~"
    }
   },
   {
    "box": {
     "id": "obj-51",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      816.0,
      64.0,
      22.0
     ],
     "text": "cycle~"
    }
   },
   {
    "box": {
     "id": "obj-52",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      400.0,
      660.0,
      72.0,
      22.0
     ],
     "text": "phasor~"
    }
   },
   {
    "box": {
     "id": "obj-53",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      400.0,
      686.0,
      64.0,
      22.0
     ],
     "text": "-~ 0.5"
    }
   },
   {
    "box": {
     "id": "obj-54",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      400.0,
      712.0,
      64.0,
      22.0
     ],
     "text": "*~ 1.6"
    }
   },
   {
    "box": {
     "id": "obj-55",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      540.0,
      660.0,
      64.0,
      22.0
     ],
     "text": "*~ -1."
    }
   },
   {
    "box": {
     "id": "obj-56",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      540.0,
      686.0,
      56.0,
      22.0
     ],
     "text": "+~ 1."
    }
   },
   {
    "box": {
     "id": "obj-57",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      400.0,
      764.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-58",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      848.0,
      46.0,
      22.0
     ],
     "text": "+~"
    }
   },
   {
    "box": {
     "id": "obj-59",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      886.0,
      1000.0,
      23.0
     ],
     "text": "共振峰：三个静止的 reson~。真人说话时共振峰一直在动，这里只在片段边界上跳一次 —— 所以 OSC 的 ramp_ms（OSC_RAMP_FRACTION）本身就是一个人机旋钮。"
    }
   },
   {
    "box": {
     "id": "obj-60",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      910.0,
      256.0,
      22.0
     ],
     "text": "expr 620. * (1. + $f1 * 0.55)"
    }
   },
   {
    "box": {
     "id": "obj-61",
     "maxclass": "newobj",
     "numinlets": 4,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      936.0,
      184.0,
      22.0
     ],
     "text": "reson~ 1.4 620. 11."
    }
   },
   {
    "box": {
     "id": "obj-62",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      284.0,
      910.0,
      264.0,
      22.0
     ],
     "text": "expr 1180. * (1. + $f1 * 0.55)"
    }
   },
   {
    "box": {
     "id": "obj-63",
     "maxclass": "newobj",
     "numinlets": 4,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      284.0,
      936.0,
      184.0,
      22.0
     ],
     "text": "reson~ 1.4 1180. 9."
    }
   },
   {
    "box": {
     "id": "obj-64",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      544.0,
      910.0,
      264.0,
      22.0
     ],
     "text": "expr 2600. * (1. + $f1 * 0.55)"
    }
   },
   {
    "box": {
     "id": "obj-65",
     "maxclass": "newobj",
     "numinlets": 4,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      544.0,
      966.0,
      184.0,
      22.0
     ],
     "text": "reson~ 1.4 2600. 7."
    }
   },
   {
    "box": {
     "id": "obj-66",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      966.0,
      46.0,
      22.0
     ],
     "text": "+~"
    }
   },
   {
    "box": {
     "id": "obj-67",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      992.0,
      46.0,
      22.0
     ],
     "text": "+~"
    }
   },
   {
    "box": {
     "id": "obj-68",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      300.0,
      996.0,
      72.0,
      22.0
     ],
     "text": "*~ 0.45"
    }
   },
   {
    "box": {
     "id": "obj-69",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      1018.0,
      46.0,
      22.0
     ],
     "text": "+~"
    }
   },
   {
    "box": {
     "id": "obj-70",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      24.0,
      1056.0,
      1000.0,
      23.0
     ],
     "text": "亮度用指数曲线（300Hz ~ 12kHz）。degrade~ 的降采样是最直白的“电子”信号，vocality 越低压得越狠。shimmer 是振幅上的微观抖动，和 jitter 一样，归零即死。"
    }
   },
   {
    "box": {
     "id": "obj-71",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      24.0,
      1080.0,
      216.0,
      22.0
     ],
     "text": "expr 300. * pow(40.\\, $f1)"
    }
   },
   {
    "box": {
     "id": "obj-72",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      1106.0,
      128.0,
      22.0
     ],
     "text": "onepole~ 2000."
    }
   },
   {
    "box": {
     "id": "obj-73",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      300.0,
      1080.0,
      192.0,
      22.0
     ],
     "text": "expr 0.06 + $f1 * 0.94"
    }
   },
   {
    "box": {
     "id": "obj-74",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      1146.0,
      128.0,
      22.0
     ],
     "text": "degrade~ 1. 16"
    }
   },
   {
    "box": {
     "id": "obj-75",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      300.0,
      1132.0,
      88.0,
      22.0
     ],
     "text": "rand~ 3.7"
    }
   },
   {
    "box": {
     "id": "obj-76",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      430.0,
      1132.0,
      64.0,
      22.0
     ],
     "text": "*~ 0.3"
    }
   },
   {
    "box": {
     "id": "obj-77",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      300.0,
      1158.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-78",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      300.0,
      1184.0,
      56.0,
      22.0
     ],
     "text": "+~ 1."
    }
   },
   {
    "box": {
     "id": "obj-79",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      1210.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-80",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      300.0,
      1210.0,
      120.0,
      22.0
     ],
     "text": "loadmess 0.18"
    }
   },
   {
    "box": {
     "format": 6,
     "id": "obj-81",
     "maxclass": "flonum",
     "numinlets": 1,
     "numoutlets": 2,
     "outlettype": [
      "",
      "bang"
     ],
     "parameter_enable": 0,
     "patching_rect": [
      300.0,
      1236.0,
      60.0,
      22.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-82",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      366.0,
      1236.0,
      60.0,
      23.0
     ],
     "text": "总音量"
    }
   },
   {
    "box": {
     "id": "obj-83",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      300.0,
      1262.0,
      96.0,
      22.0
     ],
     "text": "pack 0. 50"
    }
   },
   {
    "box": {
     "id": "obj-84",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      300.0,
      1288.0,
      56.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-85",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      24.0,
      1288.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-86",
     "maxclass": "newobj",
     "numinlets": 3,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      21.0,
      1347.0,
      144.0,
      22.0
     ],
     "text": "clip~ -0.95 0.95"
    }
   },
   {
    "box": {
     "id": "obj-87",
     "maxclass": "ezdac~",
     "numinlets": 2,
     "numoutlets": 0,
     "patching_rect": [
      33.5,
      1535.0,
      45.0,
      45.0
     ]
    }
   },
   {
    "box": {
     "id": "obj-88",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      378.0,
      1379.0,
      700.0,
      23.0
     ],
     "text": "要换成给 AI 声部用：把上面四个 [r human.*] 改成 [r ai.*] 即可，其余不用动。"
    }
   },
   {
    "box": {
     "id": "obj-701",
     "maxclass": "newobj",
     "numinlets": 0,
     "numoutlets": 1,
     "outlettype": [
      ""
     ],
     "patching_rect": [
      560.0,
      1138.0,
      162.0,
      22.0
     ],
     "text": "r ai.gate.level"
    }
   },
   {
    "box": {
     "id": "obj-702",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "outlettype": [
      "signal",
      "bang"
     ],
     "patching_rect": [
      560.0,
      1208.5,
      58.0,
      22.0
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-703",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "outlettype": [
      "signal"
     ],
     "patching_rect": [
      386.0,
      1338.0,
      46.0,
      22.0
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-704",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      640.0,
      1208.0,
      560.0,
      23.0
     ],
     "text": "开合：不发声时降到 0.12 而不是 0 —— 交叉那一刻要两个声音同时在场才听得见"
    }
   },
   {
    "box": {
     "id": "obj-951",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      760,
      1180,
      154,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "r ai.w.machine"
    }
   },
   {
    "box": {
     "id": "obj-952",
     "maxclass": "newobj",
     "numinlets": 1,
     "numoutlets": 1,
     "patching_rect": [
      920,
      1180,
      122,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "loadmess 0.16"
    }
   },
   {
    "box": {
     "id": "obj-953",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 2,
     "patching_rect": [
      760,
      1208,
      58,
      22
     ],
     "outlettype": [
      "",
      ""
     ],
     "text": "line~"
    }
   },
   {
    "box": {
     "id": "obj-954",
     "maxclass": "newobj",
     "numinlets": 2,
     "numoutlets": 1,
     "patching_rect": [
      380,
      1240,
      46,
      22
     ],
     "outlettype": [
      ""
     ],
     "text": "*~"
    }
   },
   {
    "box": {
     "id": "obj-955",
     "maxclass": "comment",
     "numinlets": 1,
     "numoutlets": 0,
     "patching_rect": [
      980,
      1208,
      520,
      20
     ],
     "text": "交叉渐变权重：这台是人的『合成器引擎』，开场权重≈1，随 xfade 淡出。loadmess 0.99 = 消息到达前保持开场状态"
    }
   }
  ],
  "lines": [
   {
    "patchline": {
     "destination": [
      "obj-28",
      0
     ],
     "source": [
      "obj-101",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-103",
      0
     ],
     "source": [
      "obj-102",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-104",
      0
     ],
     "source": [
      "obj-103",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-101",
      0
     ],
     "source": [
      "obj-104",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-65",
      2
     ],
     "source": [
      "obj-106",
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
     "order": 2,
     "source": [
      "obj-11",
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
     "order": 0,
     "source": [
      "obj-11",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-73",
      0
     ],
     "order": 1,
     "source": [
      "obj-11",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-13",
      0
     ],
     "source": [
      "obj-12",
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
     "order": 2,
     "source": [
      "obj-13",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-55",
      0
     ],
     "order": 0,
     "source": [
      "obj-13",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-76",
      0
     ],
     "order": 1,
     "source": [
      "obj-13",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-17",
      0
     ],
     "source": [
      "obj-16",
      0
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
      "obj-17",
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
      "obj-43",
      0
     ],
     "order": 1,
     "source": [
      "obj-20",
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
     "order": 0,
     "source": [
      "obj-20",
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
      "obj-30",
      0
     ],
     "order": 4,
     "source": [
      "obj-24",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-60",
      0
     ],
     "order": 3,
     "source": [
      "obj-24",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-62",
      0
     ],
     "order": 1,
     "source": [
      "obj-24",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-64",
      0
     ],
     "order": 0,
     "source": [
      "obj-24",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-71",
      0
     ],
     "order": 2,
     "source": [
      "obj-24",
      0
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
      "obj-27",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-31",
      1
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
      "obj-31",
      0
     ],
     "source": [
      "obj-30",
      0
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
      "obj-31",
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
      "obj-32",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-34",
      1
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
      "obj-35",
      0
     ],
     "source": [
      "obj-34",
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
      "obj-35",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-39",
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
      "obj-39",
      1
     ],
     "source": [
      "obj-38",
      0
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
      "obj-39",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-41",
      1
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
      "obj-45",
      0
     ],
     "order": 3,
     "source": [
      "obj-41",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-49",
      1
     ],
     "order": 1,
     "source": [
      "obj-41",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-50",
      0
     ],
     "order": 2,
     "source": [
      "obj-41",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-52",
      0
     ],
     "order": 0,
     "source": [
      "obj-41",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-44",
      0
     ],
     "source": [
      "obj-43",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-45",
      1
     ],
     "source": [
      "obj-44",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-46",
      0
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
      "obj-48",
      0
     ],
     "source": [
      "obj-46",
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
     "source": [
      "obj-47",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-49",
      0
     ],
     "source": [
      "obj-48",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-50",
      1
     ],
     "source": [
      "obj-49",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-51",
      0
     ],
     "source": [
      "obj-50",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-58",
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
      "obj-53",
      0
     ],
     "source": [
      "obj-52",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-54",
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
      "obj-57",
      0
     ],
     "source": [
      "obj-54",
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
      "obj-55",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-57",
      1
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
      "obj-58",
      1
     ],
     "source": [
      "obj-57",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-61",
      0
     ],
     "order": 3,
     "source": [
      "obj-58",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-63",
      0
     ],
     "order": 2,
     "source": [
      "obj-58",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-65",
      0
     ],
     "order": 0,
     "source": [
      "obj-58",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-68",
      0
     ],
     "order": 1,
     "source": [
      "obj-58",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-61",
      2
     ],
     "source": [
      "obj-60",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-66",
      0
     ],
     "source": [
      "obj-61",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-63",
      2
     ],
     "source": [
      "obj-62",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-66",
      1
     ],
     "source": [
      "obj-63",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-65",
      2
     ],
     "source": [
      "obj-64",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-67",
      1
     ],
     "source": [
      "obj-65",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-67",
      0
     ],
     "source": [
      "obj-66",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-69",
      0
     ],
     "source": [
      "obj-67",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-69",
      1
     ],
     "source": [
      "obj-68",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-72",
      0
     ],
     "source": [
      "obj-69",
      0
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
      "obj-7",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-100",
      1
     ],
     "order": 0,
     "source": [
      "obj-701",
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
     "order": 1,
     "source": [
      "obj-701",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-703",
      1
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
      "obj-72",
      1
     ],
     "source": [
      "obj-71",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-74",
      0
     ],
     "source": [
      "obj-72",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-74",
      1
     ],
     "source": [
      "obj-73",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-79",
      0
     ],
     "source": [
      "obj-74",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-77",
      0
     ],
     "source": [
      "obj-75",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-77",
      1
     ],
     "source": [
      "obj-76",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-78",
      0
     ],
     "source": [
      "obj-77",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-79",
      1
     ],
     "source": [
      "obj-78",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-85",
      0
     ],
     "source": [
      "obj-79",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-9",
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
      "obj-81",
      0
     ],
     "source": [
      "obj-80",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-83",
      0
     ],
     "source": [
      "obj-81",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-84",
      0
     ],
     "source": [
      "obj-83",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-85",
      1
     ],
     "source": [
      "obj-84",
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
      "obj-85",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-91",
      0
     ],
     "source": [
      "obj-86",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-11",
      0
     ],
     "source": [
      "obj-9",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-87",
      1
     ],
     "order": 2,
     "source": [
      "obj-91",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-87",
      0
     ],
     "order": 3,
     "source": [
      "obj-91",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-89",
      0
     ],
     "order": 0,
     "source": [
      "obj-91",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-90",
      0
     ],
     "order": 1,
     "source": [
      "obj-91",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-81",
      0
     ],
     "source": [
      "obj-92",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-92",
      0
     ],
     "source": [
      "obj-93",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-98",
      0
     ],
     "source": [
      "obj-94",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-94",
      0
     ],
     "source": [
      "obj-95",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-95",
      0
     ],
     "source": [
      "obj-97",
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
      "obj-98",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-68",
      1
     ],
     "source": [
      "obj-99",
      0
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
      "obj-6",
      0
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
      "obj-22",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-17",
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
      "obj-953",
      0
     ],
     "source": [
      "obj-951",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-953",
      0
     ],
     "source": [
      "obj-952",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-954",
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
      "obj-954",
      1
     ],
     "source": [
      "obj-953",
      0
     ]
    }
   },
   {
    "patchline": {
     "destination": [
      "obj-86",
      0
     ],
     "source": [
      "obj-954",
      0
     ]
    }
   }
  ],
  "parameters": {
   "obj-91": [
    "live.gain~",
    "live.gain~",
    0
   ],
   "parameterbanks": {
    "0": {
     "index": 0,
     "name": "",
     "parameters": [
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-"
     ],
     "buttons": [
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-"
     ]
    }
   },
   "inherited_shortname": 1
  },
  "dependency_cache": [],
  "autosave": 0
 }
}