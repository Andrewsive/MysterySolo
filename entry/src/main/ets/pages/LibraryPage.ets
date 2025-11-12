import router from '@ohos.router';
import { listScripts, getScript } from '../model/store';
import { ShortScript, Script, DownloadItem, DownloadStatus } from '../model/types';
import { listDownloads, startOrResumeDownload, pauseDownload, deleteDownload } from '../model/downloads';

interface FilterChip {
  label: string;
  value: string;
}

interface DifficultyTab {
  label: string;
  idx: number;
}

@Entry
@Component
struct LibraryPage {
  private scripts: Script[] = listScripts()
    .map((s: ShortScript) => getScript(s.id))
    .filter((s: Script | undefined) => s !== undefined) as Script[];
  private tabs: DifficultyTab[] = [
    { label: '全部', idx: 0 },
    { label: '新手', idx: 1 },
    { label: '进阶', idx: 2 },
    { label: '硬核', idx: 3 }
  ];
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
  @State activeTab: number = 0;
  @State downloads: DownloadItem[] = listDownloads();
  @State filtered: Script[] = [];
  @State revision: number = 0;

  aboutToAppear() {
    this.applyFilters();
  }

  private applyFilters(): void {
    const result: Script[] = [];
    const key = this.keyword.trim();
    for (let i = 0; i < this.scripts.length; i++) {
      const script = this.scripts[i];
      if (this.offlineMode && this.downloadStatusLocal(script.id) !== 'completed') {
        continue;
      }
      if (!this.matchTab(script)) {
        continue;
      }
      if (this.genre !== 'all' && script.genre !== this.genre) {
        continue;
      }
      if (!this.matchDifficulty(script)) {
        continue;
      }
      if (!this.matchDuration(script)) {
        continue;
      }
      if (!this.matchKeyword(script, key)) {
        continue;
      }
      result.push(script);
    }
    this.filtered = result;
  }

  private matchTab(script: Script): boolean {
    if (this.activeTab === 1) return script.difficulty <= 1;
    if (this.activeTab === 2) return script.difficulty === 2;
    if (this.activeTab === 3) return script.difficulty >= 3;
    return true;
  }

  private matchDifficulty(script: Script): boolean {
    if (this.difficulty === 'all') return true;
    if (this.difficulty === 'easy') return script.difficulty <= 1;
    if (this.difficulty === 'mid') return script.difficulty === 2;
    return script.difficulty >= 3;
  }

  private matchDuration(script: Script): boolean {
    if (this.duration === 'all') return true;
    if (this.duration === 'short') return script.durationMin <= 15;
    if (this.duration === 'medium') return script.durationMin > 15 && script.durationMin <= 30;
    return script.durationMin >= 30;
  }

  private matchKeyword(script: Script, key: string): boolean {
    if (key.length === 0) return true;
    if (script.title.includes(key)) return true;
    if (script.tagline && script.tagline.includes(key)) return true;
    if (script.tags && script.tags.some((tag: string) => tag.includes(key))) return true;
    return false;
  }

  private downloadStatusLocal(scriptId: string): DownloadStatus {
    const info = this.downloads.find((item: DownloadItem) => item.scriptId === scriptId);
    return info ? info.status : 'notDownloaded';
  }

  private downloadInfo(scriptId: string): DownloadItem | undefined {
    return this.downloads.find((item: DownloadItem) => item.scriptId === scriptId);
  }

  private hasDownloadInfo(scriptId: string): boolean {
    const status = this.downloadStatusLocal(scriptId);
    return status !== 'notDownloaded';
  }

  private downloadProgressValue(scriptId: string): number {
    const info = this.downloadInfo(scriptId);
    return info ? info.progress / 100 : 0;
  }

  private downloadProgressLabel(scriptId: string): string {
    const info = this.downloadInfo(scriptId);
    if (!info) return '0%';
    return `${info.progress}% · ${info.speedKBps} KB/s · 约 ${info.etaMinutes} 分钟`;
  }

  private refreshDownloads(): void {
    this.downloads = listDownloads();
    this.applyFilters();
    this.revision += 1;
  }

  private recentScripts(): Script[] {
    return this.filtered.filter((script: Script) => script.releaseDaysAgo !== undefined && script.releaseDaysAgo <= 30);
  }

  private highScoreScripts(): Script[] {
    return this.filtered.filter((script: Script) => (script.rating ?? 0) >= 4.5);
  }

  private downloadedScripts(): Script[] {
    const result: Script[] = [];
    for (let i = 0; i < this.downloads.length; i++) {
      const item = this.downloads[i];
      if (item.status === 'completed') {
        const script = getScript(item.scriptId);
        if (script) {
          result.push(script);
        }
      }
    }
    return result;
  }

  @Builder
  private filterChipRow(chips: FilterChip[], current: string, onSelect: (value: string) => void) {
    Row({ space: 10 }) {
      ForEach(chips, (chip: FilterChip) => {
        Button(chip.label)
          .type(current === chip.value ? ButtonType.Capsule : ButtonType.Normal)
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            onSelect(chip.value);
            this.applyFilters();
          })
      }, (chip: FilterChip) => chip.value)
    }.margin({ left: 20, right: 20 })
  }

  @Builder
  private renderScriptItem(script: Script) {
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
            if (this.downloadStatusLocal(script.id) === 'completed') {
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
          if (this.downloadStatusLocal(script.id) === 'downloading') {
            Button('暂停').onClick(() => {
              pauseDownload(script.id);
              this.refreshDownloads();
            })
          } else if (this.downloadStatusLocal(script.id) === 'completed') {
            Button('删除').onClick(() => {
              deleteDownload(script.id);
              this.refreshDownloads();
            })
          } else {
            Button(this.downloadStatusLocal(script.id) === 'paused' ? '继续下载' : '下载')
              .type(ButtonType.Capsule)
              .onClick(() => {
                startOrResumeDownload(script.id);
                this.refreshDownloads();
              })
          }
        }
      }
      if (this.hasDownloadInfo(script.id)) {
        Column({ space: 6 }) {
          Progress({ value: this.downloadProgressValue(script.id) }).width('100%').height(4).backgroundColor('#E4E6EB')
          Text(this.downloadProgressLabel(script.id)).fontSize(11).opacity(0.6)
        }
      }
    }
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .onClick(() => {
      try { router.pushUrl({ url: 'pages/DetailPage', params: { id: script.id } }) } catch (_) {}
    })
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('剧本库').fontSize(26).fontWeight(FontWeight.Bold)
          Blank()
          Button(this.offlineMode ? '切换在线' : '离线模式').onClick(() => {
            this.offlineMode = !this.offlineMode;
            this.applyFilters();
          })
        }.padding({ top: 24, left: 20, right: 20 })

        TextInput({ placeholder: '搜索标题 / 标签' })
          .onChange((v: string) => {
            this.keyword = v;
            this.applyFilters();
          })
          .margin({ left: 20, right: 20 })

        Row({ space: 10 }) {
          ForEach(this.tabs, (tab: DifficultyTab) => {
            Button(tab.label)
              .type(this.activeTab === tab.idx ? ButtonType.Capsule : ButtonType.Normal)
              .fontSize(13)
              .padding({ left: 14, right: 14 })
              .onClick(() => {
                this.activeTab = tab.idx;
                this.applyFilters();
              })
          }, (tab: DifficultyTab) => `${tab.idx}`)
          Blank()
        }.margin({ left: 20, right: 20 })

        Column({ space: 12 }) {
          Text('题材').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.filterChipRow(this.genres, this.genre, (value: string) => { this.genre = value })
          Text('难度').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.filterChipRow(this.difficultyChips, this.difficulty, (value: string) => { this.difficulty = value })
          Text('时长').fontSize(14).opacity(0.7).padding({ left: 20 })
          this.filterChipRow(this.durationChips, this.duration, (value: string) => { this.duration = value })
        }

        if (this.filtered.length === 0) {
          Column({ space: 10 }) {
            Text('没有符合条件的剧本').fontSize(16).padding({ top: 40 })
            Button('清空筛选').onClick(() => {
              this.keyword = '';
              this.genre = 'all';
              this.difficulty = 'all';
              this.duration = 'all';
              this.activeTab = 0;
              this.offlineMode = false;
              this.applyFilters();
            })
            Button('查看推荐').onClick(() => {
              this.offlineMode = false;
              this.applyFilters();
            })
          }.padding({ left: 20, right: 20 })
        } else {
          Column({ space: 12 }) {
            Text('新品上架').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(this.recentScripts(), (script: Script) => {
              this.renderScriptItem(script)
            }, (script: Script) => `${script.id}-new-${this.revision}`)

            Text('高分口碑').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            ForEach(this.highScoreScripts(), (script: Script) => {
              this.renderScriptItem(script)
            }, (script: Script) => `${script.id}-top-${this.revision}`)

            Text('离线已下载').fontSize(18).fontWeight(FontWeight.Medium).padding({ left: 20, right: 20 })
            if (this.downloadedScripts().length === 0) {
              Text('暂无离线剧本，先下载一个吧。').fontSize(13).opacity(0.6).padding({ left: 20, right: 20 })
            } else {
              ForEach(this.downloadedScripts(), (script: Script) => {
                this.renderScriptItem(script)
              }, (script: Script) => `${script.id}-offline-${this.revision}`)
            }
          }.padding({ bottom: 32 })
        }
      }
    }.scrollBar(BarState.Off).height('100%').backgroundColor('#F6F7F9')
  }
}
