library gridhub.actions;

import 'package:flux/flux.dart';

part './global_state_actions.dart';
part './repo_actions.dart';

class GridHubActions {

  final GlobalStateActions globalStateActions = new GlobalStateActions();
  final RepoActions repoActions = new RepoActions();

  GridHubActions();
}
