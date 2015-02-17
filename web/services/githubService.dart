library githubService;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../models/repo.dart';
import '../services/localStorageService.dart' as localStorageService;


var storage = new localStorageService.RepoGridData();
var authorization = storage.githubAuthorization;
var headers = {
    'Authorization': 'Basic ${authorization}'
};


githubApiRequest(RepoDescriptor repo, String path) {
    Future<HttpRequest> request = HttpRequest.request(
        'https://api.github.com/repos/${repo.name}/${path}', requestHeaders: headers
    );

    return request.then((HttpRequest req) {
        return JSON.decode(req.response.toString());
    });
}

getReadme(RepoDescriptor repo) {
    var readmeHeaders = new Map.from(headers);
    readmeHeaders['Accept'] = 'application/vnd.github.v3.html';

    Future<HttpRequest> request = HttpRequest.request(
        'https://api.github.com/repos/${repo.name}/readme', requestHeaders: readmeHeaders
    );
    return request.then((HttpRequest req) {
        return req.response.toString();
    });
}

getIssues(RepoDescriptor repo, String type, [String state = null]) {
    var stateString = '';
    if (state != null) {
        stateString = '?state=${state}';
    }
    return githubApiRequest(repo, '${type}${stateString}');
}

getTags(RepoDescriptor repo) {
    return githubApiRequest(repo, 'tags');
}

getReleases(RepoDescriptor repo) {
    return githubApiRequest(repo, 'releases');
}

getCommitsSinceLastTag(RepoDescriptor repo) {
    return getTags(repo).then((tags) {
        if (tags != null && tags.length > 0 && tags[0] != null) {
            var lastTag = tags[0]['name'];
            return githubApiRequest(repo, 'compare/${lastTag}...master');
        }
        else {
            print("NO TAGS!");
            return [];
        }
    });
}
