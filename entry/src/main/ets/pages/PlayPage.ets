import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { getScript } from '../model/store';
import { Engine } from '../model/engine';
import { Choice, PlayParams, PlaySummary, Script } from '../model/types';
import { recordPlay } from '../model/progress';

@Entry
@Component
struct PlayPage {
  @State sid: string = 'demo';
  private eng?: Engine;
  @State sceneText: string = '';
  @State choices: Choice[] = [];
  @State scriptTitle: string = '';
  @State scriptMood: string = '';
  private script?: Script;
  @State hints: string[] = [];
  @State usedHints: number = 0;

  aboutToAppear() {
    try {
      const p = router.getParams() as PlayParams | undefined;
      if (p && p.id) this.sid = p.id;
    } catch (_) {}
    this.script = getScript(this.sid);
    this.scriptTitle = this.script ? this.script.title : '';
    this.scriptMood = this.script && this.script.mood ? this.script.mood : '';
    this.hints = this.script && this.script.hints ? this.script.hints.map((h) => h.text) : [];
    this.usedHints = 0;
    this.eng = this.script ? new Engine(this.script) : undefined;
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

  private showHint() {
    if (this.hints.length === 0) {
      promptAction.showToast({ message: '当前剧本暂无提示' });
      return;
    }
    const index = Math.min(this.usedHints, this.hints.length - 1);
    const content = this.hints[index];
    if (this.usedHints < this.hints.length) {
      this.usedHints += 1;
    }
    promptAction.showDialog({
      title: '提示',
      message: content,
      buttons: [{ text: '继续推理', color: '#0A84FF' }]
    });
  }

  private navigateEnding(endingId: string | undefined) {
    const ending = this.script?.endings.find((e) => e.id === endingId);
    if (this.eng && this.script && ending) {
      const summary: PlaySummary = {
        sessionId: `${this.sid}-${Date.now()}`,
        scriptId: this.sid,
        endingId: ending.id,
        score: ending.score,
        durationMin: this.script.durationMin,
        timestamp: Date.now(),
        clues: this.eng.getClues(),
        flags: this.eng.getFlags(),
        trail: this.eng.getTrail(),
        usedHints: this.usedHints
      };
      recordPlay(summary, ending.title);
    }
    try {
      router.pushUrl({ url: 'pages/ResultPage', params: { id: this.sid, endingId } });
    } catch (_) {}
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
            Button(`提示（${this.usedHints}/${Math.max(this.hints.length, 1)}）`).onClick(() => {
              this.showHint();
            })
            Blank()
            Button('重置剧情').onClick(() => {
              if (this.eng) {
                this.eng.restart();
                this.refreshFromEngine();
              }
              this.usedHints = 0;
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
                    this.navigateEnding(result.endingId);
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

