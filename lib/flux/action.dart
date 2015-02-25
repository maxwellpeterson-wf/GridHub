part of flux;

class Action<T> {

    Stream<T> _stream;
    Stream<T> get stream => _stream;
    StreamController<T> _streamController;

    Action() {
        _streamController = new StreamController<T>();
        _stream = _streamController.stream.asBroadcastStream();
    }

    void dispatch(T payload) {
        _streamController.add(payload);
    }

}