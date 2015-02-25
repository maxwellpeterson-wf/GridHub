part of grid_hub_page;

var UnreleasedPane = react.registerComponent(() => new _UnreleasedPane());
class _UnreleasedPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var commits = repo.commitsSinceLastTagData;
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
            content = react.div({'className': 'scrollable-pane'}, [
                wsr.ListGroup({}, listItems)
            ]);
        }
        else {
            content = NoResultsIcon({});
        }

        return content;
    }
}