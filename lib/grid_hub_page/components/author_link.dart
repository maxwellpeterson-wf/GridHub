part of grid_hub_page;

var AuthorLink = react.registerComponent(() => new _AuthorLink());
class _AuthorLink extends react.Component {

    Map get author => this.props['author'];
    bool get includePicture => this.props['includePicture'];

    render() {
        var image = includePicture ? react.img({'height': 20, 'width': 20, 'src': author['avatar_url']}) : null;
        var href = 'https://github.com/' + author['login'];
        return react.a({'className': 'github-author', 'href': href, 'target': 'github-author'}, [
            image,
            react.span({}, ' '),
            react.span({}, author['login'])
        ]);
    }
}