library Repo;

class RepoDescriptor {
  String name;
  String url;

  RepoDescriptor(String name) {
    this.name = name;
    this.url = 'https://github.com/${name}';
  }
}