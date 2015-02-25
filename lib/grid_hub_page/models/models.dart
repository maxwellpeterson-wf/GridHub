part of grid_hub_page;

class Repository {
    String _name;
    String get name => _name;

    String get url => 'https://github.com/${name}';

    String _readmeData;
    String get readmeData => _readmeData;

    List<Map> _tagsData;
    List<Map> get tagsData => _tagsData;

    List<Map> _releasesData;
    List<Map> get releasesData => _releasesData;

    List<Map> _issuesData;
    List<Map> get issuesData => _issuesData;

    List<Map> _pullRequestsData;
    List<Map> get pullRequestsData => _pullRequestsData;

    List<Map> _commitsSinceLastTagData;
    List<Map> get commitsSinceLastTagData => _commitsSinceLastTagData;

    Repository(this._name) {
        _readmeData = '';
        _tagsData = [];
        _releasesData = [];
        _issuesData = [];
        _pullRequestsData = [];
        _commitsSinceLastTagData = [];
    }

    Future getReadme() {
        Map<String, String> readmeHeaders = new Map.from(GitHubApiRequest.headers);
        readmeHeaders['Accept'] = 'application/vnd.github.v3.html';

        Future<HttpRequest> request = HttpRequest.request(
            'https://api.github.com/repos/${name}/readme', requestHeaders: readmeHeaders
        );
        return request.then((HttpRequest req) {
            _readmeData = req.response.toString();
            return _readmeData;
        });
    }

    Future getTags() {
        return new GitHubApiRequest(this, 'tags').future.then((List<Map> tagsData) {
            _tagsData = tagsData;
            return _tagsData;
        });
    }

    Future getReleases() {
        return new GitHubApiRequest(this, 'releases').future.then((List<Map> releasesData) {
            _releasesData = releasesData;
            return _releasesData;
        });
    }

    Future getIssues() {
        return new GitHubApiRequest(this, 'issues?state=all').future.then((List<Map> issuesData) {
            _issuesData = issuesData;
            return _issuesData;
        });
    }

    Future getPullRequests() {
        return new GitHubApiRequest(this, 'pulls?state=all').future.then((List<Map> pullRequestsData) {
            _pullRequestsData = pullRequestsData;
            return _pullRequestsData;
        });
    }

    Future getCommitsSinceLastTag() {
        return getTags().then((List<Map> tags) {
            if (tags != null && tags.length > 0 && tags[0] != null) {
                String lastTag = tags[0]['name'];
                Future comparison = new GitHubApiRequest(this, 'compare/${lastTag}...master').future;
                return comparison.then((Map<String, dynamic> response) {
                    _commitsSinceLastTagData = response['commits'];
                    return _commitsSinceLastTagData;
                });
            } else {
                _commitsSinceLastTagData = [];
                return _commitsSinceLastTagData;
            }
        });
    }

}