library gridhub.src.components.unreleased_pane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import 'package:gridhub/src/components/content_loading.dart';
import 'package:gridhub/src/components/issue_list_item.dart';
import 'package:gridhub/src/components/no_results_icon.dart';
import 'package:gridhub/src/models/repository.dart';

var UnreleasedPane = react.registerComponent(() => new _UnreleasedPane());
class _UnreleasedPane extends react.Component {

  getDefaultProps() {
    return {
      'repo': null
    };
  }

  render() {
    Repository repo = this.props['repo'];
    List commits = repo.commitsData;
    List pulls = repo.pullRequestsData;
    List tags = repo.tagsData;
    List listItems = [];

    Map prNumbers = {};
    commits.forEach((commit) {
      var commitDescription = commit['commit']['message'];
      RegExp exp = new RegExp(r"Merge pull request #(\d+)");
      if (exp.hasMatch(commitDescription)) {
        var prNumber = exp.firstMatch(commitDescription).group(1);
        prNumbers[prNumber] = true;
      }
    });

    pulls.forEach((issue) {
      // If there are no tags yet, include all merged PRs
      if (prNumbers[issue['number'].toString()] == true || (tags.length == 0 && issue['merged_at'] != null)) {
        listItems.add(
          IssueListItem({'repo': repo, 'issue': issue, 'pullRequests': true, 'key': 'pr-${issue['number']}'})
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
