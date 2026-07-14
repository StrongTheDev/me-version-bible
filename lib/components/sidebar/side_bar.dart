import 'package:flutter/material.dart';
import 'package:me_version_bible/components/sidebar/pages/book_picker.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  final double width;
  final int selectedBookIndex;

  const SideBar({
    super.key,
    required this.width,
    required this.selectedBookIndex,
  });

  @override
  Widget build(BuildContext context) {
    BibleProvider provider = Provider.of<BibleProvider>(context);
    final pages = [
      {
        "name": "Books",
        "icon": Icons.book,
        "content": BookPicker(
          provider: provider,
          selectedBookIndex: selectedBookIndex,
        ),
      },
      {
        "name": "Saved",
        "icon": Icons.bookmark,
        "content": BookPicker(
          provider: provider,
          selectedBookIndex: selectedBookIndex,
        ),
      },
      {
        "name": "Notes",
        "icon": Icons.next_plan,
        "content": BookPicker(
          provider: provider,
          selectedBookIndex: selectedBookIndex,
        ),
      },
      {
        "name": "Plans",
        "icon": Icons.calendar_month,
        "content": BookPicker(
          provider: provider,
          selectedBookIndex: selectedBookIndex,
        ),
      },
      {
        "name": "Clip",
        "icon": Icons.paste,
        "content": BookPicker(
          provider: provider,
          selectedBookIndex: selectedBookIndex,
        ),
      },
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
                          Text(page['name'] as String, style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    )
                    .toList(),
                isScrollable: true,
                indicatorAnimation: .elastic,
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
