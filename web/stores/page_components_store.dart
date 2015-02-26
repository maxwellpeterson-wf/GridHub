part of gridhub_mvc;

class PageComponentsStore extends flux.Store {

    Map<String, dynamic> _pageComponents;
    Map<String, dynamic> get pageComponents => _pageComponents;

    Actions _actions;

    PageComponentsStore(this._actions, this._pageComponents): super() {
        _actions.pageComponentAdd.stream.listen(onPageAdd);
    }

    void onPageAdd(Map<String, dynamic> page) {
        _pageComponents.addAll(page);
        trigger();
    }
}
