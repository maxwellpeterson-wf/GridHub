part of gridhub.actions;


class GlobalStateActions {

  /// Payload is whether or not the global open state is open or closed
  final Action<bool> globalOpenState = new Action<bool>();

  /// Payload is active pane key
  final Action<String> switchActivePaneKey = new Action<String>();
}