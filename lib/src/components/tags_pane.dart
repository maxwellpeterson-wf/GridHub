library gridhub.src.components.tags_pane;

import 'package:react/react.dart' as react;
import 'package:web_skin_react/web_skin_react.dart';

import 'package:gridhub/src/components/author_link.dart';
import 'package:gridhub/src/components/content_loading.dart';
import 'package:gridhub/src/components/fancy_list_group_item.dart';
import 'package:gridhub/src/components/no_results_icon.dart';
import 'package:gridhub/src/models/repository.dart';
import 'package:gridhub/src/utils/date_utils.dart';

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
        var body = react.span({},
        react.div({}, [
          AuthorLink({'author': release['author'], 'includePicture': true, 'key': 'author-link'}),
          react.span({'className': 'text-muted', 'key': 'text'}, ' released this ${relativeDate}')
        ])
//                    react.div({}, [
//                        react.span({}, release['body'])
//                    ])
        );

        listItems.add(
          FancyListGroupItem({'header': header, 'key': 'tag-${tag['name']}'}, body)
        );
      }
      else {
        var href = repo.url + '/releases/tag/' + tag['name'];
        var header = react.a({'href': href, 'target': repo.name}, 'No release! Tag: ' + tag['name']);

        listItems.add(
          FancyListGroupItem({'header': header, 'key': 'tag-${tag['name']}'})
        );
      }

    });

    var content;
    if (listItems.length > 0) {
      content = react.div({'className': 'scrollable-pane'},
      ListGroup({}, listItems)
      );
    }
    else if (repo.dataInitialized != true) {
      content = ContentLoading({});
    }
    else {
      content = NoResultsIcon({});
    }

    return content;
  }
}
