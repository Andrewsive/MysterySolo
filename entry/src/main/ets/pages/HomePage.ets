import router from '@ohos.router';
import { listScripts } from '../model/store';
import { ShortScript } from '../model/types';

@Entry
@Component
struct HomePage {
  private data: ShortScript[] = listScripts();
  @State keyword: string = '';

  build() {
    Column({ space: 8 }) {
      Text('谜境独白')
        .fontSize(24).fontWeight(FontWeight.Bold)
        .padding({ top: 16, left: 16 })

      TextInput({ placeholder: '搜索剧本标题' })
        .onChange((v: string) => { this.keyword = v })
        .margin({ left: 16, right: 16 })

      List() {
        ForEach(
          this.data.filter((d: ShortScript) => d.title.includes(this.keyword)),
          (s: ShortScript) => {
            ListItem() {
              Row() {
                Column() {
                  Text(s.title).fontSize(18).fontWeight(FontWeight.Medium)
                  Text(`难度 ${s.difficulty} · 约 ${s.durationMin} 分钟`).fontSize(12).opacity(0.7)
                }
                Blank()
                Button('开始').onClick(() => {
                  try { router.pushUrl({ url: 'pages/DetailPage', params: { id: s.id } }) } catch (_) {}
                })
              }.padding(12)
            }
          }
        )
      }
    }.height('100%')
  }
}

@Preview
@Component
struct HomePreview { build() { HomePage() } }
