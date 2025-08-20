import 'package:flutter/material.dart';
import 'package:me_version_bible/providers/bible_provider.dart';

// ignore: must_be_immutable
class VerseCard extends StatelessWidget {
  VerseCard({
    super.key,
    required this.provider,
    required this.verse,
    this.color,
    this.verseName,
    this.opacity = 10,
  });

  final BibleProvider provider;
  final Map<String, dynamic> verse;
  final Color? color;
  final String? verseName;

  /// Values from 0-255
  int opacity;

  @override
  Widget build(BuildContext context) {
    opacity = opacity.clamp(0, 255);
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            color ?? Theme.of(context).colorScheme.primary.withAlpha(opacity),
        borderRadius: BorderRadius.circular(4),
      ),
      child: RichText(
        text: TextSpan(
          text:
              verseName ??
              "${provider.books.firstWhere((b) => b['id'] == verse['book_id'])['name']} ${verse['chapter']}:${verse['verse']}",
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: "Merriweather",
          ),
          children: [
            TextSpan(
              text: "   ${verse['text']}",
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
