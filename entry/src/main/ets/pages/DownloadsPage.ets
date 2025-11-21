import router from '@ohos.router';
import { listDownloads, startOrResumeDownload, pauseDownload, deleteDownload, completeDownload } from '../model/downloads';
import { getScript } from '../model/store';
import { DownloadItem } from '../model/types';
import { WarmTheme, WarmShadow } from './uiTheme';

@Entry
@Component
struct DownloadsPage {
  @State revision: number = 0;
  @State downloads: DownloadItem[] = listDownloads();

  private refresh(): void {
    this.downloads = listDownloads();
    this.revision += 1;
  }

  @Builder
  private actionButtons(item: DownloadItem) {
    Row({ space: 10 }) {
      if (item.status === 'downloading') {
        Button('暂停')
          .backgroundColor('#F9FAFB')
          .fontColor('#666666')
          .onClick(() => { pauseDownload(item.scriptId); this.refresh(); })
      } else if (item.status === 'paused' || item.status === 'queued' || item.status === 'notDownloaded') {
        Button('继续')
          .type(ButtonType.Capsule)
          .backgroundColor('#3B73FE')
          .fontColor('#FFFFFF')
          .onClick(() => { startOrResumeDownload(item.scriptId); this.refresh(); })
      } else if (item.status === 'completed') {
        Button('重新下载')
          .backgroundColor('#F9FAFB')
          .fontColor('#666666')
          .onClick(() => { startOrResumeDownload(item.scriptId); this.refresh(); })
      }
      Button('删除')
        .backgroundColor('#F9FAFB')
        .fontColor('#666666')
        .onClick(() => { deleteDownload(item.scriptId); this.refresh(); })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
      Column({ space: 18 }) {
        Text('下载管理').fontSize(26).fontWeight(FontWeight.Bold).fontColor('#1A1A1A').padding({ top: 24, left: 20, right: 20 })
        if (this.downloads.length === 0) {
          Column({ space: 12 }) {
            Text('暂无下载任务').fontSize(16).fontColor('#1A1A1A').padding({ top: 40 })
            Button('前往剧本库')
              .type(ButtonType.Capsule)
              .backgroundColor('#3B73FE')
              .fontColor('#FFFFFF')
              .onClick(() => {
                try { router.replaceUrl({ url: 'pages/LibraryPage' }) } catch (_) {}
              })
          }.padding({ left: 20, right: 20 })
        } else {
          Column({ space: 14 }) {
            ForEach(this.downloads, (item: DownloadItem) => {
              Column({ space: 10 }) {
                Row() {
                  Text(getScript(item.scriptId)?.title ?? item.scriptId).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#1A1A1A')
                  Blank()
                  Text(item.status === 'completed' ? '已完成' : item.status === 'downloading' ? '下载中' : item.status === 'paused' ? '已暂停' : '未开始').fontSize(12).fontColor('#666666')
                }
                Progress({ value: item.progress / 100 }).height(4).width('100%').backgroundColor('#E0E7FF')
                Text(`${item.progress}% · ${item.speedKBps} KB/s · 约 ${item.etaMinutes} 分钟`).fontSize(11).fontColor('#666666')
                this.actionButtons(item)
                Row({ space: 10 }) {
                  Button('查看详情')
                    .backgroundColor('#E6EFFF')
                    .fontColor('#3B73FE')
                    .onClick(() => {
                      try { router.pushUrl({ url: 'pages/DownloadDetailPage', params: { id: item.scriptId } }) } catch (_) {}
                    })
                  Button('标记完成')
                    .backgroundColor('#F9FAFB')
                    .fontColor('#666666')
                    .onClick(() => { completeDownload(item.scriptId); this.refresh(); })
                  Blank()
                  Button('开始体验')
                    .type(ButtonType.Capsule)
                    .backgroundColor('#3B73FE')
                    .fontColor('#FFFFFF')
                    .onClick(() => {
                      try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.scriptId } }) } catch (_) {}
                    })
                }
              }
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })
            }, (item: DownloadItem) => item.scriptId + '-' + this.revision)
          }.padding({ bottom: 80 })
        }
      }
      }.scrollBar(BarState.Off).backgroundColor('#F1F5F9').height('100%')

      // 底部导航栏
      Row({ space: 0 }) {
        // 主页
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.house'))
            .fontSize(24)
            .fontColor(['#666666'])
          Text('主页')
            .fontSize(11)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/HomePage' }) } catch (_) {}
        })

        // 剧本库
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.book'))
            .fontSize(24)
            .fontColor(['#666666'])
          Text('剧本库')
            .fontSize(11)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/LibraryPage' }) } catch (_) {}
        })

        // 下载管理 - 当前选中
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.arrow_down_circle'))
            .fontSize(24)
            .fontColor(['#3B73FE'])
          Text('下载管理')
            .fontSize(11)
            .fontColor('#3B73FE')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 6, bottom: 6 })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/DownloadsPage' }) } catch (_) {}
        })

        // 个人中心
        Column({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.person'))
            .fontSize(24)
            .fontColor(['#666666'])
          Text('个人中心')
            .fontSize(11)
            .fontColor('#666666')
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
      .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.25)', offsetY: -2 })
    }
    .width('100%')
    .height('100%')
  }
}

