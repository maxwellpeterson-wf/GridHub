part of grid_hub_page;

class PageActions {

    flux.Action _refreshAll = new flux.Action();
    flux.Action get refreshAll => _refreshAll;
    flux.Action _setActivePane = new flux.Action<String>();
    flux.Action get setActivePane => _setActivePane;

}