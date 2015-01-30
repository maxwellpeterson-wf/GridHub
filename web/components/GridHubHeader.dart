library GridHubHeader;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

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
            'globalButtonClickHandler': (){}
        };
    }

    getInitialState() {
        return {
            'githubUsername': storage.githubUsername,
            'githubAccessToken': storage.githubAccessToken
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
        var globalButtonClickHandler = this.props['globalButtonClickHandler'];
        var githubUsername = this.state['githubUsername'];
        var githubAccessToken = this.state['githubAccessToken'];

        var readmeIcon = Octicon({'icon': CONSTANTS.readmeIcon});
        var tagIcon = Octicon({'icon': CONSTANTS.tagsIcon});
        var issueIcon = Octicon({'icon': CONSTANTS.issuesIcon});
        var pullRequestIcon = Octicon({'icon': CONSTANTS.pullRequestsIcon});
        var pinIcon = Octicon({'icon': CONSTANTS.unreleasedIcon});

        return react.div({'className': 'page-header'}, [
            react.h1({'style': {'display': 'inline'}}, 'GridHub'),
            ButtonToolbar({'className': 'pull-right'}, [
                ButtonGroup({'bsSize': 'large'}, [
                    Button({'onClick': globalButtonClickHandler('1')}, readmeIcon),
                    Button({'onClick': globalButtonClickHandler('2')}, tagIcon),
                    Button({'onClick': globalButtonClickHandler('3')}, issueIcon),
                    Button({'onClick': globalButtonClickHandler('4')}, pullRequestIcon),
                    Button({'onClick': globalButtonClickHandler('5')}, pinIcon)
                ]),
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