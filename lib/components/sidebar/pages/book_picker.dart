import 'package:flutter/material.dart';
import 'package:me_version_bible/components/custom_list_tile.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

Widget titleColumn(String title, Color bgColor) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const .symmetric(horizontal: 24),
        child: Container(
          padding: .all(8),
          decoration: BoxDecoration(
            color: bgColor.withAlpha(120),
            borderRadius: .circular(8),
          ),
          child: Row(
            mainAxisAlignment: .center,
            children: [Text(title, style: TextStyle(fontSize: 12))],
          ),
        ),
      ),
      const SizedBox(height: 8),
    ],
  );
}

class BookListItem extends StatelessWidget {
  final int idx;

  final Map<String, dynamic> book;
  final int chapterCount;
  final void Function() onTap;
  const BookListItem({
    super.key,
    required this.idx,
    required this.book,
    required this.onTap,
    required this.chapterCount,
  });

  @override
  Widget build(BuildContext context) {
    final bookName = book["name"].toString();
    final bookNameLower = bookName.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (idx == 0)
          titleColumn("OLD TESTAMENT", colorScheme.tertiaryContainer)
        else if (bookNameLower == "matthew")
          titleColumn("NEW TESTAMENT", colorScheme.tertiaryContainer),

        // Only this rebuilds when selection changes
        Selector<BibleProvider, int?>(
          selector: (_, p) => p.setting.selection.bookIndex,
          builder: (ctx, selectedBookIndex, _) {
            final isBookSelected = selectedBookIndex == idx;
            double radius = 32;
            return GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: isBookSelected
                      ? colorScheme.secondaryContainer.withAlpha(120)
                      : colorScheme.secondaryContainer.withAlpha(40),
                  borderRadius: .circular(radius),
                  border: Border.all(
                    color: isBookSelected
                        ? colorScheme.secondaryContainer
                        : Colors.transparent,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      bookName,
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    Text(
                      chapterCount.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        Selector<BibleProvider, bool>(
          selector: (_, p) => p.setting.selection.bookIndex == idx,
          builder: (ctx, isBookSelected, _) {
            if (!isBookSelected) return const SizedBox();
            return ChapterGrid(
              chapterCount: chapterCount,
              colorScheme: colorScheme,
            );
          },
        ),
      ],
    );
  }
}

class BookPicker extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final ItemScrollController? controller;
  final ItemPositionsListener? positionsListener;

  const BookPicker({
    super.key,
    required this.books,
    this.controller,
    this.positionsListener,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<BibleProvider, (Map<String, Map<String, dynamic>>,)>(
      selector: (_, p) => (p.bookStatistics,),
      builder: (context, data, _) {
        final (chCount,) = data;
        final provider = context.read<BibleProvider>();

        return ScrollablePositionedList.builder(
          itemCount: books.length,
          physics: const ClampingScrollPhysics(),
          itemScrollController: controller,
          itemPositionsListener: positionsListener,
          itemBuilder: (ctx, idx) {
            final book = books[idx];
            return BookListItem(
              idx: idx,
              book: book,
              chapterCount: chCount[book['name']]?['chapter_count'],
              onTap: () async {
                provider.selectBook(idx);
                await Future.delayed(Durations.short1);
                controller?.scrollTo(
                  index: idx,
                  duration: Durations.medium1,
                  alignment: 0.1,
                  curve: Curves.easeOut
                );
              },
            );
          },
        );
      },
    );
  }
}

class ChapterGrid extends StatelessWidget {
  final int chapterCount;

  final ColorScheme colorScheme;
  const ChapterGrid({
    super.key,
    required this.chapterCount,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.secondaryContainer),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.secondaryContainer.withAlpha(120),
              ],
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: Selector<BibleProvider, int?>(
            selector: (_, p) => p.setting.selection.chapterIndex,
            builder: (ctx, chIndex, _) {
              return Selector<BibleProvider, void Function(int)>(
                selector: (_, p) => p.selectChapter,
                builder: (c, fnSelectChapter, _) {
                  return GridView.builder(
                    itemCount: chapterCount,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    // spacing: 8,
                    // runSpacing: 8,
                    itemBuilder: (c, index) {
                      return SizedBox(
                        width: 32,
                        height: 32,
                        child: CustomListTile(
                          text: (index + 1).toString(),
                          selected: chIndex == index,
                          borderRadius: 8,
                          onTap: () => fnSelectChapter(index),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
