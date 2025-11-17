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
  @State rating: number = 0;
  @State ratingBreakdown: number[] = [0, 0, 0];
  @State highlightCards: string[] = [];
  @State genre: string = '';
  @State coverSeed: string = '剧';
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
      this.rating = s.rating ?? 8.6;
      const base = this.rating;
      this.ratingBreakdown = [
        Math.min(9.9, parseFloat((base + 0.2).toFixed(1))),
        Math.min(9.8, parseFloat((base - 0.1).toFixed(1))),
        Math.min(9.5, parseFloat((base - 0.3).toFixed(1)))
      ];
      this.highlightCards = s.highlights ? s.highlights.map((h) => `${h.title} · ${h.description}`) : [];
      this.genre = s.genre ?? '悬疑';
      this.coverSeed = s.title.length > 0 ? s.title.substring(0, 1) : '剧';
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
      this.rating = 0;
      this.ratingBreakdown = [0, 0, 0];
      this.highlightCards = [];
      this.genre = '';
      this.coverSeed = '剧';
      this.loaded = false;
    }
  }

  private difficultyLabel(): string {
    if (this.difficulty <= 1) return '新手友好';
    if (this.difficulty === 2) return '进阶挑战';
    return '硬核逻辑';
  }

  private accentColor(): string {
    return '#FFB548';
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        if (!this.loaded) {
          Text('加载中…').padding(16).fontColor('#FFFFFF')
        } else {
          Column({ space: 18 }) {
            Row({ space: 12 }) {
              Button('◀').backgroundColor('transparent').fontColor('#FFFFFF').onClick(() => {
                try { router.back() } catch (_) {}
              })
              Text('剧本详情').fontColor('#BBBBBB').fontSize(13)
              Blank()
              Text('⤴').fontSize(16).fontColor('#BBBBBB')
            }
            .padding({ left: 20, right: 20, top: 6 })

            Column({ space: 16 }) {
              Row({ space: 16 }) {
                Column() {
                  Text(this.coverSeed).fontSize(34).fontWeight(FontWeight.Bold).fontColor('#2B1700')
                }
                .width(110)
                .height(150)
                .backgroundColor('#FFE7C4')
                .borderRadius(20)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Column({ space: 10 }) {
                  Column({ space: 4 }) {
                    Text(this.title).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
                    if (this.tagline.length > 0) {
                      Text(this.tagline).fontSize(13).fontColor('#FFC46C')
                    }
                  }
                  Row({ space: 8 }) {
                    Text(this.genre).fontSize(12).fontColor('#FFFFFF').opacity(0.8)
                    Text(this.difficultyLabel()).fontSize(12).fontColor('#FFFFFF').opacity(0.8)
                    Text(`约 ${this.durationMin} 分钟`).fontSize(12).fontColor('#FFFFFF').opacity(0.7)
                  }
                  Row({ space: 6 }) {
                    ForEach(this.tags.slice(0, 4), (tag: string) => {
                      Text(tag)
                        .fontSize(11)
                        .fontColor('#FFF')
                        .opacity(0.8)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor('rgba(255,255,255,0.12)')
                        .borderRadius(12)
                    })
                  }
                }.layoutWeight(1)
              }

              Row({ space: 12 }) {
                Button('想玩').backgroundColor('#2A2A2E').fontColor('#FFC46C').borderRadius(18)
                Button('评价').backgroundColor('#2A2A2E').fontColor('#FFFFFF').borderRadius(18)
                Blank()
              }
            }
            .padding(20)
            .backgroundColor('#1F1F23')
            .borderRadius(28)
          }

          Column({ space: 16 }) {
            Text('蜜逃君评分').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text(this.rating.toFixed(1)).fontSize(34).fontWeight(FontWeight.Bold).fontColor(this.accentColor())
                Text('综合评分').fontSize(12).fontColor('#AAAAAA')
                Text('超过 14466 位玩家评分').fontSize(10).fontColor('#6F6F6F')
              }
              Column({ space: 12 }) {
                ForEach(['剧情', '情绪', '推理'], (label: string, index: number) => {
                  Row({ space: 10 }) {
                    Text(label).fontSize(12).fontColor('#AAAAAA')
                    Progress({ value: this.ratingBreakdown[index], total: 10, type: ProgressType.Linear })
                      .layoutWeight(1)
                      .height(4)
                    Text(this.ratingBreakdown[index].toFixed(1)).fontSize(12).fontColor('#FFFFFF')
                  }
                })
              }.layoutWeight(1)
            }.padding(16).backgroundColor('#1F1F23').borderRadius(24)
          }.padding({ left: 20, right: 20 })

          Column({ space: 12 }) {
            Text('剧情简介').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            Text(this.intro).fontSize(14).lineHeight(24).fontColor('#DDDDDD')
          }.padding({ left: 20, right: 20 })

          if (this.highlightCards.length > 0 || this.mood.length > 0 || this.highlight.length > 0) {
            Column({ space: 12 }) {
              if (this.mood.length > 0) {
                Column({ space: 6 }) {
                  Text('沉浸氛围').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
                  Text(this.mood).fontSize(13).fontColor('#DDDDDD')
                }
              }
              if (this.highlight.length > 0) {
                Column({ space: 6 }) {
                  Text('亮点设定').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
                  Text(this.highlight).fontSize(13).fontColor('#DDDDDD')
                }
              }
              ForEach(this.highlightCards, (desc: string) => {
                Text(desc).fontSize(13).fontColor('#DCDCDC').padding({ top: 6, bottom: 6 })
                  .backgroundColor('#2C2C33').borderRadius(12).padding({ left: 12, right: 12 })
              }, (desc: string) => desc)
            }.padding({ left: 20, right: 20 }).backgroundColor('#1A1A1F').borderRadius(24).padding({ top: 16, bottom: 16 })
          }

          Button('立即开始推理')
            .type(ButtonType.Capsule)
            .fontSize(16)
            .backgroundColor(this.accentColor())
            .fontColor('#3B2200')
            .margin({ left: 20, right: 20, bottom: 32 })
            .onClick(() => {
              try { router.pushUrl({ url: 'pages/PlayPage', params: { id: this.sId } }) } catch (_) {}
            })
        }
      }.padding({ bottom: 20 })
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#0F0F14')
  }
} 
