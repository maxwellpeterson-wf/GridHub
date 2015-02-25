part of grid_hub_page;

String _gitHubApiPath = 'https://api/github.com/repos/';

class GitHubApiRequest {

    Future<dynamic> _future;
    Future<dynamic> get future => _future;

    GitHubApiRequest(GridHubPageRepository repo, String path) {

        Future<dynamic> request = HttpRequest.request(_gitHubApiPath + '${repo.name}/${path}',
                                                          requestHeaders: GitHubApiRequest.headers);
        _future = request.then((HttpRequest req) {
            return JSON.decode(req.response.toString());
        });
    }

    static Map<String, String> get headers => {
        'Authorization': 'Basic ${_gitHubApi.authorization}'
    };

    static GitHubApi _gitHubApi;
    static set gitHubApi(GitHubApi api) { _gitHubApi = api; }
}