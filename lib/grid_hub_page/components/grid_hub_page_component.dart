part of grid_hub_page;

var GridHubPageComponent = react.registerComponent(() => new _GridHubPageComponent());
class _GridHubPageComponent extends react.Component {

    // Props
    Actions get actions => this.props['actions'];
    Stores get stores => this.props['stores'];

    // State
    String get globalActivePane => this.state['globalActivePane'];
    List<Repository> get repos => this.state['repos'];

    StreamSubscription _globalActivePaneStoreSubscription;
    StreamSubscription _pageStoreSubscription;

    getDefaultProps() {
        return {
            'actions': null,
            'stores': null
        };
    }

    getInitialState() {
        return {
            'globalActivePane': stores.globalActivePaneStore.pane,
            'repos': stores.pageStore.repos
        };
    }

    componentWillMount() {
        print('CREATING SUBSCRIPTIONS');
        _globalActivePaneStoreSubscription = stores.globalActivePaneStore.stream.listen((_) {
            this.setState({
                'globalActivePane': stores.globalActivePaneStore.pane
            });
        });
        _pageStoreSubscription = stores.pageStore.stream.listen((_) {
            this.setState({
                'repos': stores.pageStore.repos
            });
        });
    }

    componentWillUnmount() {
        print('UNMOUNTING GRIDHUB PAGE COMPONENT');
        _globalActivePaneStoreSubscription.cancel();
        _pageStoreSubscription.cancel();
    }

    dynamic render() {
        var rows = [];
        var rowItems = [];

        repos.forEach((Repository repo) {
            rowItems.add(
                wsr.Col({'sm': 4}, [
                    RepoContainer({'actions': actions, 'repo': repo, 'globalActivePane': globalActivePane})
                ])
            );
            if (rowItems.length == 3) {
                rows.add(wsr.Row({}, rowItems));
                rowItems = [];
            }
        });

        if (rowItems.length > 0) {
            rows.add(wsr.Row({}, rowItems));
        }

        return react.div({'style': {'marginTop': '45px'}}, rows);
    }

}