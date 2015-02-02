library localStorageService;

import 'dart:html';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class RepoGridData {
    Storage localStorage = window.localStorage;

    /**
     * Authorization
     */
    get githubUsername => localStorage['githubUsername'];
    set githubUsername(String username) {
        localStorage['githubUsername'] = username;
        localStorage['githubAuthorization'] = githubUserNameAccessToken;
        this.setGithubAuthorization();
    }

    get githubAccessToken => localStorage['githubAccessToken'];
    set githubAccessToken(String accessToken) {
        localStorage['githubAccessToken'] = accessToken;
        this.setGithubAuthorization();
    }

    get githubUserNameAccessToken => githubUsername.toString() + ':' + githubAccessToken.toString();
    get githubAuthorization => localStorage['githubAuthorization'];

    setGithubAuthorization() {
        var bytes = UTF8.encode(githubUserNameAccessToken);
        var base64 = CryptoUtils.bytesToBase64(bytes);
        localStorage['githubAuthorization'] = base64;
    }

    /**
     * Repo Data
     */
    get repos => JSON.decode(localStorage['repos'] != null ? localStorage['repos'] : '[]');

    addRepo(String repoName) {
        var _repos = repos;
        _repos.add(repoName);
        localStorage['repos'] = JSON.encode(_repos);
    }

    removeRepo(String repoName) {
        var _repos = repos;
        _repos.remove(repoName);
        localStorage['repos'] = JSON.encode(_repos);
    }
}
