library IssuesPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';

import 'ContentLoading.dart';
import 'IssueListItem.dart';
import 'NoResultsIcon.dart';
import 'Octicon.dart';


var IssuesPane = react.registerComponent(() => new _IssuesPane());

class _IssuesPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null,
            'pullRequests': false,
            'openState': true
        };
    }

    getInitialState() {
        return {
            'opened': this.props['openState'],
            'currentlyRenderedState': 'opened'
        };
    }

    componentWillReceiveProps(newProps) {
        var openState = newProps['openState'];
        if (openState != this.state['opened']) {
            this.setState({'opened': openState});
        }
    }

    render() {
        Repository repo = this.props['repo'];
        var opened = this.state['opened'];
        var pullRequests = this.props['pullRequests'];
        var issues = [];
        var listItems = [];

        var headerText = 'Issues:';
        if (pullRequests) {
            headerText = 'Pull Requests:';
        }

        repo.issuesData.forEach((issue) {
            if (!pullRequests && issue['pull_request'] != null) {
                // Don't add this item, it doesn't belong
                return;
            } else if (pullRequests && issue['pull_request'] == null) {
                return;
            }
            if (!opened && issue['state'] != 'open') {
                issues.add(issue);
            } else if (opened && issue['state'] == 'open') {
                issues.add(issue);
            }
        });

        issues.forEach((issue) {
            listItems.add(
                IssueListItem({'repo': repo, 'issue': issue, 'pullRequest': repo.pullRequestsMap[issue['number']], 'key': 'issue-list-item-#${issue['number']}'})
            );
        });

        var openClosedHandler = (event) {
            this.setState({'opened': !opened});
        };

        var openClosedButtons = react.div({'style': {'borderBottom': '#dedede 2px solid'}}, [
            react.h6({'className': 'pane-header'}, headerText),
            ButtonGroup({'className': 'no-radius'}, [
                Button({'wsSize': 'xsmall', 'wsStyle': null, 'active': opened, 'className': 'open-issues', 'onClick': openClosedHandler}, 'Open'),
                Button({'wsSize': 'xsmall', 'wsStyle': null, 'active': !opened, 'className': 'closed-issues', 'onClick': openClosedHandler}, 'Closed')
            ])
        ]);

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane', 'style': {'height': '271px'}}, [
                ListGroup({}, listItems)
            ]);
        }
        else if (repo.dataInitialized != true) {
            content = ContentLoading({});
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
