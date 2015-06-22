library gridhub.src.actions.repo_actions;

import 'package:flux/flux.dart';

class RepoActions {

  /// Payload is the repo name to add
  final Action<String> addRepo = new Action<String>();

  /// Payload is the repo name to update
  final Action<String> updateRepo = new Action<String>();

  /// Payload is the repo name to remove
  final Action<String> removeRepo = new Action<String>();

  // TODO move these to "PageActions" ?
  /// Payload is the page name to add
  final Action<String> addPage = new Action<String>();

  /// Payload is the page name to delete
  final Action<String> deletePage = new Action<String>();

  /// Payload is the page name to edit
  final Action<String> editPage = new Action<String>();  // TODO what is this doing?

  /// Payload is the page name to refresh
  final Action<String> refreshPage = new Action<String>();

  /// Payload is the page name to switch to
  final Action<String> switchPage = new Action<String>();

  /// Payload is the page index to switch to
  final Action<int> switchPageByIndex = new Action<int>();

}
