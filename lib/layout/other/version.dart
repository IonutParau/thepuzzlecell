import 'package:flutter/material.dart' hide Colors, ListTile;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons, ScaffoldPage, ListTile;
import '../../logic/logic.dart';
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.2.0.0 Mathematically Complete';

final List<String> changes = [
  "Fixed several bugs with moving selection",
  "Reworked the entire dialog system to be more consistent",
  "Reordered some tools",
  "Added a new dialog for saving that allows you to change the title and description of a level very quickly",
  "Made grid tabs also cycling through worlds",
  "Added a button to resize the grid without clearing in the editor menu",
  "Fixed replicator nukes breaking",
  "Fixed mechanical-based duplication glitches",
  "Fixed the P4 Tags decoder",
  "FIXED HEAT!!!",
  "Added Inverse Airflow and Super Vacuum",
  "Made the mechanical keys also work with logic gates",
  "Added the property editor",
  "Added a Countdown property to Trash-Based Mechanical Generator",
  "Added the math category (OMG unexpected)",
  "Fixed a bug with onetick sometimes skipping ticks when lagging",
  "Made settings make more sense",
  "Added Texture Packs UI to disable or enable texture packs. You can still run multiple at the same time",
  "Made Version page also display current cell count, background count and biome count",
  "Redesigned some pages to be more modern",
  "Removed Full-Screen pages in favor of dialogs",
  "Added Spike Trap and Spike Factory",
  "Added Explosive",
  "Added Factory",
  "Added many performance-related settings",
  "Added Mechanically Powered Enemy and Mechanically Powered Trash",
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
            "Cells: ${cells.length - backgrounds.length} | Backgrounds: ${backgrounds.length - biomes.length} | Biomes: ${biomes.length} | Total: ${cells.length}",
            style: TextStyle(
              fontSize: 7.sp,
            ),
          ),
        ],
      ),
    );
  }
}
