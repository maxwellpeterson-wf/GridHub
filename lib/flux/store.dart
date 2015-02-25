part of flux;

class Store {
    
    StreamController _streamController;
    Stream get stream => _streamController.stream;
    
    Store() {
        _streamController = new StreamController();
    }

    void trigger([Object payload]) {
        _streamController.add(payload);
    }

}