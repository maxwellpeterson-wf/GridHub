part of grid_hub_page;

class PageStore extends flux.Store {

    Map<String, Repository> _repos;
    List<Repository> get repos => _repos.values;

    Actions _actions;
    List<String> _repoNames;

    PageStore(this._actions, this._repoNames): super() {
        _actions.refreshAll.stream.listen(onRefreshAll);
        _actions.repoAdd.stream.listen(onRepoAdd);
        _actions.repoRemove.stream.listen(onRepoRemove);
        _actions.repoReorder.stream.listen(onRepoReorder);
        _actions.repoUpdate.stream.listen(onRepoUpdate);

        _repos = {};
        initializeRepos();
    }

    void initializeRepos() {
        _repoNames.forEach((String repoName) {
            Repository repo = new Repository(repoName);
            _repos[repoName] = repo;
            initializeRepo(repoName);
        });
    }

    void initializeRepo(String repoName) {
        Repository repo = _repos[repoName];
        repo.getReadme().then((_) => trigger());
        repo.getTags().then((_) => trigger());
        repo.getReleases().then((_) => trigger());
        repo.getIssues().then((_) => trigger());
        repo.getPullRequests().then((_) => trigger());
        repo.getCommitsSinceLastTag().then((_) => trigger());
    }

    void onRefreshAll(_) {
        _repoNames.forEach((String repoName) {
            initializeRepo(repoName);
        });
    }

    void onRepoAdd(String repoName) {
        Repository repo = new Repository(repoName);
        _repos[repoName] = repo;
        _repoNames.add(repoName);
        initializeRepo(repoName);
    }

    void onRepoRemove(String repoName) {
        _repoNames.remove(repoName);
        _repos.remove(repoName);
        trigger();
    }

    void onRepoReorder(dynamic payload) {

    }

    void onRepoUpdate(String repoName) {
        initializeRepo(repoName);
    }

}