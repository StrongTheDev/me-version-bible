// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:me_version_bible/models/bible.dart';
import 'package:me_version_bible/pages/components/statistic_row.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/utils/functions.dart';
import 'package:provider/provider.dart' show Provider;

class BibleCard extends StatefulWidget {
  const BibleCard({super.key, required this.bible, required this.stats});

  final Bible bible;
  final Map<String, dynamic> stats;

  @override
  State<BibleCard> createState() => _BibleCardState();
}

class _BibleCardState extends State<BibleCard> {
  bool expanded = false;
  late BibleProvider bibleProvider;

  void deleteBible() {
    if (bibleProvider.bibles.length == 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Oops!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You must have at least one Bible"),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Text("I Understand"),
                icon: Icon(Icons.check),
              ),
            ],
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 210,
        child: Column(
          spacing: 16,
          children: [
            Text(
              widget.bible.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Are you sure you want to delete this bible?"),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    bibleProvider.deleteBible(widget.bible);
                  },
                  icon: Icon(Icons.delete_forever_outlined),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  label: Text("Delete"),
                ),
              ],
            ),
            Text(
              "(${fromBytes(widget.stats['size'] ?? 0)})",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    var valueStyle = TextStyle(fontStyle: FontStyle.italic);
    bibleProvider = Provider.of<BibleProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withAlpha(96),
          borderRadius: BorderRadius.circular(8),
          border: BoxBorder.all(width: 1, color: scheme.secondaryContainer),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      spacing: 4,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 24),
                        Text(
                          widget.bible.name.replaceAll(".db", ""),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (!expanded)
                          Expanded(
                            child: Text(
                              "(${widget.stats['title']})",
                              style: valueStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!expanded)
                    IconButton(
                      onPressed: () {
                        deleteBible();
                      },
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() => expanded = !expanded);
                    },
                    icon: AnimatedRotation(
                      turns: !expanded ? 0 : 0.5,
                      duration: Durations.short4,
                      child: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: Durations.short4,
                constraints: expanded
                    ? BoxConstraints(maxHeight: 800, minHeight: 100)
                    : BoxConstraints(maxHeight: 0, minHeight: 0),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(thickness: 2, color: scheme.secondaryContainer),
                    StatisticRow(
                      icon: Icons.book_outlined,
                      label: 'Title',
                      value: widget.stats['title'].toString(),
                    ),
                    StatisticRow(
                      icon: Icons.storage_rounded,
                      label: 'Translation',
                      value: widget.stats['translation'].toString(),
                    ),
                    StatisticRow(
                      icon: Icons.work_outline_rounded,
                      label: 'License',
                      value: widget.stats['license'].toString(),
                    ),
                    StatisticRow(
                      icon: Icons.tag_rounded,
                      label: 'Number of books',
                      value: widget.stats['books'].toString(),
                    ),
                    StatisticRow(
                      icon: Icons.tag_rounded,
                      label: 'Number of chapters',
                      value: widget.stats['chapters'].toString(),
                    ),
                    StatisticRow(
                      icon: Icons.folder_open_rounded,
                      label: 'Path',
                      value: widget.bible.path,
                    ),
                    Divider(thickness: 2, color: scheme.secondaryContainer),
                    Row(
                      spacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            deleteBible();
                          },
                          label: Text("Delete"),
                          icon: Icon(Icons.delete_forever_outlined),
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.red),
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          "(${fromBytes(widget.stats['size'] ?? 0)})",
                          style: valueStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
