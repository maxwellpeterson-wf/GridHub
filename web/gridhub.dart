import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:pubsub/pubsub.dart';

import 'components/GridHubApp.dart' show GridHubApp;
import 'models/repo.dart';
import 'services/localStorageService.dart' as localStorageService;


var storage = new localStorageService.RepoGridData();

void main() {
    reactClient.setClientConfiguration();

    renderApp();
    Pubsub.subscribe('repo.added', renderApp);
    Pubsub.subscribe('repo.removed', renderApp);
}

void renderApp([msg=null]) {
    var repos = [];
    var storedRepos = storage.repos;
    storedRepos.forEach((repoName) {
        repos.add(new RepoDescriptor(repoName));
    });

    react.render(GridHubApp({'repos': repos}), querySelector('#app-container'));
}
