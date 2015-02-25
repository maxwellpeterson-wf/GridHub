library GridHubHeader;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';
import 'package:repoGrid/components.dart' show Octicon;

import '../actions/repoActions.dart' as repoActions;
import '../constants.dart' as CONSTANTS;
import '../services/localStorageService.dart' as localStorageService;


/**
 * The GridHub page header component - title & controls
 */
var GridHubHeader = react.registerComponent(() => new _GridHubHeader());
class _GridHubHeader extends react.Component {

    // TODO this is bad. Antipattern.
    var storage = new localStorageService.GridHubData();

    getDefaultProps() {
        return {
            'currentPageName': '',
            'globalButtonClickHandler': (){},
            'pageNames': []
        };
    }

    getInitialState() {
        return {
            'editPageName': '',
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
            repoActions.addPage(this.state['newPageName']);
            this.setState({'newPageName': ''});
        }
    }

    deletePage(event) {
        event.preventDefault();
        repoActions.deletePage(this.props['currentPageName']);
    }

    editPage(event) {
        event.preventDefault();
        if (!this.state['editPageName'].isEmpty) {
            repoActions.editPage(this.state['editPageName']);
            this.setState({'editPageName': ''});
        }
    }

    refreshPage(event) {
        event.preventDefault();
        repoActions.refreshPage(this.props['currentPageName']);
    }

    addRepo(event) {
        event.preventDefault();
        if (!this.state['newRepoName'].isEmpty) {
          repoActions.addRepo(this.state['newRepoName']);
          this.setState({'newRepoName': ''});
        }
    }

    render() {
        var currentPageName = this.props['currentPageName'];
        var editPageName = this.state['editPageName'];
        if (editPageName == '') {
            editPageName = currentPageName;
        }
        var globalButtonClickHandler = this.props['globalButtonClickHandler'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];
        var newPageName = this.state['newPageName'];
        var newRepoName = this.state['newRepoName'];
        var pageNames = this.props['pageNames'];

        var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon, 'title': 'README'});
        var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon, 'title': 'Tags/Releases'});
        var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon, 'title': 'Issues'});
        var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon, 'title': 'Pull Requests'});
        var unreleasedIcon = Octicon({'icon': CONSTANTS.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});
        var settingsIcon = Glyphicon({'glyph': 'cog'});
        var trashIcon = Glyphicon({'glyph': 'trash'});
        var addIcon = Octicon({'icon': 'plus'});
        var refreshIcon = Octicon({'icon': 'sync'});

        var pageButtons = [];
        pageNames.forEach((pageName) {
            pageSwitch(event) {
                repoActions.switchPage(pageName);
            }
            if (currentPageName == pageName) {
                var title = react.span({}, [
                    react.span({}, 'Edit Page'),
                    react.a({'className': 'pull-right', 'style': {'color': '#f03e3c'}, 'onClick': this.deletePage}, trashIcon)
                ]);
                pageButtons.add(react.li({'className': 'active'}, [
                    OverlayTrigger({'trigger': 'click', 'placement': 'bottom', 'overlay': Popover(
                        {'className': 'inner', 'title': title}, [
                            react.form({'onSubmit': this.editPage}, [
                                Input({'type': 'text', 'label': 'Page Name',
                                    'value': editPageName,
                                    'onChange': this.onEditPageNameChange,
                                })
                            ])
                        ])},
                    react.a({'className': 'hitarea', 'onClick': null, 'style': {'cursor': 'pointer'}}, pageName)
                    ),
                ]));

            } else {
                pageButtons.add(react.li({}, [
                    react.a({'className': 'hitarea', 'onClick': pageSwitch}, pageName)
                ]));
            }

        });

        // ADD NEW PAGE BUTTON
        if (pageButtons.length > 0) {
            pageButtons.add(react.li({}, [
                OverlayTrigger({'trigger': 'click', 'placement': 'right', 'overlay': Popover(
                    {'className': 'inner add-page-popover', 'arrowOffsetTop': 18, 'title': 'Add Page'}, [
                        react.form({'onSubmit': this.addPage}, [
                            Input({'type': 'text', 'label': 'Page Name',
                                'value': newPageName,
                                'onChange': this.onNewPageNameChange,
                            }),
                        ])
                    ])},
                react.a({'className': 'hitarea', 'onClick': null}, addIcon)
                ),
            ]));
        }

        pageButtons.add(react.li({}, [
            react.a({'className': 'hitarea', 'onClick': refreshPage}, refreshIcon)
        ]));

        var brand = react.h3({'style': {'display': 'inline', 'marginTop': '2px'}}, 'GridHub');
        var navBarStyle = {'borderWidth': '0 0 1px', 'borderRadius': 0, 'paddingRight': '3px', 'paddingLeft': '12px'};
        return Navbar({'fixedTop': true, 'fluid': true, 'brand': brand, 'style': navBarStyle}, [
            react.ul({'className': 'nav navbar-nav'}, pageButtons),
            Nav({'className': 'pull-right'}, [

                // ADD REPO BUTTON
                OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': Popover(
                    {'className': 'inner add-repo-popover', 'arrowOffsetTop': 18, 'title': 'Add Repository'}, [
                        react.form({'onSubmit': this.addRepo}, [
                            Input({'type': 'text', 'label': 'Repo Path',
                                'placeholder': 'Workiva/wGulp',
                                'value': newRepoName,
                                'onChange': this.onNewRepoNameChange,
                            }),
                        ])
                    ])},
                    NavItem({'style': {'marginRight': '20px'}}, addIcon)
                ),

                // GLOBAL STATE BUTTONS
                NavItem({'onClick': globalButtonClickHandler('1')}, readmeIcon),
                NavItem({'onClick': globalButtonClickHandler('2')}, tagIcon),
                NavItem({'onClick': globalButtonClickHandler('3')}, issueIcon),
                NavItem({'onClick': globalButtonClickHandler('4')}, pullRequestIcon),
                NavItem({'onClick': globalButtonClickHandler('5')}, unreleasedIcon),

                // SETTINGS BUTTON
                // TODO Could not get this popover to work in its own component file. fix this
                // For some reason if I create a new component that renders a Popover, and then pass
                // that in as a prop to OverlayTrigger - it breaks. I assume it is dart interop issues
                OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': Popover(
                    {'title': 'Settings', 'arrowOffsetTop': 18, 'className': 'inner settings-popover'}, [
                        Input({'type': 'text', 'label': 'Github Username',
                            'value': githubUsername,
                            'onChange': this.onGithubUsernameChange}),
                        Input({'type': 'password', 'label': 'Github Access Token',
                            'value': githubAccessToken,
                            'onChange': this.onGithubAccessTokenChange})
                    ])},
                    NavItem({'style': {'marginLeft': '20px'}}, settingsIcon)
                ),
            ])
        ]);
    }
}