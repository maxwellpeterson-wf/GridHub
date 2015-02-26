part of grid_hub_page;

class ModuleApi {

    Actions _actions;

    ModuleApi(this._actions);

    void addRepo(String repoName) {
        _actions.repoAdd.dispatch(repoName);
    }

    void refreshPageData() {
        _actions.refreshAll.dispatch(null);
    }

    void setActivePane(String pane) {
        _actions.setActivePane.dispatch(pane);
    }

    void setViewportSize(int width, int height) {
        // TODO
    }

}

abstract class GitHubDataProvider {
    String get authorization;
}