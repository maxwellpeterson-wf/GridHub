part of grid_hub_page;

var FancyListGroupItem = react.registerComponent(() => new _FancyListGroupItem());
class _FancyListGroupItem extends react.Component {

    dynamic get header {
        if (this.props['header'] is! List) {
            return [this.props['header']];
        }
        return this.props['header'];
    }

    render() {
        return react.div({'className': 'list-group-item'}, [
            react.h4({'className': 'list-group-item-heading'}, header),
            react.p({'className': 'list-group-item-text'}, this.props['children'])
        ]);
    }
}