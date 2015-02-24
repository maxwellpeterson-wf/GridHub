library TagsPane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import '../components/FancyListGroupItem.dart';
import '../models/repo.dart';
import '../utils/date_utils.dart';

import 'AuthorLink.dart';
import 'NoResultsIcon.dart';


var TagsPane = react.registerComponent(() => new _TagsPane());

class _TagsPane extends react.Component {

    getDefaultProps() {
        return {
            'repo': null
        };
    }

    render() {
        Repository repo = this.props['repo'];
        var tags = repo.tagsData;
        var releases = repo.releasesData;

        var releaseMap = {};
        releases.forEach((release) {
            releaseMap[release['tag_name']] = release;
        });

        var listItems = [];

        tags.forEach((tag) {
            var release = releaseMap[tag['name']];
            if (release != null) {
                var header = react.a({'href': release['html_url'], 'target': repo.name}, release['name']);

                String relativeDate = getRelativeDate(DateTime.parse(release['published_at']));
                var body = react.span({}, [
                    react.div({}, [
                        AuthorLink({'author': release['author'], 'includePicture': true}),
                        react.span({'className': 'text-muted'}, ' released this ${relativeDate}')
                    ]),
                    react.div({}, [
//                        react.span({}, release['body'])
                    ])
                ]);

                listItems.add(
                    FancyListGroupItem({'header': header}, [body])
                );
            }
            else {
                var href = repo.url + '/releases/tag/' + tag['name'];
                var header = [
                    react.a({'href': href, 'target': repo.name}, 'No release! Tag: ' + tag['name'])
                ];

                listItems.add(
                    FancyListGroupItem({'header': header})
                );
            }

        });

        var content;
        if (listItems.length > 0) {
            content = react.div({'className': 'scrollable-pane'}, [
                ListGroup({}, listItems)
            ]);
        }
        else {
            content = NoResultsIcon({});
        }

        return content;
    }
}
