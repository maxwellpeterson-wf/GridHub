library gridhub.src.components.octicon;

import 'package:react/react.dart' as react;

var Octicon = react.registerComponent(() => new _Octicon());
class _Octicon extends react.Component {
  render() {
    var icon = this.props['icon'];
    var moreClassName = this.props.containsKey('className') ? this.props['className'] : '';
    var className = 'octicon octicon-${icon} ${moreClassName}';
    this.props.addAll({'className': className});
    return react.span(this.props);
  }
}
