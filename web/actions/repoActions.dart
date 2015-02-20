library repoActions;

import 'package:pubsub/pubsub.dart';

import '../services/localStorageService.dart' as localStorageService;


var storage = new localStorageService.RepoGridData();

void addRepo(String repoName) {
    Pubsub.publish('repo.added', repoName);
}

void removeRepo(String repoName) {
    Pubsub.publish('repo.removed', repoName);
}

void addPage(String pageName) {
    storage.addPage(pageName);
//    Pubsub.publish('page.added');
    switchPage(pageName);
}

void switchPage(String pageName) {
    Pubsub.publish('page.switch', pageName);
}
