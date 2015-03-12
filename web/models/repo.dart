library Repo;

import 'dart:async';

import '../actions/repoActions.dart' as repoActions;
import '../services/githubService.dart' as githubService;


class RepoDescriptor {
    String name;
    String url;

    RepoDescriptor(String name) {
        this.name = name;
        this.url = 'https://github.com/${name}';
    }
}

class Repository extends RepoDescriptor {
    String readmeData;
    List tagsData;
    List releasesData;
    List issuesData;
    List pullRequestsData;
    List commitsData;
    List milestonesData;

    Repository(String name) : super(name) {
        readmeData = '';
        tagsData = [];
        releasesData = [];
        issuesData = [];
        pullRequestsData = [];
        commitsData = [];
        milestonesData = [];
    }

    Future initializeData() {
        Future readmeFuture = githubService.getReadme(this).then((responseString) {
            this.readmeData = responseString;
            repoActions.repoUpdated(this.name);
        });
        Future tagsFuture = githubService.getTags(this).then((response) {
            this.tagsData = response;
        });
        Future releasesFuture = githubService.getReleases(this).then((response){
            this.releasesData = response;
        });
        Future issuesFuture = githubService.getIssues(this, 'issues').then((response) {
            this.issuesData = response;
        });
        Future pullRequestsFuture = githubService.getIssues(this, 'pulls').then((response) {
            this.pullRequestsData = response;
        });
        Future commitsFuture = githubService.getCommitsSinceLastTag(this).then((response) {
            this.commitsData = response['commits'];
        });
        Future milestonesFuture = githubService.getMilestones(this).then((response) {
            this.milestonesData = response;
        });
        return Future.wait([readmeFuture, tagsFuture, releasesFuture, issuesFuture, pullRequestsFuture, commitsFuture]);
    }
}
