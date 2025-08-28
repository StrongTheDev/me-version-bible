import 'package:flutter/material.dart';
import 'package:me_version_bible/components/bible_downloadable_card.dart';
import 'package:me_version_bible/components/bible_downloaded_card.dart';
import 'package:me_version_bible/providers/versions_provider.dart';
import 'package:provider/provider.dart';

class ManageVersions extends StatelessWidget {
  const ManageVersions({super.key});

  @override
  Widget build(BuildContext context) {
    final bold = TextStyle(fontWeight: FontWeight.bold);
    final TextEditingController controller = TextEditingController();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Manage Bible Versions"),
          bottom: TabBar(
            tabs: [
              Tab(text: "GET MORE VERSIONS"),
              Tab(text: "DOWNLOADED VERSIONS"),
            ],
          ),
        ),

        body: Consumer<BibleVersionsProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                // to download
                Padding(
                  padding: const EdgeInsets.all(24),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
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
                                    // decoration: InputDecoration(
                                    //   hintText: "Search for versions...",
                                    //   filled: true,
                                    //   suffixIcon:
                                    //       : null,
                                    // ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              return Center(
                                child: Text("No Downloads Available"),
                              );
                            }
                            try {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: ListView.builder(
                                  itemCount: provider.downloads!.length,
                                  itemBuilder: (ctx, idx) {
                                    var download = provider.downloads![idx];
                                    var downloaded = provider.isDownloaded(
                                      download.name,
                                    );
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
                ),

                // Downloaded
                Padding(
                  padding: const EdgeInsets.all(24),
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
                              final bible = provider.existingBibles.elementAt(
                                index,
                              );
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
