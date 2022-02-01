import 'package:flutter/material.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

final credits = [
  "Sam Hogan for making the original Cell Machine",
  "Me, A Monitor#1595, for making this remake",
  "k.#0086 for making our OST, \"Float\"",
  "k.#0086 for making Mirrored Reality, Spherical, Twin Instinct and Reflection",
  "Blendi Goose#0414 for making Vault Cracking 2, Vault Cracking 3 and Double Movement",
  "TheJchen#6898 for making the first 5 levels",
  "The Generator Cell#7431 for helping me remake all of the textures",
  "Everyone who has suggested the addition of features and cells",
];

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Special thanks to:"),
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
