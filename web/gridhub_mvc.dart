import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:repoGrid/grid_hub_page.dart';
import 'package:repoGrid/mvc.dart' as mvc;

import 'components/GridHubApp.dart' show GridHubApp;
import 'services/localStorageService.dart' as localStorageService;
//import 'stores/ReposStore.dart';


class GHDP implements GitHubDataProvider {

    localStorageService.GridHubData _storage;

    String get authorization => _storage.githubAuthorization;

    GHDP(localStorageService.GridHubData storage) {
        _storage = storage;
    }
}

void main() {
    reactClient.setClientConfiguration();

    // Initialize data layer
    localStorageService.GridHubData storage = new localStorageService.GridHubData();
    GitHubDataProvider githubDataProvider = new GHDP(storage);

    Map<String, mvc.ViewModule> pageModules = {};

    storage.pages.forEach((String pageName, List<String> repos) {
        pageModules[pageName] = new GridHubPage(repos, githubDataProvider);
    });

    // Render the application
    renderApp(pageModules[storage.currentPageName].component, storage.pageNames, storage.currentPageName);
}

void renderApp(dynamic pageComponent, List<String> pageNames, String currentPageName) {
    var domContainer = querySelector('#app-container');
    react.render(GridHubApp({
        'currentPageName': currentPageName,
        'pageComponent': pageComponent,
        'pageNames': pageNames
    }), domContainer);
}
