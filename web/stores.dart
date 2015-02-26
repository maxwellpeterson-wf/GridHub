part of gridhub_mvc;

class Stores {
    CurrentPageNameStore _currentPageNameStore;
    CurrentPageNameStore get currentPageNameStore => _currentPageNameStore;

    PageComponentsStore _pageComponentsStore;
    PageComponentsStore get pageComponentsStore => _pageComponentsStore;

    Stores(this._currentPageNameStore, this._pageComponentsStore);
}
