library IssueListItem;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../components/FancyListGroupItem.dart';
import '../models/repo.dart';
import '../utils/date_utils.dart';

import 'AuthorLink.dart';
import 'GithubLabel.dart';
import 'Octicon.dart';


var IssueListItem = react.registerComponent(() => new _IssueListItem());

class _IssueListItem extends react.Component {

    getDefaultProps() {
        return {
            'repo': null,
            'issue': null,
            'pullRequest': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var issue = this.props['issue'];
        var pullRequest = this.props['pullRequest'];
        DateTime actionDate = new DateTime.now();  // TODO this should be null
        String actionVerb;
        String className = '';

        var icon;
        if (pullRequest != null) {
            var iconClass = pullRequest['state'];
            if (pullRequest['merged_at'] != null) {
                iconClass = 'merged';
                actionDate = DateTime.parse(pullRequest['merged_at']);
                actionVerb = 'merged';
            }
            else if (pullRequest['state'] == 'open') {
                actionDate = DateTime.parse(issue['created_at']);
                actionVerb = 'opened';

                // Check comments to see if it is ready to merge
                List<Map> comments = repo.commentsMap[issue['number']];
                if(comments != null) {
                    comments.forEach((comment) {
                        String body = comment['body'];
                        body = body.toLowerCase();
                        if (body.contains('ready for merge') ||
                            body.contains('ready to merge') ||
                            body.contains('ready for test') ||
                            body.contains('ready for qa')) {
                            className = 'list-group-item-success';
                        }
                    });
                }
                List<Map> labels = issue['labels'];
                if (labels != null) {
                    labels.forEach((label) {
                        if(label['name'].contains('Ready for Merge')) {
                            className = 'list-group-item-success';
                        }
                    });
                }
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

        List labels = [];
        List issueLabels = issue['labels'] != null ? issue['labels'] : [];
        issueLabels.forEach((label) {
            labels.add(GithubLabel({'label': label}));
        });

        var milestone = '';
        if (issue['milestone'] != null) {
            milestone = react.span({'className': 'milestone-label'}, [
                Octicon({'icon': 'milestone'}),
                react.span({'className': 'text-muted'}, issue['milestone']['title'])
            ]);
        }

        var number = issue['number'];
        var body = react.span({'className': 'text-muted text-md'}, [
            react.span({}, '#${number} ${actionVerb} ${relativeDate} by '),
            AuthorLink({'author': issue['user']}),
            milestone,
            react.span({}, labels)
        ]);

        return FancyListGroupItem({'header': header, 'className': className}, [
            body
        ]);
    }

}