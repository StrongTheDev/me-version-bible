import 'package:flutter/material.dart';
import 'package:me_version_bible/providers/bible_provider.dart' show BibleProvider;
import 'package:me_version_bible/utils/constants.dart';

class GeneralSettings extends StatelessWidget {
  final BibleProvider bibleProvider;

  const GeneralSettings({
    super.key,
    required this.bibleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 4),
          ListTile(
            leading: Icon(
              bibleProvider.setting.lightTheme
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: Text("Change Theme"),
            onTap: () {
              bibleProvider.toggleTheme();
            },
          ),
          SizedBox(height: 4),
          ListTile(
            leading: Icon(Icons.abc),
            title: Text("Theme Color"),
            trailing: DropdownButton(
              value: bibleProvider.setting.themeColorIndex,
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
                bibleProvider.setColorIndex(colorIndex);
              },
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }
}
