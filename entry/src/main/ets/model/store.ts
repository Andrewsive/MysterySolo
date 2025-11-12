import { SCRIPTS } from './scripts';
import { Script, ShortScript } from './types';

export function listScripts(): ShortScript[] {
  return SCRIPTS.map((s: Script): ShortScript => ({
    id: s.id,
    title: s.title,
    difficulty: s.difficulty,
    durationMin: s.durationMin,
    tagline: s.tagline,
    tags: s.tags,
    mood: s.mood
  }));
}

export function getScript(id: string): Script | undefined {
  return SCRIPTS.find((s: Script) => s.id === id);
}

