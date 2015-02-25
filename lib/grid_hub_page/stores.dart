part of grid_hub_page;

class Stores {

    PageStore _pageStore;
    PageStore get pageStore => _pageStore;

    GlobalActivePaneStore _globalActivePaneStore;
    GlobalActivePaneStore get globalActivePaneStore => _globalActivePaneStore;

    Stores(this._pageStore, this._globalActivePaneStore);

}