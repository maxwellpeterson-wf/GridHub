part of components;

var Octicon = react.registerComponent(() => new _Octicon());
class _Octicon extends react.Component {

    String get icon => this.props['icon'];

    render() {
        String moreClassName = this.props.containsKey('className') ? this.props['className'] : '';
        String className = 'octicon octicon-${icon} ${moreClassName}';
        this.props.addAll({'className': className});
        return react.span(this.props);
    }
}