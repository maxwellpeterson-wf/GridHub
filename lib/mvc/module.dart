part of mvc;

abstract class Module {
    Object get events;

    void initialize();
    void destroy();
}

abstract class ViewModule extends Module {
    Function get component;
}

// TODO non-visual modules