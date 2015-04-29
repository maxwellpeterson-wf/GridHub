library GridHubApp;

import 'package:flux/flux.dart';
import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';
import '../stores/stores.dart';

import 'Octicon.dart';
import 'RepoContainer.dart';
import 'GridHubHeader.dart';


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp<GridHubActions, GridHubStores> extends FluxComponent {

    String get currentPage => this.state['currentPage'];
    String get globalActiveKey => this.state['globalActiveKey'];
    List<String> get pageNames => this.state['pageNames'];
    List<Repository> get repos => this.state['repos'];

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

    _repoStoreUpdated(ReposStore store) {
        this.setState({
            'repos': store.currentPageRepos,
            'currentPage': store.currentPage,
            'pageNames': store.pageNames
        });
    }

    getStoreHandlers() {
        return {
            stores.reposStore: _repoStoreUpdated
        };
    }

    render() {
        List rows = [];
        List rowItems = [];

        repos.forEach((Repository repo) {
            rowItems.add(
                Col({'sm': 4}, [
                    RepoContainer({'actions': actions, 'repo': repo, 'globalActiveKey': globalActiveKey})
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
                'actions': actions,
                'currentPage': currentPage,
                'globalButtonClickHandler': this.globalButtonClicked,
                'pageNames': pageNames
            }),
            react.div({'style': {'marginTop': '45px'}}, rows),
        ]);
    }
}
