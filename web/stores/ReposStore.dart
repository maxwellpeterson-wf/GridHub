library ReposStore;

import 'dart:async';
import 'package:pubsub/pubsub.dart';

import '../models/repo.dart';
import '../services/localStorageService.dart';


class ReposStore {

    RepoGridData storage;
    Map<String, List<Repository>> allRepos;

    ReposStore(storage) {
        this.storage = storage;
        this.allRepos = {};

        initializeCurrentPageRepos();

        // Subscriptions
        Pubsub.subscribe('repo.added', this._getPayload(this.onAddRepo));
        Pubsub.subscribe('repo.removed', this._getPayload(this.onRemoveRepo));
        Pubsub.subscribe('page.deleted', this._getPayload(this.onDeletePage));
        Pubsub.subscribe('page.edited', this._getPayload(this.onEditPage));
        Pubsub.subscribe('page.switch', this._getPayload(this.onSwitchPage));
    }

    initializeCurrentPageRepos() {
        var currentPageRepos = this.storage.getRepos(this.storage.currentPage);
        List<Future> futures = [];
        List<Repository> repos = [];
        currentPageRepos.forEach((repoName) {
            var repo = new Repository(repoName);
            repos.add(repo);
            futures.add(repo.initializeData());
        });
        // Trigger immediately, and also when the data is done loading
        this.trigger(repos);

        this.allRepos[this.storage.currentPage] = repos;
        Future.wait(futures).then((futures) {
            this.trigger(repos);
        });
    }

    onAddRepo(String repoName) {
        var pageRepos = this.allRepos[this.storage.currentPage];
        var repo = new Repository(repoName);
        pageRepos.add(repo);

        this.trigger(pageRepos);
        repo.initializeData().then((futures) {
            this.trigger(pageRepos);
        });
        storage.addRepo(repoName);
    }

    onRemoveRepo(String repoName) {
        var pageRepos = this.allRepos[this.storage.currentPage];

        // TODO clean this up
        var repoToRemove = null;
        pageRepos.forEach((repo) {
            if (repo.name == repoName) {
                repoToRemove = repo;
            }
        });
        pageRepos.remove(repoToRemove);

        this.trigger(pageRepos);
        storage.removeRepo(repoName);
    }

    onDeletePage(String pageName) {
        this.allRepos.remove(this.storage.currentPage);
        storage.deletePage(pageName);
        this.onSwitchPage(this.storage.currentPage);
    }

    onEditPage(String pageName) {
        var pageRepos = this.allRepos[this.storage.currentPage];
        this.allRepos[pageName] = pageRepos;
        this.allRepos.remove(this.storage.currentPage);
        storage.editPage(pageName);
        this.trigger(this.allRepos[pageName]);
    }

    onSwitchPage(String pageName) {
        storage.currentPage = pageName;
        var pageRepos = this.allRepos[pageName];
        if (pageRepos == null) {
            initializeCurrentPageRepos();
        } else {
            this.trigger(pageRepos);
        }
    }

    trigger(List<Repository> repos) {
        // Broadcast repos, current page, and page names
        Pubsub.publish('repos', repos, this.storage.currentPage, this.storage.pageNames);
    }

    _getPayload(toCall) {
        return (msg) {
            toCall(msg.args[0]);
        };
    }
}