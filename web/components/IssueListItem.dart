library IssueListItem;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../components/FancyListGroupItem.dart';
import '../models/repo.dart';

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

        var icon;
        if (pullRequests) {
            var iconClass = issue['state'];
            if (issue['merged_at'] != null) {
                iconClass = 'merged';
            }
            icon = Octicon({'icon': 'git-pull-request', 'className': iconClass});
        } else {
            if (issue['state'] == 'open'){
                icon = Octicon({'icon': 'issue-opened', 'className': 'open'});
            }
            else {
                icon = Octicon({'icon': 'issue-closed', 'className': 'closed'});
            }
        }

        var href = issue['html_url'];
        var header = [
            icon,
            react.a({'href': href, 'target': repo.name}, issue['title'])
        ];

        var number = issue['number'];
        var body = react.span({'className': 'text-muted text-md'}, [
            react.span({}, '#${number} opened x days ago by '),
            AuthorLink({'author': issue['user']})
        ]);

        return FancyListGroupItem({'header': header}, [
            body
        ]);
    }

}