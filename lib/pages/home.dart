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
  final TextEditingController _controller = TextEditingController();
  final SearchController _searchController = SearchController();
  // scrollers
  final ScrollController _scrollBook = ScrollController();
  final ScrollController _scrollChapter = ScrollController();
  final ScrollController _scrollVerse = ScrollController();

  Iterable<Widget> _lastResults = <Widget>[];
  String? _searchQuery;
  int _queryLength = 1; // using this to check if one is typing or not

  // State for verse animation
  int? _verseToAnimate;
  int? _bookIdToAnimate;
  int? _chapterToAnimate;

  @override
  Widget build(BuildContext context) {
    double pad = 8;
    var provider = Provider.of<BibleProvider>(context);
    var scheme = Theme.of(context).colorScheme;
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
      _scrollChapter.animateTo(
        selection.chapterIndex * 48,
        duration: Durations.long1,
        curve: Curves.easeInOut,
      );
      _scrollBook.animateTo(
        selection.bookIndex * 48,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  DropdownButton(
                    items: bibles,
                    value: provider.currentBible,
                    focusColor: Colors.transparent,
                    underline: SizedBox(),
                    borderRadius: BorderRadius.circular(16),
                    alignment: Alignment.center,
                    onChanged: (value) {
                      provider.selectBible(value!);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
          drawer: CustomDrawer(),
          body: Consumer<BibleProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Books
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollBook,
                                shrinkWrap: true,
                                itemCount: provider.books.length,
                                // prototypeItem: ListTile(title: Text("Genesis")),
                                itemBuilder: (context, index) {
                                  return CustomListTile(
                                    text: provider.books[index]['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    selected:
                                        provider.setting.selection.bookIndex ==
                                        index,
                                    onTap: () {
                                      provider.selectBook(index);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Chapters
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(pad),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(pad),
                          border: BoxBorder.all(
                            color: scheme.inversePrimary,
                            width: 1,
                          ),
                        ),
                        height: double.infinity,
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollChapter,
                          clipBehavior: Clip.antiAlias,
                          itemCount: provider.chapters.length,
                          itemBuilder: (context, index) {
                            return CustomListTile(
                              text: provider.chapters
                                  .elementAt(index)
                                  .toString(),
                              selected:
                                  provider.setting.selection.chapterIndex ==
                                  index,
                              onTap: () {
                                provider.selectChapter(index);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Verses
                    Expanded(
                      flex: 9,
                      child: FutureBuilder(
                        future: Future.sync(() => provider.verses.isEmpty),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!_initialScrollCompleted) {
                            // The initial scroll should happen only once, after the UI for the
                            // lists has been built. Scheduling it in a post-frame callback
                            // from here ensures that all lists (Books, Chapters, and Verses)
                            // are available and their scroll controllers have clients.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // Check if mounted to avoid errors if the widget is disposed.
                              if (mounted) _initialScroll();
                            });
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
                                    provider.setting.selection.chapterIndex,
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
                                      setState(() => _verseToAnimate = null);
                                    }
                                  },
                                );
                              } else {
                                return VerseCard(
                                  provider: provider,
                                  verse: verse,
                                  // verseName: provider.verseIDString(
                                  //   verse,
                                  //   false,
                                  // ),
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
              );
            },
          ),
        );
      },
    );
  }

  bool _initialScrollCompleted = false;
  void _initialScroll() {
    // If we've already scrolled, or if the controllers aren't ready, do nothing.
    // This check is crucial because this method is called in a post-frame callback
    // which might run on subsequent rebuilds.
    if (_initialScrollCompleted ||
        !_scrollBook.hasClients ||
        !_scrollChapter.hasClients) {
      return;
    }

    final provider = Provider.of<BibleProvider>(context, listen: false);
    final selection = provider.setting.selection;

    const double bookAndChapterItemHeight = 48.0;

    // Using jumpTo for an instantaneous scroll on load is often better
    // than an animation.
    _scrollBook.jumpTo(selection.bookIndex * bookAndChapterItemHeight);
    _scrollChapter.jumpTo(selection.chapterIndex * bookAndChapterItemHeight);

    _initialScrollCompleted = true;
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
