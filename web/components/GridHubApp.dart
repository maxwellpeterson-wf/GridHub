library GridHubApp;

import 'package:pubsub/pubsub.dart';
import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';
import 'package:repoGrid/mvc.dart' as mvc;

import '../models/repo.dart';
import '../stores/ReposStore.dart';

import 'GridHubHeader.dart';


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp extends react.Component {

    String get currentPageName => this.props['currentPageName'];

    dynamic get pageComponent {
        return this.props['pageComponent'];
    }

    List<String> get pageNames => this.props['pageNames'];

    getDefaultProps() {
        return {
            'currentPageName': '',
            'pageComponent': null,
            'pageNames': []
        };
    }

    getInitialState() {
        return {
            'globalActiveKey': '1'
        };
    }

    globalButtonClicked(activeKey) {
        return (event) {
            this.setState({'globalActiveKey': activeKey});
        };
    }

    componentWillMount() {
//        reposStore.subscribe((actionName) {
//            this.setState({
//                'repos': reposStore.currentPageRepos,
//                'currentPage': reposStore.currentPage,
//                'pageNames': reposStore.pageNames
//            });
//        });
    }

    render() {
        var globalActiveKey = this.state['globalActiveKey'];

        return react.div({'className': 'container-fluid'}, [
            GridHubHeader({
                'currentPageName': currentPageName,
                'globalButtonClickHandler': this.globalButtonClicked,
                'pageNames': pageNames
            }),
            react.div({'style': {'marginTop': '45px'}}, pageComponent),
        ]);
    }
}
