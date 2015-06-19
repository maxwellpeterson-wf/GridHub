import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;

import 'actions/actions.dart';
import 'components/GridHubApp.dart' show GridHubApp;
import 'services/localStorageService.dart' as localStorageService;
import 'stores/stores.dart';
import 'utils/keyboard_shortcuts.dart';


void main() {
    // Container that the application will be rendered into
    var domContainer = querySelector('#app-container');

    reactClient.setClientConfiguration();

    // Initialize actions
    GridHubActions actions = new GridHubActions();

    // Initialize data layer and stores
    var storage = new localStorageService.RepoGridData();
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
