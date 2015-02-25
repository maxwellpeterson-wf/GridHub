part of grid_hub_page;

var IssueListItem = react.registerComponent(() => new _IssueListItem());
class _IssueListItem extends react.Component {

    Map get issue => this.props['issue'];
    bool get isPullRequest => this.props['isPullRequest'];
    Repository get repo => this.props['repo'];

    getDefaultProps() {
        return {
            'repo': null,
            'issue': null,
            'pullRequests': false
        };
    }

    render() {
        DateTime actionDate;
        String actionVerb;

        // TODO
        var icon;
        if (isPullRequest) {
            var iconClass = issue['state'];
            if (issue['merged_at'] != null) {
                iconClass = 'merged';
                actionDate = DateTime.parse(issue['merged_at']);
                actionVerb = 'merged';
            }
            else if (issue['state'] == 'open') {
                actionDate = DateTime.parse(issue['created_at']);
                actionVerb = 'opened';
            } else {
                actionDate = DateTime.parse(issue['closed_at']);
                actionVerb = 'closed';
            }
            icon = Octicon({'icon': 'git-pull-request', 'className': iconClass});
        } else {
            if (issue['state'] == 'open') {
                actionDate = DateTime.parse(issue['created_at']);
                actionVerb = 'opened';
                icon = Octicon({'icon': 'issue-opened', 'className': 'open'});
            }
            else {
                actionDate = DateTime.parse(issue['closed_at']);
                actionVerb = 'closed';
                icon = Octicon({'icon': 'issue-closed', 'className': 'closed'});
            }
        }

        String relativeDate = getRelativeDate(actionDate);

        var href = issue['html_url'];
        var header = [
            icon,
            react.a({'href': href, 'target': repo.name}, issue['title'])
        ];

        var number = issue['number'];
        var body = react.span({'className': 'text-muted text-md'}, [
            react.span({}, '#${number} ${actionVerb} ${relativeDate} by '),
            AuthorLink({'author': issue['user']})
        ]);

        return FancyListGroupItem({'header': header}, [
            body
        ]);
    }

}