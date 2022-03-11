import 'package:flutter/material.dart';

import '../../utils/ScaleAssist.dart';

String currentVersion = '1.2.3 Codename Multiplayer Update QuickFix 3';

List<String> changes = [
  "QuickFix 1: Fixed physical enemies not being stopped by stoppers",
  "QuickFix 1: Fixed all the types of flags",
  "QuickFix 1: Added a Load New Puzzle button in puzzle mode multiplayer",
  "QuickFix 1: Fixed a duplication bug in multiplayer",
  "QuickFix 1: Nerfed mobile trash cell",
  "QuickFix 1: Nerfed anchor cell",
  "QuickFix 2: Added version checking support",
  "QuickFix 2: Removed anchor cell nerfed, it made them not work",
  "QuickFix 2: Patched a lot of other stuff",
  "QuickFix 3: Fixed some broken cells",
  "QuickFix 3: Switched to a new particle system that is less buggy",
  "QuickFix 3: Made anchors ungearable",
];

String getTrailing(String change) {
  change = change.toLowerCase();
  if (change.startsWith('fixed') ||
      change.startsWith('patched') ||
      change.startsWith('moved') ||
      change.startsWith('reworked') ||
      change.startsWith('changed')) {
    return '>';
  } else if (change.startsWith('added')) {
    return '+';
  } else if (change.startsWith('quickfix')) {
    return 'QF';
  }

  return '-';
}

class VersionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Puzzle Cell version $currentVersion'),
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
            leading: Text(
              getTrailing(changes[i - 1]),
              style: TextStyle(
                fontSize: 5.sp,
              ),
            ),
            title: Text(changes[i - 1]),
          );
        },
      ),
    );
  }
}
