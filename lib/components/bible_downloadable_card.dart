// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:me_version_bible/models/bible_downloadable.dart';
import 'package:me_version_bible/components/statistic_row.dart';
import 'package:me_version_bible/providers/versions_provider.dart';
import 'package:me_version_bible/utils/functions.dart' show fromBytes;
import 'package:provider/provider.dart';

class BibleDownloadableCard extends StatefulWidget {
  const BibleDownloadableCard({
    super.key,
    required this.data,
    required this.downloaded,
  });

  final BibleDownloadable data;
  final bool downloaded;

  @override
  State<BibleDownloadableCard> createState() => _BibleDownloadableCardState();
}

class _BibleDownloadableCardState extends State<BibleDownloadableCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    var valueStyle = TextStyle(fontStyle: FontStyle.italic);
    var provider = Provider.of<BibleVersionsProvider>(context);

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
                  Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 24),
                      Text(
                        widget.data.name.replaceAll(".db", ""),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (!expanded)
                        Text(
                          "(${fromBytes(widget.data.size)})",
                          style: valueStyle,
                        ),
                    ],
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      if (widget.downloaded)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              spacing: 4,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_download_done_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Downloaded',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!widget.downloaded)
                        TextButton.icon(
                          onPressed: provider.isDownloading(widget.data.name)
                              ? null
                              : () {
                                  provider.queueDownload(widget.data);
                                },
                          label: Text("Download"),
                          icon: Icon(Icons.file_download_outlined),
                        ),
                      if (provider.isDownloading(widget.data.name))
                        SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(),
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
                ],
              ),
              AnimatedContainer(
                duration: Durations.short2,
                height: expanded ? 90 : 0,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Column(
                  children: [
                    Divider(thickness: 2, color: scheme.secondaryContainer),
                    StatisticRow(
                      icon: Icons.folder_open_rounded,
                      label: 'Path',
                      value: widget.data.path,
                    ),
                    StatisticRow(
                      icon: Icons.storage_rounded,
                      label: 'Size',
                      value: fromBytes(widget.data.size),
                    ),
                    StatisticRow(
                      icon: Icons.tag_rounded,
                      label: 'SHA',
                      value: widget.data.sha,
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
