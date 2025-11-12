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
  @State keyword: string = '';
  @State activeTab: number = 0;

  aboutToAppear() {
    if (!hasOnboarded()) {
      try { router.replaceUrl({ url: 'pages/OnboardingPage' }) } catch (_) {}
    }
  }

  private filtered(): ShortScript[] {
    return this.data.filter((s: ShortScript) => this.matchTab(s) && this.matchKeyword(s));
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

  private difficultyLabel(d: number): string {
    if (d <= 1) return '新手友好';
    if (d === 2) return '进阶挑战';
    return '硬核逻辑';
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 6 }) {
          Text('谜境独白').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
          Text('随时沉浸单人剧本杀，记录你的推理灵感').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
        }

        Column({ space: 16 }) {
          TextInput({ placeholder: '搜索剧本或标签' })
            .onChange((v: string) => { this.keyword = v })
            .onSubmit(() => {
              try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {}
            })
            .margin({ left: 20, right: 20 })

          Row({ space: 10 }) {
            ForEach(this.tabs, (tab: TabEntry) => {
              Button(tab.label)
                .type(this.activeTab === tab.idx ? ButtonType.Capsule : ButtonType.Normal)
                .fontSize(13)
                .padding({ left: 14, right: 14 })
                .onClick(() => { this.activeTab = tab.idx; })
            }, (tab: TabEntry) => tab.idx.toString())
            Blank()
          }.margin({ left: 20, right: 20 })

          Row({ space: 12 }) {
            Button('剧本库')
              .type(ButtonType.Capsule)
              .onClick(() => { try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {} })
            Button('下载管理')
              .onClick(() => { try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {} })
            Button('个人中心')
              .onClick(() => { try { router.pushUrl({ url: 'pages/ProfilePage' }) } catch (_) {} })
            Blank()
          }.margin({ left: 20, right: 20 })
        }

        Column() {
          Column() {
            Text('今日计划').fontSize(16).fontWeight(FontWeight.Medium)
            Text('15 分钟预热 · 25 分钟沉浸 · 5 分钟记录结论').fontSize(12).opacity(0.6)
          }.padding({ left: 20, right: 20 })
          Column({ space: 8 }) {
            Row() {
              Column() {
                Text('专注提醒').fontSize(14).opacity(0.7)
                Text('记得同步线索到笔记').fontSize(16).fontWeight(FontWeight.Medium)
              }
              Blank()
              Button('打开笔记').onClick(() => {
                try { router.pushUrl({ url: 'pages/NotesPage', params: { id: 'demo' } }) } catch (_) {}
              })
            }
            Row() {
              Column() {
                Text('累计演绎时长').fontSize(12).opacity(0.6)
                Text('2 小时 15 分').fontSize(20).fontWeight(FontWeight.Bold)
              }
              Blank()
              Column({ space: 4 }) {
                Text('最近结局').fontSize(12).opacity(0.6)
                Text('脱身 · 92 分').fontSize(16)
              }
            }
          }.backgroundColor('#F0F2F5').padding(16).margin({ left: 20, right: 20 }).borderRadius(16)
        }

        Column({ space: 12 }) {
          Text('精选剧本').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
          Column({ space: 12 }) {
            ForEach(this.filtered(), (item: ShortScript) => {
              Column({ space: 8 }) {
                Row() {
                  Column({ space: 6 }) {
                    Text(item.title).fontSize(18).fontWeight(FontWeight.Medium)
                    if (item.tagline) {
                      Text(item.tagline).fontSize(13).opacity(0.7)
                    }
                    Text(`${this.difficultyLabel(item.difficulty)} · 约 ${item.durationMin} 分钟`).fontSize(12).opacity(0.55)
                    if (item.rating) {
                      Text(`评分 ${item.rating?.toFixed(1)}`).fontSize(12).opacity(0.55)
                    }
                    if (item.tags) {
                      Row({ space: 6 }) {
                        ForEach(item.tags, (tag: string) => {
                          Text(`#${tag}`).fontSize(11).opacity(0.6)
                            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                            .backgroundColor('#EEF1F5').borderRadius(12)
                        }, (tag: string) => tag)
                      }
                    }
                    if (item.offlineAvailable) {
                      Text('离线可玩').fontSize(11).opacity(0.7)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor('#E5F5EA').borderRadius(12)
                    }
                  }
                  Blank()
                  Button('体验').onClick(() => {
                    try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } }) } catch (_) {}
                  })
                }
              }.padding({ left: 20, right: 20, top: 14, bottom: 14 }).backgroundColor('#FFFFFF').borderRadius(18)
            }, (item: ShortScript) => item.id)
          }.padding({ bottom: 24 })
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#F6F7F9')
  }
}

@Preview
@Component
struct HomePreview { build() { HomePage() } }
