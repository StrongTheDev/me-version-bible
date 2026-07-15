import 'package:flutter/material.dart';
import 'package:me_version_bible/components/sidebar/pages/bible_plans.dart';
import 'package:me_version_bible/components/sidebar/pages/book_picker.dart';
import 'package:me_version_bible/components/sidebar/pages/bookmarked_verses.dart';
import 'package:me_version_bible/components/sidebar/pages/user_notes.dart';
import 'package:me_version_bible/components/sidebar/pages/verse_clipboard.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SideBar extends StatelessWidget {
  final double width;
  final int selectedBookIndex;
  final ItemScrollController? bookPickerScrollController;
  final ItemPositionsListener? bookPickerPositionsListener;

  const SideBar({
    super.key,
    required this.width,
    required this.selectedBookIndex,
    this.bookPickerScrollController,
    this.bookPickerPositionsListener
  });

  @override
  Widget build(BuildContext context) {
    BibleProvider provider = Provider.of<BibleProvider>(context);
    final pages = [
      {
        "name": "Books",
        "icon": Icons.import_contacts,
        "content": BookPicker(
          books: provider.books,
          controller: bookPickerScrollController,
          positionsListener: bookPickerPositionsListener,
        ),
      },
      {"name": "Saved", "icon": Icons.bookmark, "content": BookmarkedVerses()},
      {"name": "Notes", "icon": Icons.note_alt, "content": UserNotes()},
      {"name": "Plans", "icon": Icons.calendar_month, "content": BiblePlans()},
      {"name": "Clip", "icon": Icons.paste, "content": VerseClipboard()},
    ];
    return AnimatedSize(
      duration: Durations.medium1,
      reverseDuration: Duration.zero,
      child: DefaultTabController(
        length: pages.length,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              TabBar(
                tabs: pages
                    .map(
                      (page) => Column(
                        crossAxisAlignment: .center,
                        children: [
                          Icon(page['icon'] as IconData),
                          Text(
                            page['name'] as String,
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                isScrollable: true,
                indicatorAnimation: .elastic,
                tabAlignment: .start,
                physics: BouncingScrollPhysics(),
              ),
              SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: pages
                      .map((page) => page['content'] as Widget)
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
