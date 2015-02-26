part of gridhub_mvc;

class CurrentPageNameStore extends flux.Store {

    String _currentPageName;
    String get pageName => _currentPageName;

    Actions _actions;

    CurrentPageNameStore(this._actions, this._currentPageName): super() {
        _actions.pageSwitch.stream.listen(onPageSwitch);
    }

    void onPageSwitch(String pageName) {
        _currentPageName = pageName;
        trigger();
    }
}
