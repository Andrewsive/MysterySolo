import { SCRIPTS } from './scripts';
import { Script, ShortScript } from './types';

export function listScripts(): ShortScript[] {
  // 显式返回 ShortScript[]
  return SCRIPTS.map((s: Script): ShortScript => ({
    id: s.id, title: s.title, difficulty: s.difficulty, durationMin: s.durationMin
  }));
}

export function getScript(id: string): Script | undefined {
  return SCRIPTS.find((s: Script) => s.id === id);
}

