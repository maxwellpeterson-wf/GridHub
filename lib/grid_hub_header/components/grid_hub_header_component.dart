part of grid_hub_header;

/**
 * The GridHub page header component - title & controls
 */
var GridHubHeaderComponent = react.registerComponent(() => new _GridHubHeaderComponent());
class _GridHubHeaderComponent extends react.Component {

    // Props
    Actions get actions => this.props['actions'];
    Stores get stores => this.props['stores'];

    // State
    String get currentPageName => this.state['currentPageName'];
    String get editPageName => this.state['editPageName'];
    String get githubAccessToken => this.state['githubAccessToken'];
    String get githubUsername => this.state['githubUsername'];
    String get newPageName => this.state['newPageName'];
    String get newRepoName => this.state['newRepoName'];
    List<String> get pageNames => this.state['pageNames'];

    // Internal
    StreamSubscription _settingsStoreSubscription;
    StreamSubscription _pagesStoreSubscription;

    getDefaultProps() {
        return {
            'actions': null,
            'stores': null
        };
    }

    getInitialState() {
        return {
            'currentPageName': stores.pagesStore.currentPageName,
            'editPageName': currentPageName,
            'githubAccessToken': stores.settingsStore.githubAccessToken,
            'githubUsername': stores.settingsStore.githubUsername,
            'newPageName': '',
            'newRepoName': '',
            'pageNames': stores.pagesStore.pageNames
        };
    }

    componentWillMount() {
        _settingsStoreSubscription = stores.settingsStore.stream.listen((_) {
            this.setState({
                'githubAccessToken': stores.settingsStore.githubAccessToken,
                'githubUsername': stores.settingsStore.githubUsername
            });
        });
        _pagesStoreSubscription = stores.pagesStore.stream.listen((_) {
            this.setState({
                'currentPageName': stores.pagesStore.currentPageName,
                'pageNames': stores.pagesStore.pageNames
            });
        });
    }

    componentWillUnmount() {
        _settingsStoreSubscription.cancel();
        _pagesStoreSubscription.cancel();
    }

    void _onGithubAccessTokenChange(event) {
        this.setState({'githubAccessToken': event.target.value});
        String accessToken = event.target.value;
        actions.githubAccessTokenChange.dispatch(accessToken);
    }

    void _onGithubUsernameChange(event) {
        this.setState({'githubUsername': event.target.value});
        String username = event.target.value;
        actions.githubUsernameChange.dispatch(username);
    }

    Function _onGlobalActivePaneSwitch(String pane) {
        return (event) {
            actions.globalActivePaneSwitch.dispatch(pane);
        };
    }

    void _onNewPageNameChange(event) {
        this.setState({'newPageName': event.target.value});
    }

    void _onEditPageNameChange(event) {
        this.setState({'editPageName': event.target.value});
    }

    void _onNewRepoNameChange(event) {
        this.setState({'newRepoName': event.target.value});
    }

    void _addPage(event) {
        event.preventDefault();
        if (!newPageName.isEmpty) {
            actions.pageAdd.dispatch(newPageName);
            this.setState({'newPageName': ''});
        }
    }

    void _deletePage(event) {
        event.preventDefault();
        actions.pageRemove.dispatch(stores.pagesStore.currentPageName);
    }

    void _renamePage(event) {
        event.preventDefault();
        if (!editPageName.isEmpty) {
            actions.pageRename.dispatch(editPageName);
            this.setState({'editPageName': ''});
        }
    }

    void _refreshPage(event) {
        event.preventDefault();
        actions.pageRefresh.dispatch(null);
    }

    void _addRepo(event) {
        event.preventDefault();
        if (!newRepoName.isEmpty) {
            actions.repoAdd.dispatch(newRepoName);
            this.setState({'newRepoName': ''});
        }
    }

    render() {
        var readmeIcon = Octicon({'icon': headerConstants.readmeIcon, 'title': 'README'});
        var tagIcon = Octicon({'icon': headerConstants.tagsIcon, 'title': 'Tags/Releases'});
        var issueIcon = Octicon({'icon': headerConstants.issuesIcon, 'title': 'Issues'});
        var pullRequestIcon = Octicon({'icon': headerConstants.pullRequestsIcon, 'title': 'Pull Requests'});
        var unreleasedIcon = Octicon({'icon': headerConstants.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});
        var settingsIcon = wsr.Glyphicon({'glyph': 'cog'});
        var trashIcon = wsr.Glyphicon({'glyph': 'trash'});
        var addIcon = Octicon({'icon': 'plus'});
        var refreshIcon = Octicon({'icon': 'sync'});

        var pageButtons = [];
        pageNames.forEach((pageName) {
            pageSwitch(event) {
                actions.pageSwitch.dispatch(pageName);
            }
            if (currentPageName == pageName) {
                var title = react.span({}, [
                    react.span({}, 'Edit Page'),
                    react.a({'className': 'pull-right', 'style': {'color': '#f03e3c'}, 'onClick': _deletePage}, trashIcon)
                ]);
                pageButtons.add(react.li({'className': 'active'}, [
                    wsr.OverlayTrigger({'trigger': 'click', 'placement': 'bottom', 'overlay': wsr.Popover(
                        {'className': 'inner', 'title': title}, [
                            react.form({'onSubmit': _renamePage}, [
                                wsr.Input({'type': 'text', 'label': 'Page Name',
                                    'value': editPageName,
                                    'onChange': _onEditPageNameChange,
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
                wsr.OverlayTrigger({'trigger': 'click', 'placement': 'right', 'overlay': wsr.Popover(
                    {'className': 'inner add-page-popover', 'arrowOffsetTop': 18, 'title': 'Add Page'}, [
                        react.form({'onSubmit': _addPage}, [
                            wsr.Input({'type': 'text', 'label': 'Page Name',
                                'value': newPageName,
                                'onChange': _onNewPageNameChange,
                            }),
                        ])
                    ])},
                react.a({'className': 'hitarea', 'onClick': null}, addIcon)
                ),
            ]));
        }

        pageButtons.add(react.li({}, [
            react.a({'className': 'hitarea', 'onClick': _refreshPage}, refreshIcon)
        ]));

        var brand = react.h3({'style': {'display': 'inline', 'marginTop': '2px'}}, 'GridHub');
        var navBarStyle = {'borderWidth': '0 0 1px', 'borderRadius': 0, 'paddingRight': '3px', 'paddingLeft': '12px'};
        return wsr.Navbar({'fixedTop': true, 'fluid': true, 'brand': brand, 'style': navBarStyle}, [
            react.ul({'className': 'nav navbar-nav'}, pageButtons),
            wsr.Nav({'className': 'pull-right'}, [

                // ADD REPO BUTTON
                wsr.OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': wsr.Popover(
                    {'className': 'inner add-repo-popover', 'arrowOffsetTop': 18, 'title': 'Add Repository'}, [
                        react.form({'onSubmit': this._addRepo}, [
                            wsr.Input({'type': 'text', 'label': 'Repo Path',
                                'placeholder': 'Workiva/wGulp',
                                'value': newRepoName,
                                'onChange': _onNewRepoNameChange,
                            }),
                        ])
                    ])},
                    wsr.NavItem({'style': {'marginRight': '20px'}}, addIcon)
                ),

                // GLOBAL STATE BUTTONS
                wsr.NavItem({'onClick': _onGlobalActivePaneSwitch('1')}, readmeIcon),
                wsr.NavItem({'onClick': _onGlobalActivePaneSwitch('2')}, tagIcon),
                wsr.NavItem({'onClick': _onGlobalActivePaneSwitch('3')}, issueIcon),
                wsr.NavItem({'onClick': _onGlobalActivePaneSwitch('4')}, pullRequestIcon),
                wsr.NavItem({'onClick': _onGlobalActivePaneSwitch('5')}, unreleasedIcon),

                // SETTINGS BUTTON
                // TODO Could not get this popover to work in its own component file. fix this
                // For some reason if I create a new component that renders a Popover, and then pass
                // that in as a prop to OverlayTrigger - it breaks. I assume it is dart interop issues
                wsr.OverlayTrigger({'trigger': 'click', 'placement': 'left', 'overlay': wsr.Popover(
                    {'title': 'Settings', 'arrowOffsetTop': 18, 'className': 'inner settings-popover'}, [
                        wsr.Input({'type': 'text', 'label': 'Github Username',
                            'value': githubUsername,
                            'onChange': _onGithubUsernameChange}),
                        wsr.Input({'type': 'password', 'label': 'Github Access Token',
                            'value': githubAccessToken,
                            'onChange': _onGithubAccessTokenChange})
                    ])},
                    wsr.NavItem({'style': {'marginLeft': '20px'}}, settingsIcon)
                ),
            ])
        ]);
    }
}