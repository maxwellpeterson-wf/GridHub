library GridHubHeader;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../actions/repoActions.dart' as repoActions;
import '../constants.dart' as CONSTANTS;
import '../services/localStorageService.dart' as localStorageService;
import 'Octicon.dart';


/**
 * The GridHub page header component - title & controls
 */
var GridHubHeader = react.registerComponent(() => new _GridHubHeader());
class _GridHubHeader extends react.Component {

    var storage = new localStorageService.RepoGridData();

    getDefaultProps() {
        return {
            'currentPage': '',
            'globalButtonClickHandler': (){},
            'pageNames': []
        };
    }

    getInitialState() {
        return {
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

    addRepo(event) {
        event.preventDefault();
        if (!this.state['newRepoName'].isEmpty) {
          repoActions.addRepo(this.state['newRepoName']);
          this.setState({'newRepoName': ''});
        }
    }

    render() {
        var currentPage = this.props['currentPage'];
        var globalButtonClickHandler = this.props['globalButtonClickHandler'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];
        var newPageName = this.state['newPageName'];
        var newRepoName = this.state['newRepoName'];
        var pageNames = this.props['pageNames'];

        var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon});
        var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon});
        var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon});
        var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon});
        var unreleasedIcon = Octicon({'icon': CONSTANTS.unreleasedIcon});
        var settingsIcon = Glyphicon({'glyph': 'cog'});
        var addIcon = Octicon({'icon': 'plus'});

        var pageButtons = [];
        pageNames.forEach((pageName) {
            pageSwitch(event) {
                repoActions.switchPage(pageName);
            }
            var activeClass = '';
            if (currentPage == pageName) {
                activeClass += 'active';
            }
            pageButtons.add(react.li({'className': activeClass}, [
                react.a({'className': 'hitarea', 'onClick': pageSwitch}, pageName)
            ]));
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