import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:gridhub/gridhub.dart';

void main() {
  // Container that the application will be rendered into
  var domContainer = querySelector('#app-container');

  reactClient.setClientConfiguration();

  // Initialize actions
  GridHubActions actions = new GridHubActions();

  // Initialize data layer and stores
  var storage = new RepoGridData();
  GridHubStores stores = new GridHubStores(
    new ReposStore(actions, storage),
    new GlobalStateStore(actions)
  );

  // Render the application
  react.render(GridHubApp({'actions': actions, 'stores': stores}), domContainer);

  document.onKeyDown.listen((KeyboardEvent event) {
    handleKeyDown(event, actions);
  });
}
