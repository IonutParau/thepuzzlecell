import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors;
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

final credits = [
  "Sam Hogan for making the original Cell Machine",
  "Me, A Monitor#1595, for making this remake",
  "k.#0086 for making all the OSTs",
  "The Generator Cell#7431 for helping me remake all of the textures",
  "Qwerty.R#9850 for making the sound effects",
  "Resizing and clearing are based on CelLua's resizing and clearing buttons",
  "Blueprints are heavily inspired by schematics from Cell Machine Mystic Mod V4",
  "Everyone who has suggested the addition of features and cells",
];

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Special thanks to:",
          style: TextStyle(
            fontSize: 10.sp,
          ),
        ),
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: credits.length,
        itemBuilder: (ctx, i) {
          final item = credits[i];
          return ListTile(
            title: Text(
              item,
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}
