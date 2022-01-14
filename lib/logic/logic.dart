library logic;

import 'dart:math';
import 'dart:ui';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/layout.dart';

part 'grid.dart';
part 'update.dart';
part 'move.dart';
part 'cell_data.dart';

late SharedPreferences storage;
late DiscordRPC discord;

void setDefaultPresence() {
  discord.updatePresence(
    DiscordPresence(
      startTimeStamp: DateTime.now().millisecondsSinceEpoch,
      details: 'In menu',
      largeImageKey: 'tpc_logo',
    ),
  );
}
