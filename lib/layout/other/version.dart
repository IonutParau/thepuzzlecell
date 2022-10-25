import 'package:flutter/material.dart' hide Colors, ListTile;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons, ScaffoldPage, ListTile;
import '../../logic/logic.dart';
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.2.0.1 Mathematically Complete';

final List<String> changes = [
  "QuickFix 1: Made mouse scrolling work better on track pads",
  "QuickFix 1: Made Load Level only load it once",
  "QuickFix 1: Made Place no longer crash the game",
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
