import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:repoGrid/grid_hub_page.dart';
import 'package:repoGrid/grid_hub_header.dart';
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

class GHAP implements GitHubAuthProvider {
    localStorageService.GridHubData _storage;

    String get githubAccessToken => _storage.githubAccessToken;
    String get githubUsername => _storage.githubUsername;

    GHAP(localStorageService.GridHubData storage) {
        _storage = storage;
    }
}

void main() {
    reactClient.setClientConfiguration();

    // Initialize data layer
    localStorageService.GridHubData storage = new localStorageService.GridHubData();
    GitHubDataProvider githubDataProvider = new GHDP(storage);
    GitHubAuthProvider githubAuthProvider = new GHAP(storage);

    // Map of page modules
    Map<String, GridHubPage> pageModules = {};

    /**
     * Page module api streams
     */
    StreamController<String> _setActivePaneStreamController = new StreamController<String>();
    Stream<String> setActivePaneStream = _setActivePaneStreamController.stream.asBroadcastStream();

    /**
     * Wire up header module
     */
    GridHubHeader headerModule = new GridHubHeader(storage.pageNames, storage.currentPageName, githubAuthProvider);
    headerModule.events.githubAccessTokenUpdateAction.listen((String accessToken) {
        storage.githubAccessToken = accessToken;
    });
    headerModule.events.githubUsernameUpdateAction.listen((String username){
        storage.githubUsername = username;
    });
    headerModule.events.globalActivePaneSwitchAction.listen((String pane) {
        _setActivePaneStreamController.add(pane);
    });
    headerModule.events.pageAddAction.listen(storage.addPage);
    headerModule.events.pageRefreshAction.listen((_) {
        pageModules[storage.currentPageName].api.refreshPageData();
    });
    headerModule.events.pageRemoveAction.listen(storage.deletePage);
    headerModule.events.pageRenameAction.listen((Map<String, String> pageInfo) {
        // TODO!
//        storage.renamePage();
    });

    headerModule.events.repoAddAction.listen(storage.addRepo);


    storage.pages.forEach((String pageName, List<String> repos) {
        GridHubPage pageModule = new GridHubPage(repos, githubDataProvider);
        pageModules[pageName] = pageModule;
        setActivePaneStream.listen(pageModule.api.setActivePane);
    });

    void render() {
        // Render the application
        renderApp(headerModule.component, pageModules[storage.currentPageName].component);
    }

    headerModule.events.pageSwitchAction.listen((String pageName) {
        storage.currentPageName = pageName;
        render();
    });

    render();
}

void renderApp(dynamic headerComponent, dynamic pageComponent) {
    var domContainer = querySelector('#app-container');
    react.render(GridHubApp({
        'headerComponent': headerComponent,
        'pageComponent': pageComponent,
    }), domContainer);
}
