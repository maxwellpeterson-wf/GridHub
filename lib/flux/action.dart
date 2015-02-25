part of flux;

class Action<T> {

    Stream<T> get stream => _streamController.stream;

    StreamController<T> _streamController;

    Action() {
        _streamController = new StreamController<T>();
    }

    void dispatch(T payload) {
        _streamController.add(payload);
    }

}