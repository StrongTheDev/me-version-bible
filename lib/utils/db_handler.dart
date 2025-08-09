import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:me_version_bible/models/bible.dart';
import 'package:me_version_bible/models/setting.dart';
import 'package:me_version_bible/models/translation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? _settings;
Database? _database;
Database? get database => _database;

Future<void> openBibleDatabase(Bible bible) async {
  _database = await databaseFactory.openDatabase(bible.path);
}

Future<List<Map<String, dynamic>>> getBooks(Bible bible) async {
  return await database!.query(bible.books);
}

Future<List<Map<String, dynamic>>> getVerses(Bible bible) async {
  return await database!.query(bible.verses);
}

Future<List<Map<String, dynamic>>> getAvailableBooks(Bible bible) {
  return database!.query(
    bible.verses,
    distinct: true,
    columns: ['book_id'],
    orderBy: 'book_id',
    where: "text IS NOT ''",
  );
}

Future<List<Map<String, dynamic>>> getVerseSearch(
  Bible bible,
  String search,
) async {
  List<String> searchPieces = search.trim().replaceAll("  ", " ").split(" ");
  String whereClause = buildWhereClause("text", searchPieces);
  return await database!.query(
    bible.verses,
    where: whereClause,
    whereArgs: searchPieces.map((p) => '%$p%').toList(),
  );
}

String buildWhereClause(String column, List<String> patterns) {
  if (patterns.isEmpty) return '';

  final conditions = patterns.map((_) => "$column LIKE ?").join(' AND ');
  return conditions;
}

void loadTranslations(Bible bible) async {
  List<Map<String, dynamic>> q = await database!.query("translations");
  bible.translation = Translation.fromMap(q.first);
}

Future<Map<String, dynamic>> getDBStats(Bible bible) async {
  Map<String, dynamic> result = {};
  Database db = await databaseFactory.openDatabase(bible.path);
  try {
    var query = await db.query("translations");
    if (query.isNotEmpty) result.addAll(query.first);
    int books = (await db.query(bible.books)).length;
    int chapters = (await db.query(
      bible.verses,
      distinct: true,
      columns: ['chapter'],
    )).length;
    int size = File(bible.path).lengthSync();
    result.addAll({"books": books, "chapters": chapters, "size": size});
    // debugPrint(result.toString());
  } catch (e, stack) {
    debugPrint("Error in getDBStats: $e\n$stack");
  }
  if (db.path != database!.path) {
    await db.close();
  }
  return result;
}

/// Initializes the settings database.
/// Creates the DB file and table if they don't exist.
Future<void> initSettingsDatabase() async {
  final supportDir = await getApplicationSupportDirectory();
  final dbPath = join(supportDir.path, 'settings.db');

  _settings = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY,
            lastBiblePath TEXT,
            themeColorIndex INTEGER,
            lightTheme INTEGER,
            selection TEXT
          )
        ''');
        // Insert a default row with id=1
        await db.insert('settings', {'id': 1, ...Setting().toMap()});
      },
    ),
  );
}

/// Saves the provided [Setting] object to the database.
Future<void> saveSetting(Setting setting) async {
  if (_settings == null) await initSettingsDatabase();
  await _settings!.update(
    'settings',
    setting.toMap(),
    where: 'id = ?',
    whereArgs: [1], // We always update the row with id=1
  );
}

/// Loads the [Setting] object from the database.
Future<Setting> loadSetting() async {
  if (_settings == null) await initSettingsDatabase();
  final maps = await _settings!.query(
    'settings',
    where: 'id = ?',
    whereArgs: [1],
  );

  if (maps.isNotEmpty) {
    return Setting.fromMap(maps.first);
  }
  return Setting(); // Return default settings if not found
}
