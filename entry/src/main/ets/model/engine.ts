import { Script, Scene, Choice, FlagBag } from './types';

export class Engine {
  private script: Script;
  private sceneId: string;
  private flags: FlagBag = {};
  private clues: Set<string> = new Set<string>();

  constructor(script: Script) {
    this.script = script;
    this.sceneId = script.start ?? script.scenes[0].id;
  }

  current(): Scene | undefined {
    return this.script.scenes.find((s) => s.id === this.sceneId);
  }

  getClues(): string[] { return Array.from(this.clues); }
  getFlags(): FlagBag { return this.flags; }

  private meets(require?: FlagBag): boolean {
    if (!require) return true;
    for (const k in require) if (this.flags[k] !== require[k]) return false;
    return true;
  }

  choose(c: Choice): { ended: boolean; endingId?: string } {
    if (!this.meets(c.require)) return { ended: false };
    if (c.setFlags) Object.assign(this.flags, c.setFlags);
    if (c.gainClues) c.gainClues.forEach((id) => this.clues.add(id));

    const cur = this.current();
    if (cur?.setFlags) Object.assign(this.flags, cur.setFlags);
    if (cur?.gainClues) cur.gainClues.forEach((id) => this.clues.add(id));

    this.sceneId = c.next;
    const isEnding = this.script.endings.some(e => e.id === this.sceneId);
    return isEnding ? { ended: true, endingId: this.sceneId } : { ended: false };
  }

  restart(): void {
    this.sceneId = this.script.start ?? this.script.scenes[0].id;
    this.flags = {};
    this.clues.clear();
  }

  // ------- 新增：给 UI 用的轻量接口 -------
  getChoiceTexts(): string[] {
    const s = this.current();
    return s ? s.choices.map((c) => c.text) : [];
  }
  chooseByIndex(i: number): { ended: boolean; endingId?: string } {
    const s = this.current();
    if (!s) return { ended: false };
    const c = s.choices[i];
    if (!c) return { ended: false };
    return this.choose(c);
  }
}

