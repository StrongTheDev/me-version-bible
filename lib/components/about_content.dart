import 'package:flutter/material.dart';
import 'package:me_version_bible/models/translation.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({
    super.key,
    required this.theme,
    required this.translation,
  });

  final ThemeData theme;
  final Translation translation;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: FontWeight.bold),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Bible", style: TextStyle(fontSize: 24)),
            Divider(height: 2, thickness: 2),
            Row(
              children: [
                Text(
                  "Translation: ",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                Text(translation.translation),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title: ",
                  softWrap: true,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                Expanded(child: Text(translation.title, softWrap: true)),
              ],
            ),
            Row(
              children: [
                Text(
                  "License: ",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                Text(translation.license),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
