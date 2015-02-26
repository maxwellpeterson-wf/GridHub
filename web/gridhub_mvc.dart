library gridhub_mvc;

import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:repoGrid/flux.dart' as flux;
import 'package:repoGrid/grid_hub_page.dart';
import 'package:repoGrid/grid_hub_header.dart';
import 'package:repoGrid/mvc.dart' as mvc;

import 'services/localStorageService.dart' as localStorageService;
//import 'stores/ReposStore.dart';

part 'actions/gridhub_mvc_actions.dart';
part 'components/gridhub_app_component.dart';
part 'components/gridhub_pages_component.dart';
part 'stores/current_page_name_store.dart';
part 'stores/page_components_store.dart';
part 'stores.dart';


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
    Map<String, dynamic> pageComponents = {};

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
    });

    headerModule.events.repoAddAction.listen((String repoName){
        storage.addRepo(repoName);
        pageModules[storage.currentPageName].api.addRepo(repoName);
    });


    storage.pages.forEach((String pageName, List<String> repos) {
        GridHubPage pageModule = new GridHubPage(repos, githubDataProvider, pageName);
        pageModules[pageName] = pageModule;
        pageComponents[pageName] = pageModule.component;

        pageModule.events.repoRemove.listen(storage.removeRepo);

        setActivePaneStream.listen(pageModule.api.setActivePane);
    });

    /**
     * App-level flux
     */
    Actions actions = new Actions();
    Stores stores = new Stores(
        new CurrentPageNameStore(actions, storage.currentPageName),
        new PageComponentsStore(actions, pageComponents)
    );

    headerModule.events.pageSwitchAction.listen((String pageName) {
        actions.pageSwitch.dispatch(pageName);
        storage.currentPageName = pageName;
    });


    var pagesComponent = GridHubPagesComponent({
        'actions': actions,
        'stores': stores
    });

    renderApp(headerModule.component, pagesComponent);
}


void renderApp(dynamic headerComponent, dynamic pagesComponent) {
    var domContainer = querySelector('#app-container');
    react.render(GridHubApp({
        'headerComponent': headerComponent,
    }, [pagesComponent]), domContainer);
}
