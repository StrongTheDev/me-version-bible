import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomListTile extends StatelessWidget {
  CustomListTile({
    super.key,
    required this.text,
    required this.selected,
    this.width,
    this.height,
    this.onTap,
    this.padding,
    this.style = const TextStyle(),
    this.borderRadius = 4,
  });

  final String text;
  final bool selected;
  final TextStyle style;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width;
  final double? height;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        clipBehavior: Clip.hardEdge,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.surface,
          ),
          padding: padding,
          child: Center(
            child: Text(
              text,
              style: style.copyWith(
                color: selected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
