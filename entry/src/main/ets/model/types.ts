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
}

// 页面参数类型（统一放 TS 文件，避免 .ets 顶层声明）
export interface DetailParams { id?: string }
export interface PlayParams   { id?: string }
export interface NotesParams  { id?: string; clues?: string[] }
export interface ResultParams { id?: string; endingId?: string }
