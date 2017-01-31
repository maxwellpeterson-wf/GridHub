library gridhub.actions;

import 'package:gridhub/src/actions/global_state_actions.dart';
import 'package:gridhub/src/actions/repo_actions.dart';

class GridHubActions {

  final GlobalStateActions globalStateActions = new GlobalStateActions();
  final RepoActions repoActions = new RepoActions();

  GridHubActions();
}
