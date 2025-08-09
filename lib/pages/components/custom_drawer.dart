import 'package:flutter/material.dart';
import 'package:me_version_bible/pages/components/about_content.dart';
import 'package:me_version_bible/providers/bible_provider.dart';
import 'package:me_version_bible/utils/constants.dart' show appColors;
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BibleProvider>(context);
    const spacing = 16.0;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              "O P T I O N S",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(spacing),
            children: [
              ListTile(
                leading: Icon(Icons.cloud_download_outlined),
                title: Text("Manage Bible Versions"),
                onTap: () {
                  Navigator.of(context).pushNamed("/manage_versions");
                },
              ),
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
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About"),
                onTap: () {
                  var t = provider.currentBible!.translation!;
                  var theme = Theme.of(context);
                  showAboutDialog(
                    context: context,
                    applicationName: "Me Version Bible",
                    applicationVersion: "1.0",
                    applicationIcon: Image.asset("assets/icon.png", width: 64),
                    children: [AboutContent(theme: theme, translation: t)],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
