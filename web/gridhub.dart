import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;

import 'components/GridHubApp.dart' show GridHubApp;
import 'services/localStorageService.dart' as localStorageService;
import 'stores/ReposStore.dart';


var storage;
var reposStore;

void main() {
    reactClient.setClientConfiguration();

    // Initialize data layer and store
    storage = new localStorageService.RepoGridData();
    reposStore = new ReposStore(storage);

    // Render the application
    renderApp();
}

void renderApp() {
    var domContainer = querySelector('#app-container');
    react.render(GridHubApp({'reposStore': reposStore}), domContainer);
}
