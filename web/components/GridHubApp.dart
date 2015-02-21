library GridHubApp;

import 'package:pubsub/pubsub.dart';
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

    getInitialState() {
        return {
            'currentPage': '',
            'globalActiveKey': '1',
            'pageNames': [],
            'repos': []
        };
    }

    globalButtonClicked(activeKey) {
        return (event) {
            this.setState({'globalActiveKey': activeKey});
        };
    }

    componentWillMount() {
        Pubsub.subscribe('repos', (msg) {
            this.setState({'repos': msg.args[0]});
            this.setState({'currentPage': msg.args[1]});
            this.setState({'pageNames': msg.args[2]});
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
