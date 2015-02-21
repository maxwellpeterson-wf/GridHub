import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;

import 'components/GridHubApp.dart' show GridHubApp;
import 'services/localStorageService.dart' as localStorageService;
import 'stores/ReposStore.dart';


var storage;
var store;

void main() {
    reactClient.setClientConfiguration();

    storage = new localStorageService.RepoGridData();
    store = new ReposStore(storage);

    renderApp();
}

void renderApp() {
    react.render(GridHubApp({}), querySelector('#app-container'));
}
