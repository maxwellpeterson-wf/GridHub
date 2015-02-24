library IssueListItem;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../components/FancyListGroupItem.dart';
import '../models/repo.dart';
import '../utils/date_utils.dart';

import 'AuthorLink.dart';
import 'Octicon.dart';


var IssueListItem = react.registerComponent(() => new _IssueListItem());

class _IssueListItem extends react.Component {

    getDefaultProps() {
        return {
            'repo': null,
            'issue': null,
            'pullRequests': false
        };
    }

    render() {
        RepoDescriptor repo = this.props['repo'];
        var issue = this.props['issue'];
        var pullRequests = this.props['pullRequests'];
        DateTime actionDate = new DateTime.now();  // TODO this should be null
        String actionVerb;

        var icon;
        if (pullRequests) {
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