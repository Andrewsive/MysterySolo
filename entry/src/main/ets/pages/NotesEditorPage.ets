import router from '@ohos.router';
import { NotesParams } from '../model/types';
import { getNote, saveNote } from '../model/progress';
import { WarmTheme, WarmShadow } from './uiTheme';

@Entry
@Component
struct NotesEditorPage {
  @State scriptId: string = 'demo';
  @State suspects: string = '';
  @State motive: string = '';
  @State evidence: string = '';
  @State paradox: string = '';
  @State saved: boolean = false;

  aboutToAppear() {
    try {
      const params = router.getParams() as NotesParams | undefined;
      if (params && params.id) {
        this.scriptId = params.id;
      }
    } catch (_) {}
    const note = getNote(this.scriptId);
    if (note) {
      this.suspects = note.suspects;
      this.motive = note.motive;
      this.evidence = note.evidence;
      this.paradox = note.paradox;
    }
  }

  private save() {
    saveNote({
      scriptId: this.scriptId,
      suspects: this.suspects,
      motive: this.motive,
      evidence: this.evidence,
      paradox: this.paradox,
      updatedAt: Date.now()
    });
    this.saved = true;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('推理笔记').fontSize(26).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary).padding({ top: 24, left: 20, right: 20 })
        Text(`剧本 ${this.scriptId}`).fontSize(12).fontColor(WarmTheme.textSecondary).padding({ left: 20, right: 20 })

        this.noteCard('嫌疑人 & 关系', '记录嫌疑人与关系线索', this.suspects, (v: string) => { this.suspects = v; this.saved = false })
        this.noteCard('动机假设', '写下你推测的动机或矛盾', this.motive, (v: string) => { this.motive = v; this.saved = false })
        this.noteCard('关键证据', '线索、证人与物证', this.evidence, (v: string) => { this.evidence = v; this.saved = false })
        this.noteCard('矛盾点 / 待查验', '记录尚未解释的疑点', this.paradox, (v: string) => { this.paradox = v; this.saved = false })

        if (this.saved) {
          Text('✔ 已保存到本地').fontSize(12).fontColor(WarmTheme.textSecondary).padding({ left: 20, right: 20 })
        }

        Row({ space: 12 }) {
          Button('保存')
            .type(ButtonType.Capsule)
            .backgroundColor(WarmTheme.accent)
            .fontColor('#FFFFFF')
            .onClick(() => { this.save(); })
          Button('清空')
            .backgroundColor('#F6E7DA')
            .fontColor(WarmTheme.textPrimary)
            .onClick(() => {
              this.suspects = '';
              this.motive = '';
              this.evidence = '';
              this.paradox = '';
              this.saved = false;
            })
          Blank()
          Button('返回')
            .backgroundColor('#F0E4D9')
            .fontColor(WarmTheme.textPrimary)
            .onClick(() => { try { router.back() } catch (_) {} })
        }.margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor(WarmTheme.background)
  }

  @Builder
  private noteCard(title: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 10 }) {
      Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
      TextInput({ placeholder, text: value })
        .onChange(onChange)
        .height(120)
        .backgroundColor(WarmTheme.card)
        .borderRadius(20)
        .padding({ left: 12, right: 12 })
    }
    .padding({ left: 20, right: 20 })
  }
}

