import 'package:flutter/material.dart';

import '../../utils/ScaleAssist.dart';

String currentVersion = '1.0.4 QUICKFIX 4 to Completeness Update';

List<String> changes = [
  "QuickFix 1: Switched from Physical Key listeners to Logical Key listeners",
  "QuickFix 1: Reworded the Redirector description",
  "QuickFix 2: Generators no longer make silent trash cells play sound",
  "QuickFix 3: Fixed Saving bug by changing value string of P1+",
  "QuickFix 4: Fixed a puzzle bias issue",
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
