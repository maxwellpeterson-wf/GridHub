import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:repoGrid/grid_hub_page.dart';

//import 'components/GridHubApp.dart' show GridHubApp;
//import 'services/localStorageService.dart' as localStorageService;
//import 'stores/ReposStore.dart';


var storage;
var reposStore;

class GHDP implements GitHubDataProvider {
    String get authorization => 'ZXZhbndlaWJsZS13Zjo2MTU2ZGIxMmM4ZTExYmVjNDkxNzg1MTMzMmU0ZDFjZTZmMGM3YzA3';
}

void main() {
    reactClient.setClientConfiguration();

    var module = new GridHubPage(['Workiva/wGulp', 'Workiva/karma-jspm', 'jspm/jspm-cli'], new GHDP());
    module.events.repoRemove.listen((String repoName) {
        print('Repo removed: ${repoName}');
    });

    // Initialize data layer and store
//    storage = new localStorageService.RepoGridData();

    // Render the application
    renderApp(module.component);
}

void renderApp(component) {
    var domContainer = querySelector('#app-container');
    react.render(component, domContainer);
}
