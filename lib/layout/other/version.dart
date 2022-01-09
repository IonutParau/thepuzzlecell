import 'package:flutter/material.dart';

import '../../utils/ScaleAssist.dart';

String currentVersion = '0.1.0';

List<String> changes = [
  "Fixed Wormhole",
  "Added Darty, basically a hungry mover",
  "Added descriptions to the cells",
  "Added Grabber, it grabs everything on it's sides",
  "Added Fan, it pushes everything in front of it",
  "Added Tunnel, it moves the cell behind it in front of it",
  "Changed the key needed to move in play mode, you need to press Shift and the key to move with now",
  "Fixed issues with the key system",
  "Added a Quit button",
  "Added Discord Rich Presence text",
  "Added a new settings, Realistic Rendering, which improves rendering with special interpolation effects at the cost of FPS",
  "Added Physical Generator",
  "Added ActionBar",
  "Removed many keybinds",
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
