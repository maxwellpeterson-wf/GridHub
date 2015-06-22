library gridhub.src.components.fancy_list_group_item;

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
    var className = this.props['className'] == null ? '' : this.props['className'];
    className += ' list-group-item';
    return react.div({'className': className}, [
      headerComponent,
      react.div({'className': 'list-group-item-text'}, this.props['children'])
    ]);
  }
}
