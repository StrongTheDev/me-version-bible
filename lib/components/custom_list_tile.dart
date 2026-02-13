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
    var styleVar = style ?? TextStyle();
    return GestureDetector(
      onTap: onTap,
      child: Material(
        clipBehavior: Clip.hardEdge,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        child: Container(
          // height: 32,
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.surface,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            text,
            style: styleVar.copyWith(
              color: selected
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
