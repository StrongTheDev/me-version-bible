import 'package:flutter/material.dart';
import 'package:me_version_bible/components/sidebar/side_bar.dart';
import 'package:me_version_bible/components/verse_card.dart';
import 'package:me_version_bible/models/selection.dart';
import 'package:me_version_bible/pages/settings_page.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/providers/home_provider.dart';
import 'package:me_version_bible/utils/functions.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/// A ListTile that performs a flashing animation on its background.
class _FlashingListTile extends StatefulWidget {
  final Map<String, dynamic> verse;
  final VoidCallback onAnimationComplete;
  final String? verseName;

  const _FlashingListTile({
    required this.verse,
    required this.onAnimationComplete,
    this.verseName,
  });

  @override
  State<_FlashingListTile> createState() => _FlashingListTileState();
}

class _FlashingListTileState extends State<_FlashingListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  Widget build(BuildContext context) {
    BibleProvider provider = Provider.of<BibleProvider>(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return VerseCard(
          provider: provider,
          verse: widget.verse,
          verseName: widget.verseName,
          color: _colorAnimation.value,
        );
      },
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SearchController _searchController = SearchController();
  // scrollers
  final ItemScrollController _scrollBook = ItemScrollController();
  final ItemPositionsListener _bookPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _scrollVerse = ItemScrollController();

  Iterable<Widget> _lastResults = <Widget>[];
  String? _searchQuery;
  int _queryLength = 1; // using this to check if one is typing or not

  // State for verse animation
  int? _verseToAnimate;
  int? _bookIdToAnimate;
  int? _chapterToAnimate;

  bool _hasScrolledInitially = false;

  @override
  Widget build(BuildContext context) {
    double pad = 8;
    var provider = Provider.of<BibleProvider>(context);
    var homeProvider = Provider.of<HomeProvider>(context);
    void chooseVerse(Selection selection, int verseNumber) async {
      await provider.selectBook(selection.bookIndex);
      await provider.selectChapter(selection.chapterIndex);

      // Wait for the next frame for the provider to update the verse list
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final verseIndex = provider.verses.indexWhere(
        (v) => v['verse'] == verseNumber,
      );
      if (verseIndex == -1) return;

      // Await next frame so the scroll calculations are correct.
      await WidgetsBinding.instance.endOfFrame;
      // Scroll to the verse.
      _scrollVerse.scrollTo(
        index: verseIndex,
        duration: Durations.long4,
        curve: Curves.easeOut,
      );
      _scrollBook.scrollTo(
        index: selection.bookIndex,
        duration: Durations.long4,
        curve: Curves.easeOut,
        alignment: 0.1,
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

    void scrollToSelectedBook() {
      if (!_scrollBook.isAttached) return;
      var bookIdx = provider.setting.selection.bookIndex;
      _scrollBook.scrollTo(
        index: bookIdx,
        duration: Durations.medium4,
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }

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
                    // _scaffoldKey.currentState?.openDrawer();
                    setState(() {
                      homeProvider.toggleSidebar();
                    });
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
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return SettingsPage();
                    },
                  );
                },
                icon: Icon(Icons.settings),
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
                      barElevation: .all(2),
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
          body: Consumer<BibleProvider>(
            builder: (context, provider, child) {
              if (!provider.biblesExist ||
                  provider.books.isEmpty ||
                  provider.chapters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .center,
                    mainAxisAlignment: .center,
                    spacing: 4,
                    children: [
                      CircularProgressIndicator.adaptive(),
                      Text("Loading books & chapters..."),
                    ],
                  ),
                );
              }
              var currentBook =
                  provider.books[provider.setting.selection.bookIndex];
              var chapterNumber = provider.chapters.elementAt(
                provider.setting.selection.chapterIndex,
              );
              _maybeScrollToSelectedBook(provider);
              return Padding(
                padding: const EdgeInsets.all(16) - .only(top: 16, bottom: 8),
                child: Row(
                  mainAxisSize: .max,
                  children: [
                    // Side Bar
                    SideBar(
                      width: homeProvider.sidebarisOpen
                          ? homeProvider.sidebarWidth
                          : 0,
                      selectedBookIndex: provider.setting.selection.bookIndex,
                      bookPickerScrollController: _scrollBook,
                      bookPickerPositionsListener: _bookPositionsListener,
                    ),
                    if (homeProvider.sidebarisOpen) SizedBox(width: 8),

                    // Reading View
                    Expanded(
                      child: Column(
                        // mainAxisSize: .max,
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
                                    onPressed: () {
                                      if (!homeProvider.sidebarisOpen) {
                                        homeProvider.toggleSidebar();
                                      }

                                      scrollToSelectedBook();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
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

                                return ScrollablePositionedList.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemScrollController: _scrollVerse,
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
                                        verseName: verse['verse'].toString(),
                                        verse: verse,
                                        onAnimationComplete: () {
                                          setState(
                                            () => _verseToAnimate = null,
                                          );
                                        },
                                      );
                                    } else {
                                      return VerseCard(
                                        provider: provider,
                                        verse: verse,
                                        verseName: verse['verse'].toString(),
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
                          SizedBox(
                            height: 32,
                            child: Row(
                              mainAxisAlignment: .center,
                              spacing: 8,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    // label: Text("Previous Chapter"),
                                    onPressed: () =>
                                        provider.navPreviousChapter(),
                                    child: Icon(Icons.arrow_back_ios),
                                    // iconAlignment: .start,
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    // label: Text("Next Chapter"),
                                    onPressed: () => provider.navNextChapter(),
                                    child: Icon(Icons.arrow_forward_ios),
                                    // iconAlignment: .end,
                                  ),
                                ),
                              ],
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

  void _maybeScrollToSelectedBook(BibleProvider provider) {
    if (provider.books.isEmpty) return; // not loaded yet, nothing to scroll to
    if (_hasScrolledInitially) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollBook.isAttached) return;

      _scrollBook.scrollTo(
        index: provider.setting.selection.bookIndex,
        duration: Durations.medium4,
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
      _hasScrolledInitially = true;
    });
  }
}
