part of grid_hub_header;

class PagesStore extends flux.Store {

    /**
     * Public data that the store exposes
     */
    String get currentPageName => _currentPageName;
    List<String> get pageNames => _pageNames;

    /**
     * Internal data/state
     */
    Actions _actions;
    String _currentPageName;
    List<String> _pageNames;

    PagesStore(this._actions, this._pageNames, this._currentPageName): super() {
        _actions.pageAdd.stream.listen(onPageAdd);
        _actions.pageRemove.stream.listen(onPageRemove);
        _actions.pageRename.stream.listen(onPageRename);
        _actions.pageSwitch.stream.listen(onPageSwitch);
    }

    void onPageAdd(String pageName) {
        _pageNames.add(pageName);
        trigger();
    }

    void onPageRemove(String pageName) {
        _pageNames.remove(pageName);
        trigger();
    }

    void onPageRename(Map<String, String> pageInfo) {
        String oldName = pageInfo['oldName'];
        String newName = pageInfo['newName'];
        _pageNames.insert(_pageNames.indexOf(oldName), newName);
        trigger();
    }

    void onPageSwitch(String pageName) {
        _currentPageName = pageName;
        trigger();
    }

}