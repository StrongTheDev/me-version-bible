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
  text = text.replaceAll("--", '—');
  
  final normalStyle = TextStyle(
    color: colorScheme.secondary,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );
  
  final italicStyle = TextStyle(
    color: colorScheme.onPrimaryContainer,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontFamily: "Merriweather",
    letterSpacing: 0,
  );

  final result = <TextSpan>[TextSpan(text: "   ", style: normalStyle)];
  
  int searchStart = 0;
  while (true) {
    final openIdx = text.indexOf(italicsOpenTag, searchStart);
    if (openIdx == -1) break;
    
    final closeIdx = text.indexOf(italicsCloseTag, openIdx + italicsOpenTag.length);
    if (closeIdx == -1) break;
    
    // Add text before the opening tag
    if (openIdx > searchStart) {
      result.add(TextSpan(text: text.substring(searchStart, openIdx), style: normalStyle));
    }
    
    String italicText = text.substring(openIdx + italicsOpenTag.length, closeIdx);
    
    // Add space after if next char is alphanumeric (better visibility)
    final nextCharIndex = closeIdx + italicsCloseTag.length;
    if (nextCharIndex < text.length && RegExp(r'[a-zA-Z0-9]').hasMatch(text[nextCharIndex])) {
      italicText += ' ';
    }
    
    result.add(TextSpan(text: italicText, style: italicStyle));
    
    searchStart = closeIdx + italicsCloseTag.length;
  }
  
  // Add remaining text after last closing tag, or all text if no tags found
  if (searchStart < text.length) {
    result.add(TextSpan(text: text.substring(searchStart), style: normalStyle));
  }
  
  return result;
}