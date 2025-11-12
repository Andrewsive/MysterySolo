import router from '@ohos.router';
import { getScript } from '../model/store';
import { Clue, NotesParams } from '../model/types';

@Entry
@Component
struct NotesPage {
  @State sid: string = 'demo';
  @State got: string[] = [];
  @State clues: Clue[] = [];

  aboutToAppear() {
    try {
      const p = router.getParams() as NotesParams | undefined;
      if (p && p.id) this.sid = p.id;
      if (p && p.clues) this.got = p.clues;
    } catch (_) {}
    const s = getScript(this.sid);
    this.clues = s ? s.clues : [];
  }

  private ownedCount(): number {
    let count = 0;
    this.clues.forEach((c: Clue) => {
      if (this.isOwned(c.id)) {
        count += 1;
      }
    });
    return count;
  }

  private isOwned(id: string): boolean {
    return this.got.indexOf(id) >= 0;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 8 }) {
          Text('线索簿').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 20, left: 20, right: 20 })
          Text(`已掌握 ${this.ownedCount()} / ${this.clues.length} 条线索`).fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
        }

        Column({ space: 12 }) {
          ForEach(this.clues, (c: Clue) => {
            Column({ space: 6 }) {
              Row() {
                Text(c.name).fontSize(16).fontWeight(FontWeight.Medium)
                Blank()
                Text(this.isOwned(c.id) ? '已同步' : '待解锁').fontSize(12).opacity(this.isOwned(c.id) ? 0.7 : 0.4)
              }
              Text(c.desc).fontSize(14).opacity(0.75)
            }.padding({ left: 20, right: 20, top: 14, bottom: 14 }).backgroundColor(this.isOwned(c.id) ? '#F0F5EE' : '#F6F7F9').borderRadius(16)
          })
        }.padding({ bottom: 24 })

        Row({ space: 12 }) {
          Button('添加推理笔记').type(ButtonType.Capsule).onClick(() => {
            try { router.pushUrl({ url: 'pages/NotesEditorPage', params: { id: this.sid } }) } catch (_) {}
          })
          Button('返回').onClick(() => {
            try { router.back() } catch (_) {}
          })
        }.margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}
