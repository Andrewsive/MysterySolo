import router from '@ohos.router';
import { listScripts, getScript } from '../model/store';
import { ShortScript, Script } from '../model/types';
import { getDownload, getDownloadStatus, listDownloads, startOrResumeDownload, pauseDownload, deleteDownload } from '../model/downloads';

interface FilterChip {
  label: string;
  value: string;
}

@Entry
@Component
struct LibraryPage {
  private scripts: Script[] = listScripts().map((s: ShortScript) => getScript(s.id)).filter((s: Script | undefined): s is Script => !!s);
  private genres: FilterChip[] = [
    { label: '全部', value: 'all' },
    { label: '悬疑', value: '悬疑' },
    { label: '情感', value: '情感悬疑' },
    { label: '艺术', value: '艺术' },
    { label: '科幻', value: '科幻' }
  ];
  private difficultyChips: FilterChip[] = [
    { label: '全部', value: 'all' },
    { label: '新手', value: 'easy' },
    { label: '进阶', value: 'mid' },
    { label: '硬核', value: 'hard' }
  ];
  private durationChips: FilterChip[] = [
    { label: '全部', value: 'all' },
    { label: '≤15 分钟', value: 'short' },
    { label: '15-30 分钟', value: 'medium' },
    { label: '≥30 分钟', value: 'long' }
  ];

  @State keyword: string = '';
  @State genre: string = 'all';
  @State difficulty: string = 'all';
  @State duration: string = 'all';
  @State offlineMode: boolean = false;
  @State revision: number = 0;

  private filterScripts(): Script[] {
    return this.scripts.filter((script: Script) => {
      if (this.offlineMode && getDownloadStatus(script.id) !== 'completed') {
        return false;
      }
      if (this.genre !== 'all' && script.genre !== this.genre) {
        return false;
      }
      if (this.difficulty !== 'all') {
        if (this.difficulty === 'easy' && script.difficulty > 1) return false;
        if (this.difficulty === 'mid' && script.difficulty !== 2) return false;
        if (this.difficulty === 'hard' && script.difficulty < 3) return false;
      }
      if (this.duration !== 'all') {
        if (this.duration === 'short' && script.durationMin > 15) return false;
        if (this.duration === 'medium' && (script.durationMin <= 15 || script.durationMin > 30)) return false;
        if (this.duration === 'long' && script.durationMin < 30) return false;
      }
      const key = this.keyword.trim();
      if (key.length === 0) {
        return true;
      }
      if (script.title.includes(key)) return true;
      if (script.tags && script.tags.some((tag: string) => tag.includes(key))) return true;
      return script.tagline ? script.tagline.includes(key) : false;
    });
  }

  @Builder
  private chipRow(chips: FilterChip[], current: string, setter: (value: string) => void) {
    Row({ space: 10 }) {
      ForEach(chips, (chip: FilterChip) => {
        Button(chip.label)
          .type(current === chip.value ? ButtonType.Capsule : ButtonType.Normal)
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .onClick(() => { setter(chip.value); })
      }, (chip: FilterChip) => chip.value)
    }.margin({ left: 20, right: 20 })
  }

  @Builder
  private renderScriptItem(script: Script) {
    const download = getDownload(script.id);
    const status = download ? download.status : 'notDownloaded';
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text(script.title).fontSize(18).fontWeight(FontWeight.Medium)
          if (script.tagline) {
            Text(script.tagline).fontSize(13).opacity(0.7)
          }
          Text(`${script.genre ?? '未知题材'} · ${script.durationMin} 分钟 · ${script.difficulty <= 1 ? '新手' : script.difficulty === 2 ? '进阶' : '硬核'}`).fontSize(12).opacity(0.6)
          if (script.tags) {
            Row({ space: 6 }) {
              ForEach(script.tags, (tag: string) => {
                Text(`#${tag}`).fontSize(11).opacity(0.6)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor('#EEF1F5').borderRadius(12)
              }, (tag: string) => tag)
            }
          }
          Row({ space: 6 }) {
            if (script.rating) {
              Text(`评分 ${script.rating?.toFixed(1)}`).fontSize(12).opacity(0.65)
            }
            if (script.releaseDaysAgo !== undefined) {
              Text(script.releaseDaysAgo <= 7 ? '新品' : script.releaseDaysAgo <= 30 ? '近期开售' : '经典回归').fontSize(11).opacity(0.6)
            }
            if (status === 'completed') {
              Text('离线可玩').fontSize(11).opacity(0.7)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#E5F5EA').borderRadius(12)
            }
          }
        }
        Blank()
        Column({ space: 8 }) {
          Button('详情').onClick(() => {
            try { router.pushUrl({ url: 'pages/DetailPage', params: { id: script.id } }) } catch (_) {}
          })
          if (status === 'downloading') {
            Button('暂停').onClick(() => {
              pauseDownload(script.id);
              this.revision += 1;
            })
          } else if (status === 'completed') {
            Button('删除').onClick(() => {
              deleteDownload(script.id);
              this.revision += 1;
            })
          } else {
            Button(status === 'paused' ? '继续下载' : '下载').type(ButtonType.Capsule).onClick(() => {
              startOrResumeDownload(script.id);
              this.revision += 1;
            })
          }
        }
      }
      if (download && status !== 'notDownloaded') {
        Column({ space: 6 }) {
          Progress({ value: download.progress / 100 }).width('100%').height(4).backgroundColor('#E4E6EB')
          Text(`${download.progress}% · ${download.speedKBps} KB/s · 约 ${download.etaMinutes} 分钟`).fontSize(11).opacity(0.6)
        }
      }
    }.padding({ left: 20, right: 20, top: 16, bottom: 16 }).backgroundColor('#FFFFFF').borderRadius(18).onClick(() => {
      try { router.pushUrl({ url: 'pages/DetailPage', params: { id: script.id } }) } catch (_) {}
    })
  }

  build() {
    const _revision = this.revision;
    const filtered = this.filterScripts();
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('剧本库').fontSize(26).fontWeight(FontWeight.Bold)
          Blank()
          Button(this.offlineMode ? '切换在线' : '离线模式').onClick(() => { this.offlineMode = !this.offlineMode; })
        }.padding({ top: 24, left: 20, right: 20 })

        TextInput({ placeholder: '搜索标题 / 标签' })
          .onChange((v: string) => { this.keyword = v })
          .margin({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('题材').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.chipRow(this.genres, this.genre, (value: string) => { this.genre = value })
          Text('难度').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.chipRow(this.difficultyChips, this.difficulty, (value: string) => { this.difficulty = value })
          Text('时长').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.chipRow(this.durationChips, this.duration, (value: string) => { this.duration = value })
        }

        if (filtered.length === 0) {
          Column({ space: 10 }) {
            Text('没有符合条件的剧本').fontSize(16).padding({ top: 40 })
            Button('清空筛选').onClick(() => {
              this.keyword = '';
              this.genre = 'all';
              this.difficulty = 'all';
              this.duration = 'all';
            })
            Button('查看推荐').onClick(() => { this.offlineMode = false; })
          }.padding({ left: 20, right: 20 })
        } else {
          Column({ space: 12 }) {
            Text('新品上架').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(filtered.filter((script: Script) => script.releaseDaysAgo !== undefined && script.releaseDaysAgo <= 30), (script: Script) => {
              this.renderScriptItem(script)
            }, (script: Script) => script.id + '-new-' + _revision)

            Text('高分口碑').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(filtered.filter((script: Script) => (script.rating ?? 0) >= 4.5), (script: Script) => {
              this.renderScriptItem(script)
            }, (script: Script) => script.id + '-top-' + _revision)

            Text('离线已下载').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            const downloaded = listDownloads().filter((item) => item.status === 'completed');
            if (downloaded.length === 0) {
              Text('暂无离线剧本，先下载一个吧。').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
            } else {
              ForEach(downloaded, (item) => {
                const script = getScript(item.scriptId);
                if (script) { this.renderScriptItem(script) }
              }, (item) => item.scriptId + '-offline-' + _revision)
            }
          }.padding({ bottom: 32 })
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#F6F7F9')
  }
}

