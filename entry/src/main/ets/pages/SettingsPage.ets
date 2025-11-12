import { getUserSettings, updateUserSettings } from '../model/progress';
import { UserSettings } from '../model/types';
import router from '@ohos.router';

@Entry
@Component
struct SettingsPage {
  @State settings: UserSettings = getUserSettings();

  private persist(next: UserSettings) {
    this.settings = next;
    updateUserSettings(next);
  }

  build() {
    Column({ space: 20 }) {
      Text('设置中心').fontSize(26).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })

      Column({ space: 14 }) {
        Row() {
          Text('音效').fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.settings.soundEnabled })
            .onChange((value: boolean) => {
              const next: UserSettings = {
                soundEnabled: value,
                textSize: this.settings.textSize,
                autoDownload: this.settings.autoDownload,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }.padding({ left: 20, right: 20 })

        Column({ space: 6 }) {
          Text('文字大小').fontSize(16)
          Slider({ value: this.settings.textSize, min: 14, max: 22, step: 1 })
            .onChange((value: number) => {
              const next: UserSettings = {
                soundEnabled: this.settings.soundEnabled,
                textSize: Math.round(value),
                autoDownload: this.settings.autoDownload,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }.padding({ left: 20, right: 20 })

        Row() {
          Text('自动下载离线剧本').fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.settings.autoDownload })
            .onChange((value: boolean) => {
              const next: UserSettings = {
                soundEnabled: this.settings.soundEnabled,
                textSize: this.settings.textSize,
                autoDownload: value,
                theme: this.settings.theme
              };
              this.persist(next);
            })
        }.padding({ left: 20, right: 20 })

        Row({ space: 12 }) {
          Text('画面风格').fontSize(16)
          Blank()
          Button(this.settings.theme === 'default' ? '默认' : '低光')
            .type(ButtonType.Capsule)
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
        }.padding({ left: 20, right: 20 })
      }

      Column({ space: 10 }) {
        Text('数据管理').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
        Button('清空缓存').onClick(() => {
          console.info('缓存清理功能将在正式版提供');
        }).margin({ left: 20, right: 20 })
        Button('恢复默认设置').onClick(() => {
          this.persist({ soundEnabled: true, textSize: 16, autoDownload: false, theme: 'default' });
        }).margin({ left: 20, right: 20 })
      }

      Column({ space: 10 }) {
        Text('关于').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
        Text('版本 0.1.0 · 谜境独白').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
      }

      Button('返回').onClick(() => { try { router.back() } catch (_) {} }).margin({ left: 20, right: 20, bottom: 24 })
    }.height('100%').backgroundColor('#FFFFFF')
  }
}

