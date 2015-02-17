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
        var addIcon = Octicon({'icon': 'plus'});

        var pageButtons = [];
        if (pageNames.length > 1) {
            pageNames.forEach((pageName) {
                pageSwitch(event) {
                    repoActions.switchPage(pageName);
                }
                pageButtons.add(Button({'title': pageName, 'onClick': pageSwitch}, pageName));
            });
        }

        return react.div({'className': 'page-header'}, [
            react.h1({'style': {'display': 'inline'}}, 'GridHub'),
            ButtonToolbar({'className': 'pull-right'}, [
                react.span({}, 'Page: '),
                ButtonGroup({'bsSize': 'large'}, pageButtons),
                react.span({}, 'State Select: '),
                ButtonGroup({'bsSize': 'large'}, [
                    Button({'title': 'Readme', 'onClick': globalButtonClickHandler('1')}, readmeIcon),
                    Button({'title': 'Tags/Releases', 'onClick': globalButtonClickHandler('2')}, tagIcon),
                    Button({'title': 'Issues', 'onClick': globalButtonClickHandler('3')}, issueIcon),
                    Button({'title': 'Pull Requests', 'onClick': globalButtonClickHandler('4')}, pullRequestIcon),
                    Button({'title': 'Merged but not released', 'onClick': globalButtonClickHandler('5')}, unreleasedIcon)
                ]),
                OverlayTrigger({'trigger': 'click', 'placement': 'bottom', 'overlay': Popover(
                    {'className': 'inner'}, [
                        react.form({'onSubmit': this.addRepo}, [
                            Input({'type': 'text', 'label': 'Repo Path',
                                'placeholder': 'Workiva/wGulp',
                                'value': newRepoName,
                                'onChange': this.onNewRepoNameChange,

                            }),
                        ])
//                        Button({'type': 'submit', 'onClick': this.addRepo, 'bsStyle': 'primary'}, 'Add')
                    ])},
                    Button({'bsStyle': 'default'}, [
                        Octicon({'icon': 'repo'}),
                        react.span({}, ' Add Repo')
                    ])
                ),
                OverlayTrigger({'trigger': 'click', 'placement': 'bottom', 'overlay': Popover(
                    {'className': 'inner'}, [
                        react.form({'onSubmit': this.addPage}, [
                            Input({'type': 'text', 'label': 'Page Name',
                                'value': newPageName,
                                'onChange': this.onNewPageNameChange,
                            }),
                        ])
//                        Button({'type': 'submit', 'onClick': this.addRepo, 'bsStyle': 'primary'}, 'Add')
                    ])},
                    Button({'bsStyle': 'default'}, [
                        Glyphicon({'glyph': 'file-new'}),
                        react.span({}, ' Add Page')
                    ])
                ),
                // TODO Could not get this popover to work in its own component file. fix this
                // For some reason if I create a new component that renders a Popover, and then pass
                // that in as a prop to OverlayTrigger - it breaks. I assume it is dart interop issues
                OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': Popover(
                    {'title': 'Settings', 'arrowOffsetTop': 25, 'className': 'inner settings-popover'}, [
                        Input({'type': 'text', 'label': 'Github Username',
                            'value': githubUsername,
                            'onChange': this.onGithubUsernameChange}),
                        Input({'type': 'password', 'label': 'Github Access Token',
                            'value': githubAccessToken,
                            'onChange': this.onGithubAccessTokenChange})
                    ])},
                Button({'className': 'settings-icon', 'bsStyle': 'link'}, [
                    Glyphicon({'glyph': 'cog', 'bsSize': 'large'})
                ])
                ),
            ]),
        ]);
    }
}