import Ability from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends Ability {
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/HomePage', (err) => {
      if (err) {
        console.error('Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
      }
    });
  }
}
