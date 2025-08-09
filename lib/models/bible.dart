import 'package:me_version_bible/models/translation.dart';
import 'package:path/path.dart' show separator;

class Bible {
  final String name;
  final String path;
  Translation? translation;
  String get books => "${name}_books";
  String get verses => "${name}_verses";

  Bible({required this.name, required this.path});

  factory Bible.fromPath(String path) {
    var name = path.split(separator).last.split(".").first;
    return Bible(name: name, path: path);
  }
}
