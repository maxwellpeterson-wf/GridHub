part of grid_hub_page;

var GridHubPageComponent = react.registerComponent(() => new _GridHubPageComponent());
class _GridHubPageComponent extends react.Component {

    GlobalActivePaneStore get globalActivePaneStore => this.props['globalActivePaneStore'];
    PageStore get pageStore => this.props['pageStore'];
    GridHubPageInternalActions get internalActions => this.props['internalActions'];

    getDefaultProps() {
        return {
            'pageStore': null
        };
    }

    getInitialState() {
        return {
            'globalActivePane': null,
            'repos': []
        };
    }

    componentWillMount() {
        globalActivePaneStore.stream.listen((_) {
            this.setState({
                'globalActivePane': globalActivePaneStore.pane
            });
        });
        pageStore.stream.listen((_) {
            this.setState({
                'repos': pageStore.repos
            });
        });
    }

    dynamic render() {
        var rows = [];
        var rowItems = [];

        List<Repository> repos = this.state['repos'];
        repos.forEach((Repository repo) {
            rowItems.add(
                Col({'sm': 4}, [
                    RepoContainer({'repo': repo, 'globalActiveKey': globalActiveKey})
                ])
            );
            if (rowItems.length == 3) {
                rows.add(Row({}, rowItems));
                rowItems = [];
            }
        });

        if (rowItems.length > 0) {
            rows.add(Row({}, rowItems));
        }

        return react.div({'style': {'marginTop': '45px'}}, rows);
    }

}