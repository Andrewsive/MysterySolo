import router from '@ohos.router';
import { getScript } from '../model/store';
import { ResultParams } from '../model/types';
import { getLastPlaySummary, buildReplaySuggestions, trailDisplay } from '../model/progress';

@Entry
@Component
struct ResultPage {
  @State sid: string = 'demo';
  @State endingId: string = 'ending_bad';
  @State title: string = '';
  @State summary: string = '';
  @State score: number = 0;
  @State clueIds: string[] = [];
  @State suggestions: string[] = [];
  @State trailLines: string[] = [];

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
    const last = getLastPlaySummary();
    if (last && last.scriptId === this.sid) {
      this.clueIds = last.clues;
      this.suggestions = buildReplaySuggestions(last);
      this.trailLines = trailDisplay(last.trail);
    } else {
      this.clueIds = [];
      this.suggestions = [];
      this.trailLines = [];
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

        if (this.clueIds.length > 0) {
          Column({ space: 8 }) {
            Text('关键线索').fontSize(16).fontWeight(FontWeight.Medium)
            ForEach(this.clueIds, (id: string) => {
              Text(`· ${id}`).fontSize(13).opacity(0.65)
            }, (id: string) => id)
          }.padding({ left: 20, right: 20 })
        }

        if (this.trailLines.length > 0) {
          Column({ space: 8 }) {
            Text('选择轨迹').fontSize(16).fontWeight(FontWeight.Medium)
            ForEach(this.trailLines, (line: string) => {
              Text(line).fontSize(13).opacity(0.65)
            }, (line: string) => line)
          }.padding({ left: 20, right: 20 })
        }

        Column({ space: 8 }) {
          Text('复盘建议').fontSize(16).fontWeight(FontWeight.Medium)
          if (this.suggestions.length === 0) {
            Text('暂无更多建议，尝试新的选择吧。').fontSize(13).opacity(0.6)
          } else {
            ForEach(this.suggestions, (text: string) => {
              Text(`· ${text}`).fontSize(13).opacity(0.7)
            }, (text: string) => text)
          }
        }.padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Button('回到首页').onClick(() => {
            try { router.replaceUrl({ url: 'pages/HomePage' }) } catch (_) {}
          })
          Button('再来一次').type(ButtonType.Capsule).onClick(() => {
            try { router.replaceUrl({ url: 'pages/PlayPage', params: { id: this.sid } }) } catch (_) {}
          })
          Button('撰写推理笔记').onClick(() => {
            try { router.pushUrl({ url: 'pages/NotesEditorPage', params: { id: this.sid } }) } catch (_) {}
          })
        }.margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

