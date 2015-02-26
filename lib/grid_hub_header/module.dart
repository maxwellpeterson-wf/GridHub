part of grid_hub_header;

class GridHubHeader implements mvc.ViewModule {

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
    Function _component;
    Function get component {
        return () {
            return GridHubHeaderComponent({
                'actions': _actions,
                'stores': _stores
            });
        };
    }

    /**
     * Internals
     */
    Actions _actions;
    Stores _stores;

    /**
     * Constructor
     */
    GridHubHeader(List<String> pageNames, String currentPageName, GitHubAuthProvider githubAuthProvider) {
        if (pageNames == null) {
            pageNames = [];
        }

        // Construct the internal actions and stores
        _actions = new Actions();
        _stores = new Stores(
            new PagesStore(_actions, pageNames, currentPageName),
            new SettingsStore(_actions, githubAuthProvider.githubAccessToken, githubAuthProvider.githubUsername)
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
