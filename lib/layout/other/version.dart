import 'package:flutter/material.dart' hide Colors, ListTile;
import 'package:fluent_ui/fluent_ui.dart'
    show Colors, FluentIcons, ScaffoldPage, ListTile;
import '../../logic/logic.dart';
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.3.0.0 Configurable';

final List<String> changes = [
  "Reworked all the textures",
  "Added themes",
  "Improved multiplayer performance",
  "Added some settings to limit bandwidth usage",
  "Added a modding API",
  "Added Random Filler",
  "Added Configurable Filler",
  "Made selection area show size and position",
  "Made Debug Mode also show cell position",
  "Moved Zoom In and Zoom Out out of tools",
  "Added Cell Searching",
  "Added Sticky Cell (real)",
  "Added modules",
  "Added a fancy hover effect for cells",
  "Added a Copy Old Instance button to transfer over blueprints, texture packs, mods and modules!",
  "Added Secret Cells (check cell searching)",
  "Reworked the multiplayer packet format (more robust, but may require more bandwidth)",
  "Added VX support (VX is a saving format made by ModularCM)",
  "Added Electric Cells!",
  "NOT YET: Added support for TPC Content Hubs",
  "NOT YET: Removed Worlds in favor of Workspaces",
  "NOT YET: Added Macros (buttons that run little scripts)",
  "Added Text Cell",
  "Added Shield",
  "Added Debt Enemy",
  "Added Portal C",
  "Added Custom Weight",
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
