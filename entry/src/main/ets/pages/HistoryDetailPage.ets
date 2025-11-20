import router from '@ohos.router';
import { HistoryParams, TrailEntry } from '../model/types';
import { getHistoryById } from '../model/progress';
import { WarmTheme, WarmShadow } from './uiTheme';

@Entry
@Component
struct HistoryDetailPage {
  @State sessionId: string = '';
  @State scriptId: string = '';
  @State timestamp: number = 0;
  @State score: number = 0;
  @State endingTitle: string = '';
  @State trail: TrailEntry[] = [];
  @State clues: string[] = [];
  @State loaded: boolean = false;

  aboutToAppear() {
    try {
      const params = router.getParams() as HistoryParams | undefined;
      if (params && params.id) {
        this.sessionId = params.id;
      }
    } catch (_) {}
    
    if (this.sessionId.length > 0) {
      const entry = getHistoryById(this.sessionId);
      if (entry) {
        this.scriptId = entry.scriptId;
        this.timestamp = entry.timestamp;
        this.score = entry.score;
        this.endingTitle = entry.endingTitle;
        this.trail = entry.trail;
        this.clues = entry.clues;
        this.loaded = true;
      }
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Text('历史详情').fontSize(26).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary)

          if (!this.loaded) {
            Column({ space: 12 }) {
              Text('未找到游玩记录').fontSize(16).fontColor(WarmTheme.textSecondary).padding({ top: 40 })
              Button('返回').onClick(() => { try { router.back() } catch (_) {} })
            }
          } else {
            Column({ space: 12 }) {
              Text(`剧本 ${this.scriptId}`).fontSize(18).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
              Text(`${new Date(this.timestamp).toLocaleString()} · 得分 ${this.score}`).fontSize(12).fontColor(WarmTheme.textSecondary)
              Text(`结局：${this.endingTitle}`).fontSize(14).fontColor(WarmTheme.textPrimary)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .backgroundColor(WarmTheme.card)
            .borderRadius(20)
            .shadow(WarmShadow.light)

            Column({ space: 8 }) {
              Text('线路回放').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
              ForEach(this.trail, (step: TrailEntry, index?: number) => {
                Column({ space: 4 }) {
                  Text(`步骤 ${(index ?? 0) + 1}`).fontSize(12).fontColor(WarmTheme.textSecondary)
                  Text(step.choiceText).fontSize(14).fontColor(WarmTheme.textPrimary)
                }.padding({ top: 10, bottom: 10, left: 16, right: 16 }).backgroundColor(WarmTheme.card).borderRadius(16).shadow(WarmShadow.light)
              }, (step: TrailEntry) => `${step.sceneId}-${step.choiceText}`)
            }

            Column({ space: 8 }) {
              Text('收集线索').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
              ForEach(this.clues, (id: string) => {
                Text(`· ${id}`).fontSize(13).fontColor(WarmTheme.textSecondary)
              }, (id: string) => id)
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(WarmTheme.card)
            .borderRadius(20)
            .shadow(WarmShadow.light)

            // 底部按钮放在滚动区域内
            Row({ space: 12 }) {
              Button('再次挑战')
                .type(ButtonType.Capsule)
                .layoutWeight(1)
                .backgroundColor(WarmTheme.accent)
                .fontColor('#FFFFFF')
                .onClick(() => {
                  try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.scriptId } }) } catch (_) {}
                })
              Button('返回')
                .layoutWeight(1)
                .backgroundColor('#F6E1D4')
                .fontColor(WarmTheme.textPrimary)
                .onClick(() => { try { router.back() } catch (_) {} })
            }
            .padding({ top: 20 })
            .width('100%')
          }
        }
        .padding({ left: 20, right: 20, top: 24, bottom: 32 })
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(WarmTheme.background)
    }
    .height('100%')
    .backgroundColor(WarmTheme.background)
  }
}

