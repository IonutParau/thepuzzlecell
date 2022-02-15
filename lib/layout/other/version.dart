import 'package:flutter/material.dart';

import '../../utils/ScaleAssist.dart';

String currentVersion = '1.1.2 Codename MoreCells Update QuickFix 2';

List<String> changes = [
  "QuickFix 1: Made reset to initial also reset the puzzle win state",
  "QuickFix 1: Added music volume slider",
  "QuickFix 2: Patched Slow Puller and Fast Puller not showing their names and description",
  "QuickFix 2: Patched an optimization breaking generators",
  "QuickFix 2: Fixed replicators instantly lasering in soem cases",
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
