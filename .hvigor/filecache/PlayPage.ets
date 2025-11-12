import router from '@ohos.router';
import { getScript } from '../model/store';
import { Engine } from '../model/engine';
import { PlayParams } from '../model/types';

@Component
struct PlayPage {
  @State sid: string = 'demo';
  private eng?: Engine;

  aboutToAppear() {
    try {
      const p = router.getParams() as PlayParams | undefined;
      if (p && p.id) this.sid = p.id;
    } catch (_) {}
    this.eng = new Engine(getScript(this.sid)!);
  }

  build() {
    Column({ space: 8 }) {
      if (!this.eng) {
        Text('加载中…').padding(16)
      } else {
        const scene = this.eng.current();

        Row() {
          Button('线索').onClick(() => {
            try {
              const clues = this.eng ? this.eng.getClues() : [];
              router.pushUrl({ url: 'pages/NotesPage', params: { id: this.sid, clues } })
            } catch (_) {}
          })
          Blank()
          Button('重开').onClick(() => {
            if (this.eng) this.eng.restart();
            try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
          })
        }.padding(12)

        Scroll() { Text(scene ? scene.text : '').fontSize(18).padding(16) }.height('60%')

        Column() {
          ForEach(scene ? scene.choices : [], (c) => {
            Button(c.text).margin({ top: 6, left: 16, right: 16 }).onClick(() => {
              if (!this.eng) { return }
              const r = this.eng.choose(c);
              try {
                if (r.ended) {
                  router.pushUrl({ url: 'pages/ResultPage', params: { id: this.sid, endingId: r.endingId } })
                } else {
                  router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } })
                }
              } catch (_) {}
            })
          })
        }.padding({ bottom: 16 })
      }
    }.height('100%')
  }
}

@Preview
@Component
struct PlayPreview { build() { PlayPage() } }
