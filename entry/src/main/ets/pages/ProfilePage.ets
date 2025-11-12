import router from '@ohos.router';
import { listHistory, getAchievements, getUserSettings } from '../model/progress';
import { Achievement, HistoryEntry, UserSettings } from '../model/types';

@Entry
@Component
struct ProfilePage {
  @State history: HistoryEntry[] = [];
  @State achievements: Achievement[] = [];
  @State settings: UserSettings = getUserSettings();

  aboutToAppear() {
    this.history = listHistory();
    this.achievements = getAchievements();
    this.settings = getUserSettings();
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 6 }) {
          Text('我的').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
          Text('记录你的推理旅程与成就').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
        }

        Column({ space: 8 }) {
          Text('昵称').fontSize(14).opacity(0.6)
          Text('谜境旅人').fontSize(18).fontWeight(FontWeight.Medium)
          Text(`首个剧本完成于 ${(this.history.length > 0 ? new Date(this.history[this.history.length - 1].timestamp).toLocaleDateString() : '今日')}`).fontSize(12).opacity(0.5)
        }.padding({ left: 20, right: 20 }).backgroundColor('#F6F7F9').borderRadius(18).padding({ top: 16, bottom: 16 })

        Column({ space: 12 }) {
          Row() {
            Text('游玩历史').fontSize(18).fontWeight(FontWeight.Medium)
            Blank()
            Button('查看全部').onClick(() => { try { router.pushUrl({ url: 'pages/HistoryDetailPage', params: { id: this.history[0]?.sessionId } }) } catch (_) {} })
          }.padding({ left: 20, right: 20 })
          if (this.history.length === 0) {
            Text('还没有记录，去完成一场推理吧。').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
          } else {
            Column({ space: 10 }) {
              ForEach(this.history.slice(0, 5), (entry: HistoryEntry) => {
                Column({ space: 6 }) {
                  Row() {
                    Text(`${entry.scriptId} · ${entry.endingTitle}`).fontSize(15).fontWeight(FontWeight.Medium)
                    Blank()
                    Text(`${entry.score} 分`).fontSize(13).opacity(0.6)
                  }
                  Text(new Date(entry.timestamp).toLocaleString()).fontSize(12).opacity(0.5)
                  Button('详情').onClick(() => {
                    try { router.pushUrl({ url: 'pages/HistoryDetailPage', params: { id: entry.sessionId } }) } catch (_) {}
                  })
                }.padding({ left: 20, right: 20, top: 12, bottom: 12 }).backgroundColor('#FFFFFF').borderRadius(16)
              }, (entry: HistoryEntry) => entry.sessionId)
            }.padding({ bottom: 12 })
          }
        }

        Column({ space: 12 }) {
          Text('成就').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
          Row({ space: 12 }) {
            ForEach(this.achievements, (achievement: Achievement) => {
              Column({ space: 6 }) {
                Text(achievement.title).fontSize(14).fontWeight(FontWeight.Medium)
                Text(achievement.description).fontSize(12).opacity(0.6)
                Text(achievement.unlocked ? '已解锁' : `进度 ${(Math.round(achievement.progress * 100) / 100).toFixed(2)}`).fontSize(12).opacity(0.6)
              }.padding(14).backgroundColor(achievement.unlocked ? '#E5F5EA' : '#F6F7F9').borderRadius(16)
            }, (achievement: Achievement) => achievement.id)
          }.padding({ left: 20, right: 20 })
          Button('成就墙').onClick(() => { try { router.pushUrl({ url: 'pages/AchievementsPage' }) } catch (_) {} }).margin({ left: 20, right: 20 })
        }

        Column({ space: 12 }) {
          Text('快捷入口').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
          Column({ space: 10 }) {
            Button('下载管理').onClick(() => { try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {} })
            Button('推理笔记').onClick(() => { try { router.pushUrl({ url: 'pages/NotesEditorPage', params: { id: 'demo' } }) } catch (_) {} })
            Button('设置中心').onClick(() => { try { router.pushUrl({ url: 'pages/SettingsPage' }) } catch (_) {} })
          }.margin({ left: 20, right: 20 })
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#F6F7F9')
  }
}

