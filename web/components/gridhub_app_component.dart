part of gridhub_mvc;


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp extends react.Component {

    dynamic get headerComponent => this.props['headerComponent'];
    dynamic get pagesComponent => this.props['children'];

    getDefaultProps() {
        return {
            'headerComponent': null
        };
    }

    render() {
        return react.div({'className': 'container-fluid'}, [
            headerComponent(),
            react.div({'style': {'marginTop': '45px'}}, pagesComponent),
        ]);
    }
}
