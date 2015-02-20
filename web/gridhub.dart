import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:pubsub/pubsub.dart';

import 'components/GridHubApp.dart' show GridHubApp;
import 'models/repo.dart';
import 'services/localStorageService.dart' as localStorageService;
import 'stores/ReposStore.dart';


var storage;
var store;

void main() {
    reactClient.setClientConfiguration();

    storage = new localStorageService.RepoGridData();
    store = new ReposStore(storage);

    renderApp();
    Pubsub.subscribe('repos', renderApp);
}

void renderApp([msg=null]) {
    var page = storage.currentPage;
    var pageNames = storage.pageNames;

    var repos = [];
    if (msg != null) {
        repos = msg.args[0];
        print(repos);
    } else {
        var storedRepos = storage.getRepos(page);
        storedRepos.forEach((repoName) {
            repos.add(new Repository(repoName));
        });
    }

    react.render(GridHubApp({
        'currentPage': page,
        'pageNames': pageNames,
        'repos': repos
    }), querySelector('#app-container'));
}
