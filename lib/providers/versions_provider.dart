import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:me_version_bible/models/bible.dart';
import 'package:me_version_bible/models/bible_downloadable.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/utils/constants.dart';
import 'package:me_version_bible/utils/db_handler.dart';
import 'package:me_version_bible/utils/download.dart';
import 'package:path/path.dart';

class BibleVersionsProvider extends ChangeNotifier {
  final BibleProvider _bibleProvider;
  List<BibleDownloadable>? _downloads;
  bool reloading = false;
  final url = "$githubAPI/$githubRepo/contents/formats/sqlite";

  bool sorted = false;
  bool hideDownloaded = true;

  String _filterString = "";
  final Set<String> _downloading = {};
  BibleVersionsProvider(this._bibleProvider) {
    reload();
  }

  List<BibleDownloadable>? get downloads => _downloads
      ?.where((b) => !hideDownloaded || !isDownloaded(b.name))
      .where(
        (b) =>
            _filterString.isEmpty ||
            b.name.toLowerCase().contains(_filterString) ||
            b.sha.toLowerCase().contains(_filterString),
      )
      .toList();

  bool get downloadsAvailable => _downloads != null && _downloads!.isNotEmpty;

  Set<Bible> get existingBibles => _bibleProvider.bibles;

  Future<bool> checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void filterWith(String value) {
    _filterString = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getStats(Bible bible) async {
    return await getDBStats(bible);
  }

  bool isDownloaded(String name) {
    return existingBibles
        .where((s) => s.path.contains("$separator$name"))
        .isNotEmpty;
  }

  bool isDownloading(String name) {
    return _downloading.contains(name);
  }

  void queueDownload(BibleDownloadable bible) async {
    _downloading.add(bible.name);
    notifyListeners();
    await downloadBible(bible);
    _downloading.remove(bible.name);
    _bibleProvider.initBibles();
    notifyListeners();
  }

  void reload() async {
    reloading = true;
    notifyListeners();

    var data = await http.get(Uri.parse(url));
    try {
      List<dynamic> body = jsonDecode(data.body);
      _downloads = body.map((e) {
        return BibleDownloadable.fromJson(e);
      }).toList();
      _downloads?.sort((a, b) {
        var aDownloaded = isDownloaded(a.name);
        var bDownloaded = isDownloaded(b.name);
        if (aDownloaded && !bDownloaded) return -1;
        if (aDownloaded && bDownloaded) return 0;
        return 1;
      });
    } catch (e) {
      _downloads = null;
    }
    reloading = false;
    notifyListeners();
  }

  void setHideDownloaded(bool v) {
    hideDownloaded = v;
    notifyListeners();
  }
}
