import 'dart:io' show Directory, File;

import 'package:flutter/material.dart';
import 'package:me_version_bible/models/bible.dart';
import 'package:me_version_bible/models/selection.dart';
import 'package:me_version_bible/models/setting.dart';
import 'package:me_version_bible/utils/db_handler.dart';
import 'package:me_version_bible/utils/download.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

class BibleProvider extends ChangeNotifier {
  bool biblesExist = false;
  String downloadingMessage = 'Loading...';
  String _documentsDirectoryPath = '';
  String _biblesDirectoryPath = '';

  final Set<Bible> _bibles = {};
  Set<Bible> get bibles => _bibles;
  Bible? currentBible;

  List<Map<String, dynamic>> books = [];
  Setting _setting = Setting();
  Setting get setting => _setting;

  // int currentBookIndex = 0;
  Set<int> chapters = {};
  Set<int> bookIdFilters = {};
  // int currentChapterIndex = 0;
  Selection _lastSelection = Selection.at(-1, -1);
  String _lastTranslation = '';
  List<Map<String, dynamic>> _verses = [];
  List<Map<String, dynamic>> _versesCache = [];
  List<Map<String, dynamic>> get verses => _v();

  List<Map<String, dynamic>> _v() {
    var currT = currentBible!.translation;
    if (_lastSelection == setting.selection &&
        _versesCache.isNotEmpty &&
        currT != null &&
        _lastTranslation == currT.translation) {
      return _versesCache;
    }
    _lastSelection = Selection.at(
      setting.selection.bookIndex,
      setting.selection.chapterIndex,
    );
    _lastTranslation = currentBible!.translation!.translation;
    _versesCache = _verses.where((verse) {
      bool isChapter =
          verse['chapter'] ==
          chapters.elementAt(setting.selection.chapterIndex);
      bool isBook =
          verse['book_id'] == books[setting.selection.bookIndex]['id'];
      return isChapter && isBook;
    }).toList();
    return _versesCache;
  }

  final colors = [
    Colors.brown,
    Colors.red,
    Colors.deepOrange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  BibleProvider() {
    initFiles();
  }

  void initFiles() async {
    _setting = await loadSetting();
    var directory = await getApplicationSupportDirectory();
    _documentsDirectoryPath = directory.path;
    initBibles();
  }

  Future<void> initBibles() async {
    _biblesDirectoryPath = join(_documentsDirectoryPath, "bibles");
    var biblesDirectory = Directory(_biblesDirectoryPath);
    if (!biblesDirectory.existsSync()) {
      biblesDirectory.createSync(recursive: true);
    }
    _bibles.clear();
    for (var file in biblesDirectory.listSync()) {
      if (file.path.endsWith(".db")) {
        debugPrint(file.path);
        _bibles.add(Bible.fromPath(file.path));
      }
    }
    if (_bibles.isEmpty) {
      downloadingMessage = "Downloading your first Bible...";
      notifyListeners();
      await downloadBibleString(
        "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/sqlite/KJV.db",
      );
      _bibles.add(Bible.fromPath(join(_biblesDirectoryPath, "KJV.db")));
      _setting.lastBiblePath = _bibles.first.path;
    }
    biblesExist = true;
    notifyListeners();
    currentBible = _bibles.firstWhere(
      (b) => b.path == _setting.lastBiblePath,
      orElse: () => _bibles.first,
    );
    loadBible();
  }

  Future<void> selectBible(Bible bible) async {
    currentBible = bible;
    loadBible();
  }

  Future<void> selectBook(int index) async {
    _setting.selection.bookIndex = index;
    _loadChaptersAndSetIndexBounds();
    notifyListeners();
    _saveSettings();
  }

  Future<void> selectChapter(int index) async {
    _setting.selection.chapterIndex = index;
    notifyListeners();
    _saveSettings();
  }

  void toggleTheme() {
    _setting.lightTheme = !_setting.lightTheme;
    notifyListeners();
    _saveSettings();
  }

  Future<List<Map<String, dynamic>>> searchVerse(String search) async {
    return await getVerseSearch(currentBible!, search);
  }

  void deleteBible(Bible bible) {
    File(bible.path).deleteSync();
    _bibles.remove(bible);
    notifyListeners();
  }

  void setColorIndex(int colorIndex) {
    _setting.themeColorIndex = colorIndex;
    notifyListeners();
    _saveSettings();
  }

  void _saveSettings() async {
    await saveSetting(setting);
  }

  // new functions

  void loadBible() async {
    if (currentBible == null) return;
    await _getData();
    await _filterData();
    _loadChaptersAndSetIndexBounds();
    notifyListeners();
    _saveSettings();
  }

  Future<void> _getData() async {
    await openBibleDatabase(currentBible!);
    loadTranslations(currentBible!);
    _setting.lastBiblePath = currentBible!.path;
    // get books and verses
    books.clear();
    _verses.clear();
    books.addAll(await getBooks(currentBible!));
    _verses.addAll(await getVerses(currentBible!));
  }

  Future<void> _filterData() async {
    // Filter books
    bookIdFilters.clear();
    var bookFilters = await getAvailableBooks(currentBible!);
    for (var book in bookFilters) {
      bookIdFilters.add(book['book_id'] as int);
    }
    books = books.where((b) => bookIdFilters.contains(b['id'])).toList();
    // Filter verses
    _verses = _verses.where((v) => (v['text'] as String).isNotEmpty).toList();
  }

  void _loadChaptersAndSetIndexBounds() {
    // set book index
    if (_setting.selection.bookIndex >= books.length) {
      _setting.selection.bookIndex = books.length - 1;
    }
    // load chapters
    chapters.clear();
    int currentBook = books[setting.selection.bookIndex]['id'];
    for (var verse in _verses) {
      if (verse['book_id'] != currentBook) continue;
      chapters.add(verse['chapter'] as int);
    }
    // set chapter index
    if (_setting.selection.chapterIndex >= chapters.length) {
      _setting.selection.chapterIndex = chapters.length - 1;
    }
  }
}
