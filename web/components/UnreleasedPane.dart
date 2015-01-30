library UnreleasedPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../services/githubService.dart' as githubService;
import '../models/repo.dart';

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

    getInitialState() {
        return {
            'issues': [],
            'commits': []
        };
    }

    componentWillMount() {
        RepoDescriptor repo = this.props['repo'];
        if (repo != null) {
            githubService.getIssues(repo, 'pulls', 'closed', (responseJson) {
                this.setState({
                    'issues': responseJson
                });
            });

            githubService.getCommitsSinceLastTag(repo, (commits) {
                this.setState({
                    'commits': commits['commits']
                });
            });
        }
    }

    render() {
        RepoDescriptor repo = this.props['repo'];
        var commits = this.state['commits'] != null ? this.state['commits'] : [];
        var issues = this.state['issues'];
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

        issues.forEach((issue) {
            if (prNumbers[issue['number'].toString()] == true) {
                listItems.add(
                    IssueListItem({'repo': repo, 'issue': issue, 'pullRequests': true})
                );
            }
        });

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane'}, [
                ListGroup({}, listItems)
            ]);
        }
        else {
            content = NoResultsIcon({});
        }

        return content;
    }
}