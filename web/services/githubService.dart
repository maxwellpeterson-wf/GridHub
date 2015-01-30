library githubService;

import 'dart:convert';
import 'dart:html';

import '../models/repo.dart';
import '../services/localStorageService.dart' as localStorageService;


var storage = new localStorageService.RepoGridData();

githubApiRequest(RepoDescriptor repo, String path, Function callback, [json=true]) {
    var authorization = storage.githubAuthorization;
    var request = new HttpRequest();
    request.open('GET', 'https://api.github.com/repos/${repo.name}/${path}');
    request.setRequestHeader('Authorization', 'Basic ${authorization}');
    if (json) {
        request.onLoad.listen(wrapJsonCallback(callback));
    } else {
        request.onLoad.listen(wrapCallback(callback));
    }
    return request;
}


getReadme(RepoDescriptor repo, callback) {
    HttpRequest request = githubApiRequest(repo, 'readme', callback, false);
    request.setRequestHeader('Accept', 'application/vnd.github.v3.html');
    request.send();
}

getIssues(RepoDescriptor repo, String type, String state, Function callback) {
    HttpRequest request = githubApiRequest(repo, '${type}?state=${state}', callback);
    request.send();
}

getTags(RepoDescriptor repo, Function callback) {
    HttpRequest request = githubApiRequest(repo, 'tags', callback);
    request.send();
}

getReleases(RepoDescriptor repo, Function callback) {
    HttpRequest request = githubApiRequest(repo, 'releases', callback);
    request.send();
}

getCommitsSinceLastTag(RepoDescriptor repo, Function callback) {
    getTags(repo, (tags) {
        if (tags != null && tags.length > 0 && tags[0] != null) {
            var lastTag = tags[0]['name'];
            HttpRequest request = githubApiRequest(repo, 'compare/${lastTag}...master', callback);
            request.send();
        }
        else {
            print("NO TAGS!");
        }
    });
}

wrapJsonCallback(Function callback) {
    return (event) {
        if (event.target.status > 299) {
            callback(null);
        } else {
            Map parsedResponse = JSON.decode(event.target.responseText);
            callback(parsedResponse);
        }

    };
}

wrapCallback(Function callback) {
    return (event) {
        callback(event.target.responseText);
    };
}
