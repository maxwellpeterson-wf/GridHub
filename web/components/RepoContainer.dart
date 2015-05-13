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
          'openState': true,
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
      bool changed = globalActiveKey != this.props['globalActiveKey'];
      if (changed && globalActiveKey != this.state['activeKey']) {
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
      var openState = this.props['openState'];
      var repoName = repo != null ? repo.name : 'Test Repo';
      var title = react.h3({}, [
          Octicon({'icon': 'repo', 'key': 'icon'}),
          react.a({'href': repo.url, 'target': repoName, 'key': 'link'}, repoName),
          react.span({'className': 'pull-right', 'key': 'actions'},
              react.a({'className': 'remove-repo', 'onClick': this.removeRepo}, Glyphicon({'glyph': 'trash'}))
          )
      ]);

      var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon, 'title': 'README'});
      var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon, 'title': 'Tags/Releases'});
      var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon, 'title': 'Issues'});
      var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon, 'title': 'Pull Requests'});
      var unreleasedIcon = Octicon({'icon': CONSTANTS.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});
      var milestonesIcon = Octicon({'icon': CONSTANTS.milestonesIcon, 'title': 'Milestones'});

      return Panel({'header': title, 'className': 'repo-panel', 'key': repoName},
          TabbedArea({
              'activeKey': activeKey, 'className': 'tabs-right',
              'animation': false, 'onSelect': this.paneSelected
          }, [
              TabPane({'eventKey': '1', 'tab': readmeIcon, 'key': repoName + 'readmePane'},
                  ReadmePane({'repo': repo})
              ),
              TabPane({'eventKey': '2', 'tab': tagIcon, 'key': repoName + 'tagPane'},
                  TagsPane({'repo': repo})
              ),
              TabPane({'eventKey': '3', 'tab': issueIcon, 'key': repoName + 'issuePane'},
                  IssuesPane({'repo': repo, 'openState': openState})
              ),
              TabPane({'eventKey': '4', 'tab': pullRequestIcon, 'key': repoName + 'pullPane'},
                  IssuesPane({'repo': repo, 'pullRequests': true, 'openState': openState})
              ),
              TabPane({'eventKey': '5', 'tab': unreleasedIcon, 'key': repoName + 'unreleasedPane'},
                  UnreleasedPane({'repo': repo})
              ),
              TabPane({'eventKey': '6', 'tab': milestonesIcon, 'key': repoName + 'milestonePane'},
                  MilestonesPane({'repo': repo})
              )
          ])
      );
  }
}
