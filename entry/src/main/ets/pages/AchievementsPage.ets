import router from '@ohos.router';
import { Achievement } from '../model/types';
import { getAchievements } from '../model/progress';

@Entry
@Component
struct AchievementsPage {
  @State achievements: Achievement[] = [];

  aboutToAppear() {
    this.achievements = getAchievements();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('成就墙').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
        Grid() {
          ForEach(this.achievements, (item: Achievement) => {
            GridItem() {
              Column({ space: 6 }) {
                Text(item.title).fontSize(14).fontWeight(FontWeight.Medium)
                Text(item.description).fontSize(12).opacity(0.6)
                Text(item.unlocked ? '已解锁' : `进度 ${(Math.round(item.progress * 100)).toString()}%`).fontSize(12).opacity(0.6)
              }.padding(16)
                .backgroundColor(item.unlocked ? '#E5F5EA' : '#F0F2F5')
                .borderRadius(16)
                .opacity(item.unlocked ? 1 : 0.6)
            }
          }, (item: Achievement) => item.id)
        }.columnsTemplate('1fr 1fr').rowsTemplate('auto').columnsGap(12).rowsGap(12).padding({ left: 20, right: 20 })
        Button('返回').onClick(() => { try { router.back() } catch (_) {} }).margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

