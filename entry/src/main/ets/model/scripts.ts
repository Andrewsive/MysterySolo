import { Script } from './types';

export const SCRIPTS: Script[] = [
  {
    id: 'demo',
    title: '午夜书房',
    difficulty: 2,
    durationMin: 25,
    intro: '一场暴雨让你被困在书房。线索散落在旧书与窗棂间，你需要在零点前串联记忆，找到逃脱的正确顺序。',
    tagline: '雨夜独白 · 线索步步揭开',
    tags: ['古宅', '线索追踪', '单线解谜'],
    genre: '悬疑',
    recommendedFocus: '适合喜欢慢推理的玩家',
    mood: '压抑却温柔的雨夜',
    highlight: '以日记与物件串联的线索网',
    start: 'start',
    scenes: [
      {
        id: 'start',
        text: '雷声轰鸣，书房的窗微微敞开。桌面上，一本手札与一把生锈的钥匙被灯光照亮。',
        choices: [
          { text: '翻阅手札', next: 'diary' },
          { text: '检查钥匙', next: 'key' }
        ]
      },
      {
        id: 'diary',
        text: '手札的纸张被雨水打湿。上面写着：“午夜前锁上边门，勿回头。”',
        gainClues: ['note_diary'],
        choices: [{ text: '折好手札', next: 'start' }]
      },
      {
        id: 'key',
        text: '钥匙柄刻着 1201，齿位有水渍。也许来自边门。',
        choices: [
          { text: '前往边门', next: 'sideDoor', setFlags: { hasKey: true } },
          { text: '继续搜查书房', next: 'start' }
        ]
      },
      {
        id: 'sideDoor',
        text: '边门紧闭，门缝里渗出潮气。风声像有人在耳边低语。',
        choices: [
          { text: '用钥匙试试', next: 'ending_good', require: { hasKey: true } },
          { text: '畏惧地退回', next: 'ending_bad' }
        ]
      }
    ],
    endings: [
      { id: 'ending_good', title: '脱身', summary: '钥匙转动的一瞬，风暴远去。你在雨夜中找到出口，也终于接受了记忆里的告别。', score: 92 },
      { id: 'ending_bad', title: '困于雷声', summary: '你退回书房，任凭雷声在耳边回响。黎明时分，你依旧未能踏出房门。', score: 32 }
    ],
    clues: [
      { id: 'note_diary', name: '手札', desc: '手札提醒：午夜前锁上边门，勿回头。似乎是逃脱关键。' }
    ]
  },
  {
    id: 'echo',
    title: '回声公寓',
    difficulty: 1,
    durationMin: 18,
    intro: '你搬入一间转手多次的公寓，夜里总能听到脚步回声。调查楼道、住户与旧档案，找出回声的来源。',
    tagline: '城市孤岛里的温柔谜案',
    tags: ['都市', '情感', '轻推理'],
    genre: '情感悬疑',
    recommendedFocus: '新手快速上手',
    mood: '温暖而略带惆怅',
    highlight: '通过邻里互动拼凑出真实记忆',
    start: 'lobby',
    scenes: [
      {
        id: 'lobby',
        text: '夜深的公寓大堂只剩值班灯。回声在楼梯间回荡。',
        choices: [
          { text: '上楼寻找声源', next: 'stairs' },
          { text: '敲响管理员室', next: 'concierge' }
        ]
      },
      {
        id: 'stairs',
        text: '二层走廊有淡淡花香。尽头的旧储物间门半掩。',
        gainClues: ['scent'],
        choices: [
          { text: '推开储物间', next: 'storage' },
          { text: '回到一层', next: 'lobby' }
        ]
      },
      {
        id: 'concierge',
        text: '管理员递给你一份旧住户档案，上面密密麻麻的搬家记录。',
        gainClues: ['record'],
        choices: [
          { text: '查看档案细节', next: 'files' },
          { text: '前往楼梯', next: 'stairs' }
        ]
      },
      {
        id: 'storage',
        text: '储物间里堆着被遗忘的纸箱。角落里有一台旧投影仪。',
        choices: [
          { text: '打开投影仪', next: 'ending_echo' },
          { text: '取走箱子', next: 'ending_loop' }
        ]
      },
      {
        id: 'files',
        text: '你发现所有搬走的住户都在夜里听见同样的脚步声。',
        choices: [{ text: '回想脚步节奏', next: 'storage' }]
      }
    ],
    endings: [
      { id: 'ending_echo', title: '真相回声', summary: '投影仪播放着前住户练舞的影像。你将它送回家属，回声自此归于静默。', score: 85 },
      { id: 'ending_loop', title: '回声轮回', summary: '你带走纸箱，回声依旧在夜里出现。或许你只是成为下一个见证者。', score: 55 }
    ],
    clues: [
      { id: 'scent', name: '栀子花香', desc: '二层走廊的花香，似乎和旧档案里的舞者有关。' },
      { id: 'record', name: '搬家档案', desc: '管理员的档案记录了频繁搬离的住户。' }
    ]
  },
  {
    id: 'atelier',
    title: '静物画室',
    difficulty: 3,
    durationMin: 35,
    intro: '著名绘画导师的画室突然封闭。你受邀进入画室，寻找失踪的学生与隐藏在作品中的留言。',
    tagline: '在色块与笔触间解读真相',
    tags: ['艺术', '多结局', '逻辑推理'],
    genre: '心理悬疑',
    recommendedFocus: '喜欢多线索交织的玩家',
    mood: '冷冽而理性',
    highlight: '每幅画都是解谜密码，收集色号决定结局',
    start: 'studio',
    scenes: [
      {
        id: 'studio',
        text: '画室布满半完成的静物画。调色盘上残留着鲜艳的红。',
        choices: [
          { text: '检查画架', next: 'easel' },
          { text: '翻看导师手稿', next: 'notes' }
        ]
      },
      {
        id: 'easel',
        text: '画架旁散落着色卡。某些色块被标注为“锁”“出口”。',
        gainClues: ['palette'],
        choices: [
          { text: '拼合色卡', next: 'ending_truth', require: { hasClue: true } },
          { text: '继续搜查', next: 'storeroom', setFlags: { hasClue: true } }
        ]
      },
      {
        id: 'notes',
        text: '手稿记录着学生的练习计划，也暗藏导师的不安。',
        gainClues: ['note_teacher'],
        choices: [
          { text: '前往暗房', next: 'darkroom' },
          { text: '返回画室', next: 'studio' }
        ]
      },
      {
        id: 'storeroom',
        text: '储物柜上锁，但锁孔与某个色卡形状相似。',
        choices: [
          { text: '合上色卡开锁', next: 'ending_rescue', require: { hasClue: true } },
          { text: '放弃', next: 'studio' }
        ]
      },
      {
        id: 'darkroom',
        text: '暗房里晾着学生的底片，影像显得孤独。',
        choices: [
          { text: '解析底片', next: 'ending_reflect' },
          { text: '返回画室', next: 'studio' }
        ]
      }
    ],
    endings: [
      { id: 'ending_truth', title: '真相定格', summary: '你组合色卡，打开画室的天窗，师生终于坦白彼此的焦虑与期待。', score: 95 },
      { id: 'ending_rescue', title: '暗室救赎', summary: '储物柜中藏着学生留下的道歉字条与联络方式，你成功让导师与学生重逢。', score: 88 },
      { id: 'ending_reflect', title: '独自写生', summary: '你选择保留秘密，让画室维持平衡。导师继续创作，只是画作愈发孤独。', score: 60 }
    ],
    clues: [
      { id: 'palette', name: '色卡碎片', desc: '拼合后的色卡构成密码，是开启储物柜的关键。' },
      { id: 'note_teacher', name: '导师手稿', desc: '记录学生的练习与导师的忧虑，暗示矛盾来源。' }
    ]
  }
];
