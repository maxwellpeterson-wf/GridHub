library NoResultsIcon;

import 'package:react/react.dart' as react;

import 'Octicon.dart';


var NoResultsIcon = react.registerComponent(() => new _NoResultsIcon());

class _NoResultsIcon extends react.Component {

    render() {
        return react.div({'className': 'empty-results'}, [
            Octicon({'icon': 'gift', 'style': {'fontSize': '28px', 'key': 'icon'}}),
            react.div({'key': 'description'}, 'Nothing to show!')
        ]);
    }
}
