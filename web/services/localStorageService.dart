library localStorageService;

import 'dart:html';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class GridHubData {
    Storage localStorage = window.localStorage;

    /**
     * Authorization
     */
    get githubUsername => localStorage['githubUsername'];
    set githubUsername(String username) {
        localStorage['githubUsername'] = username;
        localStorage['githubAuthorization'] = githubUserNameAccessToken;
        setGithubAuthorization();
    }

    get githubAccessToken => localStorage['githubAccessToken'];
    set githubAccessToken(String accessToken) {
        localStorage['githubAccessToken'] = accessToken;
        setGithubAuthorization();
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
    get pages => safeJSONGet('pages');
    set pages(Map pagesObj) {
        localStorage['pages'] = JSON.encode(pagesObj);
    }

    getRepos(String pageName) {
        var repos = pages[pageName];
        if (repos == null) {
            repos = [];
        }
        return repos;
    }

    addRepo(String repoName) {
        var _repos = getRepos(currentPageName);
        _repos.add(repoName);
        var pagesData = pages;
        pagesData[currentPageName] = _repos;
        pages = pagesData;
    }

    removeRepo(String repoName) {
        var _repos = getRepos(this.currentPageName);
        _repos.remove(repoName);
        var pagesData = pages;
        pagesData[currentPageName] = _repos;
        pages = pagesData;
    }

    addPage(String pageName) {
        var pagesData = pages;
        pagesData[pageName] = [];
        pages = pagesData;
    }

    deletePage(String pageName) {
        var pagesData = pages;
        pagesData.remove(pageName);
        pages = pagesData;
        if (pageNames.length > 0) {
            currentPage = pageNames.elementAt(0);
        } else {
            currentPage = '';
        }
    }

    editPage(String pageName) {
        var pagesData = pages;
        pagesData[pageName] = pagesData[currentPageName];
        pagesData.remove(currentPageName);
        pages = pagesData;
        currentPage = pageName;
    }

    get currentPageName {
        var storedCurrentPage = localStorage['currentPageName'];
        if (storedCurrentPage != null && storedCurrentPage != '') {
            return storedCurrentPage;
        }
        return defaultPage;
    }
    set currentPage(String pageName) {
        localStorage['currentPageName'] = pageName;
    }

    get defaultPage {
        if (pages.keys.length > 1) {
            return pages.keys.elementAt(0);
        }
        return 'Default Page';
    }

    get pageNames {
        return pages.keys;
    }

    safeJSONGet(String key, [String emptyCase = '{}']) {
        return JSON.decode(localStorage[key] != null ? localStorage[key]: emptyCase);
    }
}
