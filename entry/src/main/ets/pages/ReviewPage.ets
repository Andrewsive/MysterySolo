import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ResultParams, NotesParams } from '../model/types';
import { WarmTheme, WarmShadow } from './uiTheme';

interface ReviewParams {
  id?: string;
  title?: string;
}

@Entry
@Component
struct ReviewPage {
  @State scriptId: string = 'demo';
  @State scriptTitle: string = '';
  @State feeling: string = '';
  @State highlight: string = '';
  @State suggestion: string = '';
  @State saved: boolean = false;

  aboutToAppear() {
    try {
      const params = router.getParams() as ReviewParams | undefined;
      if (params && params.id) this.scriptId = params.id;
      if (params && params.title) this.scriptTitle = params.title;
    } catch (_) {}
  }

  private onSubmit() {
    this.saved = true;
    promptAction.showToast({ message: '感谢分享你的体验！' });
  }

  @Builder
  private reviewField(title: string, placeholder: string, value: string, handler: (v: string) => void) {
    Column({ space: 10 }) {
      Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
      TextInput({ placeholder, text: value })
        .onChange((v: string) => { handler(v); this.saved = false })
        .height(120)
        .backgroundColor(WarmTheme.card)
        .borderRadius(20)
        .padding({ left: 12, right: 12 })
    }
    .padding({ left: 20, right: 20 })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Button('← 返回')
            .backgroundColor('#F6E1D4')
            .fontColor(WarmTheme.textPrimary)
            .borderRadius(16)
            .onClick(() => { try { router.back() } catch (_) {} })
          Blank()
        }.width('100%').padding({ left: 20, right: 20, top: 16 })

        Column({ space: 6 }) {
          Text('撰写剧本点评').fontSize(24).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary)
          Text(`剧本：${this.scriptTitle.length > 0 ? this.scriptTitle : this.scriptId}`).fontSize(12).fontColor(WarmTheme.textSecondary)
        }.padding({ left: 20, right: 20 })

        this.reviewField('整体感受', '写写氛围、节奏或剧情给你的触动', this.feeling, (v: string) => { this.feeling = v })
        this.reviewField('亮点与体验', '哪些设置或关卡最令你惊喜？', this.highlight, (v: string) => { this.highlight = v })
        this.reviewField('建议 / 吐槽', '想改进的地方、或对下一位玩家的提醒', this.suggestion, (v: string) => { this.suggestion = v })

        if (this.saved) {
          Text('✔ 已提交，感谢你的反馈').fontSize(12).fontColor(WarmTheme.textSecondary).padding({ left: 20, right: 20 })
        }

        Row({ space: 12 }) {
          Button('提交')
            .type(ButtonType.Capsule)
            .backgroundColor(WarmTheme.accent)
            .fontColor('#FFFFFF')
            .layoutWeight(1)
            .onClick(() => { this.onSubmit(); })
          Button('清空')
            .backgroundColor('#F6E1D4')
            .fontColor(WarmTheme.textPrimary)
            .layoutWeight(1)
            .onClick(() => {
              this.feeling = '';
              this.highlight = '';
              this.suggestion = '';
              this.saved = false;
            })
        }.padding({ left: 20, right: 20, bottom: 32 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor(WarmTheme.background)
  }
}


