import router from '@ohos.router';
import { listScripts } from '../model/store';
import { ShortScript } from '../model/types';
import { hasOnboarded } from '../model/progress';
import { WarmTheme, WarmShadow } from './uiTheme';

interface TabEntry {
  label: string;
  idx: number;
}

interface Notification {
  id: string;
  title: string;
  content: string;
  time: string;
  read: boolean;
  type: 'new' | 'activity' | 'system';
}

@Entry
@Component
struct HomePage {
  private data: ShortScript[] = listScripts();
  private filterGroups: string[] = ['主题', '类型', '玩法', '难度'];
  private themeOptions: string[] = ['全部', '古宅', '都市', '艺术', '情感'];
  private genreOptions: string[] = ['全部', '线索追踪', '轻推理', '逻辑推理', '多结局'];
  private playOptions: string[] = ['全部', '单线解谜', '情感', '推理'];
  private difficultyOptions: string[] = ['全部', '新手', '进阶', '硬核'];
  private moodOptions: string[] = ['全部', '情感', '推理', '艺术', '都市'];
  @State keyword: string = '';
  @State moodFilter: string = '全部';
  @State expandedFilter: string = ''; // 当前展开的筛选项
  @State selectedTheme: string = '全部';
  @State selectedGenre: string = '全部';
  @State selectedPlay: string = '全部';
  @State selectedDifficulty: string = '全部';
  @State showNotifications: boolean = false;
  @State showNotificationDetail: boolean = false;
  @State selectedNotification: Notification | null = null;
  @State notifications: Notification[] = [
    {
      id: 'n1',
      title: '新剧本上线',
      content: '「静物画室」已解锁，挑战艺术系硬核推理！',
      time: '10分钟前',
      read: false,
      type: 'new'
    },
    {
      id: 'n2',
      title: '限时活动',
      content: '完成3个剧本即可解锁隐藏结局，活动倒计时3天',
      time: '1小时前',
      read: false,
      type: 'activity'
    },
    {
      id: 'n3',
      title: '游戏提示',
      content: '记得使用笔记功能记录线索，可大幅提升推理效率',
      time: '昨天',
      read: true,
      type: 'system'
    }
  ];

  aboutToAppear() {
    if (!hasOnboarded()) {
      try { router.replaceUrl({ url: 'pages/OnboardingPage' }) } catch (_) {}
    }
  }

  private filtered(): ShortScript[] {
    return this.data.filter((s: ShortScript) => 
      this.matchKeyword(s) && 
      this.matchMood(s) &&
      this.matchTheme(s) &&
      this.matchGenre(s) &&
      this.matchPlay(s) &&
      this.matchDifficulty(s)
    );
  }

  private matchTheme(s: ShortScript): boolean {
    if (this.selectedTheme === '全部') {
      return true;
    }
    return !!(s.tags && s.tags.some(tag => tag.includes(this.selectedTheme)));
  }

  private matchGenre(s: ShortScript): boolean {
    if (this.selectedGenre === '全部') {
      return true;
    }
    return !!(s.tags && s.tags.some(tag => tag.includes(this.selectedGenre)));
  }

  private matchPlay(s: ShortScript): boolean {
    if (this.selectedPlay === '全部') {
      return true;
    }
    return !!(s.tags && s.tags.some(tag => tag.includes(this.selectedPlay)));
  }

  private matchDifficulty(s: ShortScript): boolean {
    if (this.selectedDifficulty === '全部') {
      return true;
    }
    switch (this.selectedDifficulty) {
      case '新手':
        return s.difficulty <= 1;
      case '进阶':
        return s.difficulty === 2;
      case '硬核':
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

  private toggleFilter(filterName: string) {
    if (this.expandedFilter === filterName) {
      this.expandedFilter = '';
    } else {
      this.expandedFilter = filterName;
    }
  }

  private getFilterOptions(filterName: string): string[] {
    switch (filterName) {
      case '主题':
        return this.themeOptions;
      case '类型':
        return this.genreOptions;
      case '玩法':
        return this.playOptions;
      case '难度':
        return this.difficultyOptions;
      default:
        return [];
    }
  }

  private getSelectedValue(filterName: string): string {
    switch (filterName) {
      case '主题':
        return this.selectedTheme;
      case '类型':
        return this.selectedGenre;
      case '玩法':
        return this.selectedPlay;
      case '难度':
        return this.selectedDifficulty;
      default:
        return '全部';
    }
  }

  private selectFilterOption(filterName: string, option: string) {
    switch (filterName) {
      case '主题':
        this.selectedTheme = option;
        break;
      case '类型':
        this.selectedGenre = option;
        break;
      case '玩法':
        this.selectedPlay = option;
        break;
      case '难度':
        this.selectedDifficulty = option;
        break;
    }
    this.expandedFilter = '';
  }

  private getUnreadCount(): number {
    return this.notifications.filter(n => !n.read).length;
  }

  private markAsRead(notificationId: string) {
    const index = this.notifications.findIndex(n => n.id === notificationId);
    if (index !== -1) {
      this.notifications[index].read = true;
      this.notifications = this.notifications.slice();
    }
  }

  private viewNotificationDetail(notification: Notification) {
    // 标记为已读
    if (!notification.read) {
      this.markAsRead(notification.id);
    }
    // 显示详情
    this.selectedNotification = notification;
    this.showNotificationDetail = true;
  }

  private getNotificationDetailContent(notification: Notification): string {
    switch (notification.id) {
      case 'n1':
        return '新剧本「静物画室」现已上线！\n\n这是一个艺术系硬核推理剧本，难度等级★★★。著名绘画导师的画室突然封闭，你受邀进入画室，寻找失踪的学生与隐藏在作品中的留言。\n\n特色玩法：\n• 色卡拼图：不同色块对应字母\n• 暗房底片：记录学生情绪\n• 导师手稿：揭示师生矛盾\n\n预计游玩时长：35分钟\n立即前往剧本库查看详情吧！';
      case 'n2':
        return '限时活动「推理达人」正在进行中！\n\n活动时间：即日起至3天后\n\n活动内容：\n完成任意3个剧本即可解锁神秘隐藏结局「真相回响」\n\n活动奖励：\n✨ 独家剧本结局\n🎁 推理达人称号\n⭐ 额外成就点数\n\n当前进度：0/3\n快去挑战剧本，解锁专属奖励吧！';
      case 'n3':
        return '游戏小贴士：善用笔记功能\n\n推理过程中遇到难题？试试使用笔记功能！\n\n使用方法：\n1. 在游戏中点击「笔记」按钮\n2. 记录嫌疑人、动机、证据等信息\n3. 整理思路，串联线索\n\n小技巧：\n• 及时记录重要线索，避免遗忘\n• 用笔记梳理时间线和人物关系\n• 标记矛盾点，帮助突破推理瓶颈\n\n使用笔记功能可大幅提升推理效率，快去试试吧！';
      default:
        return notification.content;
    }
  }

  private getNotificationIcon(type: string): string {
    switch (type) {
      case 'new':
        return '🎉';
      case 'activity':
        return '🎁';
      case 'system':
        return '💡';
      default:
        return '📢';
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Scroll() {
        Column({ space: 0 }) {
          // 顶部区域 - 浅蓝灰色背景
          Column({ space: 0 }) {
            // 顶部标题栏
            Row({ space: 12 }) {
              // 左侧头像 - 使用背景色块
              Stack({ alignContent: Alignment.Center }) {
                Text('👤')
                  .fontSize(20)
              }
              .width(35)
              .height(35)
              .backgroundColor('#E5E9EC')
              .borderRadius(10)
              
              Column({ space: 2 }) {
                Text('你好，推理旅人')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                Text('继续在独白世界里寻找真相')
                  .fontSize(11)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              
              Blank()
              
              // 右侧通知图标
              Badge({
                count: this.getUnreadCount(),
                position: BadgePosition.RightTop,
                style: { badgeSize: 16, badgeColor: '#FF5A5F' }
              }) {
                Column() {
                  SymbolGlyph($r('sys.symbol.bell'))
                    .fontSize(20)
                    .fontColor(['#666666'])
                    .opacity(0.8)
                }
                .width(35)
                .height(35)
                .backgroundColor('#E5E9EC')
                .borderRadius(10)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.showNotifications = !this.showNotifications;
                })
              }
            }
            .padding({ left: 20, right: 20, top: 16, bottom: 8 })
            .width('100%')

            // 白色搜索区域容器
            Column({ space: 0 }) {
              Row({ space: 8 }) {
                TextInput({ placeholder: '搜索剧本/标签/作者' })
                  .onChange((v: string) => { this.keyword = v })
                  .layoutWeight(1)
                  .backgroundColor('rgba(223, 228, 233, 0.5)')
                  .borderRadius(15)
                  .placeholderColor('#999999')
                  .fontSize(13)
                  .padding({ left: 16, right: 16 })
                  .border({ width: 0 })
                  .height(35)
                
                // 搜索图标
                Text('🔍')
                  .fontSize(18)
                  .opacity(0.6)
              }
              .padding({ left: 6, right: 6, top: 5, bottom: 5 })
            }
            .padding({ left: 20, right: 20, top: 5, bottom: 5 })
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .margin({ left: 20, right: 20, bottom: 8 })

            // 筛选按钮区域
            Stack({ alignContent: Alignment.TopStart }) {
              Row({ space: 12 }) {
                ForEach(this.filterGroups, (label: string) => {
                  Column() {
                    Text(label)
                      .fontSize(10)
                      .fontColor('#1A1A1A')
                  }
                  .height(16)
                  .padding({ left: 10, right: 10 })
                  .backgroundColor('#F9FAFB')
                  .borderRadius(6)
                  .border({ width: 0.5, color: 'rgba(128, 128, 128, 0.5)' })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.toggleFilter(label);
                  })
                }, (label: string) => label)
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')

              if (this.expandedFilter.length > 0) {
                Column({ space: 0 }) {
                  Column({ space: 8 }) {
                    ForEach(this.getFilterOptions(this.expandedFilter), (option: string) => {
                      Text(option)
                        .fontSize(13)
                        .fontColor(this.getSelectedValue(this.expandedFilter) === option ? '#3B73FE' : '#1A1A1A')
                        .fontWeight(this.getSelectedValue(this.expandedFilter) === option ? FontWeight.Medium : FontWeight.Regular)
                        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                        .backgroundColor(this.getSelectedValue(this.expandedFilter) === option ? '#F0F5FF' : '#FFFFFF')
                        .width('100%')
                        .onClick(() => {
                          this.selectFilterOption(this.expandedFilter, option);
                        })
                    }, (option: string) => option)
                  }
                  .padding(8)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.15)', offsetY: 2 })
                  .margin({ top: 25, left: 20 })
                  .width(140)
                }
              }
            }
            .width('100%')
            .height(this.expandedFilter.length > 0 ? 220 : 26)
            .margin({ bottom: 8 })
          }
          .backgroundColor('#F1F5F9')
          .padding({ bottom: 8 })

        // 今日推荐区域
        Column({ space: 8 }) {
          Text('今日推荐')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .padding({ left: 20 })
          
          // 推荐大卡片 - 带文字覆盖
          Stack({ alignContent: Alignment.BottomStart }) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#C4B5A0')
              .borderRadius(15)
            
            Text('冷小兵档案')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D2419')
              .padding({ left: 20, bottom: 16 })
          }
          .height(141)
          .borderRadius(15)
          .margin({ left: 20, right: 20 })
          .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.25)', offsetY: 5 })
        }
        .margin({ top: 8 })

        // 剧本栏标题
        Text('剧本栏')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .padding({ left: 20 })
          .margin({ top: 14 })

        if (this.filtered().length === 0) {
          Column({ space: 16 }) {
            Text('😔')
              .fontSize(48)
              .margin({ top: 50 })
            Text('暂无匹配的剧本')
              .fontSize(16)
              .fontColor('#666666')
            Text('试试调整筛选条件或搜索其他关键词')
              .fontSize(13)
              .fontColor('#999999')
              .opacity(0.7)
            Button('清除所有筛选')
              .fontSize(13)
              .backgroundColor('#E5ECF2')
              .fontColor('#1A1A1A')
              .margin({ top: 12 })
              .onClick(() => {
                this.keyword = '';
                this.selectedTheme = '全部';
                this.selectedGenre = '全部';
                this.selectedPlay = '全部';
                this.selectedDifficulty = '全部';
                this.moodFilter = '全部';
              })
          }
          .width('100%')
          .padding({ top: 30, bottom: 60 })
          .alignItems(HorizontalAlign.Center)
        } else {
          Column({ space: 11 }) {
            ForEach(this.filtered(), (item: ShortScript) => {
              // 剧本卡片 - 设计稿样式
              Row({ space: 12 }) {
                // 左侧图片
                Column()
                  .width(88)
                  .height(96)
                  .backgroundColor(this.coverColor(item.id))
                  .borderRadius(15)

                // 右侧信息
                Column({ space: 4 }) {
                  Row({ space: 8 }) {
                    Text(item.title)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#1A1A1A')
                      .layoutWeight(1)
                    Text(item.rating ? `${item.rating.toFixed(1)}分` : '评分待定')
                      .fontSize(11)
                      .fontColor('#3B73FE')
                  }
                  .width('100%')

                  if (item.tagline) {
                    Text(item.tagline)
                      .fontSize(11)
                      .fontColor('#666666')
                      .opacity(0.7)
                      .maxLines(1)
                  }

                  Text(`${this.difficultyLabel(item.difficulty)} · 约${item.durationMin}分钟`)
                    .fontSize(11)
                    .fontColor('#666666')
                    .opacity(0.7)

                  Row({ space: 6 }) {
                    if (item.tags) {
                      ForEach(item.tags.slice(0, 3), (tag: string) => {
                        Text(`#${tag}`)
                          .fontSize(9)
                          .fontColor('#1A1A1A')
                          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                          .backgroundColor('#D5E0FF')
                          .borderRadius(10)
                      }, (tag: string) => tag)
                    }
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .padding(0)
              .width('100%')
              .height(96)
              .backgroundColor('#F9FAFB')
              .borderRadius(15)
              .border({ width: 0.5, color: 'rgba(128, 128, 128, 0.5)' })
              .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.25)', offsetY: 2 })
              .padding({ left: 0, right: 12, top: 0, bottom: 0 })
              .onClick(() => {
                try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } }) } catch (_) {}
              })
            }, (item: ShortScript) => item.id)
          }
          .padding({ left: 20, right: 20, bottom: 100, top: 8 })
        }
        }.padding({ bottom: 20 })
        }.scrollBar(BarState.Auto).height('100%').backgroundColor('#F1F5F9')
      }.height('100%').backgroundColor('#F1F5F9')

      // 通知弹窗
      if (this.showNotifications) {
        Column() {
          Column({ space: 0 }) {
            Row({ space: 12 }) {
              Text('通知中心').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
              Blank()
              Text('关闭')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => {
                  this.showNotifications = false;
                })
            }
            .padding({ left: 20, right: 20, top: 16, bottom: 12 })

            Scroll() {
              Column({ space: 1 }) {
                ForEach(this.notifications, (notification: Notification) => {
                  Column({ space: 8 }) {
                    Row({ space: 10 }) {
                      Text(this.getNotificationIcon(notification.type)).fontSize(24)
                      Column({ space: 6 }) {
                        Row({ space: 8 }) {
                          Text(notification.title)
                            .fontSize(15)
                            .fontWeight(FontWeight.Medium)
                            .fontColor('#1A1A1A')
                          if (!notification.read) {
                            Text('未读')
                              .fontSize(10)
                              .fontColor('#FFFFFF')
                              .backgroundColor('#FF5A5F')
                              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                              .borderRadius(8)
                          }
                        }
                        Text(notification.content)
                          .fontSize(13)
                          .fontColor('#666666')
                          .maxLines(2)
                        Text(notification.time)
                          .fontSize(11)
                          .fontColor('#999999')
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .padding(16)
                    .width('100%')
                  }
                  .backgroundColor(notification.read ? '#FFFFFF' : '#F0F5FF')
                  .onClick(() => {
                    this.viewNotificationDetail(notification);
                  })
                }, (notification: Notification) => notification.id)
              }
            }
            .layoutWeight(1)
          }
          .width('90%')
          .height('70%')
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.25)', offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showNotifications = false;
        })
      }

      // 通知详情弹窗
      if (this.showNotificationDetail && this.selectedNotification) {
        Column() {
          Column({ space: 0 }) {
            Row({ space: 12 }) {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontSize(20)
                .fontColor(['#1A1A1A'])
                .onClick(() => {
                  this.showNotificationDetail = false;
                  this.selectedNotification = null;
                })
              Text('通知详情')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
              Blank()
              Text('关闭')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => {
                  this.showNotificationDetail = false;
                  this.showNotifications = false;
                  this.selectedNotification = null;
                })
            }
            .padding({ left: 20, right: 20, top: 16, bottom: 12 })

            Scroll() {
              Column({ space: 20 }) {
                // 标题和图标
                Row({ space: 12 }) {
                  Text(this.getNotificationIcon(this.selectedNotification.type))
                    .fontSize(36)
                  Column({ space: 6 }) {
                    Text(this.selectedNotification.title)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1A1A1A')
                    Text(this.selectedNotification.time)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .padding({ left: 20, right: 20 })

                Divider()
                  .color('#EEEEEE')
                  .margin({ left: 20, right: 20 })

                // 详细内容
                Text(this.getNotificationDetailContent(this.selectedNotification))
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(24)
                  .padding({ left: 20, right: 20 })
              }
              .padding({ top: 12, bottom: 20 })
            }
            .layoutWeight(1)
          }
          .width('90%')
          .height('75%')
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.25)', offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showNotificationDetail = false;
          this.selectedNotification = null;
        })
      }
      // 底部导航栏
      Row({ space: 0 }) {
        // 主页
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.house'))
            .fontSize(24)
            .fontColor(['#1A1A1A'])
          Text('主页')
            .fontSize(11)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })

        // 剧本库
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.book'))
            .fontSize(24)
            .fontColor(['#1A1A1A'])
          Text('剧本库')
            .fontSize(11)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/ScriptLibraryPage' }) } catch (_) {}
        })

        // 下载管理
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.arrow_down_circle'))
            .fontSize(24)
            .fontColor(['#1A1A1A'])
          Text('下载管理')
            .fontSize(11)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/DownloadPage' }) } catch (_) {}
        })

        // 个人中心
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.person'))
            .fontSize(24)
            .fontColor(['#1A1A1A'])
          Text('个人中心')
            .fontSize(11)
            .fontColor('#1A1A1A')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/ProfilePage' }) } catch (_) {}
        })
      }
      .width('100%')
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(15)
      .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.25)', offsetY: 4 })
      .margin({ left: 20, right: 20, bottom: 15 })
    }
    .width('100%')
    .height('100%')
  }

}

@Preview
@Component
struct HomePreview { build() { HomePage() } }
