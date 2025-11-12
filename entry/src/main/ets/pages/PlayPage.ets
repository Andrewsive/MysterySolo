import router from '@ohos.router';
import { getScript } from '../model/store';
import { Engine } from '../model/engine';
import { Choice, PlayParams } from '../model/types';

@Entry
@Component
struct PlayPage {
  @State sid: string = 'demo';
  private eng?: Engine;
  @State sceneText: string = '';
  @State choices: Choice[] = [];
  @State scriptTitle: string = '';
  @State scriptMood: string = '';

  aboutToAppear() {
    try {
      const p = router.getParams() as PlayParams | undefined;
      if (p && p.id) this.sid = p.id;
    } catch (_) {}
    const script = getScript(this.sid);
    this.scriptTitle = script ? script.title : '';
    this.scriptMood = script && script.mood ? script.mood : '';
    this.eng = script ? new Engine(script) : undefined;
    this.refreshFromEngine();
  }

  private refreshFromEngine() {
    if (!this.eng) {
      this.sceneText = '暂无剧情';
      this.choices = [];
      return;
    }
    const curScene = this.eng.current();
    this.sceneText = curScene ? curScene.text : '暂无剧情';
    this.choices = curScene ? curScene.choices : [];
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 6 }) {
          Text(this.scriptTitle).fontSize(22).fontWeight(FontWeight.Bold).padding({ top: 20, left: 20, right: 20 })
          if (this.scriptMood.length > 0) {
            Text(this.scriptMood).fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
          }
        }

        Column({ space: 12 }) {
          Row() {
            Button('线索簿').onClick(() => {
              try {
                const clues = this.eng ? this.eng.getClues() : [];
                router.pushUrl({ url: 'pages/NotesPage', params: { id: this.sid, clues } })
              } catch (_) {}
            })
            Blank()
            Button('重置剧情').onClick(() => {
              if (this.eng) {
                this.eng.restart();
                this.refreshFromEngine();
              }
              try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
            })
          }.margin({ left: 20, right: 20 })

          Column() {
            Text(this.sceneText).fontSize(18).lineHeight(24).padding({ left: 20, right: 20, top: 16, bottom: 16 })
          }.backgroundColor('#F6F7F9').borderRadius(18).margin({ left: 20, right: 20 })

          Column({ space: 10 }) {
            ForEach(this.choices, (c: Choice) => {
              Button(c.text)
                .type(ButtonType.Normal)
                .margin({ left: 20, right: 20 })
                .padding({ top: 12, bottom: 12 })
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .onClick(() => {
                  if (!this.eng) {
                    return;
                  }
                  const result = this.eng.choose(c);
                  if (result.ended) {
                    try {
                      router.pushUrl({ url: 'pages/ResultPage', params: { id: this.sid, endingId: result.endingId } })
                    } catch (_) {}
                  } else {
                    this.refreshFromEngine();
                    try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
                  }
                })
            })
          }
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

