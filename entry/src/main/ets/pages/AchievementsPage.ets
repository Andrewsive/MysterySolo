import router from '@ohos.router';
import { Achievement } from '../model/types';
import { getAchievements } from '../model/progress';
import { WarmTheme } from './uiTheme';

@Entry
@Component
struct AchievementsPage {
  @State achievements: Achievement[] = [];

  aboutToAppear() {
    this.achievements = getAchievements();
  }

  build() {
    Column({ space: 14 }) {
      // 页面标题
      Column({ space: 4 }) {
        Text('成就墙').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Text('你的推理成就记录').fontSize(12).fontColor('#666666')
      }
      .padding({ top: 20, left: 20, right: 20 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      
      // 成就卡片列表
      Column({ space: 12 }) {
        ForEach(this.achievements, (item: Achievement) => {
          Row({ space: 10 }) {
            Text(item.unlocked ? '🏆' : '🔒').fontSize(18)
            Column({ space: 2 }) {
              Text(item.title).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
              Text(item.description).fontSize(12).fontColor('#666666')
              Text(item.unlocked ? '✅ 已解锁' : `📊 进度 ${(Math.round(item.progress * 100)).toString()}%`)
                .fontSize(11)
                .fontColor(item.unlocked ? '#3B73FE' : '#999999')
                .margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .padding(14)
          .backgroundColor(item.unlocked ? '#E6EFFF' : '#FFFFFF')
          .borderRadius(15)
          .alignItems(VerticalAlign.Top)
          .width('100%')
          .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.08)', offsetY: 1 })
        }, (item: Achievement) => item.id)
      }.padding({ left: 20, right: 20 }).layoutWeight(1)
      
      // 返回按钮
      Button('返回')
        .type(ButtonType.Capsule)
        .backgroundColor('#3B73FE')
        .fontColor('#FFFFFF')
        .onClick(() => { try { router.back() } catch (_) {} })
        .margin({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F5F9')
  }
}

