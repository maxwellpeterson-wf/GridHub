import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;

import 'components/GridHubApp.dart' show GridHubApp;

import 'models/repo.dart';


void main() {
    reactClient.setClientConfiguration();

    var repos = [
          new RepoDescriptor('maxwellpeterson-wf/GridHub'),
          new RepoDescriptor('Workiva/wSession'),
          new RepoDescriptor('Workiva/wSessionUI'),
          new RepoDescriptor('Workiva/wTransport'),
          new RepoDescriptor('Workiva/wService'),
          new RepoDescriptor('Workiva/wAuth'),
          new RepoDescriptor('Workiva/wSessionContext'),
          new RepoDescriptor('Workiva/wGulp'),
          new RepoDescriptor('Workiva/karma-jspm'),
          new RepoDescriptor('Workiva/web-skin-react'),
      ];

    react.render(GridHubApp({'repos': repos}), querySelector('#app-container'));
}
