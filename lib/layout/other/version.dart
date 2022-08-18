import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons;
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.1.2.0 The Biomes Update Content Update 2';

final List<String> changes = [
  "Added the Trickster Tool :trell:",
  "Added a new level",
  "Fixed a bug in the editor menu",
  "Made the editor menu also have an SFX slider",
  "Made locks no longer lose their data when unlocked",
  "Put Multiplayer settings into a new tab",
  "Made cursors in multiplayer sandbox mode show their current selection (works with tools)",
  "Made cursor icon configurable",
  "Added a setting to process most sent packets client-side as if they were from the server for less visual latency (can cause out-of-sync issues if your internet is unreliable, does not do anything to wrap toggling or invisibility tool packets due to them ebing a toggle which would cause issues)",
  "Added the ability to resize the grid when clearing",
];

IconData getTrailing(String change) {
  change = change.toLowerCase();
  if (change.startsWith('fixed') ||
      change.startsWith('patched') ||
      change.startsWith('moved') ||
      change.startsWith('reworked') ||
      change.startsWith('changed') ||
      change.startsWith("made") ||
      change.startsWith("put")) {
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
