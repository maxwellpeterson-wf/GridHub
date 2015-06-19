library gridhub.utils.keyboard_shortcuts;

import 'dart:html';

import '../actions/actions.dart';

void handleKeyDown(KeyboardEvent event, GridHubActions gridhubActions) {
  RepoActions actions = gridhubActions.repoActions;
  switch (event.keyCode) {
    // Pages
    case KeyCode.ONE:
      actions.switchPageByIndex.dispatch(0);
      break;
    case KeyCode.TWO:
      actions.switchPageByIndex.dispatch(1);
      break;
    case KeyCode.THREE:
      actions.switchPageByIndex.dispatch(2);
      break;
    case KeyCode.FOUR:
      actions.switchPageByIndex.dispatch(3);
      break;
    case KeyCode.FIVE:
      actions.switchPageByIndex.dispatch(4);
      break;
    case KeyCode.SIX:
      actions.switchPageByIndex.dispatch(5);
      break;
    case KeyCode.SEVEN:
      actions.switchPageByIndex.dispatch(6);
      break;
    case KeyCode.EIGHT:
      actions.switchPageByIndex.dispatch(7);
      break;
    case KeyCode.NINE:
      actions.switchPageByIndex.dispatch(8);
      break;
    case KeyCode.ZERO:
      actions.switchPageByIndex.dispatch(9);
      break;

    // Panels
    case KeyCode.A:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('1');
      break;
    case KeyCode.S:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('2');
      break;
    case KeyCode.D:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('3');
      break;
    case KeyCode.F:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('4');
      break;
    case KeyCode.G:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('5');
      break;
    case KeyCode.H:
      gridhubActions.globalStateActions.switchActivePaneKey.dispatch('6');
      break;

    // Open/Close
    case KeyCode.O:
      gridhubActions.globalStateActions.globalOpenState.dispatch(true);
      break;
    case KeyCode.P:
      gridhubActions.globalStateActions.globalOpenState.dispatch(false);
      break;

    // Refresh
    case KeyCode.R:
      actions.refreshPage.dispatch();
      break;
  }
}
