import 'package:http/http.dart' as http;
import 'package:me_version_bible/models/bible_downloadable.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> downloadBible(BibleDownloadable bible) async {
  return await downloadBibleString(bible.downloadUrl);
}

Future<Future<File>> downloadBibleString(String url) async {
  final response = await http.get(Uri.parse(url));
  final filename = url.split("/").last;
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}$separator/bibles/$filename');
  return file.writeAsBytes(response.bodyBytes);
}
