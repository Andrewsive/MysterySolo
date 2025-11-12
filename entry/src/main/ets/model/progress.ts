import { Achievement, HistoryEntry, PlaySummary, TrailEntry, UserNote, UserSettings } from './types';
import { getScript } from './store';

const DEFAULT_SETTINGS: UserSettings = {
  soundEnabled: true,
  textSize: 16,
  autoDownload: false,
  theme: 'default'
};

const historyStore: HistoryEntry[] = [];
const notesStore: UserNote[] = [];
let settingsStore: UserSettings = DEFAULT_SETTINGS;
let lastPlay: HistoryEntry | undefined = undefined;
let onboarded = false;

const seedScript = getScript('demo');
if (seedScript) {
  historyStore.push({
    sessionId: 'seed-history',
    scriptId: 'demo',
    endingId: 'ending_good',
    endingTitle: '脱身',
    score: 92,
    durationMin: seedScript.durationMin,
    timestamp: Date.now() - 3600 * 6 * 1000,
    clues: ['note_diary'],
    flags: { hasKey: true },
    trail: [
      { sceneId: 'start', choiceText: '翻阅手札' },
      { sceneId: 'diary', choiceText: '折好手札' },
      { sceneId: 'start', choiceText: '检查钥匙' },
      { sceneId: 'key', choiceText: '前往边门' },
      { sceneId: 'sideDoor', choiceText: '用钥匙试试' }
    ],
    usedHints: 0,
    notes: '雨夜的手札提示很关键。'
  });
  lastPlay = historyStore[0];
}

function cloneHistory(entry: HistoryEntry): HistoryEntry {
  return {
    sessionId: entry.sessionId,
    scriptId: entry.scriptId,
    endingId: entry.endingId,
    endingTitle: entry.endingTitle,
    score: entry.score,
    durationMin: entry.durationMin,
    timestamp: entry.timestamp,
    clues: [...entry.clues],
    flags: { ...entry.flags },
    trail: entry.trail.map((item: TrailEntry) => ({ ...item })),
    usedHints: entry.usedHints,
    notes: entry.notes
  };
}

export function listHistory(): HistoryEntry[] {
  return historyStore.map((entry: HistoryEntry) => cloneHistory(entry));
}

export function getHistoryById(id: string): HistoryEntry | undefined {
  const match = historyStore.find((entry: HistoryEntry) => entry.sessionId === id);
  return match ? cloneHistory(match) : undefined;
}

export function recordPlay(summary: PlaySummary, endingTitle: string): void {
  const entry: HistoryEntry = { ...summary, endingTitle };
  const existingIndex = historyStore.findIndex((item: HistoryEntry) => item.sessionId === entry.sessionId);
  if (existingIndex >= 0) {
    historyStore.splice(existingIndex, 1);
  }
  historyStore.unshift(entry);
  lastPlay = entry;
}

export function getLastPlaySummary(): HistoryEntry | undefined {
  return lastPlay ? cloneHistory(lastPlay) : undefined;
}

export function getAchievements(): Achievement[] {
  const count = historyStore.length;
  let highScore = 0;
  let clueRuns = 0;
  for (let i = 0; i < historyStore.length; i++) {
    const entry = historyStore[i];
    if (entry.score > highScore) highScore = entry.score;
    if (entry.clues.length >= 3) clueRuns += 1;
  }
  return [
    {
      id: 'starter',
      title: '初探谜境',
      description: '完成首次剧本推理',
      unlocked: count >= 1,
      progress: Math.min(count, 1)
    },
    {
      id: 'collector',
      title: '线索收集者',
      description: '在单次剧本中收集 3 条以上线索',
      unlocked: clueRuns > 0,
      progress: Math.min(clueRuns, 5)
    },
    {
      id: 'highscore',
      title: '推理大师',
      description: '达成 90 分以上结局',
      unlocked: highScore >= 90,
      progress: highScore >= 90 ? 1 : highScore / 90
    }
  ];
}

export function getUserSettings(): UserSettings {
  return {
    soundEnabled: settingsStore.soundEnabled,
    textSize: settingsStore.textSize,
    autoDownload: settingsStore.autoDownload,
    theme: settingsStore.theme
  };
}

export function updateUserSettings(next: UserSettings): void {
  settingsStore = next;
}

export function getNote(scriptId: string): UserNote | undefined {
  const match = notesStore.find((note: UserNote) => note.scriptId === scriptId);
  if (!match) return undefined;
  return {
    scriptId: match.scriptId,
    suspects: match.suspects,
    motive: match.motive,
    evidence: match.evidence,
    paradox: match.paradox,
    updatedAt: match.updatedAt
  };
}

export function saveNote(note: UserNote): void {
  const idx = notesStore.findIndex((item: UserNote) => item.scriptId === note.scriptId);
  if (idx >= 0) {
    notesStore[idx] = note;
  } else {
    notesStore.unshift(note);
  }
}

export function setOnboarded(): void {
  onboarded = true;
}

export function hasOnboarded(): boolean {
  return onboarded;
}

export function buildReplaySuggestions(entry: HistoryEntry): string[] {
  const script = getScript(entry.scriptId);
  const suggestions: string[] = [];
  if (!script) {
    return suggestions;
  }
  if (entry.clues.length < script.clues.length) {
    suggestions.push('尝试收集更多线索后再做关键选择，可能触发隐藏结局。');
  }
  if (entry.usedHints === 0 && entry.score < 80) {
    suggestions.push('合理利用提示功能，关注线索之间的矛盾点。');
  }
  if (entry.flags && Object.keys(entry.flags).length === 0) {
    suggestions.push('某些道具需要在场景内主动获取，注意道具描述。');
  }
  if (script.highlights && script.highlights.length > 0) {
    suggestions.push(`重点体验：${script.highlights[0].title} — ${script.highlights[0].description}`);
  }
  return suggestions;
}

export function trailDisplay(trail: TrailEntry[]): string[] {
  const lines: string[] = [];
  for (let i = 0; i < trail.length; i++) {
    lines.push(`步骤 ${i + 1} · ${trail[i].choiceText}`);
  }
  return lines;
}

