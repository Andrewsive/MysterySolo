// 通用域模型
export type FlagBag = Record<string, boolean | number | string>;

export interface Choice {
  text: string;
  next: string;
  require?: FlagBag;
  setFlags?: FlagBag;
  gainClues?: string[];
}

export interface Scene {
  id: string;
  text: string;
  choices: Choice[];
  gainClues?: string[];
  setFlags?: FlagBag;
}

export interface Ending {
  id: string;
  title: string;
  summary: string;
  score: number;
}

export interface Clue {
  id: string;
  name: string;
  desc: string;
}

export interface ScriptHighlight {
  title: string;
  description: string;
}

export interface ScriptHint {
  id: string;
  text: string;
}

export interface Script {
  id: string;
  title: string;
  difficulty: number;
  durationMin: number;
  intro: string;
  start: string;
  scenes: Scene[];
  endings: Ending[];
  clues: Clue[];
  cover?: string;
  tagline?: string;
  tags?: string[];
  genre?: string;
  recommendedFocus?: string;
  mood?: string;
  highlight?: string;
  highlights?: ScriptHighlight[];
  sizeMB?: number;
  releaseDaysAgo?: number;
  rating?: number;
  offlineAvailable?: boolean;
  hints?: ScriptHint[];
}

// 供 UI 列表使用的轻量类型
export interface ShortScript {
  id: string;
  title: string;
  difficulty: number;
  durationMin: number;
  tagline?: string;
  tags?: string[];
  mood?: string;
  rating?: number;
  offlineAvailable?: boolean;
  sizeMB?: number;
}

// 页面参数类型（统一放 TS 文件，避免 .ets 顶层声明）
export interface DetailParams { id?: string }
export interface PlayParams   { id?: string }
export interface NotesParams  { id?: string; clues?: string[] }
export interface ResultParams { id?: string; endingId?: string }
export interface DownloadDetailParams { id?: string }
export interface HistoryParams { id?: string }
export interface ErrorParams { message?: string; code?: string }

export type DownloadStatus = 'notDownloaded' | 'queued' | 'downloading' | 'paused' | 'completed';

export interface DownloadItem {
  scriptId: string;
  status: DownloadStatus;
  progress: number; // 0 - 100
  speedKBps: number;
  etaMinutes: number;
  sizeMB: number;
  updatedAt: number;
}

export interface TrailEntry {
  sceneId: string;
  choiceText: string;
}

export interface PlaySummary {
  sessionId: string;
  scriptId: string;
  endingId: string;
  score: number;
  durationMin: number;
  timestamp: number;
  clues: string[];
  flags: FlagBag;
  trail: TrailEntry[];
  usedHints: number;
}

export interface HistoryEntry extends PlaySummary {
  endingTitle: string;
  notes?: string;
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  unlocked: boolean;
  progress: number;
}

export interface UserSettings {
  soundEnabled: boolean;
  textSize: number;
  autoDownload: boolean;
  theme: 'default' | 'lowlight';
}

export interface UserNote {
  scriptId: string;
  suspects: string;
  motive: string;
  evidence: string;
  paradox: string;
  updatedAt: number;
}
