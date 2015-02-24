library repoActions;

import 'package:pubsub/pubsub.dart';

import '../services/localStorageService.dart' as localStorageService;


var storage = new localStorageService.RepoGridData();

void addRepo(String repoName) {
    Pubsub.publish('repo.added', repoName);
}

void repoUpdated(String repoName) {
    Pubsub.publish('repo.update', repoName);
}

void removeRepo(String repoName) {
    Pubsub.publish('repo.removed', repoName);
}

void addPage(String pageName) {
    storage.addPage(pageName);
//    Pubsub.publish('page.added');
    switchPage(pageName);
}

void deletePage(String pageName) {
    Pubsub.publish('page.deleted', pageName);
}

void editPage(String pageName) {
    Pubsub.publish('page.edited', pageName);
}

void refreshPage(String pageName) {
    Pubsub.publish('page.refresh', pageName);
}

void switchPage(String pageName) {
    Pubsub.publish('page.switch', pageName);
}
