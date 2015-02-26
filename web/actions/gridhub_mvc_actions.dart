part of gridhub_mvc;

class Actions {
    flux.Action<String> _pageSwitch = new flux.Action<String>();
    flux.Action get pageSwitch => _pageSwitch;

    flux.Action<Map<String, dynamic>> _pageComponentAdd = new flux.Action<Map<String, dynamic>>();
    flux.Action<Map<String, dynamic>> get pageComponentAdd => _pageComponentAdd;
}
