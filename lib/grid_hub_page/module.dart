part of grid_hub_page;

abstract class GitHubApi {
    String get authorization;
}

typedef String _GitHubAuthorizationGetter();

class GridHubPage implements mvc.Module {

    static final GridHubPageConstants constants = new GridHubPageConstants();

    Object _publicEvents;
    PublicEvents get events => _publicEvents;

    react.Component get component => null;

    GridHubPageInternalActions _internalActions;

    PageStore _pageStore;

    GridHubPage(List<String> repoNames, GitHubApi gitHubApi) {
        if (repoNames == null) {
            repoNames = [];
        }
        GitHubApiRequest.gitHubApi = gitHubApi;
        _publicEvents = new PublicEvents();
        _internalActions = new GridHubPageInternalActions();
        _pageStore = new PageStore(_publicEvents, _internalActions, repoNames);
    }

    void setActivePane(String pane) {
        // TODO
    }

    void setViewportSize(int width, int height) {
        // TODO
    }

}