part of grid_hub_page;

abstract class GitHubApi {
    String get authorization;
}

typedef String _GitHubAuthorizationGetter();

class GridHubPage implements mvc.Module {

    static final GridHubPageConstants constants = new GridHubPageConstants();
    GridHubPageInternalActions _internalActions;
    Object _publicEvents;

    PublicEvents get events => _publicEvents;
    react.Component get component {
        return GridHubPageComponent({
            'pageStore': _pageStore,
            'globalActivePaneStore': _globalActivePaneStore,
            'internalActions': _internalActions
        });
    }

    GlobalActivePaneStore _globalActivePaneStore;
    PageStore _pageStore;

    GridHubPage(List<String> repoNames, GitHubApi gitHubApi) {
        if (repoNames == null) {
            repoNames = [];
        }
        GitHubApiRequest.gitHubApi = gitHubApi;
        _publicEvents = new PublicEvents();
        _internalActions = new GridHubPageInternalActions();
        _globalActivePaneStore = new GlobalActivePaneStore(_internalActions);
        _pageStore = new PageStore(_internalActions, repoNames);
    }

    void setActivePane(String pane) {
        // TODO
    }

    void setViewportSize(int width, int height) {
        // TODO
    }

}