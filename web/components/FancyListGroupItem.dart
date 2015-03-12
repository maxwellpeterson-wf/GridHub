library FancyListGroupItem;

import 'package:react/react.dart' as react;


var FancyListGroupItem = react.registerComponent(() => new _FancyListGroupItem());

class _FancyListGroupItem extends react.Component {

    render() {
        var header = this.props['header'];
        var headerComponent;

        if (header != null) {
            if (header is! List) {
                header = [header];
            }
            headerComponent = react.h4({'className': 'list-group-item-heading'}, header);
        }
        return react.div({'className': 'list-group-item'}, [
            headerComponent,
            react.div({'className': 'list-group-item-text'}, this.props['children'])
        ]);
    }
}