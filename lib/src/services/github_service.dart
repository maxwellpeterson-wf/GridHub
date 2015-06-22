library gridhub.src.services.github_service;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:gridhub/src/models/repository.dart';
import 'package:gridhub/src/services/local_storage_service.dart' as localStorageService;

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
  if (state == null) {
    state = 'all';
  }
  return githubApiRequest(repo, '${type}?state=${state}&per_page=300');
}

getTags(RepoDescriptor repo) {
  return githubApiRequest(repo, 'tags');
}

getReleases(RepoDescriptor repo) {
  return githubApiRequest(repo, 'releases');
}

getCommitsSinceLastTag(RepoDescriptor repo, [List tags = null]) async {
  if (tags == null) {
    tags = await getTags(repo);
  }
  if (tags != null && tags.length > 0 && tags[0] != null) {
    var lastTag = tags[0]['name'];
    return githubApiRequest(repo, 'compare/${lastTag}...master');
  }
  else {
    return {
      'commits': []
    };
  }
}

getMilestones(RepoDescriptor repo) {
  return githubApiRequest(repo, 'milestones');
}

getCommentsForIssue(RepoDescriptor repo, int issueNumber) {
  return githubApiRequest(repo, 'issues/${issueNumber}/comments');
}
