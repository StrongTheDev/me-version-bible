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
    this.onSelect,
    this.onRightClick,
    this.selected = false,
  });

  final BibleProvider provider;
  final Map<String, dynamic> verse;
  final Color? color;
  final String? verseName;
  final void Function()? onSelect;
  final void Function()? onRightClick;

  /// Values from 0-255
  int opacity;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    opacity = (opacity + (selected ? 20 : 0)).clamp(0, 255);
    var colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onSelect,
      onLongPress: onRightClick,
      onSecondaryTap: onRightClick,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color:
              color ?? Theme.of(context).colorScheme.primary.withAlpha(opacity),
          borderRadius: BorderRadius.circular(4),
          border: BoxBorder.all(
            width: 1,
            color: selected ? colorScheme.inversePrimary : Colors.transparent,
          ),
        ),
        child: RichText(
          text: TextSpan(
            text: verseName ?? provider.verseIDString(verse),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: "Merriweather",
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: "   ${verse['text']}",
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
