library gridhub.src.stores;

import 'package:gridhub/src/stores/global_state_store.dart';
import 'package:gridhub/src/stores/repos_store.dart';

class GridHubStores {

  GlobalStateStore globalStateStore;
  ReposStore reposStore;

  GridHubStores(this.reposStore, this.globalStateStore);
}
