part of grid_hub_header;

class Actions {

    flux.Action _globalActivePaneSwitch = new flux.Action<String>();
    flux.Action get globalActivePaneSwitch => _globalActivePaneSwitch;

    flux.Action _pageAdd = new flux.Action<String>();
    flux.Action get pageAdd => _pageAdd;
    flux.Action _pageRefresh = new flux.Action<String>();
    flux.Action get pageRefresh => _pageRefresh;
    flux.Action _pageRename = new flux.Action<Map<String, String>>();
    flux.Action get pageRename => _pageRename;
    flux.Action _pageRemove = new flux.Action();
    flux.Action get pageRemove => _pageRemove;
    flux.Action _pageSwitch = new flux.Action<String>();
    flux.Action get pageSwitch => _pageSwitch;

    flux.Action _repoAdd = new flux.Action<String>();
    flux.Action get repoAdd => _repoAdd;

    flux.Action _githubAccessTokenChange = new flux.Action<String>();
    flux.Action get githubAccessTokenChange => _githubAccessTokenChange;
    flux.Action _githubUsernameChange = new flux.Action<String>();
    flux.Action get githubUsernameChange => _githubUsernameChange;
}
