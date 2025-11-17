import router from '@ohos.router';
import { listScripts } from '../model/store';
import { ShortScript } from '../model/types';
import { hasOnboarded } from '../model/progress';

interface TabEntry {
  label: string;
  idx: number;
}

@Entry
@Component
struct HomePage {
  private data: ShortScript[] = listScripts();
  private tabs: TabEntry[] = [
    { label: '全部', idx: 0 },
    { label: '新手', idx: 1 },
    { label: '进阶', idx: 2 },
    { label: '硬核', idx: 3 }
  ];
  private filterGroups: string[] = ['主题', '类型', '人数', '玩法'];
  private moodOptions: string[] = ['全部', '欢乐', '情感', '硬核', '惊悚', '都市'];
  @State keyword: string = '';
  @State activeTab: number = 0;
  @State moodFilter: string = '全部';

  aboutToAppear() {
    if (!hasOnboarded()) {
      try { router.replaceUrl({ url: 'pages/OnboardingPage' }) } catch (_) {}
    }
  }

  private filtered(): ShortScript[] {
    return this.data.filter((s: ShortScript) => this.matchTab(s) && this.matchKeyword(s) && this.matchMood(s));
  }

  private matchTab(s: ShortScript): boolean {
    switch (this.activeTab) {
      case 1:
        return s.difficulty <= 1;
      case 2:
        return s.difficulty === 2;
      case 3:
        return s.difficulty >= 3;
      default:
        return true;
    }
  }

  private matchKeyword(s: ShortScript): boolean {
    const key = this.keyword.trim();
    if (key.length === 0) {
      return true;
    }
    if (s.title.includes(key)) {
      return true;
    }
    if (s.tagline && s.tagline.includes(key)) {
      return true;
    }
    return !!(s.tags && s.tags.some(tag => tag.includes(key)));
  }

  private matchMood(s: ShortScript): boolean {
    if (this.moodFilter === '全部') {
      return true;
    }
    return !!(s.tags && s.tags.some(tag => tag.includes(this.moodFilter)));
  }

  private difficultyLabel(d: number): string {
    if (d <= 1) return '新手友好';
    if (d === 2) return '进阶挑战';
    return '硬核逻辑';
  }

  private accentColor(): string {
    return '#F6B756';
  }

  private coverColor(id: string): string {
    const palette: string[] = ['#FEE5CF', '#E8F1FF', '#F5E4FF', '#EAF7EF', '#FFEAEA'];
    let hash = 0;
    for (let i = 0; i < id.length; i++) {
      hash += id.charCodeAt(i);
    }
    return palette[Math.abs(hash) % palette.length];
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        // 顶部大卡片
        Column({ space: 16 }) {
          Row({ space: 10 }) {
            Text('◀').opacity(0.7).fontSize(18).onClick(() => {
              try { router.back() } catch (_) {}
            })
            Column({ space: 2 }) {
              Text('主题剧本库').fontSize(22).fontWeight(FontWeight.Bold)
              Text('单人沉浸 · 卡片式精选').fontSize(12).opacity(0.65)
            }.alignItems(HorizontalAlign.Start)
            Blank()
            Text('⋯').fontSize(22).opacity(0.7)
          }.padding({ left: 20, right: 20, top: 8 })

          Row({ space: 10 }) {
            Text('🔍')
            TextInput({ placeholder: '搜剧本/标签/作者' })
              .onChange((v: string) => { this.keyword = v })
              .onSubmit(() => {
                try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {}
              })
              .layoutWeight(1)
            Button('筛选').fontSize(12).onClick(() => {})
          }
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .height(44)
          .margin({ left: 20, right: 20 })

          Row({ space: 12 }) {
            ForEach(this.filterGroups, (label: string) => {
              Row({ space: 4 }) {
                Text(label).fontSize(12)
                Text('▾').fontSize(10).opacity(0.6)
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,255,255,0.35)')
              .borderRadius(14)
            }, (label: string) => label)
          }.margin({ left: 20, right: 20, bottom: 4 })

          Row({ space: 10 }) {
            ForEach(this.tabs, (tab: TabEntry) => {
              Button(tab.label)
                .type(this.activeTab === tab.idx ? ButtonType.Capsule : ButtonType.Normal)
                .backgroundColor(this.activeTab === tab.idx ? '#FFFFFF' : 'rgba(255,255,255,0.35)')
                .fontColor(this.activeTab === tab.idx ? '#333333' : '#4B3C1F')
                .fontSize(12)
                .padding({ left: 18, right: 18 })
                .onClick(() => { this.activeTab = tab.idx; })
            }, (tab: TabEntry) => tab.idx.toString())
          }.margin({ left: 20, right: 20, bottom: 8 })
        }
        .padding({ bottom: 20, top: 12 })
        .backgroundColor(this.accentColor())
        .borderRadius({ bottomLeft: 28, bottomRight: 28 })

        // 分类 chips
        Column({ space: 8 }) {
          Text('热门玩法').fontSize(15).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
          Row({ space: 8 }) {
            ForEach(this.moodOptions, (label: string) => {
              Button(label)
                .type(this.moodFilter === label ? ButtonType.Capsule : ButtonType.Normal)
                .fontSize(12)
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.moodFilter === label ? '#FFECD2' : '#F3F4F7')
                .fontColor('#333333')
                .onClick(() => { this.moodFilter = label; })
            }, (label: string) => label)
          }.margin({ left: 20, right: 20 })
        }

        // 快速入口
        Column({ space: 8 }) {
          Text('快速入口').fontSize(15).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
          Row({ space: 12 }) {
            Button('剧本库')
              .type(ButtonType.Capsule)
              .backgroundColor('#FFE2C0')
              .fontColor('#5B2A00')
              .layoutWeight(1)
              .onClick(() => {
                try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {}
              })
            Button('下载管理')
              .backgroundColor('#FFF6E8')
              .fontColor('#8A4A00')
              .layoutWeight(1)
              .onClick(() => {
                try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {}
              })
            Button('个人中心')
              .backgroundColor('#F3F4F7')
              .fontColor('#333333')
              .layoutWeight(1)
              .onClick(() => {
                try { router.pushUrl({ url: 'pages/ProfilePage' }) } catch (_) {}
              })
          }.padding({ left: 20, right: 20 })
        }

        // 卡片列表
        Column({ space: 14 }) {
          ForEach(this.filtered(), (item: ShortScript) => {
            Column({ space: 12 }) {
              Row({ space: 14 }) {
                Column() {
                  Text(item.title.length > 0 ? item.title.substring(0, 1) : '剧')
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#5A4A2B')
                }
                .width(72)
                .height(96)
                .backgroundColor(this.coverColor(item.id))
                .borderRadius(18)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Column({ space: 6 }) {
                  Row({ space: 8 }) {
                    Text(item.title).fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1)
                    Text(item.rating ? `${item.rating.toFixed(1)}分` : '评分待定')
                      .fontSize(12).fontColor('#FF8A00')
                  }.width('100%')
                  if (item.tagline) {
                    Text(item.tagline).fontSize(12).opacity(0.7).maxLines(2)
                  }
                  Text(`${this.difficultyLabel(item.difficulty)} · 约 ${item.durationMin} 分钟`).fontSize(11).opacity(0.55)
                  Row({ space: 6 }) {
                    if (item.tags) {
                      ForEach(item.tags.slice(0, 3), (tag: string) => {
                        Text(tag).fontSize(10).opacity(0.75)
                          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                          .backgroundColor('#F4F4F5')
                          .borderRadius(12)
                      }, (tag: string) => tag)
                    }
                  }
                }.layoutWeight(1)
              }
              Row({ space: 10 }) {
                Button('想玩').fontSize(12).backgroundColor('#FFF5E3').fontColor('#C47A00')
                Button('评价').fontSize(12).backgroundColor('#F1F2F5').fontColor('#333333')
                Blank()
                Button('查看').type(ButtonType.Capsule).fontSize(13).backgroundColor('#FFB347').fontColor('#3A2200')
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } }) } catch (_) {}
                  })
              }
            }
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(22)
            .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 6 })
          }, (item: ShortScript) => item.id)
        }.padding({ left: 20, right: 20, bottom: 40 })
      }
    }.scrollBar(BarState.Auto).height('100%').backgroundColor('#F7F5F2')
  }
}

@Preview
@Component
struct HomePreview { build() { HomePage() } }
