part of gridhub_mvc;


var GridHubPagesComponent = react.registerComponent(() => new _GridHubPagesComponent());
class _GridHubPagesComponent extends react.Component {

    // props
    Actions get actions => this.props['actions'];
    Stores get stores => this.props['stores'];

    // state
    String get currentPageName => this.state['currentPageName'];
    Map<String, dynamic> get pageComponents => this.state['pageComponents'];

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
        stores.currentPageNameStore.stream.listen((_) {
            this.setState({
                'currentPageName': stores.currentPageNameStore.pageName
            });
        });

        stores.pageComponentsStore.stream.listen((_) {
            this.setState({
                'pageComponents': stores.pageComponentsStore.pageComponents
            });
        });
    }

    render() {
        var pageComponent = pageComponents[currentPageName];
//        var pages = [];
//        pageComponents.values.forEach((comp) {
//            pages.add(comp());
//        });
        print('${pageComponents.keys} - ${currentPageName}');
        return react.div({'style': {'marginTop': '45px'}}, [
            pageComponent()
        ]);
//        return react.div({'style': {'marginTop': '45px'}}, pages);
    }
}
