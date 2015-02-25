part of grid_hub_page;


//
//class Storage {
//
//    Map<String, String> pages;
//
//    int _count;
//
//    Storage() {
//        _count = 0;
//        pages = new Map<String, String>();
//    }
//
//    void addPage(String pageName) {
//        pages[_getNewPageId()] = pageName;
//    }
//
//    String _getNewPageId() {
//        return 'page${_count++}';
//    }
//
//    GridHubPageStorage getStorageForPage(String pageId) {
//        return new ExternalStorage(pageId, this);
//    }
//
//}
//
//class ExternalStorage implements GridHubPageStorage {
//
//    String _pageId;
//    Storage _storage;
//
//    ExternalStorage(this._pageId, this._storage) {
//
//    }
//}