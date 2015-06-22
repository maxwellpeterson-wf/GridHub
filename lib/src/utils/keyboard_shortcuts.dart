library gridhub.utils.keyboard_shortcuts;

import 'dart:html';

import 'package:gridhub/src/actions.dart';
import 'package:gridhub/src/actions/repo_actions.dart';

void handleKeyDown(KeyboardEvent event, GridHubActions gridhubActions) {
  RepoActions actions = gridhubActions.repoActions;
  if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
  switch (event.keyCode) {
    // Pages
    case KeyCode.ONE:
      actions.switchPageByIndex(0);
      break;
    case KeyCode.TWO:
      actions.switchPageByIndex(1);
      break;
    case KeyCode.THREE:
      actions.switchPageByIndex(2);
      break;
    case KeyCode.FOUR:
      actions.switchPageByIndex(3);
      break;
    case KeyCode.FIVE:
      actions.switchPageByIndex(4);
      break;
    case KeyCode.SIX:
      actions.switchPageByIndex(5);
      break;
    case KeyCode.SEVEN:
      actions.switchPageByIndex(6);
      break;
    case KeyCode.EIGHT:
      actions.switchPageByIndex(7);
      break;
    case KeyCode.NINE:
      actions.switchPageByIndex(8);
      break;
    case KeyCode.ZERO:
      actions.switchPageByIndex(9);
      break;

    // Panels
    case KeyCode.A:
      gridhubActions.globalStateActions.switchActivePaneKey('1');
      break;
    case KeyCode.S:
      gridhubActions.globalStateActions.switchActivePaneKey('2');
      break;
    case KeyCode.D:
      gridhubActions.globalStateActions.switchActivePaneKey('3');
      break;
    case KeyCode.F:
      gridhubActions.globalStateActions.switchActivePaneKey('4');
      break;
    case KeyCode.G:
      gridhubActions.globalStateActions.switchActivePaneKey('5');
      break;
    case KeyCode.H:
      gridhubActions.globalStateActions.switchActivePaneKey('6');
      break;

    // Open/Close
    case KeyCode.O:
      gridhubActions.globalStateActions.globalOpenState(true);
      break;
    case KeyCode.P:
      gridhubActions.globalStateActions.globalOpenState(false);
      break;

    // Refresh
    case KeyCode.R:
      actions.refreshPage();
      break;
  }
}
