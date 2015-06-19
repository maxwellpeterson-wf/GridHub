library GridHubApp;

import 'package:flux/flux.dart';
import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../actions/actions.dart';
import '../models/repo.dart';
import '../stores/stores.dart';

import 'Octicon.dart';
import 'RepoContainer.dart';
import 'GridHubHeader.dart';


/**
 * The GridHub Application component
 */
var GridHubApp = react.registerComponent(() => new _GridHubApp());
class _GridHubApp extends FluxComponent<GridHubActions, GridHubStores> {

    String get currentPage => this.state['currentPage'];
    String get globalActiveKey => this.state['globalActiveKey'];
    bool get openState => this.state['openState'];
    List<String> get pageNames => this.state['pageNames'];
    List<Repository> get repos => this.state['repos'];

    getInitialState() {
        return {
            'currentPage': '',
            'globalActiveKey': '1',
            'openState': true,
            'pageNames': [],
            'repos': []
        };
    }

    _globalStateStoreUpdated(GlobalStateStore store) {
        this.setState({
            'globalActiveKey': store.activePaneKey,
            'openState': store.openState
        });
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
            stores.reposStore: _repoStoreUpdated,
            stores.globalStateStore: _globalStateStoreUpdated
        };
    }

    render() {
        List rows = [];
        List rowItems = [];
        int colKey = 0;
        int rowKey = 0;

        repos.forEach((Repository repo) {
            rowItems.add(
                Col({'sm': 4, 'key': '${currentPage}-col-${colKey++}'},
                    RepoContainer({
                        'actions': actions,
                        'repo': repo,
                        'globalActiveKey': globalActiveKey,
                        'key': '${repo.name}-container',
                        'openState': openState
                    })
                )
            );
            if (rowItems.length == 3) {
                rows.add(Row({'key': '${currentPage}-row-${rowKey++}'}, rowItems));
                rowItems = [];
            }
        });

        if (rowItems.length > 0) {
            rows.add(Row({'key': '${currentPage}-row-${rowKey++}'}, rowItems));
        }

        return react.div({'className': 'container-fluid'}, [
            GridHubHeader({
                'actions': actions,
                'currentPage': currentPage,
                'pageNames': pageNames,
                'key': 'header'
            }),
            react.div({'style': {'marginTop': '45px'}, 'key': 'main-content'}, rows),
        ]);
    }
}
