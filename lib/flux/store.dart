part of flux;

class Store {
    
    StreamController _streamController;
    Stream _stream;
    Stream get stream => _stream;
    
    Store() {
        _streamController = new StreamController();
        _stream = _streamController.stream.asBroadcastStream();
    }

    void trigger([Object payload]) {
        _streamController.add(payload);
    }

}