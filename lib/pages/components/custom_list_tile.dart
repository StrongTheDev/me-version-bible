import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomListTile extends StatelessWidget {
  CustomListTile({
    super.key,
    required this.text,
    required this.selected,
    this.onTap,
    this.style,
  });

  final String text;
  final bool selected;
  final TextStyle? style;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      child: ListTile(
        style: ListTileStyle.list,
        title: Text(text, style: style),
        selected: selected,
        selectedColor: Theme.of(context).colorScheme.surface,
        selectedTileColor: Theme.of(context).colorScheme.secondary,
        onTap: onTap,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
