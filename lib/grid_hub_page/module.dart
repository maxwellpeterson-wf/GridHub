part of grid_hub_page;

class GridHubPage implements mvc.ViewModule {

    /**
     * Module-specific API
     */

    Object _api;
    Object get api => _api;

    /**
     * Public Event Streams
     */
    Object _events;
    Events get events => _events;

    /**
     * View Component
     */
    react.Component get component {
        return GridHubPageComponent({
            'actions': _actions,
            'stores': _stores
        });
    }

    /**
     * Constants
     */
    static final GridHubPageConstants constants = gridHubPageConstants;

    /**
     * Internals
     */
    Actions _actions;
    Stores _stores;

    GridHubPage(List<String> repoNames, GitHubDataProvider gitHubDataProvider) {
        if (repoNames == null) {
            repoNames = [];
        }
        GitHubApiRequest.gitHubDataProvider = gitHubDataProvider;

        // Construct the internal actions and stores
        _actions = new Actions();
        _stores = new Stores(
            new PageStore(_actions, repoNames),
            new GlobalActivePaneStore(_actions)
        );

        // Construct the public API and public event streams
        _api = new ModuleApi();
        _events = new Events(_actions);
    }

    /**
     * Life Cycle
     */

    void initialize() {
        // TODO
    }

    void destroy() {
        // TODO
    }

}