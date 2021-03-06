import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons;
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.1.0.0 The Biomes Update';

final List<String> changes = [
  "Added ability to change audio device",
  "Added biomes",
  "Added Fullscreen toggle",
  "Reworked the generator optimization",
  "Reworked the settings page",
  "Added setting to change chunk size",
  "Reworked some categories",
  "Added Water, Sand, Gas, Filler, Fire, Plasma, Lava and Cancer",
  "Added Memory Generators",
  "Added AutoDetect in texture packs",
  "Added YAML and TOML support to texture packs",
  "Added more puzzle variants",
  "Added KeyLimit, Robot and Assistant",
  "Reworked the entire grid system to be less buggy",
  "Added plant",
  "Added lose conditions",
  "Added a music switcher",
  "Replaced the default background music from Flight to Drift",
  "Added IMPLY and NIMPLY logic gates",
  "Changed the NAND texture",
];

IconData getTrailing(String change) {
  change = change.toLowerCase();
  if (change.startsWith('fixed') || change.startsWith('patched') || change.startsWith('moved') || change.startsWith('reworked') || change.startsWith('changed')) {
    return FluentIcons.change_entitlements;
  } else if (change.startsWith('added')) {
    return FluentIcons.insert;
  } else if (change.startsWith('quickfix')) {
    return FluentIcons.quick_note;
  } else if (change.startsWith('replaced') || change.startsWith('switched')) {
    return FluentIcons.switch_widget;
  }

  return FluentIcons.delete;
}

class VersionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(
              'The Puzzle Cell v$currentVersion',
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: changes.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Text(
              'Changes in version $currentVersion',
              style: TextStyle(
                fontSize: 7.sp,
              ),
            );
          }

          return ListTile(
            leading: Icon(
              getTrailing(changes[i - 1]),
              size: 5.sp,
            ),
            title: Text(changes[i - 1]),
          );
        },
      ),
    );
  }
}
