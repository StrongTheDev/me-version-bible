import 'package:flutter/material.dart';
import 'package:me_version_bible/providers/bible_provider.dart';

// ignore: must_be_immutable
class VerseCard extends StatelessWidget {
  final BibleProvider provider;

  final Map<String, dynamic> verse;
  final Color? color;
  final String? verseName;
  final void Function()? onSelect;
  final void Function()? onRightClick;

  /// Values from 0-255
  int opacity;

  final bool selected;
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
            children: convertText(verse['text'], colorScheme),
          ),
        ),
      ),
    );
  }
}

List<TextSpan> convertText(
  String text,
  ColorScheme colorScheme, {
  String italicsOpenTag = "<FI>",
  String italicsCloseTag = "<Fi>",
}) {
  TextStyle normalTextStyle = TextStyle(
    color: colorScheme.secondary,
    fontWeight: .normal,
    letterSpacing: 0,
  );
  text = text.replaceAll("--", '—');
  List<TextSpan> result = List.of([TextSpan(text: "   ")], growable: true);
  int lastOpenIndex = text.indexOf(italicsOpenTag);
  int lastCloseIndex = 0;
  int count = 0;
  while (lastOpenIndex != -1) {
    if (0 == count++) {
      result.add(
        TextSpan(
          text: text.substring(0, lastOpenIndex),
          style: normalTextStyle,
        ),
      );
    }
    lastCloseIndex = text.indexOf(italicsCloseTag, lastOpenIndex);
    result.add(
      TextSpan(
        text: "${text.substring(
          lastOpenIndex + italicsOpenTag.length,
          lastCloseIndex,
        )} ",
        style: TextStyle(
          color: colorScheme.secondaryFixed,
          fontWeight: .bold,
          fontStyle: .italic,
          fontFamily: "Merriweather",
          letterSpacing: 0,
        )
      ),
    );
    lastOpenIndex = text.indexOf(italicsOpenTag, lastCloseIndex);
    if (lastOpenIndex != -1) {
      result.add(
        TextSpan(
          text: text.substring(lastCloseIndex + italicsCloseTag.length, lastOpenIndex),
          style: normalTextStyle,
        ),
      );
    }
  }
  if (count == 0) {
    result.add(TextSpan(text: text, style: normalTextStyle));
  } else {
    result.add(
      TextSpan(
        text: text.substring(lastCloseIndex + italicsCloseTag.length),
        style: normalTextStyle,
      ),
    );
  }
  return result;
}