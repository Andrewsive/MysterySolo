import router from '@ohos.router';
import { DownloadDetailParams } from '../model/types';
import { getDownload, startOrResumeDownload, pauseDownload, deleteDownload, completeDownload } from '../model/downloads';
import { getScript } from '../model/store';

@Entry
@Component
struct DownloadDetailPage {
  @State scriptId: string = '';
  @State refreshKey: number = 0;

  aboutToAppear() {
    try {
      const params = router.getParams() as DownloadDetailParams | undefined;
      if (params && params.id) {
        this.scriptId = params.id;
      }
    } catch (_) {}
  }

  private refresh(): void {
    this.refreshKey += 1;
  }

  private downloadInfo() {
    if (this.scriptId.length === 0) {
      return undefined;
    }
    return getDownload(this.scriptId);
  }

  private currentScript() {
    if (this.scriptId.length === 0) {
      return undefined;
    }
    return getScript(this.scriptId);
  }

  private progressValue(): number {
    const info = this.downloadInfo();
    return info ? info.progress / 100 : 0;
  }

  private progressLabel(): string {
    const info = this.downloadInfo();
    if (!info) {
      return '0%';
    }
    return `进度 ${info.progress}% · ${info.speedKBps} KB/s · 剩余 ${info.etaMinutes} 分钟`;
  }

  private statusText(): string {
    const info = this.downloadInfo();
    return info ? info.status : '未开始';
  }

  private scriptTitle(): string {
    const script = this.currentScript();
    if (script) {
      return script.title;
    }
    return this.scriptId;
  }

  private scriptTagline(): string {
    const script = this.currentScript();
    if (script && script.tagline) {
      return script.tagline;
    }
    return '';
  }

  build() {
    Column({ space: 18 }) {
      Text('下载详情').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
      if (!this.downloadInfo()) {
        Column({ space: 12 }) {
          Text('未找到下载任务').fontSize(16).padding({ top: 40 })
          Button('返回').onClick(() => { try { router.back() } catch (_) {} })
        }.padding({ left: 20, right: 20 })
      } else {
        Column({ space: 12 }) {
          Text(this.scriptTitle()).fontSize(20).fontWeight(FontWeight.Medium)
          if (this.scriptTagline().length > 0) {
            Text(this.scriptTagline()).fontSize(13).opacity(0.7)
          }
          Text(`状态：${this.statusText()}`).fontSize(12).opacity(0.6)
          Progress({ value: this.progressValue() }).height(4).width('100%').backgroundColor('#E4E6EB')
          Text(this.progressLabel()).fontSize(12).opacity(0.6)
          Row({ space: 10 }) {
            Button('暂停').onClick(() => { pauseDownload(this.scriptId); this.refresh(); })
            Button('继续').type(ButtonType.Capsule).onClick(() => { startOrResumeDownload(this.scriptId); this.refresh(); })
            Button('完成').onClick(() => { completeDownload(this.scriptId); this.refresh(); })
            Button('删除').onClick(() => { deleteDownload(this.scriptId); this.refresh(); try { router.back() } catch (_) {} })
          }
          Button('返回').onClick(() => { try { router.back() } catch (_) {} })
        }.padding({ left: 20, right: 20, top: 20 }).backgroundColor('#FFFFFF').borderRadius(18)
      }
    }.backgroundColor('#F6F7F9').height('100%')
  }
}

