import router from '@ohos.router';
import { getScript } from '../model/store';
import { DetailParams } from '../model/types';

@Component
struct DetailPage {
  @State sId: string = 'demo';

  aboutToAppear() {
    try {
      const p = router.getParams() as DetailParams | undefined;
      if (p && p.id) this.sId = p.id;
    } catch (_) {}
  }

  build() {
    const s = getScript(this.sId)!;
    Column({ space: 12 }) {
      Text(s.title).fontSize(22).fontWeight(FontWeight.Bold).padding(16)
      Text(`难度 ${s.difficulty} · 约 ${s.durationMin} 分钟`).fontSize(14).opac

