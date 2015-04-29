library RepoContainer;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../actions/actions.dart';
import '../constants.dart' as CONSTANTS;
import '../models/repo.dart';

import 'IssuesPane.dart';
import 'Octicon.dart';
import 'ReadmePane.dart';
import 'TagsPane.dart';
import 'UnreleasedPane.dart';
import 'MilestonesPane.dart';


var RepoContainer = react.registerComponent(() => new _RepoContainer());
class _RepoContainer extends react.Component {

    GridHubActions get actions => this.props['actions'];

    getDefaultProps() {
      return {
          'actions': null,
          'globalActiveKey': '1',
          'repo': null,
      };
  }

  getInitialState() {
      return {
          'activeKey': this.props['globalActiveKey']
      };
  }

  componentWillReceiveProps(newProps) {
      var globalActiveKey = newProps['globalActiveKey'];
      if (globalActiveKey != this.state['activeKey']) {
          this.setState({'activeKey': globalActiveKey});
      }
  }

  paneSelected(activeKey) {
      this.setState({'activeKey': activeKey});
  }

  removeRepo(event) {
      RepoDescriptor repo = this.props['repo'];
      actions.repoActions.removeRepo.dispatch(repo.name);
  }

  render() {
      Repository repo = this.props['repo'];
      var activeKey = this.state['activeKey'];
      var repoName = repo != null ? repo.name : 'Test Repo';
      var title = react.h3({}, [
          Octicon({'icon': 'repo'}),
          react.a({'href': repo.url, 'target': repoName}, repoName),
          react.span({'className': 'pull-right'}, [
              react.a({'className': 'remove-repo', 'onClick': this.removeRepo}, Glyphicon({'glyph': 'trash'}))
          ])
      ]);

      var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon, 'title': 'README'});
      var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon, 'title': 'Tags/Releases'});
      var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon, 'title': 'Issues'});
      var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon, 'title': 'Pull Requests'});
      var unreleasedIcon = Octicon({'icon': CONSTANTS.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});
      var milestonesIcon = Octicon({'icon': CONSTANTS.milestonesIcon, 'title': 'Milestones'});

      return Panel({'header': title, 'className': 'repo-panel'}, [
          TabbedArea({
              'activeKey': activeKey, 'className': 'tabs-right',
              'animation': false, 'onSelect': this.paneSelected
          }, [
              TabPane({'eventKey': '1', 'tab': readmeIcon}, [
                  ReadmePane({'repo': repo})
              ]),
              TabPane({'eventKey': '2', 'tab': tagIcon}, [
                  TagsPane({'repo': repo})
              ]),
              TabPane({'eventKey': '3', 'tab': issueIcon}, [
                  IssuesPane({'repo': repo})
              ]),
              TabPane({'eventKey': '4', 'tab': pullRequestIcon}, [
                  IssuesPane({'repo': repo, 'pullRequests': true})
              ]),
              TabPane({'eventKey': '5', 'tab': unreleasedIcon}, [
                  UnreleasedPane({'repo': repo})
              ]),
              TabPane({'eventKey': '6', 'tab': milestonesIcon}, [
                  MilestonesPane({'repo': repo})
              ])
          ])
      ]);
  }
}
