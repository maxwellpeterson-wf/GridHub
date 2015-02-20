library GridHubApp;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';

import 'Octicon.dart';
import 'RepoContainer.dart';
import 'GridHubHeader.dart';


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp extends react.Component {


    getDefaultProps() {
        return {
            'currentPage': '',
            'pageNames': [],
            'repos': []
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

    render() {
        var globalActiveKey = this.state['globalActiveKey'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];
        var rows = [];
        var rowItems = [];

        List<Repository> repos = this.props['repos'];
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

        return react.div({'className': 'container-fluid'}, [
            GridHubHeader({
                'currentPage': this.props['currentPage'],
                'globalButtonClickHandler': this.globalButtonClicked,
                'pageNames': this.props['pageNames']
            }),
            react.div({}, rows),
        ]);
    }
}
