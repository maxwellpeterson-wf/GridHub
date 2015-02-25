part of grid_hub_page;

var RepoContainer = react.registerComponent(() => new _RepoContainer());
class _RepoContainer extends react.Component {

    Actions get actions => this.props['actions'];
    String get activePane => this.state['activePane'];
    String get globalActivePane => this.props['globalActivePane'];
    Repository get repo => this.props['repo'];

    getDefaultProps() {
        return {
            'actions': null,
            'globalActivePane': gridHubPageConstants.readmePane,
            'repo': null,
        };
    }

    getInitialState() {
        return {
            'activePane': globalActivePane
        };
    }

    componentWillReceiveProps(dynamic newProps) {
        String pane = newProps['globalActivePane'];
        if (pane != activePane) {
            this.setState({'activePane': pane});
        }
    }

    _paneSelected(String activePane) {
        this.setState({'activePane': activePane});
    }

    _removeRepo(event) {
        actions.repoRemove.dispatch(repo.name);
    }

    render() {
        String repoName = repo != null ? repo.name : 'Test Repo';
        var title = react.h3({}, [
            Octicon({'icon': 'repo'}),
            react.a({'href': repo.url, 'target': repoName}, repoName),
            react.span({'className': 'pull-right'}, [
                react.a({'className': 'remove-repo', 'onClick': _removeRepo}, wsr.Glyphicon({'glyph': 'trash'}))
            ])
        ]);

        var readmeIcon = Octicon({'icon': gridHubPageConstants.readmeIcon, 'title': 'README'});
        var tagIcon = Octicon({'icon': gridHubPageConstants.tagsIcon, 'title': 'Tags/Releases'});
        var issueIcon = Octicon({'icon': gridHubPageConstants.issuesIcon, 'title': 'Issues'});
        var pullRequestIcon = Octicon({'icon': gridHubPageConstants.pullRequestsIcon, 'title': 'Pull Requests'});
        var unreleasedIcon = Octicon({'icon': gridHubPageConstants.unreleasedIcon, 'title': 'Unreleased PRs (PRs merged since last tag)'});

        return wsr.Panel({'header': title, 'className': 'repo-panel'}, [
            wsr.TabbedArea({
                'activeKey': activePane, 'className': 'tabs-right',
                'animation': false, 'onSelect': _paneSelected
            }, [
                wsr.TabPane({'eventKey': '1', 'tab': readmeIcon}, [
                    ReadmePane({'repo': repo})
                ]),
                wsr.TabPane({'eventKey': '2', 'tab': tagIcon}, [
                    TagsPane({'repo': repo})
                ]),
                wsr.TabPane({'eventKey': '3', 'tab': issueIcon}, [
                    IssuesPane({'repo': repo})
                ]),
                wsr.TabPane({'eventKey': '4', 'tab': pullRequestIcon}, [
                    IssuesPane({'repo': repo, 'pullRequests': true})
                ]),
                wsr.TabPane({'eventKey': '5', 'tab': unreleasedIcon}, [
                    UnreleasedPane({'repo': repo})
                ]),
            ])
        ]);
    }
}
