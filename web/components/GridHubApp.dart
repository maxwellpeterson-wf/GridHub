library RepoGridApp;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../constants.dart' as CONSTANTS;
import '../services/localStorageService.dart' as localStorageService;
import 'Octicon.dart';
import 'RepoContainer.dart';


var GridHubApp = react.registerComponent(() => new _RepoGridApp());

class _RepoGridApp extends react.Component {

    var storage = new localStorageService.RepoGridData();

    getDefaultProps() {
        return {
            'repos': []
        };
    }

    getInitialState() {
        return {
            'globalActiveKey': '1',
            'githubUsername': storage.githubUsername,
            'githubAccessToken': storage.githubAccessToken
        };
    }

    globalButtonClicked(activeKey) {
        return (event) {
            this.setState({'globalActiveKey': activeKey});
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

    render() {
        var globalActiveKey = this.state['globalActiveKey'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];
        var rows = [];
        var rowItems = [];

        var repos = this.props['repos'];
        repos.forEach((repo) {
            rowItems.add(
                Col({'sm': 4}, [
                    RepoContainer({'repo': repo, 'globalActiveKey': globalActiveKey})
                ])
            );
            if (rowItems.length == 3) {
                rows.add(
                    Row({}, rowItems)
                );
                rowItems = [];
            }
        });

        var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon});
        var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon});
        var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon});
        var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon});
        var pinIcon = Octicon({'icon': CONSTANTS.unreleasedIcon});

        return react.div({'className': 'container-fluid'}, [
            react.div({'className': 'page-header'}, [
                react.h1({'style': {'display': 'inline'}}, 'GridHub'),
                ButtonToolbar({'className': 'pull-right'}, [
                    ButtonGroup({'bsSize': 'large'}, [
                        Button({'onClick': this.globalButtonClicked('1')}, readmeIcon),
                        Button({'onClick': this.globalButtonClicked('2')}, tagIcon),
                        Button({'onClick': this.globalButtonClicked('3')}, issueIcon),
                        Button({'onClick': this.globalButtonClicked('4')}, pullRequestIcon),
                        Button({'onClick': this.globalButtonClicked('5')}, pinIcon)
                    ]),
                    // TODO Could not get this popover to work in its own component file. fix this
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
            ]),
            react.div({}, rows),

        ]);
    }
}
