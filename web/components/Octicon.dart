library Octicon;

import 'package:react/react.dart' as react;


var Octicon = react.registerComponent(() => new _Octicon());

class _Octicon extends react.Component {
  render() {
    var icon = this.props['icon'];
    var moreClassName = this.props['className'];
    var className = 'octicon octicon-${icon} ${moreClassName}';
    return react.span({'className': className});
  }
}