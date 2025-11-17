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
          .backgroundColor('#F6E1D4')
          .fontColor(WarmTheme.textPrimary)
          .onClick(() => { pauseDownload(item.scriptId); this.refresh(); })
      } else if (item.status === 'paused' || item.status === 'queued' || item.status === 'notDownloaded') {
        Button('继续')
          .type(ButtonType.Capsule)
          .backgroundColor(WarmTheme.accent)
          .fontColor('#FFFFFF')
          .onClick(() => { startOrResumeDownload(item.scriptId); this.refresh(); })
      } else if (item.status === 'completed') {
        Button('重新下载')
          .backgroundColor('#F6E1D4')
          .fontColor(WarmTheme.textPrimary)
          .onClick(() => { startOrResumeDownload(item.scriptId); this.refresh(); })
      }
      Button('删除')
        .backgroundColor('#F6E1D4')
        .fontColor(WarmTheme.textPrimary)
        .onClick(() => { deleteDownload(item.scriptId); this.refresh(); })
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('下载管理').fontSize(26).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary).padding({ top: 24, left: 20, right: 20 })
        if (this.downloads.length === 0) {
          Column({ space: 12 }) {
            Text('暂无下载任务').fontSize(16).fontColor(WarmTheme.textPrimary).padding({ top: 40 })
            Button('前往剧本库')
              .type(ButtonType.Capsule)
              .backgroundColor(WarmTheme.accent)
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
                  Text(getScript(item.scriptId)?.title ?? item.scriptId).fontSize(18).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                  Blank()
                  Text(item.status === 'completed' ? '已完成' : item.status === 'downloading' ? '下载中' : item.status === 'paused' ? '已暂停' : '未开始').fontSize(12).fontColor(WarmTheme.textSecondary)
                }
                Progress({ value: item.progress / 100 }).height(4).width('100%').backgroundColor('#F1E4D8')
                Text(`${item.progress}% · ${item.speedKBps} KB/s · 约 ${item.etaMinutes} 分钟`).fontSize(11).fontColor(WarmTheme.textSecondary)
                this.actionButtons(item)
                Row({ space: 10 }) {
                  Button('查看详情')
                    .backgroundColor('#F3E6DA')
                    .fontColor(WarmTheme.textPrimary)
                    .onClick(() => {
                      try { router.pushUrl({ url: 'pages/DownloadDetailPage', params: { id: item.scriptId } }) } catch (_) {}
                    })
                  Button('标记完成')
                    .backgroundColor('#F5E1D5')
                    .fontColor(WarmTheme.textPrimary)
                    .onClick(() => { completeDownload(item.scriptId); this.refresh(); })
                  Blank()
                  Button('开始体验')
                    .type(ButtonType.Capsule)
                    .backgroundColor(WarmTheme.accent)
                    .fontColor('#FFFFFF')
                    .onClick(() => {
                      try { router.pushUrl({ url: 'pages/DetailPage', params: { id: item.scriptId } }) } catch (_) {}
                    })
                }
              }
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .backgroundColor(WarmTheme.card)
              .borderRadius(20)
              .shadow(WarmShadow.light)
            }, (item: DownloadItem) => item.scriptId + '-' + this.revision)
          }.padding({ bottom: 32 })
        }
      }
    }.scrollBar(BarState.Off).backgroundColor(WarmTheme.background).height('100%')
  }
}

