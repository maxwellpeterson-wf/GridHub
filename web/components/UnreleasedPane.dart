library UnreleasedPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../models/repo.dart';

import 'ContentLoading.dart';
import 'IssueListItem.dart';
import 'NoResultsIcon.dart';
import 'Octicon.dart';


var UnreleasedPane = react.registerComponent(() => new _UnreleasedPane());

class _UnreleasedPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var commits = repo.commitsData;
        var pulls = repo.pullRequestsData;
        var listItems = [];

        var prNumbers = {};
        commits.forEach((commit) {
            var commitDescription = commit['commit']['message'];
            RegExp exp = new RegExp(r"Merge pull request #(\d+)");
            if (exp.hasMatch(commitDescription)) {
                var prNumber = exp.firstMatch(commitDescription).group(1);
                prNumbers[prNumber] = true;
            }
        });

        pulls.forEach((issue) {
            if (prNumbers[issue['number'].toString()] == true) {
                listItems.add(
                    IssueListItem({'repo': repo, 'issue': issue, 'pullRequests': true})
                );
            }
        });

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane issues-pane'}, [
                ListGroup({}, listItems)
            ]);
        }
        else if (repo.dataInitialized != true) {
            content = ContentLoading({});
        }
        else {
            content = NoResultsIcon({});
        }

        return content;
    }
}