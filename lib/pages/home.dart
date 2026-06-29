import 'package:flutter/material.dart';
import 'package:me_version_bible/models/selection.dart';
import 'package:me_version_bible/components/custom_drawer.dart';
import 'package:me_version_bible/components/custom_list_tile.dart';
import 'package:me_version_bible/components/verse_card.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/utils/functions.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SearchController _searchController = SearchController();
  // scrollers
  final ScrollController _scrollBook = ScrollController();
  final ScrollController _scrollVerse = ScrollController();

  Iterable<Widget> _lastResults = <Widget>[];
  String? _searchQuery;
  int _queryLength = 1; // using this to check if one is typing or not

  // State for verse animation
  int? _verseToAnimate;
  int? _bookIdToAnimate;
  int? _chapterToAnimate;
  double bookAndChapterItemHeight = 43;

  @override
  Widget build(BuildContext context) {
    double pad = 8;
    var provider = Provider.of<BibleProvider>(context);
    void chooseVerse(Selection selection, int verseNumber) async {
      await provider.selectBook(selection.bookIndex);
      await provider.selectChapter(selection.chapterIndex);

      // Wait for the next frame for the provider to update the verse list
      await Future.delayed(Duration.zero);
      if (!mounted) return;

      final verseIndex = provider.verses.indexWhere(
        (v) => v['verse'] == verseNumber,
      );
      if (verseIndex == -1) return;

      // Scroll to the verse.
      // NOTE: This assumes a fixed height for each verse's ListTile.
      // For more complex layouts, a package like `scrollable_positioned_list`
      // would be more reliable.
      _scrollVerse.animateTo(
        verseIndex * 56.0, // Approximate height of a ListTile
        duration: Durations.long1,
        curve: Curves.easeInOut,
      );
      _scrollBook.animateTo(
        selection.bookIndex * bookAndChapterItemHeight,
        duration: Durations.long1,
        curve: Curves.easeInOut,
      );
      if (!mounted) return;

      // Trigger the animation
      setState(() {
        _verseToAnimate = verseNumber;
        _bookIdToAnimate = provider.books[selection.bookIndex]['id'];
        _chapterToAnimate = provider.chapters.elementAt(selection.chapterIndex);
      });
    }

    var bibles = provider.bibles
        .map(
          (b) => DropdownMenuItem(
            value: b,
            // label: b.name,
            child: Text(
              b.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        )
        .toList();
    return Builder(
      builder: (context) {
        if (!provider.biblesExist) {
          return Scaffold(
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: pad,
                children: [
                  Text(provider.downloadingMessage),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            toolbarHeight: 72,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            leading: Row(
              children: [
                SizedBox(width: pad * 2),
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  provider.toggleTheme();
                },
                icon: Icon(
                  provider.setting.lightTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              SizedBox(width: pad * 2),
            ],
            title: Padding(
              padding: EdgeInsets.all(pad),
              child: Row(
                spacing: pad * 2,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    onPressed: () {
                      appAboutDialog(
                        context,
                        provider.currentBible!.translation!,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 32,
                            child: Image.asset("assets/icon.png"),
                          ),
                          Text(
                            "Me Version Bible",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SearchAnchor.bar(
                      searchController: _searchController,
                      barHintText: "Search for verses...",
                      viewHintText: "Use <book1,...,bookn> to filter books",
                      barElevation: WidgetStatePropertyAll(0),
                      suggestionsBuilder: (context, controller) async {
                        _searchQuery = controller.text;
                        if (_searchQuery == null ||
                            _searchQuery!.trim().isEmpty) {
                          return [];
                        }
                        var length = _searchQuery!.length;
                        if (length >= _queryLength &&
                            _searchQuery!.endsWith("<")) {
                          _searchController.text = "$_searchQuery>";
                          _searchController.selection = TextSelection(
                            baseOffset: length,
                            extentOffset: length,
                          );
                        }
                        _queryLength = length;
                        var results = /* await */ provider.searchVerse(
                          _searchQuery!,
                        );
                        if (results.isEmpty) {
                          return [];
                        }

                        if (_searchQuery != controller.text) {
                          return _lastResults;
                        }

                        _lastResults = List<Widget>.generate(results.length, (
                          idx,
                        ) {
                          var verse = results[idx];
                          return VerseCard(
                            provider: provider,
                            verse: verse,
                            onSelect: () {
                              chooseVerse(
                                Selection.at(
                                  verse['book_id'] - 1,
                                  verse['chapter'] - 1,
                                ),
                                verse['verse'],
                              );
                              _searchController.closeView(_searchQuery);
                            },
                          );
                        });
                        return _lastResults;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: CustomDrawer(),
          body: Consumer<BibleProvider>(
            builder: (context, provider, child) {
              if (!provider.biblesExist || provider.books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .center,
                    mainAxisAlignment: .center,
                    spacing: 4,
                    children: [
                      CircularProgressIndicator.adaptive(),
                      Text("Loading books..."),
                    ],
                  ),
                );
              }
              var currentBook =
                  provider.books[provider.setting.selection.bookIndex];
              var chapterNumber = provider.chapters.elementAt(
                provider.setting.selection.chapterIndex,
              );
              return Padding(
                padding: const EdgeInsets.all(16) - .only(top: 16),
                child: Column(
                  mainAxisSize: .max,
                  spacing: 4,
                  children: [
                    SizedBox(
                      // height: 32,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(20),
                              borderRadius: .circular(16),
                            ),
                            child: DropdownButton(
                              items: bibles,
                              value: provider.currentBible,
                              focusColor: Colors.transparent,
                              underline: SizedBox(),
                              borderRadius: .circular(16),
                              alignment: .center,
                              onChanged: (value) {
                                provider.selectBible(value!);
                              },
                              isDense: true,
                              padding: .only(left: 16),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(20),
                              borderRadius: .circular(16),
                            ),
                            child: TextButton.icon(
                              icon: Icon(Icons.book_rounded, size: 14),
                              label: Text(
                                "${currentBook['name']}, chapter $chapterNumber",
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ButtonStyle(
                                padding: .all(.symmetric(horizontal: 16)),
                              ),
                              onPressed: () async {
                                buildBookAndChapterDialog(
                                  context,
                                  pad,
                                  provider,
                                );

                                await Future.delayed(Durations.short2);
                                if (!mounted) return;

                                // Ensure the scroll controllers are attached
                                if (!_scrollBook.hasClients) {
                                  // If not attached, wait for the next frame
                                  if (!mounted) return;
                                }

                                // Now animate
                                _scrollBook.jumpTo(
                                  provider.setting.selection.bookIndex *
                                      bookAndChapterItemHeight,
                                );

                                if (!mounted) return;

                                // Trigger the animation only if books list is not empty
                                if (provider.books.isNotEmpty) {
                                  setState(() {
                                    _bookIdToAnimate =
                                        provider.books[provider
                                            .setting
                                            .selection
                                            .bookIndex]['id'];
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        // spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Verses
                          Expanded(
                            flex: 9,
                            child: FutureBuilder(
                              future: Future.sync(
                                () => provider.verses.isEmpty,
                              ),
                              builder: (context, snap) {
                                if (!snap.hasData || snap.data!) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return ListView.builder(
                                  controller: _scrollVerse,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final verse = provider.verses[index];
                                    final currentBookId =
                                        provider.books[provider
                                            .setting
                                            .selection
                                            .bookIndex]['id'];
                                    final currentChapter = provider.chapters
                                        .elementAt(
                                          provider
                                              .setting
                                              .selection
                                              .chapterIndex,
                                        );

                                    final bool isTargetVerse =
                                        verse['verse'] == _verseToAnimate &&
                                        currentBookId == _bookIdToAnimate &&
                                        currentChapter == _chapterToAnimate;

                                    if (isTargetVerse) {
                                      return _FlashingListTile(
                                        verse: verse,
                                        onAnimationComplete: () {
                                          if (mounted) {
                                            setState(
                                              () => _verseToAnimate = null,
                                            );
                                          }
                                        },
                                      );
                                    } else {
                                      return VerseCard(
                                        provider: provider,
                                        verse: verse,
                                        opacity: 20,
                                        selected: provider.isVerseSelected(
                                          verse['id'],
                                        ),
                                        onSelect: () => provider
                                            .selectOrDeselectVerse(verse['id']),
                                        onRightClick: () =>
                                            provider.quickCopyVerses(context),
                                      );
                                    }
                                  },
                                  itemCount: provider.verses.length,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<dynamic> buildBookAndChapterDialog(
    BuildContext context,
    double pad,
    BibleProvider provider,
  ) {
    if (provider.books.isEmpty) {
      return showDialog(
        context: context,
        builder: (ctx) => const AlertDialog(
          title: Text('Loading...'),
          content: CircularProgressIndicator(),
        ),
      );
    }
    return showDialog(
      context: context,
      builder: (ctx) {
        return SizedBox(
          width: MediaQuery.of(ctx).size.width,
          height: MediaQuery.of(ctx).size.height,
          child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Row(
                  spacing: pad,
                  children: [
                    //Books
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 250,
                            child: ListView.builder(
                              controller: _scrollBook,
                              shrinkWrap: true,
                              itemCount: provider.books.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: .only(bottom: pad / 2),
                                  child: CustomListTile(
                                    text: provider.books[index]['name'],
                                    style: TextStyle(
                                      fontWeight: .bold,
                                      fontSize: 16,
                                    ),
                                    selected:
                                        provider.setting.selection.bookIndex ==
                                        index,
                                    borderRadius: 16,
                                    padding: .symmetric(
                                      vertical: pad,
                                      horizontal: pad,
                                    ),
                                    onTap: () {
                                      provider.selectBook(index);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Chapters
                    Expanded(
                      child: SizedBox(
                        height: .infinity,
                        child: Wrap(
                          spacing: pad,
                          runSpacing: pad,

                          children: List.generate(provider.chapters.length, (
                            index,
                          ) {
                            return CustomListTile(
                              text: provider.chapters
                                  .elementAt(index)
                                  .toString(),
                              selected:
                                  provider.setting.selection.chapterIndex ==
                                  index,
                              width: 48,
                              height: 48,
                              borderRadius: 16,
                              onTap: () {
                                provider.selectChapter(index);
                                Navigator.of(ctx).pop();
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A ListTile that performs a flashing animation on its background.
class _FlashingListTile extends StatefulWidget {
  final Map<String, dynamic> verse;
  final VoidCallback onAnimationComplete;

  const _FlashingListTile({
    required this.verse,
    required this.onAnimationComplete,
  });

  @override
  State<_FlashingListTile> createState() => _FlashingListTileState();
}

class _FlashingListTileState extends State<_FlashingListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;

    // This sequence animates the color from transparent to the theme's
    // primary container color and back again, twice.
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.transparent,
          end: colorScheme.primaryContainer,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: colorScheme.primaryContainer,
          end: Colors.transparent,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.transparent,
          end: colorScheme.primaryContainer,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: colorScheme.primaryContainer,
          end: colorScheme.primary.withAlpha(20),
        ),
        weight: 1,
      ),
    ]).animate(_animationController);

    _animationController.forward().whenComplete(widget.onAnimationComplete);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BibleProvider provider = Provider.of<BibleProvider>(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return VerseCard(
          provider: provider,
          verse: widget.verse,
          // verseName: provider.verseIDString(widget.verse, false),
          color: _colorAnimation.value,
        );
      },
    );
  }
}

// class LineSeparation extends StatelessWidget {
//   final bool vertical;
//   const LineSeparation({super.key, this.vertical = true});

//   @override
//   Widget build(BuildContext context) {
//     double dimension = 4;
//     return Container(
//       width: vertical ? dimension : double.infinity,
//       height: vertical ? double.infinity : dimension,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.secondary,
//         borderRadius: BorderRadius.circular(dimension / 2),
//       ),
//     );
//   }
// }
