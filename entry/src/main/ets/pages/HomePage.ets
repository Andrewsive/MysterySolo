import router from '@ohos.router';
import { listScripts } from '../model/store';
import { ShortScript } from '../model/types';
import { hasOnboarded } from '../model/progress';
import { WarmTheme, WarmShadow } from './uiTheme';

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

  private coverColor(id: string): string {
    const palette: string[] = ['#FFE9DA', '#FEE0C6', '#FFEFD7', '#FFDACF', '#FFF2E2'];
    let hash = 0;
    for (let i = 0; i < id.length; i++) {
      hash += id.charCodeAt(i);
    }
    return palette[Math.abs(hash) % palette.length];
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 18 }) {
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text('你好，推理旅人').fontSize(20).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
              Text('继续在独白世界里寻找真相').fontSize(12).fontColor(WarmTheme.textSecondary)
            }.layoutWeight(1)
            Button('🔔').backgroundColor('transparent').onClick(() => {})
          }.padding({ left: 20, right: 20, top: 16 })

          Column({ space: 12 }) {
            Row({ space: 10 }) {
              Text('🔍').fontSize(16)
              TextInput({ placeholder: '搜索剧本 / 标签 / 作者' })
                .onChange((v: string) => { this.keyword = v })
                .layoutWeight(1)
              Button('筛选').fontSize(12).backgroundColor(WarmTheme.card)
            }
            .padding({ left: 18, right: 18 })
            .height(50)
            .backgroundColor('#FFFFFF')
            .borderRadius(28)
            .shadow(WarmShadow.light)

            Row({ space: 10 }) {
              ForEach(this.filterGroups, (label: string) => {
                Row({ space: 4 }) {
                  Text(label).fontSize(12)
                  Text('▾').fontSize(10).opacity(0.7)
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#FFEFE0')
                .borderRadius(16)
              }, (label: string) => label)
            }

            Row({ space: 10 }) {
              ForEach(this.tabs, (tab: TabEntry) => {
                Button(tab.label)
                  .type(this.activeTab === tab.idx ? ButtonType.Capsule : ButtonType.Normal)
                  .backgroundColor(this.activeTab === tab.idx ? WarmTheme.card : '#FFE9DA')
                  .fontColor(this.activeTab === tab.idx ? WarmTheme.textPrimary : WarmTheme.textSecondary)
                  .fontSize(12)
                  .padding({ left: 18, right: 18 })
                  .onClick(() => { this.activeTab = tab.idx; })
              }, (tab: TabEntry) => tab.idx.toString())
            }
          }.padding({ left: 20, right: 20, bottom: 12 })
        }
        .backgroundColor(WarmTheme.softCard)
        .borderRadius({ bottomLeft: 32, bottomRight: 32 })

        Column({ space: 10 }) {
          Text('热门玩法').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary).padding({ left: 20, right: 20 })
          Row({ space: 8 }) {
            ForEach(this.moodOptions, (label: string) => {
              Button(label)
                .type(this.moodFilter === label ? ButtonType.Capsule : ButtonType.Normal)
                .fontSize(12)
                .padding({ left: 14, right: 14 })
                .backgroundColor(this.moodFilter === label ? WarmTheme.accentLight : '#F8E9DD')
                .fontColor(this.moodFilter === label ? WarmTheme.accentDark : WarmTheme.textSecondary)
                .onClick(() => { this.moodFilter = label; })
            }, (label: string) => label)
          }.margin({ left: 20, right: 20 })
        }

        Column({ space: 8 }) {
          Text('快捷入口').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary).padding({ left: 20, right: 20 })
          Row({ space: 12 }) {
            this.quickEntry('剧本库', () => { try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {} })
            this.quickEntry('下载管理', () => { try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {} })
            this.quickEntry('个人中心', () => { try { router.pushUrl({ url: 'pages/ProfilePage' }) } catch (_) {} })
          }.padding({ left: 20, right: 20 })
        }

        Column({ space: 16 }) {
          ForEach(this.filtered(), (item: ShortScript) => {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                Column() {
                  Text(item.title.length > 0 ? item.title.substring(0, 1) : '剧')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(WarmTheme.textPrimary)
                }
                .width(64)
                .height(84)
                .backgroundColor(this.coverColor(item.id))
                .borderRadius(22)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Column({ space: 6 }) {
                  Row({ space: 8 }) {
                    Text(item.title).fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1).fontColor(WarmTheme.textPrimary)
                    Text(item.rating ? `${item.rating.toFixed(1)}分` : '评分待定')
                      .fontSize(12).fontColor(WarmTheme.accentDark)
                  }.width('100%')
                  if (item.tagline) {
                    Text(item.tagline).fontSize(12).fontColor(WarmTheme.textSecondary).maxLines(2)
                  }
                  Text(`${this.difficultyLabel(item.difficulty)} · 约 ${item.durationMin} 分钟`).fontSize(11).fontColor(WarmTheme.textSecondary)
                  Row({ space: 6 }) {
                    if (item.tags) {
                      ForEach(item.tags.slice(0, 3), (tag: string) => {
                        Text(`#${tag}`).fontSize(10).fontColor(WarmTheme.textSecondary)
                          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                          .backgroundColor('#FFF2E5')
                          .borderRadius(10)
                      }, (tag: string) => tag)
                    }
                  }
                }.layoutWeight(1)
              }
              Row({ space: 10 }) {
                Button('想玩')
                  .fontSize(12)
                  .backgroundColor('#FFE1CD')
                  .fontColor(WarmTheme.accentDark)
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/PlayPage', params: { id: item.id } }) } catch (_) {}
                  })
                Button('笔记')
                  .fontSize(12)
                  .backgroundColor('#F6E7DF')
                  .fontColor(WarmTheme.textPrimary)
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/NotesPage', params: { id: item.id } }) } catch (_) {}
                  })
                Blank()
                Button('查看').type(ButtonType.Capsule).fontSize(13).backgroundColor(WarmTheme.accent).fontColor('#FFFFFF')
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } }) } catch (_) {}
                  })
              }
            }
            .padding(18)
            .backgroundColor(WarmTheme.card)
            .borderRadius(26)
            .shadow(WarmShadow.light)
          }, (item: ShortScript) => item.id)
        }.padding({ left: 20, right: 20, bottom: 48 })
      }
    }.scrollBar(BarState.Auto).height('100%').backgroundColor(WarmTheme.background)
  }

  @Builder
  private quickEntry(label: string, action: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(13)
      .layoutWeight(1)
      .backgroundColor(WarmTheme.accentLight)
      .fontColor(WarmTheme.accentDark)
      .onClick(() => { try { action() } catch (_) {} })
  }
}

@Preview
@Component
struct HomePreview { build() { HomePage() } }
