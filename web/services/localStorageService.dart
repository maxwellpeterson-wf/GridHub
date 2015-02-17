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
    get pages => this.safeJSONGet('pages');
    set pages(Map pagesObj) {
        localStorage['pages'] = JSON.encode(pagesObj);
    }

    getRepos(String pageName) {
        var repos = this.pages[pageName];
        if (repos == null) {
            repos = [];
        }
        return repos;
    }

    addRepo(String repoName) {
        var _repos = this.getRepos(this.currentPage);
        _repos.add(repoName);
        var pagesData = this.pages;
        pagesData[this.currentPage] = _repos;
        this.pages = pagesData;
    }

    removeRepo(String repoName) {
        var _repos = this.getRepos(this.currentPage);
        _repos.remove(repoName);
        var pagesData = this.pages;
        pagesData[this.currentPage] = _repos;
        this.pages = pagesData;
    }

    addPage(String pageName) {
        var pagesData = this.pages;
        pagesData[pageName] = [];
        this.pages = pagesData;
    }

    get currentPage {
        var storedCurrentPage = localStorage['currentPage'];
        if (storedCurrentPage != null) {
            return storedCurrentPage;
        }
        return this.defaultPage;
    }
    set currentPage(String pageName) {
        localStorage['currentPage'] = pageName;
    }

    get defaultPage {
        var storedDefaultPage = localStorage['defaultPage'];
        if (storedDefaultPage != null) {
            return storedDefaultPage;
        }
        return 'default';
    }
    set defaultPage(String pageName) {
        localStorage['defaultPage'] = pageName;
    }

    get pageNames {
        return this.pages.keys;
    }

    safeJSONGet(String key, [String emptyCase = '{}']) {
        return JSON.decode(localStorage[key] != null ? localStorage[key]: emptyCase);
    }
}
