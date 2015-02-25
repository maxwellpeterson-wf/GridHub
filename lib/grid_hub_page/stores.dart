part of grid_hub_page;

class PageStore extends flux.Store {

    Map<String, GridHubPageRepository> _repos;
    List<GridHubPageRepository> get repos => _repos.values;

    GridHubPageInternalActions _internalActions;
    PublicEvents _publicEvents;
    List<String> _repoNames;

    PageStore(this._publicEvents, this._internalActions, this._repoNames): super() {
        _internalActions.refreshAll.stream.listen(onRefreshAll);
        _internalActions.repoAdd.stream.listen(onRepoAdd);
        _internalActions.repoRemove.stream.listen(onRepoRemove);
        _internalActions.repoReorder.stream.listen(onRepoReorder);
        _internalActions.repoUpdate.stream.listen(onRepoUpdate);

        _repos = {};
        initializeRepos();
    }

    void initializeRepos() {
        _repoNames.forEach((String repoName) {
            GridHubPageRepository repo = new GridHubPageRepository(repoName);
            _repos[repoName] = repo;
            initializeRepo(repoName);
        });
    }

    void initializeRepo(String repoName) {
        GridHubPageRepository repo = _repos[repoName];
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
        GridHubPageRepository repo = new GridHubPageRepository(repoName);
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