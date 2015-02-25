part of grid_hub_page;

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
            wsr.ButtonGroup({'className': 'no-radius'}, [
                wsr.Button({'bsSize': 'xsmall', 'active': opened, 'onClick': openClosedHandler}, 'Open'),
                wsr.Button({'bsSize': 'xsmall', 'active': !opened, 'onClick': openClosedHandler}, 'Closed')
            ])
        ]);

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane', 'style': {'height': '276px'}}, [
                wsr.ListGroup({}, listItems)
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
