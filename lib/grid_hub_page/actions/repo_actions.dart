part of grid_hub_page;

class RepoActions {

    flux.Action _repoAdd = new flux.Action<String>();
    flux.Action get repoAdd => _repoAdd;
    flux.Action _repoRemove = new flux.Action<String>();
    flux.Action get repoRemove => _repoRemove;
    flux.Action _repoReorder = new flux.Action<dynamic>();
    flux.Action get repoReorder => _repoReorder;
    flux.Action _repoUpdate = new flux.Action<String>();
    flux.Action get repoUpdate => _repoUpdate;

}