part of grid_hub_page;

var GridHubPageComponent = react.registerComponent(() => new _GridHubPageComponent());
class _GridHubPageComponent extends react.Component {

    Actions get actions => this.props['actions'];
    String get globalActivePane => this.state['globalActivePane'];
    List<Repository> get repos => this.state['repos'];
    Stores get stores => this.props['stores'];

    getDefaultProps() {
        return {
            'actions': null,
            'stores': null
        };
    }

    getInitialState() {
        return {
            'globalActivePane': null,
            'repos': []
        };
    }

    componentWillMount() {
        stores.globalActivePaneStore.stream.listen((_) {
            print('triggered: ${stores.globalActivePaneStore.pane}');
            this.setState({
                'globalActivePane': stores.globalActivePaneStore.pane
            });
        });
        stores.pageStore.stream.listen((_) {
            this.setState({
                'repos': stores.pageStore.repos
            });
        });
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