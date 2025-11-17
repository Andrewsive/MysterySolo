import router from '@ohos.router';
import { listHistory, getAchievements, getUserSettings } from '../model/progress';
import { Achievement, HistoryEntry, UserSettings } from '../model/types';

interface IdParam {
  id: string;
}

@Entry
@Component
struct ProfilePage {
  @State history: HistoryEntry[] = [];
  @State achievements: Achievement[] = [];
  @State settings: UserSettings = getUserSettings();
  private nickname: string = '谜境旅人';
  private tagline: string = '记录你的推理履历与成就';

  aboutToAppear() {
    this.history = listHistory();
    this.achievements = getAchievements();
    this.settings = getUserSettings();
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        // 头部信息
        Column({ space: 6 }) {
          Text('我的').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#1F1F28')
          Text(this.tagline).fontSize(13).fontColor('#787C96')
        }.padding({ left: 24, right: 24, top: 28 })

        Column({ space: 8 }) {
          Text(this.nickname).fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1F1F28')
          Text('首个剧本完成于 11/13/2025').fontSize(12).fontColor('#8C8FA5')
        }.padding({ left: 24, right: 24, bottom: 8 })

        // 游玩历史
        Column({ space: 12 }) {
          Row({ space: 10 }) {
            Text('游玩历史').fontSize(16).fontWeight(FontWeight.Medium)
            Blank()
            Button('查看全部')
              .type(ButtonType.Capsule)
              .fontSize(12)
              .onClick(() => {
                if (this.history.length > 0) {
                  try { router.pushUrl({ url: 'pages/HistoryPage' }) } catch (_) {}
                }
              })
          }.padding({ left: 24, right: 24 })

          Column({ space: 10 }) {
            ForEach(this.history.slice(0, 3), (item: HistoryEntry) => {
              this.historyCard(item)
            }, (item: HistoryEntry) => item.sessionId)
            if (this.history.length === 0) {
              Text('暂无游玩记录，去体验一个剧本吧！').fontSize(12).fontColor('#979BB5').padding({ left: 24, right: 24 })
            }
          }
        }

        // 成就
        Column({ space: 10 }) {
          Text('成就').fontSize(16).fontWeight(FontWeight.Medium).padding({ left: 24, right: 24 })
          Row({ space: 12 }) {
            ForEach(this.achievements.slice(0, 2), (ach: Achievement) => {
              Column({ space: 4 }) {
                Text(ach.title).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#1F1F28')
                Text(ach.description).fontSize(11).fontColor('#6F728C')
                Text(ach.unlocked ? '已解锁' : `进度 ${ach.progress}`).fontSize(10).fontColor('#4B76FF')
              }
              .padding(14)
              .backgroundColor('#F2F4FF')
              .borderRadius(18)
            }, (ach: Achievement) => ach.id)
          }.padding({ left: 24, right: 24 })

          Button('成就墙')
            .type(ButtonType.Capsule)
            .fontSize(13)
            .margin({ left: 24, right: 24 })
            .onClick(() => { try { router.pushUrl({ url: 'pages/AchievementsPage' }) } catch (_) {} })
        }

        // 快捷入口
        Column({ space: 10 }) {
          Text('快捷入口').fontSize(16).fontWeight(FontWeight.Medium).padding({ left: 24, right: 24 })
          Column({ space: 12 }) {
            this.quickEntry('下载管理', () => { try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {} })
            this.quickEntry('推理笔记', () => { try { router.pushUrl({ url: 'pages/NotesPage', params: { id: 'demo' } }) } catch (_) {} })
            this.quickEntry('设置中心', () => { try { router.pushUrl({ url: 'pages/SettingsPage' }) } catch (_) {} })
          }.padding({ left: 24, right: 24 })
        }

        // 旧菜单入口（保持功能）
        Column({ space: 14 }) {
          this.menuItem('📒', 'Address book', 'pages/HistoryDetailPage', this.history[0]?.sessionId)
          this.menuItem('📁', 'Document management', 'pages/NotesEditorPage', 'demo')
          this.menuItem('💬', 'Message', 'pages/AchievementsPage', undefined, 'N')
          this.menuItem('⚙️', 'Setting', 'pages/SettingsPage')
          this.menuItem('🗑️', 'Recycle bin', 'pages/DownloadsPage')
          this.menuItem('ℹ️', 'Help center', 'pages/NotesPage', 'demo')
        }.padding({ left: 24, right: 24, bottom: 40 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#F9F8FB')
  }

  @Builder
  private historyCard(entry: HistoryEntry) {
    Column({ space: 6 }) {
      Text(`${entry.scriptId} · ${entry.endingTitle}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E223A')
      Text(this.formatTime(entry.timestamp)).fontSize(11).fontColor('#8C90A8')
      Button('详情')
        .type(ButtonType.Capsule)
        .fontSize(12)
        .width('32%')
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/HistoryDetailPage', params: { id: entry.sessionId } }) } catch (_) {}
        })
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .margin({ left: 24, right: 24 })
  }

  private formatTime(ts: number): string {
    const date = new Date(ts);
    return `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()} ${date.toLocaleTimeString()}`;
  }

  @Builder
  private quickEntry(label: string, action: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .fontSize(13)
      .width('100%')
      .onClick(() => { try { action() } catch (_) {} })
  }

  @Builder
  private menuItem(icon: string, label: string, url: string, param?: string, badge?: string) {
    Row({ space: 12 }) {
      Column() {
        Text(icon).fontSize(20)
      }
      .width(46)
      .height(46)
      .borderRadius(23)
      .backgroundColor('#E8EEFF')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Text(label).layoutWeight(1).fontSize(15).fontColor('#2C365E')
      if (badge) {
        Text(badge)
          .fontSize(11)
          .fontColor('#FFFFFF')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#FF4D5A')
          .borderRadius(10)
      }
      Text('>').fontSize(14).opacity(0.4)
    }
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 6, color: '#0F000010', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      try {
        if (param) {
          const paramsObj: IdParam = { id: param };
          router.pushUrl({ url, params: paramsObj });
        } else {
          router.pushUrl({ url });
        }
      } catch (_) {}
    })
  }
}

