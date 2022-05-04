import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons;
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.0.0.0 Codename World of Changes Update';

final List<String> changes = [
  "Fixed some bugs",
  "Added Constraints",
  "Added Worlds",
  "Switched from Material UI to Fluent UI",
  "Replaced background music \"Float\" with \"Flight\"",
  "Removed Update Visible because nobody used it",
  "Added In-Game Store and Skins (they are local, so, your skins dont show for others in Multiplayer)",
  "Added an Update Checker",
  "Reworked all cell textures",
  "Added Time Travel",
  "Added Tools",
  "Added many more cells",
  "Added quantum cells",
];

IconData getTrailing(String change) {
  change = change.toLowerCase();
  if (change.startsWith('fixed') ||
      change.startsWith('patched') ||
      change.startsWith('moved') ||
      change.startsWith('reworked') ||
      change.startsWith('changed')) {
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
              'The Puzzle Cell version $currentVersion',
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
