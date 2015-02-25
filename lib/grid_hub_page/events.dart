part of grid_hub_page;

class PublicEvents {

    flux.Action<String> _repoAddAction;
    flux.Action<String> _repoRemoveAction;
    flux.Action<String> _repoReorderAction;

    Stream<String> get repoAdd => _repoAddAction.stream;
    Stream<String> get repoRemove => _repoRemoveAction.stream;
    Stream<dynamic> get repoReorder => _repoReorderAction.stream;

    PublicEvents(GridHubPageInternalActions internalActions) {
        _repoAddAction = new flux.Action<String>();
        _repoRemoveAction = new flux.Action<String>();
        _repoReorderAction = new flux.Action<dynamic>();

        internalActions.repoAdd.stream.listen(_repoAddAction.dispatch);
        internalActions.repoRemove.stream.listen(_repoRemoveAction.dispatch);
        internalActions.repoReorder.stream.listen(_repoReorderAction.dispatch);
    }

}
