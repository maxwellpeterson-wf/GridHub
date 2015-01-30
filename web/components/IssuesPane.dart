library IssuesPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../services/githubService.dart' as githubService;
import '../models/repo.dart';

import 'IssueListItem.dart';
import 'NoResultsIcon.dart';
import 'Octicon.dart';


var IssuesPane = react.registerComponent(() => new _IssuesPane());

class _IssuesPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null,
            'pullRequests': false
        };
    }

    getInitialState() {
        return {
            'issues': [],
            'opened': true,
            'currentlyRenderedState': 'opened'
        };
    }

    getIssues(state) {
        RepoDescriptor repo = this.props['repo'];
        if (repo != null) {
            var type = this.props['pullRequests'] ? 'pulls' : 'issues';
            githubService.getIssues(repo, type, state, (responseJson) {
                this.setState({
                    'issues': responseJson,
                    'currentlyRenderedState': state
                });
            });
        }
    }

    componentWillMount() {
        this.getIssues('open');
    }

    componentWillUpdate(nextProps, nextState) {
        if (nextState['opened'] == true && nextState['currentlyRenderedState'] != 'open') {
            this.getIssues('open');
        }
        else if (nextState['opened'] == false && nextState['currentlyRenderedState'] != 'closed') {
            this.getIssues('closed');
        }
    }

    render() {
        RepoDescriptor repo = this.props['repo'];
        var opened = this.state['opened'];
        var pullRequests = this.props['pullRequests'];
        var issues = this.state['issues'];
        var listItems = [];

        issues.forEach((issue) {
            if(!pullRequests && issue['pull_request'] != null) {
                return;
            }

            listItems.add(
                IssueListItem({'repo': repo, 'issue': issue, 'pullRequests': pullRequests})
            );
        });

        var openClosedHandler = (event) {
            this.setState({'opened': !opened});
        };

        var openClosedButtons = react.div({}, [
            ButtonGroup({'className': 'no-radius'}, [
                Button({'bsSize': 'xsmall', 'active': opened, 'onClick': openClosedHandler}, 'Open'),
                Button({'bsSize': 'xsmall', 'active': !opened, 'onClick': openClosedHandler}, 'Closed')
            ])
        ]);

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane', 'style': {'height': '276px'}}, [
                ListGroup({}, listItems)
            ]);
        }
        else {
            content = NoResultsIcon({});
        }

        return react.div({'className': 'issues-pane'}, [
            openClosedButtons,
            content
        ]);
    }
}
