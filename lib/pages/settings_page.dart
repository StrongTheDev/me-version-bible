import 'package:flutter/material.dart';
import 'package:me_version_bible/pages/manage_versions.dart';
import 'package:me_version_bible/providers/bible_provider.dart'
    show BibleProvider;
import 'package:me_version_bible/utils/constants.dart';
import 'package:provider/provider.dart' show Provider;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BibleProvider>(context);
    List<Map<String, Object>> tabsData = [
      {
        "name": "General",
        "icon": Icons.menu,
        "content": Material(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: 4),
              ListTile(
                leading: Icon(
                  provider.setting.lightTheme
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: Text("Change Theme"),
                onTap: () {
                  provider.toggleTheme();
                },
              ),
              SizedBox(height: 4),
              ListTile(
                leading: Icon(Icons.abc),
                title: Text("Theme Color"),
                trailing: DropdownButton(
                  value: provider.setting.themeColorIndex,
                  focusColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  underline: SizedBox(),
                  items: appColors
                      .map(
                        (color) => DropdownMenuItem(
                          value: appColors.indexOf(color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (colorIndex) {
                    if (colorIndex == null) return;
                    provider.setColorIndex(colorIndex);
                  },
                ),
              ),
              SizedBox(height: 4),
            ],
          ),
        )
      },
      {
        "name": "Manage Versions",
        "icon": Icons.download_done,
        "content": ManageVersions(),
      },
    ];

    var theme = Theme.of(context);
    return DefaultTabController(
      length: tabsData.length,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: .circular(24),
            border: BoxBorder.all(color: theme.colorScheme.onPrimaryContainer, width: 2)
          ),          
          child: SizedBox(
            child: Stack(
              children: [
                Column(
                  mainAxisSize: .max,
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: .start,
        
                      tabs: tabsData
                          .map(
                            (t) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Text(
                                    t["name"].toString(),
                                    style: TextStyle(fontWeight: .bold),
                                  ),
                                  Icon(t["icon"] as IconData),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: tabsData
                            .map(
                              (t) => Padding(
                                padding: const .all(8),
                                child: t["content"] as Widget,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: IconButton.filled(
                      tooltip: "Close (Esc)",
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
