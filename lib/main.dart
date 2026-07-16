import 'dart:io';

import 'package:flutter/material.dart';
import 'package:me_version_bible/pages/home.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/providers/home_provider.dart';
import 'package:me_version_bible/providers/versions_provider.dart';
import 'package:me_version_bible/utils/constants.dart' show appColors;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    databaseFactory = databaseFactoryFfi;
  }

  // await initFiles();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider(context)),
        ChangeNotifierProvider(create: (context) => BibleProvider()),
        ChangeNotifierProvider(
          create: (context) {
            var b = Provider.of<BibleProvider>(context);
            BibleVersionsProvider(b);
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BibleProvider>(context);
    return MaterialApp(
      home: Home(),
      theme: ThemeData(
        colorSchemeSeed: appColors[provider.setting.themeColorIndex],
        brightness: provider.setting.lightTheme
            ? Brightness.light
            : Brightness.dark,
        useMaterial3: true,
        listTileTheme: ListTileThemeData(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        fontFamily: "Merriweather",
      ),
      // debugShowCheckedModeBanner: false,
    );
  }
}
