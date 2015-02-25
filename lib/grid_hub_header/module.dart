part of grid_hub_header;

class GridHubHeader implements mvc.ViewModule {

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
        return GridHubHeaderComponent({
            'actions': _actions,
            'stores': _stores
        });
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
