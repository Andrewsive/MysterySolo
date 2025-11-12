import router from '@ohos.router';
import { NotesParams } from '../model/types';
import { getNote, saveNote } from '../model/progress';

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
        Text('推理笔记').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 24, left: 20, right: 20 })
        Text(`剧本 ${this.scriptId}`).fontSize(12).opacity(0.6).padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('嫌疑人 & 关系').fontSize(14).fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '记录嫌疑人与关系线索', text: this.suspects })
            .onChange((value: string) => { this.suspects = value; this.saved = false; })
            .height(120)
            .margin({ top: 4 })
        }.padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('动机假设').fontSize(14).fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '写下你推测的动机或矛盾', text: this.motive })
            .onChange((value: string) => { this.motive = value; this.saved = false; })
            .height(120)
        }.padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('关键证据').fontSize(14).fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '线索、证人与物证', text: this.evidence })
            .onChange((value: string) => { this.evidence = value; this.saved = false; })
            .height(120)
        }.padding({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('矛盾点/待查验').fontSize(14).fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '记录尚未解释的疑点', text: this.paradox })
            .onChange((value: string) => { this.paradox = value; this.saved = false; })
            .height(120)
        }.padding({ left: 20, right: 20 })

        if (this.saved) {
          Text('已保存到本地').fontSize(12).opacity(0.6).padding({ left: 20, right: 20 })
        }

        Row({ space: 12 }) {
          Button('保存').type(ButtonType.Capsule).onClick(() => { this.save(); })
          Button('清空').onClick(() => {
            this.suspects = '';
            this.motive = '';
            this.evidence = '';
            this.paradox = '';
            this.saved = false;
          })
          Blank()
          Button('返回').onClick(() => { try { router.back() } catch (_) {} })
        }.margin({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}

