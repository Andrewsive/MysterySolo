import router from '@ohos.router';
import { getScript } from '../model/store';
import { ResultParams } from '../model/types';

@Entry
@Component
struct ResultPage {
  @State sid: string = 'demo';
  @State endingId: string = 'ending_bad';
  @State title: string = '';
  @State summary: string = '';
  @State score: number = 0;

  aboutToAppear() {
    try {
      const p = router.getParams() as ResultParams | undefined;
      if (p && p.id) this.sid = p.id;
      if (p && p.endingId) this.endingId = p.endingId;
    } catch (_) {}
    const s = getScript(this.sid);
    if (s) {
      const e = s.endings.find(x => x.id === this.endingId) ?? s.endings[0];
      this.title = e.title;
      this.summary = e.summary;
      this.score = e.score;
    } else {
      this.title = '';
      this.summary = '';
      this.score = 0;
    }
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 6 }) {
          Text('推理结束').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
          Text('整理思路，记录你的演绎故事').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
        }

        Column({ space: 10 }) {
          Text(this.title).fontSize(20).fontWeight(FontWeight.Medium)
          Text(`得分 ${this.score}`).fontSize(32).fontWeight(FontWeight.Bold)
        }.padding({ left: 20, right: 20, top: 24, bottom: 24 }).backgroundColor('#F6F7F9').borderRadius(18)

        Column({ space: 12 }) {
          Text('结局摘要').fontSize(16).fontWeight(FontWeight.Medium)
          Text(this.summary).fontSize(14).opacity(0.75)
        }.padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Button('回到首页').onClick(() => {
            try { router.replaceUrl({ url: 'pages/HomePage' }) } catch (_) {}
          })
          Button('再来一次').type(ButtonType.Capsule).onClick(() => {
            try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
          })
        }.margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

