part of grid_hub_page;

class GlobalActivePaneStore extends flux.Store {

    String _pane;
    String get pane => _pane;

    Actions _actions;

    GlobalActivePaneStore(this._actions): super() {
        _actions.setActivePane.stream.listen(onSetActivePane);
    }

    void onSetActivePane(String globalActivePane) {
        _pane = globalActivePane;
        trigger();
    }
}