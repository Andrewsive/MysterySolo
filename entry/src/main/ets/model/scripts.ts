import { Script } from './types';

export const SCRIPTS: Script[] = [
  {
    id: 'demo',
    title: '午夜书房',
    difficulty: 2,
    durationMin: 15,
    intro: '你独自在书房醒来，窗外雷雨。桌上有一本手札与一把生锈的钥匙……',
    start: 'start',
    scenes: [
      {
        id: 'start',
        text: '桌上有一本沾湿的手札与一把生锈的钥匙。',
        choices: [
          { text: '查看手札', next: 'diary' },
          { text: '检查钥匙', next: 'key' }
        ]
      },
      {
        id: 'diary',
        text: '手札写着：“午夜十二点前一定要锁上…”',
        gainClues: ['note_diary'],
        choices: [{ text: '回到书桌', next: 'start' }]
      },
      {
        id: 'key',
        text: '钥匙刻着 1201。',
        choices: [
          { text: '去试试边门', next: 'sideDoor', setFlags: { hasKey: true } },
          { text: '回到书桌', next: 'start' }
        ]
      },
      {
        id: 'sideDoor',
        text: '边门上锁。钥匙似乎能插入。',
        choices: [
          { text: '使用钥匙', next: 'ending_good', require: { hasKey: true } },
          { text: '放弃', next: 'start' }
        ]
      }
    ],
    endings: [
      { id: 'ending_good', title: '脱身', summary: '你及时锁上，暴雨将秘密掩埋，你获得自由。', score: 90 },
      { id: 'ending_bad', title: '困于雷声', summary: '午夜钟声敲响，你被困在书房。', score: 30 }
    ],
    clues: [{ id: 'note_diary', name: '手札', desc: '十二点前要锁上…' }]
  }
];
