import 'dart:math' show pow;

import 'package:flutter/material.dart'
    show BuildContext, showAboutDialog, Image, Theme;
import 'package:me_version_bible/models/translation.dart';
import 'package:me_version_bible/components/about_content.dart';
import 'package:package_info_plus/package_info_plus.dart';

int byte = pow(1024, 1).toInt();
int kilobyte = pow(1024, 2).toInt();
int megabyte = pow(1024, 3).toInt();
int gigabyte = pow(1024, 4).toInt();

String fromBytes(int bytes) {
  if (bytes < byte) return '$bytes B';
  if (bytes < kilobyte) return '${(bytes / byte).toStringAsFixed(2)} KB';
  if (bytes < megabyte) {
    return '${(bytes / kilobyte).toStringAsFixed(2)} MB';
  }
  if (bytes < gigabyte) {
    return '${(bytes / megabyte).toStringAsFixed(2)} GB';
  }
  return '${(bytes / gigabyte).toStringAsFixed(2)} TB';
}

PackageInfo? packageInfo;

void appAboutDialog(BuildContext context, Translation translation) async {
  packageInfo ??= await PackageInfo.fromPlatform();
  if (context.mounted) {
    showAboutDialog(
      context: context,
      applicationName: "Me Version Bible",
      applicationVersion: packageInfo?.version,
      applicationIcon: Image.asset("assets/icon.png", width: 64),
      children: [
        AboutContent(theme: Theme.of(context), translation: translation),
      ],
    );
  }
}
