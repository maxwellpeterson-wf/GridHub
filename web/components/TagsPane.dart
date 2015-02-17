library TagsPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../services/githubService.dart' as githubService;
import '../models/repo.dart';

import 'AuthorLink.dart';
import 'NoResultsIcon.dart';


var TagsPane = react.registerComponent(() => new _TagsPane());

class _TagsPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    getInitialState() {
        return {
            'releases': [],
            'tags': []
        };
    }

    componentWillMount() {
        RepoDescriptor repo = this.props['repo'];
        if (repo != null) {
            githubService.getTags(repo).then((responseJson) {
                this.setState({'tags': responseJson});
            });
            githubService.getReleases(repo).then((responseJson) {
                this.setState({'releases': responseJson});
            });
        }
    }

    render() {
        RepoDescriptor repo = this.props['repo'];
        var tags = this.state['tags'];
        var releases = this.state['releases'];

        var releaseMap = {};
        releases.forEach((release) {
            releaseMap[release['tag_name']] = release;
        });

        var listItems = [];

        tags.forEach((tag) {
            var release = releaseMap[tag['name']];
            if (release != null) {
                var header = react.h4({}, [
                    react.a({'href': release['html_url'], 'target': repo.name}, release['name'])
                ]);
//                var publishDate = DateTime.parse(release['published_at']);
                var body = react.span({}, [
                    react.div({}, [
                        AuthorLink({'author': release['author'], 'includePicture': true}),
                        react.span({'className': 'text-muted'}, ' released this on ' + release['published_at'])
                    ]),
                    react.div({}, [
//                        react.span({}, release['body'])
                    ])
                ]);

                listItems.add(
                    ListGroupItem({'header': header}, body)
                );
            }
            else {
                var href = repo.url + '/releases/tag/' + tag['name'];
                var header = react.h4({}, [
                    react.a({'href': href, 'target': repo.name}, 'No release! Tag: ' + tag['name'])
                ]);

                listItems.add(
                    ListGroupItem({'header': header})
                );
            }

        });

        var content;
        if (listItems.length > 0) {
            content =         react.div({'className': 'scrollable-pane'}, [
                ListGroup({}, listItems)
            ]);
        }
        else {
            content = NoResultsIcon({});
        }

        return content;
    }
}
