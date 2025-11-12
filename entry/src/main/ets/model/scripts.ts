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
    highlights: [
      { title: '日记引导', description: '通过手札的只言片语获取下一步行动提示。' },
      { title: '道具互动', description: '钥匙、边门等道具关联，触发不同剧情分支。' },
      { title: '情绪线索', description: '暴雨与灯光构建情感氛围，触发回忆片段。' }
    ],
    sizeMB: 32,
    releaseDaysAgo: 12,
    rating: 4.6,
    offlineAvailable: true,
    hints: [
      { id: 'demo-h1', text: '手札与边门之间存在时间限制，注意日记中的时间线。' },
      { id: 'demo-h2', text: '钥匙不仅可以开门，也许还代表某个数字或日期。' }
    ],
    start: 'intro',
    scenes: [
      {
        id: 'intro',
        text: '【开场】\n\n暴雨夜，你在书房醒来，头痛欲裂。窗外雷声轰鸣，时钟指向晚上 11 点。\n\n书房门被反锁，你记不清为何会在这里。桌上散落着泛黄的手札、一把生锈的钥匙，墙角还有一盏摇曳的煤油灯。\n\n【任务目标】\n· 探查书房，收集线索\n· 在午夜前找到逃脱方法\n· 解开记忆中的秘密',
        choices: [
          { text: '开始调查', next: 'start' }
        ]
      },
      {
        id: 'start',
        text: '【书房环境】\n\n雷声轰鸣，书房的窗微微敞开，冷风吹进。桌面上，一本手札与一把生锈的钥匙被灯光照亮。\n\n墙上的时钟滴答作响，现在是 23:05。你感到时间紧迫。\n\n💡 提示：仔细检查每一件物品，它们可能藏着关键信息。',
        choices: [
          { text: '翻阅手札（收集线索）', next: 'diary' },
          { text: '检查钥匙（查看细节）', next: 'key' },
          { text: '观察书架', next: 'bookshelf' }
        ]
      },
      {
        id: 'diary',
        text: '【线索：手札】\n\n手札的纸张被雨水打湿，字迹模糊。你辨认出几行字：\n\n"1201...午夜前锁上边门，勿回头..."\n"雷雨夜的约定...我会在那里等你..."\n\n手札末尾署名已无法辨认，但你隐约感到一阵心痛。\n\n✅ 获得线索：《神秘手札》\n💭 思考：1201 是什么？边门在哪里？',
        gainClues: ['note_diary'],
        choices: [
          { text: '继续调查（返回书房）', next: 'start_explored' },
          { text: '立即寻找边门', next: 'search_door' }
        ]
      },
      {
        id: 'key',
        text: '【线索：钥匙】\n\n这把钥匙很旧，表面有铜绿。钥匙柄刻着"1201"，齿位有水渍和泥土痕迹。\n\n你想起来了——这是边门的钥匙！那扇通往后院的旧门，多年未开。\n\n💡 推理：钥匙上的水渍说明有人最近用过它。是谁？为什么？\n\n✅ 获得关键道具：边门钥匙',
        gainClues: ['key_info'],
        setFlags: { hasKey: true },
        choices: [
          { text: '带上钥匙，继续搜查', next: 'start_explored' },
          { text: '立即前往边门', next: 'sideDoor' }
        ]
      },
      {
        id: 'bookshelf',
        text: '【书架探索】\n\n书架上满是旧书，你抽出一本泛黄的日记本，翻开第一页：\n\n"12月1日，雨夜。我决定在边门等她最后一次..."\n\n后面的页面被撕掉了。你注意到书架背后有划痕，似乎有人曾试图移动它。\n\n💡 新线索：12月1日，边门，约定...\n\n✅ 获得线索：《撕毁的日记》',
        gainClues: ['diary_torn'],
        choices: [
          { text: '继续调查书房', next: 'start_explored' }
        ]
      },
      {
        id: 'start_explored',
        text: '【书房·再次审视】\n\n时钟指向 23:20，雷声渐弱。你已经收集了一些线索。\n\n现有线索：\n· 手札提到"午夜前锁上边门"\n· 钥匙刻着"1201"，有水渍\n· 日记提到"12月1日，边门约定"\n\n💭 推理：所有线索都指向边门，而且时间紧迫...',
        choices: [
          { text: '再检查一次煤油灯', next: 'lamp' },
          { text: '前往边门（关键选择）', next: 'search_door' }
        ]
      },
      {
        id: 'lamp',
        text: '【煤油灯的秘密】\n\n你走近煤油灯，发现底座刻着一行小字：\n\n"记忆之门只为勇敢者开启"\n\n灯光映照下，你看到墙上有一幅褪色的照片——那是你和某个人在雨中的合影，背景正是边门...\n\n💡 记忆闪回：你想起了什么重要的事...\n\n✅ 获得线索：《褪色照片》',
        gainClues: ['photo'],
        choices: [
          { text: '前往边门，揭开真相', next: 'search_door' }
        ]
      },
      {
        id: 'search_door',
        text: '【寻找边门】\n\n你穿过走廊，来到宅子深处。边门就在眼前，门上布满铁锈，门缝渗出潮气。\n\n风声在耳边低语，仿佛有人在呼唤你的名字...\n\n时钟敲响 23:45。还有 15 分钟到午夜。',
        choices: [
          { text: '检查门锁', next: 'sideDoor' }
        ]
      },
      {
        id: 'sideDoor',
        text: '【边门·抉择时刻】\n\n边门紧闭，锁孔与你手中的钥匙完美吻合。\n\n门缝里渗出潮气，风声像有人在耳边低语："别害怕...进来..."\n\n你的手在颤抖。手札上写着"午夜前锁上边门"，但现在门是锁着的，你应该...\n\n💡 关键推理：\n· 手札说"锁上"，但门已经锁着\n· 也许是要你"解锁"而不是"锁上"？\n· 或者...你该离开这里？\n\n⏰ 时间：23:50，还有 10 分钟',
        choices: [
          { text: '用钥匙打开边门（勇敢面对）', next: 'unlock_door', require: { hasKey: true } },
          { text: '不对劲，先退回书房', next: 'retreat_think' },
          { text: '畏惧地逃离这里', next: 'ending_bad' }
        ]
      },
      {
        id: 'unlock_door',
        text: '【开启边门】\n\n钥匙插入锁孔，转动的瞬间，一道白光闪过...\n\n记忆如潮水般涌来：\n\n这是你和她约定相见的地方。那个雨夜，你因为害怕而没有出现。她一直在边门外等你，直到...\n\n现在，你终于鼓起勇气，推开了这扇"记忆之门"。\n\n门外，暴雨已停，天空泛起鱼肚白...',
        choices: [
          { text: '踏出边门', next: 'ending_good' }
        ]
      },
      {
        id: 'retreat_think',
        text: '【重新思考】\n\n你退回走廊，重新审视手札：\n\n"午夜前锁上边门，勿回头"\n\n等等...如果"锁上"是指"锁住过去的记忆"呢？\n如果"勿回头"是说不要逃避？\n\n也许，打开边门才是真正的答案...\n\n⏰ 时间：23:55',
        choices: [
          { text: '返回边门，做出选择', next: 'sideDoor' }
        ]
      }
    ],
    endings: [
      { id: 'ending_good', title: '脱身', summary: '钥匙转动的一瞬，风暴远去。你在雨夜中找到出口，也终于接受了记忆里的告别。', score: 92 },
      { id: 'ending_bad', title: '困于雷声', summary: '你退回书房，任凭雷声在耳边回响。黎明时分，你依旧未能踏出房门。', score: 32 }
    ],
    clues: [
      { id: 'note_diary', name: '神秘手札', desc: '手札提醒：午夜前锁上边门，勿回头。1201...雷雨夜的约定。似乎是逃脱关键。' },
      { id: 'key_info', name: '边门钥匙', desc: '刻着"1201"的旧钥匙，齿位有水渍。这是打开边门的关键道具。' },
      { id: 'diary_torn', name: '撕毁的日记', desc: '12月1日，雨夜。"我决定在边门等她最后一次..."后面的页面被撕掉了。' },
      { id: 'photo', name: '褪色照片', desc: '你和某个人在雨中的合影，背景是边门。记忆之门只为勇敢者开启。' }
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
    highlights: [
      { title: '邻里访谈', description: '与管理员、邻居对话获得不同视角的线索。' },
      { title: '声音谜题', description: '回声的节奏暗藏密码，可与档案互相印证。' }
    ],
    sizeMB: 24,
    releaseDaysAgo: 5,
    rating: 4.4,
    offlineAvailable: false,
    hints: [
      { id: 'echo-h1', text: '花香与舞者之间有联系，试着把气味与档案对照。' },
      { id: 'echo-h2', text: '投影仪与脚步声的节奏一致，说明回声来自影像。' }
    ],
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
    highlights: [
      { title: '色卡拼图', description: '不同色块对应字母，拼合后是储物柜密码。' },
      { title: '暗房底片', description: '底片记录学生情绪，可决定最终结局。' },
      { title: '导师手稿', description: '手稿提示师生矛盾，用于判断不同分支。' }
    ],
    sizeMB: 48,
    releaseDaysAgo: 38,
    rating: 4.8,
    offlineAvailable: true,
    hints: [
      { id: 'atelier-h1', text: '色卡上标注的“锁”与储物柜形状一致，考虑颜色顺序。' },
      { id: 'atelier-h2', text: '暗房底片与手稿搭配阅读，能看出学生失踪的真正原因。' }
    ],
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
