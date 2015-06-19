part of gridhub.stores;


class ReposStore extends Store {

    // Private data
    Map<String, List<Repository>> _allRepos;
    RepoGridData _storage;

    // Public data
    String get currentPage => _storage.currentPage;
    List<Repository> get currentPageRepos => _allRepos[currentPage];
    List<String> get pageNames => _storage.pageNames;

    // Internals
    RepoActions _actions;

    ReposStore(GridHubActions actions, storage) {
        _actions = actions.repoActions;
        _storage = storage;
        _allRepos = {};

        initializeCurrentPageRepos();

        // Subscriptions
        _actions.addRepo.listen(onAddRepo);
        _actions.updateRepo.listen(onRefresh);
        _actions.removeRepo.listen(onRemoveRepo);

        // TODO move to page store?
        _actions.addPage.listen(onAddPage);
        _actions.deletePage.listen(onDeletePage);
        _actions.editPage.listen(onEditPage);
        _actions.refreshPage.listen(onRefreshPage);
        _actions.switchPage.listen(onSwitchPage);
        _actions.switchPageByIndex.listen(onSwitchPageByIndex);
    }

    Future initializeCurrentPageRepos() {
        return initializePageRepos(_storage.currentPage);
    }

    Future initializePageRepos(String pageName) {
        var repoNames = _storage.getRepos(pageName);
        List<Future> futures = [];
        List<Repository> repos = [];
        repoNames.forEach((repoName) {
            var repo = new Repository(repoName, _actions);
            repos.add(repo);
            futures.add(repo.initializeData());
        });
        // Trigger immediately, and also when the data is done loading
        _allRepos[pageName] = repos;
        if (pageName == _storage.currentPage) trigger();

        return Future.wait(futures).then((futures) {
            _allRepos[pageName] = repos;
            if (pageName == _storage.currentPage) trigger();
        });
    }

    onAddRepo(String repoName) {
        var pageRepos = _allRepos[_storage.currentPage];
        var repo = new Repository(repoName, _actions);
        pageRepos.add(repo);

        trigger();
        repo.initializeData().then((futures) {
            trigger();
        });
        _storage.addRepo(repoName);
    }

    onRefresh(String pageName) {
        trigger();
    }

    onRemoveRepo(String repoName) {
        var pageRepos = _allRepos[_storage.currentPage];

        // TODO clean this up
        var repoToRemove = null;
        pageRepos.forEach((repo) {
            if (repo.name == repoName) {
                repoToRemove = repo;
            }
        });
        pageRepos.remove(repoToRemove);

        trigger();
        _storage.removeRepo(repoName);
    }

    onDeletePage(String pageName) {
        _allRepos.remove(_storage.currentPage);
        _storage.deletePage(pageName);
        onSwitchPage(_storage.currentPage);
    }

    onEditPage(String pageName) {
        var pageRepos = _allRepos[_storage.currentPage];
        _allRepos[pageName] = pageRepos;
        _allRepos.remove(_storage.currentPage);
        _storage.editPage(pageName);
        trigger();
    }

    onRefreshPage(String pageName) async {
        await initializeCurrentPageRepos();
        for (int i=0; i < pageNames.length; i++) {
            String name = pageNames[i];
            if (name != _storage.currentPage)  {
                await initializePageRepos(name);
            }
        }
    }

    onAddPage(String pageName) {
        _storage.addPage(pageName);
        _actions.switchPage.dispatch(pageName);
    }

    onSwitchPage(String pageName) {
        _storage.currentPage = pageName;
        if (currentPageRepos == null) {
            initializeCurrentPageRepos();
        } else {
            trigger();
        }
    }

    onSwitchPageByIndex(int index) {
        if (pageNames.length < index + 1) {
            // If there aren't enough pages, go to last page
            onSwitchPage(pageNames.last);
        }
        else {
            onSwitchPage(pageNames[index]);
        }
    }

    _getPayload(toCall) {
        return (msg) {
            toCall(msg.args[0]);
        };
    }
}