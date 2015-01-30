library UnreleasedPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../services/githubService.dart' as githubService;
import '../models/repo.dart';

import 'IssueListItem.dart';
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
        var contents = [];

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
                contents.add(
                    IssueListItem({'repo': repo, 'issue': issue, 'pullRequests': true})
                );
            }
        });

        return react.div({'className': 'scrollable-pane'}, [
            ListGroup({}, contents)
        ]);
    }
}