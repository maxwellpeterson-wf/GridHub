part of grid_hub_page;

class GridHubPage implements mvc.ViewModule {

    /**
     * Module-specific API
     */

    ModuleApi _api;
    ModuleApi get api => _api;

    /**
     * Public Event Streams
     */
    Events _events;
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

    /**
     * Constructor
     */
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
        _api = new ModuleApi(_actions);
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