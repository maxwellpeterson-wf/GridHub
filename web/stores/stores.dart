library gridhub.stores;

import 'dart:async';
import 'package:flux/flux.dart';

import '../actions/actions.dart';
import '../models/repo.dart';
import '../services/localStorageService.dart';

part './repos_store.dart';


class GridHubStores {

  ReposStore reposStore;

  GridHubStores(this.reposStore);
}
