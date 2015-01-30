library ReadmePane;

import 'dart:js' as js;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../services/githubService.dart' as githubService;
import '../models/repo.dart';


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

    getInitialState() {
        return {
            'readmeHtml': ''
        };
    }

    componentWillMount() {
        RepoDescriptor repo = this.props['repo'];
        if (repo != null) {
            githubService.getReadme(repo, (responseString) {
                this.setState({
                    'readmeHtml': responseString
                });
            });
        }
    }

    render() {
        var contents = this.state['readmeHtml'];
        return react.div({
            'dangerouslySetInnerHTML': new js.JsObject.jsify({'__html': contents}),
            'className': 'scrollable-pane readme'
        });
    }
}
