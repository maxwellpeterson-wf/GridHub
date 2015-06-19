part of gridhub.stores;

class GlobalStateStore extends Store {

  GridHubActions _actions;
  String _activePaneKey = '1';
  bool _openState = true;

  String get activePaneKey => _activePaneKey;
  bool get openState => _openState;

  GlobalStateStore(GridHubActions this._actions) {
    _actions.globalStateActions.globalOpenState.listen(onGlobalOpenState);
    _actions.globalStateActions.switchActivePaneKey.listen(onSwitchActivePaneKey);
  }


  onGlobalOpenState(bool open) {
    _openState = open;
    trigger();
  }

  onSwitchActivePaneKey(String key) {
    _activePaneKey = key;
    trigger();
  }
}
