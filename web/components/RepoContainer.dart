library RepoContainer;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../actions/repoActions.dart' as repoActions;
import '../constants.dart' as CONSTANTS;
import '../models/repo.dart';

import 'IssuesPane.dart';
import 'Octicon.dart';
import 'ReadmePane.dart';
import 'TagsPane.dart';
import 'UnreleasedPane.dart';


var RepoContainer = react.registerComponent(() => new _RepoContainer());

class _RepoContainer extends react.Component {

  getDefaultProps() {
      return {
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
      repoActions.removeRepo(repo.name);
  }

  render() {
      RepoDescriptor repo = this.props['repo'];
      var activeKey = this.state['activeKey'];
      var repoName = repo != null ? repo.name : 'Test Repo';
      var title = react.h3({}, [
          Octicon({'icon': 'repo'}),
          react.a({'href': repo.url, 'target': repoName}, repoName),
          react.a({'className': 'remove-repo', 'onClick': this.removeRepo}, Glyphicon({'glyph': 'trash'}))
      ]);

      var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon});
      var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon});
      var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon});
      var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon});
      var unreleasedIcon = Octicon({'icon': CONSTANTS.unreleasedIcon});

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
          ])
      ]);
  }
}
