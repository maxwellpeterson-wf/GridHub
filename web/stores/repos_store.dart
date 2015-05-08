part of gridhub.stores;


class ReposStore extends Store {

    // Private data
    Map<String, List<Repository>> _allRepos;
    RepoGridData _storage;
    bool _openState;

    // Public data
    bool get openState => _openState;
    String get currentPage => _storage.currentPage;
    List<Repository> get currentPageRepos => _allRepos[currentPage];
    List<String> get pageNames => _storage.pageNames;

    // Internals
    RepoActions _actions;

    ReposStore(GridHubActions actions, storage) {
        _actions = actions.repoActions;
        _storage = storage;
        _allRepos = {};
        _openState = true;

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
        _actions.globalOpenState.listen(onGlobalOpenState);
    }

    Future initializeCurrentPageRepos() {
        var currentPageRepos = _storage.getRepos(_storage.currentPage);
        List<Future> futures = [];
        List<Repository> repos = [];
        currentPageRepos.forEach((repoName) {
            var repo = new Repository(repoName, _actions);
            repos.add(repo);
            futures.add(repo.initializeData());
        });
        // Trigger immediately, and also when the data is done loading
        _allRepos[_storage.currentPage] = repos;
        trigger();

        return Future.wait(futures).then((futures) {
            _allRepos[_storage.currentPage] = repos;
            trigger();
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

    onRefreshPage(String pageName) {
        initializeCurrentPageRepos();
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

    onGlobalOpenState(bool open) {
        _openState = open;
        trigger();
    }

    _getPayload(toCall) {
        return (msg) {
            toCall(msg.args[0]);
        };
    }
}