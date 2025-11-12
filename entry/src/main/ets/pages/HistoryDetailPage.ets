import router from '@ohos.router';
import { HistoryParams, TrailEntry } from '../model/types';
import { getHistoryById } from '../model/progress';

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
    Scroll() {
      Column({ space: 18 }) {
        Text('历史详情').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })

        if (!this.loaded) {
          Column({ space: 12 }) {
            Text('未找到游玩记录').fontSize(16).padding({ top: 40 })
            Button('返回').onClick(() => { try { router.back() } catch (_) {} })
          }.padding({ left: 20, right: 20 })
        } else {
          Column({ space: 12 }) {
            Text(`剧本 ${this.scriptId}`).fontSize(18).fontWeight(FontWeight.Medium)
            Text(`${new Date(this.timestamp).toLocaleString()} · 得分 ${this.score}`).fontSize(12).opacity(0.6)
            Text(`结局：${this.endingTitle}`).fontSize(14)
          }.padding({ left: 20, right: 20 })

          Column({ space: 8 }) {
            Text('线路回放').fontSize(16).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(this.trail, (step: TrailEntry, index?: number) => {
              Column({ space: 4 }) {
                Text(`步骤 ${(index ?? 0) + 1}`).fontSize(12).opacity(0.6)
                Text(step.choiceText).fontSize(14)
              }.padding({ left: 20, right: 20, top: 10, bottom: 10 }).backgroundColor('#FFFFFF').borderRadius(14)
            }, (step: TrailEntry) => `${step.sceneId}-${step.choiceText}`)
          }

          Column({ space: 8 }) {
            Text('收集线索').fontSize(16).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(this.clues, (id: string) => {
              Text(`· ${id}`).fontSize(13).opacity(0.65)
            }, (id: string) => id)
          }

          Column({ space: 12 }) {
            Button('再次挑战').type(ButtonType.Capsule).onClick(() => {
              try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.scriptId } }) } catch (_) {}
            })
            Button('返回').onClick(() => { try { router.back() } catch (_) {} })
          }.margin({ left: 20, right: 20, bottom: 24 })
        }
      }
    }.scrollBar(BarState.Off).backgroundColor('#F6F7F9').height('100%')
  }
}

