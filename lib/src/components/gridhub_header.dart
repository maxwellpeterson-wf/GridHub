library gridhub.src.components.gridhub_header;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import 'package:gridhub/src/actions.dart';
import 'package:gridhub/src/constants.dart' as constants;
import 'package:gridhub/src/services/local_storage_service.dart' as localStorageService;
import 'package:gridhub/src/components/octicon.dart';

/**
 * The GridHub page header component - title & controls
 */
var GridHubHeader = react.registerComponent(() => new _GridHubHeader());
class _GridHubHeader extends react.Component {

  // TODO this is bad. Antipattern.
  var storage = new localStorageService.RepoGridData();
  GridHubActions get actions => this.props['actions'];

  getDefaultProps() {
    return {
      'actions': null,
      'currentPage': '',
      'pageNames': []
    };
  }

  getInitialState() {
    return {
      'editPageName': null,
      'githubUsername': storage.githubUsername,
      'githubAccessToken': storage.githubAccessToken,
      'newPageName': '',
      'newRepoName': ''
    };
  }

  onGithubUsernameChange(event) {
    this.setState({'githubUsername': event.target.value});
    storage.githubUsername = event.target.value;
  }

  onGithubAccessTokenChange(event) {
    this.setState({'githubAccessToken': event.target.value});
    storage.githubAccessToken = event.target.value;
  }

  onNewPageNameChange(event) {
    this.setState({'newPageName': event.target.value});
  }

  onEditPageNameChange(event) {
    this.setState({'editPageName': event.target.value});
  }

  onNewRepoNameChange(event) {
    this.setState({'newRepoName': event.target.value});
  }

  addPage(event) {
    event.preventDefault();
    if (!this.state['newPageName'].isEmpty) {
      actions.repoActions.addPage(this.state['newPageName']);
      this.setState({'newPageName': ''});
    }
  }

  deletePage(event) {
    event.preventDefault();
    actions.repoActions.deletePage(this.props['currentPage']);
  }

  editPage(event) {
    event.preventDefault();
    if (!this.state['editPageName'].isEmpty) {
      actions.repoActions.editPage(this.state['editPageName']);
      this.setState({'editPageName': ''});
    }
  }

  refreshPage(event) {
    event.preventDefault();
    actions.repoActions.refreshPage(this.props['currentPage']);
  }

  addRepo(event) {
    event.preventDefault();
    if (!this.state['newRepoName'].isEmpty) {
      actions.repoActions.addRepo(this.state['newRepoName']);
      this.setState({'newRepoName': ''});
    }
  }

  onOpenState(event) {
    event.preventDefault();
    actions.globalStateActions.globalOpenState(true);
  }

  onCloseState(event) {
    event.preventDefault();
    actions.globalStateActions.globalOpenState(false);
  }

  onSwitchActivePane(String key) {
    return (event, href, target) {
      actions.globalStateActions.switchActivePaneKey(key);
    };
  }

  render() {
    var currentPage = this.props['currentPage'];
    var editPageName = this.state['editPageName'];
    if (editPageName == null) {
      editPageName = currentPage;
    }
    var githubUsername = this.state['githubUsername'];
    var githubAccessToken = this.state['githubAccessToken'];
    var newPageName = this.state['newPageName'];
    var newRepoName = this.state['newRepoName'];
    var pageNames = this.props['pageNames'];

    var readmeIcon = Octicon({'icon': constants.readmeIcon, 'title': 'README'});
    var tagIcon = Octicon({'icon': constants.tagsIcon, 'title': 'Tags/Releases'});
    var issueIcon = Octicon({'icon': constants.issuesIcon, 'title': 'Issues'});
    var pullRequestIcon = Octicon({'icon': constants.pullRequestsIcon, 'title': 'Pull Requests'});
    var unreleasedIcon = Octicon({'icon': constants.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});
    var milestonesIcon = Octicon({'icon': constants.milestonesIcon, 'title': 'Milestones'});
    var settingsIcon = Glyphicon({'glyph': 'cog'});
    var trashIcon = Glyphicon({'glyph': 'trash'});
    var addIcon = Octicon({'icon': 'plus'});
    var addIcon2 = Octicon({'icon': 'plus'});
    var refreshIcon = Octicon({'icon': 'sync'});

    var pageButtons = [];
    pageNames.forEach((pageName) {
      pageSwitch(event) {
        actions.repoActions.switchPage(pageName);
      }
      if (currentPage == pageName) {
        var title = react.span({}, [
          react.span({'key': 'title'}, 'Edit Page'),
          react.a({'className': 'pull-right', 'style': {'color': '#f03e3c'}, 'onClick': this.deletePage, 'key': 'link'}, trashIcon)
        ]);
        pageButtons.add(NavItem({'active': true, 'key': pageName + '-nav-item'},
        OverlayTrigger({'trigger': 'click', 'placement': 'bottom', 'overlay': Popover(
          {'className': 'inner', 'title': title},
          react.form({'onSubmit': this.editPage},
          Input({
            'type': 'text',
            'id': 'edit-page-name',
            'label': 'Page Name',
            'value': editPageName,
            'onChange': this.onEditPageNameChange,
          })
          )
        )},
        react.span({'style': {'cursor': 'pointer'}}, pageName)
        )
        ));

      } else {
        pageButtons.add(react.li({'className': 'nav-item', 'key': pageName + '-nav-item'},
        react.a({'className': 'hitarea', 'onClick': pageSwitch}, pageName)
        ));
      }

    });

    // ADD NEW PAGE BUTTON
    if (pageButtons.length > 0) {
      pageButtons.add(react.li({'className': 'nav-item', 'key': 'new-page-button-nav-item'},
      OverlayTrigger({'trigger': 'click', 'placement': 'right', 'overlay': Popover(
        {'className': 'inner add-page-popover', 'arrowOffsetTop': 18, 'title': 'Add Page'},
        react.form({'onSubmit': this.addPage},
        Input({
          'type': 'text',
          'id': 'new-page-name',
          'label': 'Page Name',
          'value': newPageName,
          'onChange': this.onNewPageNameChange,
        })
        )
      )},
      react.a({'className': 'hitarea', 'onClick': null}, addIcon)
      )
      ));
    }

    pageButtons.add(react.li({'className': 'nav-item', 'key': 'refresh-button-nav-item'},
    react.a({'className': 'hitarea', 'onClick': refreshPage}, refreshIcon)
    ));

    var brand = react.h4({'style': {'display': 'inline', 'marginTop': '2px', 'fontWeight': 'bold', 'paddingLeft': '0'}}, 'GridHub');
    var navBarStyle = {'borderWidth': '0 0 1px', 'borderRadius': 0, 'paddingRight': '3px', 'paddingLeft': '12px'};
    return Navbar({'fixedTop': true, 'fluid': true, 'brand': brand, 'style': navBarStyle}, [
      Nav({'key': 'page-buttons'}, pageButtons),
      Nav({'className': 'pull-right', 'key': 'right-buttons'}, [

        // ADD REPO BUTTON
        NavItem({'style': {'marginRight': '20px'}, 'key': 'add-repo-button-nav-item'},
        OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': Popover(
          {'className': 'inner add-repo-popover', 'arrowOffsetTop': 18, 'title': 'Add Repository'},
          react.form({'onSubmit': this.addRepo},
          Input({
            'type': 'text',
            'id': 'new-repo-name',
            'label': 'Repo Path',
            'placeholder': 'Workiva/wGulp',
            'value': newRepoName,
            'onChange': this.onNewRepoNameChange,
          })
          )
        )},
        react.span({}, addIcon2)
        )
        ),

        // GLOBAL STATE BUTTONS
        NavItem({'onSelect': onSwitchActivePane('1'), 'key': 'readme-icon-nav-item'}, readmeIcon),
        NavItem({'onSelect': onSwitchActivePane('2'), 'key': 'tag-icon-nav-item'}, tagIcon),
        NavItem({'onSelect': onSwitchActivePane('3'), 'key': 'issue-icon-nav-item'}, issueIcon),
        NavItem({'onSelect': onSwitchActivePane('4'), 'key': 'pull-icon-nav-item'}, pullRequestIcon),
        NavItem({'onSelect': onSwitchActivePane('5'), 'key': 'unreleased-icon-nav-item'}, unreleasedIcon),
        NavItem({'onSelect': onSwitchActivePane('6'), 'key': 'milestone-icon-nav-item'}, milestonesIcon),

        react.li({'className': 'nav-item nav-item-text-button', 'onClick': onOpenState, 'key': 'open-button-nav-item'},
        Button({'wsSize': 'xsmall', 'wsStyle': null, 'className': 'hitarea'}, 'Open')),
        react.li({'className': 'nav-item nav-item-text-button', 'onClick': onCloseState, 'key': 'closed-button-nav-item'},
        Button({'wsSize': 'xsmall', 'wsStyle': null, 'className': 'hitarea'}, 'Closed')),

        // SETTINGS BUTTON
        // TODO Could not get this popover to work in its own component file. fix this
        // For some reason if I create a new component that renders a Popover, and then pass
        // that in as a prop to OverlayTrigger - it breaks. I assume it is dart interop issues
        NavItem({'style': {'marginLeft': '20px'}, 'key': 'settings-button-nav-item'},
        OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': Popover(
          {'title': 'Settings', 'arrowOffsetTop': 18, 'className': 'inner settings-popover'}, [
            Input({
              'type': 'text',
              'id': 'github-user-name',
              'label': 'Github Username',
              'value': githubUsername,
              'onChange': this.onGithubUsernameChange,
              'key': 'settings-input-username'}),
            Input({
              'type': 'password',
              'id': 'github-access-token',
              'label': 'Github Access Token',
              'value': githubAccessToken,
              'onChange': this.onGithubAccessTokenChange,
              'key': 'settings-input-accesstoken'})

          ])},
        settingsIcon
        )
        )
      ])
    ]);
  }
}
