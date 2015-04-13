library GridHubApp;

import 'package:pubsub/pubsub.dart';
import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';
import '../stores/ReposStore.dart';

import 'Octicon.dart';
import 'RepoContainer.dart';
import 'GridHubHeader.dart';


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp extends react.Component {

    ReposStore get reposStore {
        return this.props['reposStore'];
    }

    getDefaultProps() {
        return {
            'reposStore': null
        };
    }

    getInitialState() {
        return {
            'currentPage': '',
            'globalActiveKey': '1',
            'pageNames': [],
            'repos': []
        };
    }

    globalButtonClicked(activeKey) {
        return (eventKey, href, target) {
            this.setState({'globalActiveKey': activeKey});
        };
    }

    componentWillMount() {
        reposStore.subscribe((actionName) {
            this.setState({
                'repos': reposStore.currentPageRepos,
                'currentPage': reposStore.currentPage,
                'pageNames': reposStore.pageNames
            });
        });
    }

    render() {
        var globalActiveKey = this.state['globalActiveKey'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];
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

        return react.div({'className': 'container-fluid'}, [
            GridHubHeader({
                'currentPage': this.state['currentPage'],
                'globalButtonClickHandler': this.globalButtonClicked,
                'pageNames': this.state['pageNames']
            }),
            react.div({'style': {'marginTop': '45px'}}, rows),
        ]);
    }
}
