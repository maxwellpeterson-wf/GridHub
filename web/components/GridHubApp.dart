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

    dynamic get headerComponent => this.props['headerComponent'];
    dynamic get pageComponent => this.props['pageComponent'];

    getDefaultProps() {
        return {
            'headerComponent': null,
            'pageComponent': null
        };
    }

    render() {
        return react.div({'className': 'container-fluid'}, [
            headerComponent,
            react.div({'style': {'marginTop': '45px'}}, pageComponent),
        ]);
    }
}
