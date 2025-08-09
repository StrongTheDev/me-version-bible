class BibleDownloadable {
  final String name;
  final String path;
  final String sha;
  final int size;
  final String url;
  final String htmlUrl;
  final String gitUrl;
  final String downloadUrl;
  final String type; // dir|file

  BibleDownloadable({
    required this.name,
    required this.path,
    required this.sha,
    required this.size,
    required this.url,
    required this.htmlUrl,
    required this.gitUrl,
    required this.downloadUrl,
    required this.type,
  });

  factory BibleDownloadable.fromJson(Map<String, dynamic> json) {
    return BibleDownloadable(
      name: json['name'],
      path: json['path'],
      sha: json['sha'],
      size: json['size'],
      url: json['url'],
      htmlUrl: json['html_url'],
      gitUrl: json['git_url'],
      downloadUrl: json['download_url'] ?? "",
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'sha': sha,
      'size': size,
      'url': url,
      'html_url': htmlUrl,
      'git_url': gitUrl,
      'download_url': downloadUrl,
      'type': type,
    };
  }
}

/* 
{
    "name": "vlsJoNT.db",
    "path": "formats/sqlite/vlsJoNT.db",
    "sha": "4f80b84e2a5c694d7aa1d0cbc3048d9bd9f3b641",
    "size": 1490944,
    "url": "https://api.github.com/repos/scrollmapper/bible_databases/contents/formats/sqlite/vlsJoNT.db?ref=master",
    "html_url": "https://github.com/scrollmapper/bible_databases/blob/master/formats/sqlite/vlsJoNT.db",
    "git_url": "https://api.github.com/repos/scrollmapper/bible_databases/git/blobs/4f80b84e2a5c694d7aa1d0cbc3048d9bd9f3b641",
    "download_url": "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/sqlite/vlsJoNT.db",
    "type": "file",
    "_links": {
      "self": "https://api.github.com/repos/scrollmapper/bible_databases/contents/formats/sqlite/vlsJoNT.db?ref=master",
      "git": "https://api.github.com/repos/scrollmapper/bible_databases/git/blobs/4f80b84e2a5c694d7aa1d0cbc3048d9bd9f3b641",
      "html": "https://github.com/scrollmapper/bible_databases/blob/master/formats/sqlite/vlsJoNT.db"
    }
  }
 */
