part of grid_hub_page;

class GridHubPageInternalActions {

    flux.Action _refreshAll;
    flux.Action get refreshAll => _refreshAll;
    flux.Action _repoAdd;
    flux.Action get repoAdd => _repoAdd;
    flux.Action _repoRemove;
    flux.Action get repoRemove => _repoRemove;
    flux.Action _repoReorder;
    flux.Action get repoReorder => _repoReorder;
    flux.Action _repoUpdate;
    flux.Action get repoUpdate => _repoUpdate;
    flux.Action _setActivePane;
    flux.Action get setActivePane => _setActivePane;

    GridHubPageActions() {
        _refreshAll = new flux.Action();
        _repoAdd = new flux.Action<String>();
        _repoRemove = new flux.Action<String>();
        _repoReorder = new flux.Action<dynamic>();
        _repoUpdate = new flux.Action<String>();
        _setActivePane = new flux.Action<String>();
    }
    
}