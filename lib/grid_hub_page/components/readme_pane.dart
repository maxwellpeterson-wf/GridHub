part of grid_hub_page;

/**
 * A pane containing the HTML version of the README for a repo
 */
var ReadmePane = react.registerComponent(() => new _ReadmePane());
class _ReadmePane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var contents = repo.readmeData;
        return react.div({
            'dangerouslySetInnerHTML': new js.JsObject.jsify({'__html': contents}),
            'className': 'scrollable-pane readme'
        });
    }
}
