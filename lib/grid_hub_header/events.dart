part of grid_hub_header;

class Events {

    flux.Action<String> _githubAccessTokenUpdateAction = new flux.Action<String>();
    flux.Action<String> _githubUsernameUpdateAction = new flux.Action<String>();
    flux.Action<String> _globalActivePaneSwitchAction = new flux.Action<String>();
    flux.Action<String> _pageAddAction = new flux.Action<String>();
    flux.Action _pageRefresh = new flux.Action();
    flux.Action<String> _pageRemoveAction = new flux.Action<String>();
    flux.Action<Map<String, String>> _pageRenameAction = new flux.Action<Map<String, String>>();
    flux.Action<String> _pageSwitchAction = new flux.Action<String>();
    flux.Action<String> _repoAddAction = new flux.Action<String>();

    Stream<String> get githubAccessTokenUpdateAction => _githubAccessTokenUpdateAction.stream.asBroadcastStream();
    Stream<String> get githubUsernameUpdateAction => _githubUsernameUpdateAction.stream.asBroadcastStream();
    Stream<String> get globalActivePaneSwitchAction => _globalActivePaneSwitchAction.stream.asBroadcastStream();
    Stream<String> get pageAddAction => _pageAddAction.stream.asBroadcastStream();
    Stream get pageRefreshAction => _pageAddAction.stream.asBroadcastStream();
    Stream<String> get pageRemoveAction => _pageRemoveAction.stream.asBroadcastStream();
    Stream<Map<String, String>> get pageRenameAction => _pageRenameAction.stream.asBroadcastStream();
    Stream<String> get pageSwitchAction => _pageSwitchAction.stream.asBroadcastStream();
    Stream<String> get repoAddAction => _repoAddAction.stream.asBroadcastStream();

    Events(Actions actions) {
        actions.githubAccessTokenChange.stream.listen(_githubAccessTokenUpdateAction.dispatch);
        actions.githubUsernameChange.stream.listen(_githubUsernameUpdateAction.dispatch);
        actions.globalActivePaneSwitch.stream.listen(_globalActivePaneSwitchAction.dispatch);
        actions.pageAdd.stream.listen(_pageAddAction.dispatch);
        actions.pageRefresh.stream.listen(_pageRefresh.dispatch);
        actions.pageRemove.stream.listen(_pageRemoveAction.dispatch);
        actions.pageRename.stream.listen(_pageRenameAction.dispatch);
        actions.pageSwitch.stream.listen(_pageSwitchAction.dispatch);
        actions.repoAdd.stream.listen(_repoAddAction.dispatch);
    }
}
