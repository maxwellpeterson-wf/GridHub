part of grid_hub_header;

class Stores {

    PagesStore _pagesStore;
    PagesStore get pagesStore => _pagesStore;

    SettingsStore _settingsStore;
    SettingsStore get settingsStore => _settingsStore;

    Stores(this._pagesStore, this._settingsStore);

}
