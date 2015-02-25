part of grid_hub_page;

var NoResultsIcon = react.registerComponent(() => new _NoResultsIcon());
class _NoResultsIcon extends react.Component {

    render() {
        return react.div({'className': 'empty-results'}, [
            Octicon({'icon': 'gift', 'style': {'fontSize': '28px'}}),
            react.div({}, 'Nothing to show!')
        ]);
    }
}
