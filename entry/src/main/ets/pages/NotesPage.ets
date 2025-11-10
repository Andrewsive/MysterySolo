import router from '@ohos.router';
import { getScript } from '../model/store';
import { NotesParams } from '../model/types';

@Component
struct NotesPage {
  @State sid: string = 'demo';
  @State got: string[] = [];

  aboutToAppear() {
    try {
      const p = router.getParams() as NotesParams | undefined;
      if (p && p.id) this.sid = p.id;
      if (p && p.clues) this.got = p.clues;
    } catch (_) {}
  }

  build() {
    const all = getScript(this.sid)!.clues;
    Column() {
      Text('线索').fontSize(20).fontWeight(FontWeight.Bold).padding(16)
      List() {
        ForEach(all, (c) => {
          ListItem() {
            Column() {
              Row() {
                Text(c.name).fontSize(16)
                Text(this.got.indexOf(c.id) >= 0 ? '  已获得' : '  未获得').fontSize(12).opacity(0.6)
              }
              Text(c.desc).fontSize(14).opacity(0.8)
            }.padding(12)
          }
        })
      }
      Button('返回').margin(16).onClick(() => { try { router.back()
