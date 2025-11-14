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
  @State clueCount: number = 0;
  @State totalClues: number = 0;
  @State hasNewClue: boolean = false;

  aboutToAppear() {
    try {
      const p = router.getParams() as PlayParams | undefined;
      if (p && p.id) this.sid = p.id;
    } catch (_) {}
    this.script = getScript(this.sid);
    this.scriptTitle = this.script ? this.script.title : '';
    this.scriptMood = this.script && this.script.mood ? this.script.mood : '';
    this.hints = this.script && this.script.hints ? this.script.hints.map((h) => h.text) : [];
    this.totalClues = this.script && this.script.clues ? this.script.clues.length : 0;
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
    const previousClueCount = this.clueCount;
    const curScene = this.eng.current();
    this.sceneText = curScene ? curScene.text : '暂无剧情';
    this.choices = curScene ? curScene.choices : [];
    this.clueCount = this.eng.getClues().length;
    
    // 检测是否有新线索
    if (this.clueCount > previousClueCount) {
      this.hasNewClue = true;
      promptAction.showToast({ message: '✅ 获得新线索！', duration: 2000 });
      // 2秒后重置新线索标记
      setTimeout(() => {
        this.hasNewClue = false;
      }, 2000);
    }
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
      Column({ space: 16 }) {
        // 顶部标题栏
        Column({ space: 6 }) {
          Text(this.scriptTitle).fontSize(22).fontWeight(FontWeight.Bold).padding({ top: 20, left: 20, right: 20 })
          if (this.scriptMood.length > 0) {
            Text(this.scriptMood).fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
          }
        }

        // 线索进度提示卡片
        if (this.totalClues > 0) {
          Column({ space: 8 }) {
            Row() {
              Text('🔍 线索进度').fontSize(14).fontWeight(FontWeight.Medium)
              Blank()
              Text(`${this.clueCount}/${this.totalClues}`).fontSize(14).opacity(0.7)
            }.width('100%')
            
            Progress({ value: this.clueCount, total: this.totalClues, type: ProgressType.Linear })
              .width('100%')
              .height(6)
              .borderRadius(3)
            
            if (this.hasNewClue) {
              Text('✨ 刚刚获得了新线索！').fontSize(12).fontColor('#52C41A')
            }
          }
          .padding(16)
          .backgroundColor('#F0F9FF')
          .borderRadius(12)
          .margin({ left: 20, right: 20 })
        }

        // 功能按钮栏
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Button() {
              Row({ space: 4 }) {
                Text('📋').fontSize(16)
                Text('线索簿').fontSize(14)
                if (this.clueCount > 0) {
                  Text(`(${this.clueCount})`).fontSize(12).opacity(0.7)
                }
              }
            }
            .type(ButtonType.Normal)
            .backgroundColor('#E8F4FD')
            .borderRadius(12)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              try {
                const clues = this.eng ? this.eng.getClues() : [];
                router.pushUrl({ url: 'pages/NotesPage', params: { id: this.sid, clues } })
              } catch (_) {}
            })
            
            Button() {
              Row({ space: 4 }) {
                Text('💡').fontSize(16)
                Text(`提示`).fontSize(14)
                Text(`${this.usedHints}/${Math.max(this.hints.length, 1)}`).fontSize(12).opacity(0.7)
              }
            }
            .type(ButtonType.Normal)
            .backgroundColor('#FFF7E6')
            .borderRadius(12)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.showHint();
            })
          }.width('100%')

          Button() {
            Row({ space: 4 }) {
              Text('🔄').fontSize(16)
              Text('重新开始').fontSize(14)
            }
          }
          .type(ButtonType.Normal)
          .backgroundColor('#F6F7F9')
          .borderRadius(12)
          .height(44)
          .width('100%')
          .onClick(() => {
            promptAction.showDialog({
              title: '重新开始',
              message: '确定要重新开始游戏吗？当前进度将会丢失。',
              buttons: [
                { text: '取消', color: '#999999' },
                { text: '确定', color: '#FF4D4F' }
              ]
            }).then((result) => {
              if (result.index === 1) {
                if (this.eng) {
                  this.eng.restart();
                  this.refreshFromEngine();
                }
                this.usedHints = 0;
                this.clueCount = 0;
                try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
              }
            });
          })
        }.padding({ left: 20, right: 20 })

        // 剧情文本区域
        Column() {
          Text(this.sceneText)
            .fontSize(16)
            .lineHeight(26)
            .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        }
        .backgroundColor('#F6F7F9')
        .borderRadius(16)
        .margin({ left: 20, right: 20 })

        // 选项提示
        if (this.choices.length > 0) {
          Text('📍 请选择你的行动：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .opacity(0.8)
            .padding({ left: 20 })
        }

        // 选择按钮
        Column({ space: 12 }) {
          ForEach(this.choices, (c: Choice, index: number) => {
            Button() {
              Row({ space: 8 }) {
                Text(`${index + 1}`).fontSize(14).opacity(0.5)
                Text(c.text).fontSize(15).layoutWeight(1).textAlign(TextAlign.Start)
                Text('→').fontSize(16).opacity(0.3)
              }.width('100%')
            }
            .type(ButtonType.Normal)
            .margin({ left: 20, right: 20 })
            .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
            .border({ width: 1, color: '#E5E7EB' })
            .onClick(() => {
              if (!this.eng) {
                return;
              }
              const result = this.eng.choose(c);
              if (result.ended) {
                this.navigateEnding(result.endingId);
              } else {
                this.refreshFromEngine();
              }
            })
          })
        }.padding({ bottom: 20 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

