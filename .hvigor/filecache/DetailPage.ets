import router from '@ohos.router';
import { getScript } from '../model/store';
import { DetailParams } from '../model/types';

@Component
struct DetailPage {
  @State sId: string = 'demo';
  @State title: string = '';
  @State difficulty: number = 0;
  @State durationMin: number = 0;
  @State intro: string = '';
  @State loaded: boolean = false;

  aboutToAppear() {
    try {
      const p = router.getParams() as DetailParams | undefined;
      if (p && p.id && p.id.length > 0) {
        this.sId = p.id;
      }
    } catch (_) {}

    const s = getScript(this.sId);
    if (s) {
      this.title = s.title;
      this.difficulty = s.difficulty;
      this.durationMin = s.durationMin;
      this.intro = s.intro;
      this.loaded = true;
    } else {
      this.title = '';
      this.difficulty = 0;
      this.durationMin = 0;
      this.intro = '';
      this.loaded = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      if (!this.loaded) {
        Text('加载中…').padding(16)
      } else {
        Text(this.title).fontSize(22).fontWeight(FontWeight.Bold).padding(16)
        Text(`难度 ${this.difficulty} · 约 ${this.durationMin} 分钟`)
          .fontSize(14).opacity(0.7).padding({ left: 16, right: 16 })
        Scroll() { Text(this.intro).fontSize(16).padding(16) }.height('60%')
        Row() {
          Button('返回').onClick(() => { try { router.back() } catch (_) {} })
          Blank()
          Button('开始游玩').onClick(() => {
            try { router.pushUrl({ url: 'pages/PlayPage', params: { id: this.sId } }) } catch (_) {}
          })
        }.padding(16)
      }
    }.height('100%')
  }
}
