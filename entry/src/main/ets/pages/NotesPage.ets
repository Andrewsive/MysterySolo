import router from '@ohos.router';
import { getScript } from '../model/store';
import { Clue, NotesParams } from '../model/types';

@Entry
@Component
struct NotesPage {
  @State sid: string = 'demo';
  @State got: string[] = [];
  @State clues: Clue[] = [];

  aboutToAppear() {
    try {
      const p = router.getParams() as NotesParams | undefined;
      if (p && p.id) this.sid = p.id;
      if (p && p.clues) this.got = p.clues;
    } catch (_) {}
    const s = getScript(this.sid);
    this.clues = s ? s.clues : [];
  }

  private ownedCount(): number {
    let count = 0;
    this.clues.forEach((c: Clue) => {
      if (this.isOwned(c.id)) {
        count += 1;
      }
    });
    return count;
  }

  private isOwned(id: string): boolean {
    return this.got.indexOf(id) >= 0;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        // 顶部标题栏
        Column({ space: 8 }) {
          Row() {
            Button('← 返回')
              .type(ButtonType.Normal)
              .backgroundColor('#F6F7F9')
              .borderRadius(12)
              .height(36)
              .onClick(() => {
                try { router.back() } catch (_) {}
              })
            Blank()
          }.width('100%').padding({ left: 20, right: 20, top: 12 })
          
          Text('📋 线索簿').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 8, left: 20, right: 20 })
          Text(`已掌握 ${this.ownedCount()} / ${this.clues.length} 条线索`).fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
        }

        // 进度条
        if (this.clues.length > 0) {
          Column({ space: 6 }) {
            Row() {
              Text('收集进度').fontSize(14).fontWeight(FontWeight.Medium)
              Blank()
              Text(`${Math.round((this.ownedCount() / this.clues.length) * 100)}%`).fontSize(14).fontColor('#52C41A')
            }.width('100%')
            
            Progress({ value: this.ownedCount(), total: this.clues.length, type: ProgressType.Linear })
              .width('100%')
              .height(8)
              .borderRadius(4)
          }
          .padding(16)
          .backgroundColor('#F0F9FF')
          .borderRadius(12)
          .margin({ left: 20, right: 20 })
        }

        // 推理提示卡片
        if (this.ownedCount() >= 2) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('💡').fontSize(18)
              Text('推理建议').fontSize(14).fontWeight(FontWeight.Medium)
            }
            Text('你已经收集了多条线索，试着将它们串联起来思考：线索之间有什么联系？哪些信息是关键？')
              .fontSize(13)
              .opacity(0.7)
              .lineHeight(20)
          }
          .padding(16)
          .backgroundColor('#FFF7E6')
          .borderRadius(12)
          .margin({ left: 20, right: 20 })
          .alignItems(HorizontalAlign.Start)
        }

        // 线索列表
        Column({ space: 12 }) {
          Text('🔍 线索详情').fontSize(16).fontWeight(FontWeight.Medium).padding({ left: 20 })
          
          ForEach(this.clues, (c: Clue, index: number) => {
            Column({ space: 10 }) {
              Row({ space: 8 }) {
                // 线索状态图标
                Text(this.isOwned(c.id) ? '✅' : '🔒').fontSize(18)
                
                Column({ space: 6 }) {
                  Row() {
                    Text(`${index + 1}. ${c.name}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .opacity(this.isOwned(c.id) ? 1 : 0.4)
                    Blank()
                    Text(this.isOwned(c.id) ? '已获得' : '未解锁')
                      .fontSize(12)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor(this.isOwned(c.id) ? '#D4EDDA' : '#E9ECEF')
                      .fontColor(this.isOwned(c.id) ? '#155724' : '#6C757D')
                      .borderRadius(8)
                  }.width('100%')
                  
                  if (this.isOwned(c.id)) {
                    Text(c.desc)
                      .fontSize(14)
                      .opacity(0.75)
                      .lineHeight(22)
                  } else {
                    Text('继续探索以解锁此线索...')
                      .fontSize(14)
                      .opacity(0.4)
                      .fontStyle(FontStyle.Italic)
                  }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }
            .padding(16)
            .backgroundColor(this.isOwned(c.id) ? '#F0F5EE' : '#F9FAFB')
            .borderRadius(12)
            .border({ 
              width: this.isOwned(c.id) ? 2 : 1, 
              color: this.isOwned(c.id) ? '#52C41A' : '#E5E7EB' 
            })
            .margin({ left: 20, right: 20 })
          })
        }.padding({ bottom: 16 })

        // 底部操作按钮
        Column({ space: 12 }) {
          Button() {
            Row({ space: 6 }) {
              Text('📝').fontSize(16)
              Text('写下推理笔记').fontSize(15)
            }
          }
          .type(ButtonType.Normal)
          .backgroundColor('#0A84FF')
          .fontColor('#FFFFFF')
          .borderRadius(14)
          .height(48)
          .width('100%')
          .onClick(() => {
            try { router.pushUrl({ url: 'pages/NotesEditorPage', params: { id: this.sid } }) } catch (_) {}
          })
          
          if (this.ownedCount() === 0) {
            Text('💬 还没有收集到线索，继续探索剧情吧！')
              .fontSize(13)
              .opacity(0.6)
              .textAlign(TextAlign.Center)
          }
        }.padding({ left: 20, right: 20, bottom: 24 })
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#FFFFFF')
  }
}
