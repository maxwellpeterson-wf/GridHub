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
            'pullRequests': false
        };
    }

    getInitialState() {
        return {
            'opened': true,
            'currentlyRenderedState': 'opened'
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var opened = this.state['opened'];
        var pullRequests = this.props['pullRequests'];
        var allIssues = pullRequests ? repo.pullRequestsData : repo.issuesData;
        var issues = [];
        var listItems = [];

        allIssues.forEach((issue) {
            if (!pullRequests && issue['pull_request'] != null) {
                // Don't add this item, it doesn't belong
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
