import router from '@ohos.router';
import { getScript } from '../model/store';
import { DetailParams } from '../model/types';

@Entry
@Component
struct DetailPage {
  @State sId: string = 'demo';
  @State title: string = '';
  @State difficulty: number = 0;
  @State durationMin: number = 0;
  @State intro: string = '';
  @State tagline: string = '';
  @State tags: string[] = [];
  @State mood: string = '';
  @State highlight: string = '';
  @State loaded: boolean = false;

  aboutToAppear() {
    try {
      const p = router.getParams() as DetailParams | undefined;
      if (p && p.id) this.sId = p.id;
    } catch (_) {}

    const s = getScript(this.sId);
    if (s) {
      this.title = s.title;
      this.difficulty = s.difficulty;
      this.durationMin = s.durationMin;
      this.intro = s.intro;
      this.tagline = s.tagline ?? '';
      this.tags = s.tags ?? [];
      this.mood = s.mood ?? '';
      this.highlight = s.highlight ?? '';
      this.loaded = true;
    } else {
      this.title = '';
      this.difficulty = 0;
      this.durationMin = 0;
      this.intro = '';
      this.tagline = '';
      this.tags = [];
      this.mood = '';
      this.highlight = '';
      this.loaded = false;
    }
  }

  private difficultyLabel(): string {
    if (this.difficulty <= 1) return '新手友好';
    if (this.difficulty === 2) return '进阶挑战';
    return '硬核逻辑';
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (!this.loaded) {
          Text('加载中…').padding(16)
        } else {
          Column({ space: 10 }) {
            Text(this.title).fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 20, left: 20, right: 20 })
            if (this.tagline.length > 0) {
              Text(this.tagline).fontSize(14).opacity(0.65).padding({ left: 20, right: 20 })
            }
            Row({ space: 10 }) {
              Text(this.difficultyLabel()).fontSize(12).opacity(0.75).padding({ left: 10, right: 10, top: 6, bottom: 6 }).backgroundColor('#EEF1F5').borderRadius(12)
              Text(`约 ${this.durationMin} 分钟`).fontSize(12).opacity(0.75).padding({ left: 10, right: 10, top: 6, bottom: 6 }).backgroundColor('#EEF1F5').borderRadius(12)
            }.margin({ left: 20, right: 20 })
            if (this.tags.length > 0) {
              Row({ space: 6 }) {
                ForEach(this.tags, (tag: string) => {
                  Text(`#${tag}`).fontSize(11).opacity(0.6).padding({ left: 8, right: 8, top: 4, bottom: 4 }).backgroundColor('#F0F2F5').borderRadius(12)
                })
              }.margin({ left: 20, right: 20 })
            }
          }

          Column({ space: 12 }) {
            Text('故事简介').fontSize(18).fontWeight(FontWeight.Medium)
            Text(this.intro).fontSize(14).opacity(0.75)
          }.padding({ left: 20, right: 20 })

          if (this.mood.length > 0 || this.highlight.length > 0) {
            Column({ space: 12 }) {
              if (this.mood.length > 0) {
                Column({ space: 6 }) {
                  Text('沉浸氛围').fontSize(16).fontWeight(FontWeight.Medium)
                  Text(this.mood).fontSize(14).opacity(0.7)
                }
              }
              if (this.highlight.length > 0) {
                Column({ space: 6 }) {
                  Text('亮点设定').fontSize(16).fontWeight(FontWeight.Medium)
                  Text(this.highlight).fontSize(14).opacity(0.7)
                }
              }
            }.padding({ left: 20, right: 20 }).backgroundColor('#F6F7F9').borderRadius(16).padding({ top: 16, bottom: 16 })
          }

          Row({ space: 12 }) {
            Button('返回').onClick(() => { try { router.back() } catch (_) {} }).backgroundColor('#EEF1F5').fontColor('#333333')
            Button('开始推理').type(ButtonType.Capsule).onClick(() => {
              try { router.pushUrl({ url: 'pages/PlayPage', params: { id: this.sId } }) } catch (_) {}
            })
          }.margin({ left: 20, right: 20, bottom: 24 })
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}
