library ReadmePane;

import 'dart:js' as js;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';
import './ContentLoading.dart';


/**
 * A pane containing the HTML version of the README for a repo
 */
var ReadmePane = react.registerComponent(() => new _ReadmePane());
class _ReadmePane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var readme = repo.readmeData;
        var content;
        if (repo != null && repo.dataInitialized) {
            content = react.div({'dangerouslySetInnerHTML': new js.JsObject.jsify({'__html': readme})});
        }
        else {
            content = ContentLoading({});
        }
        return react.div({'className': 'scrollable-pane readme'}, content);
    }
}
