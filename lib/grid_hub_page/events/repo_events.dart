part of grid_hub_page;

class RepoEvents {

    flux.Action<String> _repoRemoveAction = new flux.Action<String>();
    flux.Action<String> _repoReorderAction = new flux.Action<dynamic>();

    Stream<String> get repoRemove => _repoRemoveAction.stream.asBroadcastStream();
    Stream<dynamic> get repoReorder => _repoReorderAction.stream.asBroadcastStream();

    void wireRepoEvents(Actions actions) {
        actions.repoRemove.stream.listen(_repoRemoveAction.dispatch);
        actions.repoReorder.stream.listen(_repoReorderAction.dispatch);
    }

}