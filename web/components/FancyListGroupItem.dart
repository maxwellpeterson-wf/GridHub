library FancyListGroupItem;

import 'package:react/react.dart' as react;


var FancyListGroupItem = react.registerComponent(() => new _FancyListGroupItem());

class _FancyListGroupItem extends react.Component {

    render() {
        var header = this.props['header'];
        if (header is! List) {
            header = [header];
        }
        return react.div({'className': 'list-group-item'}, [
            react.h4({'className': 'list-group-item-heading'}, header),
            react.p({'className': 'list-group-item-text'}, this.props['children'])
        ]);
    }
}