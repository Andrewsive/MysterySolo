import router from '@ohos.router';
import { getScript } from '../model/store';
import { ResultParams } from '../model/types';

@Component
struct ResultPage {
  @State sid: string = 'demo';
  @State endingId: string = 'ending_bad';

  aboutToAppear() {
    try {
      const p = router.getParams() as ResultParams | undefined;
      if (p && p.id) this.sid = p.id;
      if (p && p.endingId) this.endingId = p.endingId;
    } catch (_) {}
  }

  build() {
    const s = getScript(this.sid)!;
    const e = s.endings.find(x => x.id === this.endingId) ?? s.endings[0];

    Column({ space: 12 }) {
      Text('结局').fontSize(20).fontWeight(FontWeight.Bold).padding(16)
      Text(`${e.title} · 得分 ${e.score}`).fontSize(18).padding({ left: 16, right: 16 })
      Scroll() { Text(e.summary).fontSize(16).padding(16) }.height('60%')
      Row() {
        Button('回首页').onClick(() => {
          try { router.
