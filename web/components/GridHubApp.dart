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

    globalButtonClicked(activeKey) {
        return (eventKey, href, target) {
            this.setState({'globalActiveKey': activeKey});
        };
    }

    _repoStoreUpdated(ReposStore store) {
        this.setState({
            'repos': store.currentPageRepos,
            'currentPage': store.currentPage,
            'openState': store.openState,
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
        int colKey = 0;
        int rowKey = 0;

        repos.forEach((Repository repo) {
            rowItems.add(
                Col({'sm': 4, 'key': '${currentPage}-col-${colKey++}'}, [
                    RepoContainer({
                        'actions': actions,
                        'repo': repo,
                        'globalActiveKey': globalActiveKey,
                        'key': '${repo.name}-container',
                        'openState': openState
                    })
                ])
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
                'globalButtonClickHandler': this.globalButtonClicked,
                'pageNames': pageNames
            }),
            react.div({'style': {'marginTop': '45px'}}, rows),
        ]);
    }
}
