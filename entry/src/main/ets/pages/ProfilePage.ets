import router from '@ohos.router';
import { listHistory, getAchievements, getUserSettings } from '../model/progress';
import { Achievement, HistoryEntry, UserSettings } from '../model/types';
import { WarmTheme, WarmShadow } from './uiTheme';

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
          Text('我的').fontSize(28).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary)
          Text(this.tagline).fontSize(13).fontColor(WarmTheme.textSecondary)
        }.padding({ left: 24, right: 24, top: 28 })

        Column({ space: 8 }) {
          Text(this.nickname).fontSize(20).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
          Text('首个剧本完成于 11/13/2025').fontSize(12).fontColor(WarmTheme.textSecondary)
        }.padding({ left: 24, right: 24, bottom: 8 })

        // 游玩历史
        Column({ space: 12 }) {
          Row({ space: 10 }) {
            Text('游玩历史').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
            Blank()
            Button('查看全部')
              .type(ButtonType.Capsule)
              .fontSize(12)
              .backgroundColor(WarmTheme.accent)
              .fontColor('#FFFFFF')
              .onClick(() => {
                if (this.history.length > 0) {
                  try { router.pushUrl({ url: 'pages/HistoryPage' }) } catch (_) {}
                }
              })
          }.padding({ left: 24, right: 24 })

          Column({ space: 12 }) {
            ForEach(this.history.slice(0, 3), (item: HistoryEntry) => {
              this.historyCard(item)
            }, (item: HistoryEntry) => item.sessionId)
            if (this.history.length === 0) {
              Text('暂无游玩记录，去体验一个剧本吧！').fontSize(12).fontColor(WarmTheme.textSecondary).padding({ left: 24, right: 24 })
            }
          }
        }

        // 成就
        Column({ space: 10 }) {
          Text('成就').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary).padding({ left: 24, right: 24 })
          Row({ space: 12 }) {
            ForEach(this.achievements.slice(0, 2), (ach: Achievement) => {
              Column({ space: 4 }) {
                Text(ach.title).fontSize(13).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                Text(ach.description).fontSize(11).fontColor(WarmTheme.textSecondary)
                Text(ach.unlocked ? '已解锁' : `进度 ${ach.progress}`).fontSize(10).fontColor(WarmTheme.accentDark)
              }
              .padding(16)
              .backgroundColor(WarmTheme.softCard)
              .borderRadius(20)
            }, (ach: Achievement) => ach.id)
          }.padding({ left: 24, right: 24 })

          Button('成就墙')
            .type(ButtonType.Capsule)
            .fontSize(13)
            .backgroundColor(WarmTheme.accent)
            .fontColor('#FFFFFF')
            .margin({ left: 24, right: 24 })
            .onClick(() => { try { router.pushUrl({ url: 'pages/AchievementsPage' }) } catch (_) {} })
        }

        // 快捷入口
        Column({ space: 10 }) {
          Text('快捷入口').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary).padding({ left: 24, right: 24 })
          Column({ space: 12 }) {
            this.quickEntry('下载管理', () => { try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {} })
            this.quickEntry('推理笔记', () => { try { router.pushUrl({ url: 'pages/NotesPage', params: { id: 'demo' } }) } catch (_) {} })
            this.quickEntry('设置中心', () => { try { router.pushUrl({ url: 'pages/SettingsPage' }) } catch (_) {} })
          }.padding({ left: 24, right: 24 })
        }

        // 底部留白
        Blank().height(20)
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor(WarmTheme.background)
  }

  @Builder
  private historyCard(entry: HistoryEntry) {
    Column({ space: 6 }) {
      Text(`${entry.scriptId} · ${entry.endingTitle}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
      Text(this.formatTime(entry.timestamp)).fontSize(11).fontColor(WarmTheme.textSecondary)
      Button('详情')
        .type(ButtonType.Capsule)
        .fontSize(12)
        .backgroundColor('#F3E6DA')
        .fontColor(WarmTheme.textPrimary)
        .width('32%')
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/HistoryDetailPage', params: { id: entry.sessionId } }) } catch (_) {}
        })
    }
    .padding(16)
    .backgroundColor(WarmTheme.card)
    .borderRadius(20)
    .shadow(WarmShadow.light)
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
      .backgroundColor(WarmTheme.accent)
      .fontColor('#FFFFFF')
      .width('100%')
      .onClick(() => { try { action() } catch (_) {} })
  }
}

