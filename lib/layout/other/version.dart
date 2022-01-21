import 'package:flutter/material.dart';

import '../../utils/ScaleAssist.dart';

String currentVersion = '0.1.1 Codename Mechanical Update';

List<String> changes = [
  "Added SELECT mode",
  "Added categories to the editor",
  "Added Stopper",
  "Added Opposite Rotator",
  "Added Mechanical Gear",
  "Added Mechanical Generator",
  "Added Mechanically Powered Mover, Puller, Grabber and Fan",
  "Added Cross Mechanical Gear",
  "Added Logic Gates",
];

String getTrailing(String change) {
  change = change.toLowerCase();
  if (change.startsWith('fixed') || change.startsWith('patched')) {
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
