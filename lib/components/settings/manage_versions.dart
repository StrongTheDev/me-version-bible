import 'package:flutter/material.dart';
import 'package:me_version_bible/components/settings/components/bible_downloadable_card.dart';
import 'package:me_version_bible/components/settings/components/bible_downloaded_card.dart';
import 'package:me_version_bible/providers/versions_provider.dart';

const double pad = 16;

class GetMoreVersions extends StatelessWidget {
  final TextEditingController controller;

  final BibleVersionsProvider provider;
  const GetMoreVersions({
    super.key,
    required this.controller,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bold = TextStyle(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.all(pad) - const .only(bottom: pad),
      child: Column(
        children: [
          if (!provider.downloadsAvailable)
            TextButton.icon(
              onPressed: () => provider.reload(),
              icon: Icon(Icons.refresh),
              label: Text("Refresh"),
            ),
          if (provider.downloadsAvailable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  "Download other versions from here",
                  style: bold.copyWith(fontSize: 18),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SearchBar(
                        controller: controller,
                        elevation: WidgetStatePropertyAll(0),
                        hintText: " Search for versions...",
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.search),
                        ),
                        trailing: [
                          if (controller.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                controller.text = "";
                                provider.filterWith("");
                              },
                              icon: Icon(Icons.close),
                            ),
                        ],
                        autoFocus: true,
                        onChanged: (value) {
                          provider.filterWith(value);
                        },
                      ),
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: provider.hideDownloaded ? 1 : 0.3,
                  duration: Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Hide Downloaded", style: bold),
                      Switch(
                        value: provider.hideDownloaded,
                        onChanged: (v) {
                          provider.setHideDownloaded(v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.reloading) {
                  return Center(
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Checking versions..."),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }
                if (!provider.downloadsAvailable) {
                  return Center(child: Text("No Downloads Available"));
                }
                try {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: provider.downloads!.length,
                      itemBuilder: (ctx, idx) {
                        var download = provider.downloads![idx];
                        var downloaded = provider.isDownloaded(download.name);
                        // debugPrint(
                        //   "Bible: ${download.name}, Downloaded: $downloaded",
                        // );
                        return BibleDownloadableCard(
                          data: download,
                          downloaded: downloaded,
                        );
                      },
                    ),
                  );
                } catch (e) {
                  return Center(child: Text("No Data Available"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ManageDownloadedBibles extends StatelessWidget {
  final BibleVersionsProvider provider;

  const ManageDownloadedBibles({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bold = TextStyle(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.all(pad) - const .only(bottom: pad),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage downloaded versions",
              style: bold.copyWith(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.existingBibles.length,
                itemBuilder: (context, index) {
                  final bible = provider.existingBibles.elementAt(index);
                  return FutureBuilder(
                    future: provider.getStats(bible),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      var data = snapshot.data;
                      return BibleCard(bible: bible, stats: data!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageVersions extends StatelessWidget {
  const ManageVersions({super.key, required this.bibleVersionsProvider});

  final BibleVersionsProvider bibleVersionsProvider;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    final pages = [
      {
        "title": "GET MORE VERSIONS",
        // to download
        "content": GetMoreVersions(
          provider: bibleVersionsProvider,
          controller: controller,
        ),
        // "icon": Icons.download_for_offline,
      },
      {
        "title": "DOWNLOADED VERSIONS",
        // Downloaded
        "content": ManageDownloadedBibles(provider: bibleVersionsProvider),
        // "icon": Icons.straight,
      },
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Manage Bible Versions",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TabBar(
            tabs: pages
                .map(
                  (p) => Tab(
                    text: p['title'] as String,
                  ),
                )
                .toList(),
            isScrollable: true,
          ),
          Expanded(
            child: TabBarView(
              children: pages.map((p) => p['content'] as Widget).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
