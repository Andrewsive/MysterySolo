import { getUserSettings, updateUserSettings } from '../model/progress';
import { UserSettings } from '../model/types';
import router from '@ohos.router';
import { WarmTheme, WarmShadow } from './uiTheme';

@Entry
@Component
struct SettingsPage {
  @State settings: UserSettings = getUserSettings();

  private persist(next: UserSettings) {
    this.settings = next;
    updateUserSettings(next);
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Text('设置中心')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .padding({ top: 24, left: 20, right: 20 })

      Column({ space: 14 }) {
        Row() {
          Text('音效')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.settings.soundEnabled })
            .selectedColor('#3B73FE')
            .onChange((value: boolean) => {
              const next: UserSettings = {
                soundEnabled: value,
                textSize: this.settings.textSize,
                autoDownload: this.settings.autoDownload,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }
        .padding({ left: 20, right: 20, top: 14, bottom: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(15)
        .margin({ left: 20, right: 20 })
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

        Column({ space: 8 }) {
          Text('文字大小')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Slider({ value: this.settings.textSize, min: 14, max: 22, step: 1 })
            .blockColor('#3B73FE')
            .trackColor('#E6EFFF')
            .selectedColor('#3B73FE')
            .onChange((value: number) => {
              const next: UserSettings = {
                soundEnabled: this.settings.soundEnabled,
                textSize: Math.round(value),
                autoDownload: this.settings.autoDownload,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }
        .padding({ left: 20, right: 20, top: 14, bottom: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(15)
        .margin({ left: 20, right: 20 })
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

        Row() {
          Text('自动下载离线剧本')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.settings.autoDownload })
            .selectedColor('#3B73FE')
            .onChange((value: boolean) => {
              const next: UserSettings = {
                soundEnabled: this.settings.soundEnabled,
                textSize: this.settings.textSize,
                autoDownload: value,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }
        .padding({ left: 20, right: 20, top: 14, bottom: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(15)
        .margin({ left: 20, right: 20 })
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

        Row({ space: 12 }) {
          Text('画面风格')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Blank()
          Button(this.settings.theme === 'default' ? '默认' : '低光')
            .type(ButtonType.Capsule)
            .backgroundColor('#E6EFFF')
            .fontColor('#3B73FE')
            .onClick(() => {
              const nextTheme = this.settings.theme === 'default' ? 'lowlight' : 'default';
              const next: UserSettings = {
                soundEnabled: this.settings.soundEnabled,
                textSize: this.settings.textSize,
                autoDownload: this.settings.autoDownload,
                theme: nextTheme
              };
              this.persist(next);
            })
        }
        .padding({ left: 20, right: 20, top: 14, bottom: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(15)
        .margin({ left: 20, right: 20 })
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })
      }

      Column({ space: 10 }) {
        Text('数据管理')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .padding({ left: 20, right: 20 })
        Button('清空缓存')
          .backgroundColor('#E6EFFF')
          .fontColor('#3B73FE')
          .onClick(() => {
            console.info('缓存清理功能将在正式版提供');
          })
          .margin({ left: 20, right: 20 })
        Button('恢复默认设置')
          .backgroundColor('#E5E9EC')
          .fontColor('#666666')
          .onClick(() => {
            this.persist({ soundEnabled: true, textSize: 16, autoDownload: false, theme: 'default' });
          })
          .margin({ left: 20, right: 20 })
      }

      Column({ space: 10 }) {
        Text('关于')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .padding({ left: 20, right: 20 })
        Text('版本 0.1.0 · 谜境独白')
          .fontSize(13)
          .fontColor('#666666')
          .padding({ left: 20, right: 20 })
      }

      Button('返回')
        .type(ButtonType.Capsule)
        .backgroundColor('#3B73FE')
        .fontColor('#FFFFFF')
        .onClick(() => { try { router.back() } catch (_) {} })
        .margin({ left: 20, right: 20, bottom: 32 })
    }
    .padding({ bottom: 20 })
    }
    .scrollBar(BarState.Auto)
    .height('100%')
    .backgroundColor('#F1F5F9')
  }
}

