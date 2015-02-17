library ReposStore;

import 'dart:async';
import 'package:pubsub/pubsub.dart';

import '../models/repo.dart';
import '../services/localStorageService.dart';


class ReposStore {

    RepoGridData storage;

    ReposStore(storage) {
        this.storage = storage;

        var currentPageRepos = this.storage.getRepos(this.storage.currentPage);
        List<Future> futures = [];
        List<Repository> repos = [];
        currentPageRepos.forEach((repoName) {
            var repo = new Repository(repoName);
            repos.add(repo);
            futures.add(repo.initializeData());
        });
        Future.wait(futures).then((futures) {
            this.trigger(repos);
        });
    }

    trigger(List<Repository> repos) {
        Pubsub.publish('repos', repos);
    }
}