part of gridhub_mvc;


var GridHubPagesComponent = react.registerComponent(() => new _GridHubPagesComponent());
class _GridHubPagesComponent extends react.Component {

    // Props
    Actions get actions => this.props['actions'];
    Stores get stores => this.props['stores'];

    // State
    String get currentPageName => this.state['currentPageName'];
    Map<String, dynamic> get pageComponents => this.state['pageComponents'];

    // Internal
    StreamSubscription _currentPageNameSubscription;
    StreamSubscription _pageComponentsSubscription;

    getDefaultProps() {
        return {
            'actions': null,
            'stores': null,
        };
    }

    getInitialState() {
        return {
            'currentPageName': stores.currentPageNameStore.pageName,
            'pageComponents': stores.pageComponentsStore.pageComponents
        };
    }

    componentWillMount() {
        _currentPageNameSubscription = stores.currentPageNameStore.stream.listen((_) {
            this.setState({
                'currentPageName': stores.currentPageNameStore.pageName
            });
        });

        _pageComponentsSubscription = stores.pageComponentsStore.stream.listen((_) {
            this.setState({
                'pageComponents': stores.pageComponentsStore.pageComponents
            });
        });
    }

    componentWillUnmount() {
        _currentPageNameSubscription.cancel();
        _pageComponentsSubscription.cancel();
    }

    render() {
        var pageComponent = pageComponents[currentPageName]();
        return react.div({'style': {'marginTop': '45px'}}, pageComponent);
    }
}
