import router from '@ohos.router';
import { hasOnboarded, setOnboarded, getUserSettings, updateUserSettings } from '../model/progress';
import { UserSettings } from '../model/types';

interface OnboardingSlide {
  title: string;
  description: string;
}

@Entry
@Component
struct OnboardingPage {
  private slides: OnboardingSlide[] = [
    { title: '沉浸式独白', description: '单人剧本杀 · 随时记录推理灵感' },
    { title: '离线可玩', description: '支持下载剧本，无网也能继续破案' },
    { title: '线索同步', description: '笔记与线索自动整理，方便复盘' }
  ];
  private controller: SwiperController = new SwiperController();
  @State index: number = 0;
  @State allowOffline: boolean = true;

  aboutToAppear() {
    if (hasOnboarded()) {
      try { router.replaceUrl({ url: 'pages/HomePage' }) } catch (_) {}
    }
  }

  private finishOnboarding() {
    setOnboarded();
    const current = getUserSettings();
    const next: UserSettings = {
      soundEnabled: current.soundEnabled,
      textSize: current.textSize,
      autoDownload: this.allowOffline,
      theme: current.theme
    };
    updateUserSettings(next);
    try { router.replaceUrl({ url: 'pages/HomePage' }) } catch (_) {}
  }

  build() {
    Column({ space: 32 }) {
      Swiper(this.controller) {
        ForEach(this.slides, (item: OnboardingSlide) => {
          Column({ space: 12 }) {
            Blank().height('10%')
            Image($r('app.media.startIcon')).height(120).width(120).opacity(0.85)
            Text(item.title).fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 12 })
            Text(item.description).fontSize(14).opacity(0.7).textAlign(TextAlign.Center).padding({ left: 24, right: 24 })
            Blank()
          }.width('100%')
        }, (item: OnboardingSlide) => item.title)
      }
      .index(this.index)
      .onChange((idx: number) => { this.index = idx })
      .indicator(true)
      .height('65%')

      Column({ space: 12 }) {
        Row() {
          Checkbox({ name: 'offline', group: 'start' })
            .select(this.allowOffline)
            .onChange((value: boolean) => { this.allowOffline = value })
          Text('允许自动下载支持离线剧本').fontSize(13)
        }.padding({ left: 24, right: 24 })

        Button(this.index < this.slides.length - 1 ? '下一页' : '开始使用')
          .type(ButtonType.Capsule)
          .margin({ left: 24, right: 24 })
          .onClick(() => {
            if (this.index < this.slides.length - 1) {
              this.controller.showNext();
            } else {
              this.finishOnboarding();
            }
          })

        Button('跳过')
          .margin({ left: 24, right: 24, bottom: 24 })
          .onClick(() => { this.finishOnboarding() })
      }
    }
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

