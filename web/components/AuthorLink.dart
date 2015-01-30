library AuthorLink;

import 'package:react/react.dart' as react;


var AuthorLink = react.registerComponent(() => new _AuthorLink());

class _AuthorLink extends react.Component {

    render() {
        var author = this.props['author'];
        var includePicture = this.props['includePicture'];
        var image = includePicture ? react.img({'height': 20, 'width': 20, 'src': author['avatar_url']}) : null;
        var href = 'https://github.com/' + author['login'];
        return react.a({'className': 'github-author', 'href': href, 'target': 'github-author'}, [
            image,
            react.span({}, ' '),
            react.span({}, author['login'])
        ]);
    }
}