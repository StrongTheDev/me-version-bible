// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class StatisticRow extends StatelessWidget {
  const StatisticRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        trailing ?? SizedBox(),
      ],
    );
  }
}
