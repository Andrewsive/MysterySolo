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
          Text('历史详情').fontSize(26).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')

          if (!this.loaded) {
            Column({ space: 12 }) {
              Text('未找到游玩记录').fontSize(16).fontColor('#666666').padding({ top: 40 })
              Button('返回')
                .backgroundColor('#E6EFFF')
                .fontColor('#3B73FE')
                .onClick(() => { try { router.back() } catch (_) {} })
            }
          } else {
            Column({ space: 12 }) {
              Text(`剧本 ${this.scriptId}`).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
              Text(`${new Date(this.timestamp).toLocaleString()} · 得分 ${this.score}`).fontSize(12).fontColor('#666666')
              Text(`结局：${this.endingTitle}`).fontSize(14).fontColor('#1A1A1A')
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

            Column({ space: 8 }) {
              Text('线路回放').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
              ForEach(this.trail, (step: TrailEntry, index?: number) => {
                Column({ space: 4 }) {
                  Text(`步骤 ${(index ?? 0) + 1}`).fontSize(12).fontColor('#666666')
                  Text(step.choiceText).fontSize(14).fontColor('#1A1A1A')
                }.padding({ top: 10, bottom: 10, left: 16, right: 16 }).backgroundColor('#FFFFFF').borderRadius(12).shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.08)', offsetY: 1 })
              }, (step: TrailEntry) => `${step.sceneId}-${step.choiceText}`)
            }

            Column({ space: 8 }) {
              Text('收集线索').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
              ForEach(this.clues, (id: string) => {
                Text(`· ${id}`).fontSize(13).fontColor('#666666')
              }, (id: string) => id)
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

            // 底部按钮放在滚动区域内
            Row({ space: 12 }) {
              Button('再次挑战')
                .type(ButtonType.Capsule)
                .layoutWeight(1)
                .backgroundColor('#3B73FE')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.scriptId } }) } catch (_) {}
                })
              Button('返回')
                .layoutWeight(1)
                .backgroundColor('#E6EFFF')
                .fontColor('#3B73FE')
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
      .backgroundColor('#F1F5F9')
    }
    .height('100%')
    .backgroundColor('#F1F5F9')
  }
}

