import 'package:flutter/material.dart';
import 'package:me_version_bible/components/custom_list_tile.dart';
import 'package:me_version_bible/providers/bible_provider.dart';

class BookPicker extends StatelessWidget {
  final BibleProvider provider;
  final int selectedBookIndex;

  const BookPicker({
    super.key,
    required this.provider,
    required this.selectedBookIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: provider.books.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (ctx, idx) {
        var bookName = provider.books[idx]["name"].toString();
        var isBookSelected = selectedBookIndex == idx;
        var colorScheme = Theme.of(ctx).colorScheme;
        return Column(
          children: [
            if (bookName.toLowerCase() == "matthew")
              Column(
                mainAxisSize: .min,
                children: [
                  Divider(
                    height: 4,
                    thickness: 4,
                    indent: 16,
                    endIndent: 16,
                    radius: .circular(8),
                    color: colorScheme.secondaryContainer,
                  ),
                  SizedBox(height: 8),
                ],
              ),

            if (idx == 0)
              titleColumn("OLD TESTAMENT")
            else if (bookName.toLowerCase() == "matthew")
              titleColumn("NEW TESTAMENT"),

            ElevatedButton(
              onPressed: () {
                provider.selectBook(idx);
              },
              style: isBookSelected
                  ? ButtonStyle(
                      side: .all(
                        BorderSide(color: colorScheme.secondaryContainer),
                      ),
                    )
                  : null,
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(bookName),
                  Text(
                    provider.bookStatistics
                        .firstWhere(
                          (s) => s['book_name'] == bookName,
                        )['chapter_count']
                        .toString(),
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            if (isBookSelected)
              Column(
                mainAxisSize: .min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: .circular(8),
                      border: .all(color: colorScheme.secondaryContainer),
                      gradient: LinearGradient(
                        begin: .bottomCenter, end: .topCenter,
                        colors: [colorScheme.secondaryContainer, colorScheme.secondaryContainer.withAlpha(120)]
                      ),
                    ),
                    width: .infinity,
                    padding: .all(8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(provider.chapters.length, (
                        index,
                      ) {
                        return CustomListTile(
                          text: provider.chapters.elementAt(index).toString(),
                          selected:
                              provider.setting.selection.chapterIndex == index,
                          width: 32,
                          height: 32,
                          borderRadius: 8,
                          onTap: () {
                            provider.selectChapter(index);
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
          ],
        );
      },
    );
  }

  Column titleColumn(String title) {
    return Column(
      mainAxisSize: .min,
      children: [
        Row(mainAxisAlignment: .center, children: [Text(title, style: TextStyle(fontSize: 12),)]),
        SizedBox(height: 8),
      ],
    );
  }
}
