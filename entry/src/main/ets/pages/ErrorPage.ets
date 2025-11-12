import router from '@ohos.router';
import { ErrorParams } from '../model/types';

@Entry
@Component
struct ErrorPage {
  @State message: string = '暂时无法加载内容';
  @State code: string = 'ERR_UNKNOWN';

  aboutToAppear() {
    try {
      const params = router.getParams() as ErrorParams | undefined;
      if (params && params.message) this.message = params.message;
      if (params && params.code) this.code = params.code;
    } catch (_) {}
  }

  build() {
    Column({ space: 20 }) {
      Text('出错啦').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 40 })
      Text(`错误码：${this.code}`).fontSize(14).opacity(0.6)
      Text(this.message).fontSize(14).opacity(0.7).padding({ left: 24, right: 24 })
      Button('重试').type(ButtonType.Capsule).onClick(() => { try { router.back() } catch (_) {} })
      Button('返回首页').onClick(() => { try { router.replaceUrl({ url: 'pages/HomePage' }) } catch (_) {} })
    }.height('100%').width('100%').backgroundColor('#FFFFFF').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}

