import 'package:me_version_bible/models/selection.dart';

class Setting {
  String lastBiblePath = 'undefined';
  int themeColorIndex = 0;
  bool lightTheme = true;
  Selection selection = Selection();

  Setting();

  /// Converts this [Setting] instance to a [Map] for database storage.
  Map<String, dynamic> toMap() {
    return {
      'lastBiblePath': lastBiblePath,
      'themeColorIndex': themeColorIndex,
      'lightTheme': lightTheme ? 1 : 0, // Store bool as an integer (1 or 0)
      'selection': selection.toString(), // Store Selection as a String
    };
  }

  /// Creates a [Setting] instance from a [Map] from the database.
  factory Setting.fromMap(Map<String, dynamic> map) {
    final setting = Setting();
    setting.lastBiblePath = map['lastBiblePath'] as String? ?? 'undefined';
    setting.themeColorIndex = map['themeColorIndex'] as int? ?? 0;
    // Convert integer back to bool, defaulting to true (1) if null.
    setting.lightTheme = (map['lightTheme'] as int? ?? 1) == 1;
    if (map['selection'] != null) {
      // Safely parse the selection string.
      try {
        setting.selection = Selection.fromString(map['selection'] as String);
      } catch (e) { /* Use default selection on error */ }
    }
    return setting;
  }
}
