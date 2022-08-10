import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons;
import '../../utils/ScaleAssist.dart';

String currentVersion = '2.1.1.0 The Biomes Update Content Update 1';

final List<String> changes = [
  "Added Clear Storage button",
  "Added Portal A and Portal B",
  "Made the Graviton 64 times heavier",
  "Made the Unstable Generator only generate ungeneratables",
  "Added Muon (electron with twice the mass) and Tau (electron with 4 times the mass)",
  "Reworked physics system (distance exponent is 2 instead of 5, the particle force constant has been removed for being useless, the maximum distance is 50 instead of 10)",
  "Made background darker",
  "Added visual indicator for stopped cells",
  "Fixed a mistake in a blueprint and added another one",
  "Made Temporal Puzzle visible and also fixed its bug",
  "Fixed bug with puzzle bias",
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
