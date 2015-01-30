library localStorageService;

import 'dart:html';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class RepoGridData {
    Storage localStorage = window.localStorage;

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
}
