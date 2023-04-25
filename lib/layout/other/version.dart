import 'package:flutter/material.dart' hide Colors, ListTile;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons, ScaffoldPage, ListTile;
import '../../logic/logic.dart';
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.3.0.1 Configurable QuickFix 1';

final List<String> changes = [
  "QuickFix: Fixed skin textures being out of date",
  "QuickFix: Deleted Test-Mod",
  "QuickFix: Fixed a problem with the description of Anti-Generators",
  "Made generators faster with an amazing optimization",
  "QuickFix: Made generators not commit die",
  "QuickFix: Made multiplayer pasting not broken",
  "QuickFix: Changed order of subticks so Releaser can work better",
  "QuickFix: Fixed VX implementation being horribly bugged",
  "QuickFix: Made the modding API not add subticks AFTER time reset",
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
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
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
      ),
      content: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ListView.builder(
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
      }),
      bottomBar: Row(
        children: [
          Spacer(),
          Text(
            cellInfoBar,
            style: TextStyle(
              fontSize: 7.sp,
            ),
          ),
        ],
      ),
    );
  }

  String get cellInfoBar {
    final parts = <String>[];

    parts.add("Foregrounds: ${cells.length - backgrounds.length}");
    parts.add("Backgrounds: ${backgrounds.length - biomes.length}");
    parts.add("Biomes: ${biomes.length}");

    if (modded.isNotEmpty) {
      parts.add("Modded: ${modded.length}");
    }

    parts.add("Total: ${cells.length}");

    return parts.join(" | ");
  }
}
