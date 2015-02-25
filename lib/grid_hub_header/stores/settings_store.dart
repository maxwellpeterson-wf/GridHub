part of grid_hub_header;

class SettingsStore extends flux.Store {

    /**
     * Public data that the store exposes
     */
    String get githubAccessToken => _githubAccessToken;
    String get githubUsername => _githubUsername;

    /**
     * Internal data/state
     */
    Actions _actions;
    String _githubAccessToken;
    String _githubUsername;

    SettingsStore(this._actions, this._githubAccessToken, this._githubUsername): super() {
        _actions.githubAccessTokenChange.stream.listen(onGithubAccessTokenChange);
        _actions.githubUsernameChange.stream.listen(onGithubUsernameChange);
    }

    void onGithubAccessTokenChange(String accessToken) {
        _githubAccessToken = accessToken;
        trigger();
    }

    void onGithubUsernameChange(String username) {
        _githubUsername = username;
        trigger();
    }

}
