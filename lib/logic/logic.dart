library logic;

// All the high-quality code I didn't bother writing
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:http/http.dart' as http show get;
import 'package:yaml/yaml.dart' show loadYaml;
import '../layout/tools/tools.dart';
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';
import 'package:window_manager/window_manager.dart';

// Stuffz
part 'grid.dart';
part 'update.dart';
part 'move.dart';
part 'cell_data.dart';
part 'world.dart';
part 'blueprints.dart';
part 'lang.dart';
part 'coins.dart';
part 'skins.dart';
part 'texturepack.dart';
part 'achievements.dart';
part 'updatechecker.dart';
part 'queue.dart';

// Update methods
part 'update/mover.dart';
part 'update/puller.dart';
part 'update/grabber.dart';
part 'update/generators.dart';
part 'update/superGenerators.dart';
part 'update/reps.dart';
part 'update/tunnels.dart';
part 'update/transformers.dart';
part 'update/rots.dart';
part 'update/gear.dart';
part 'update/speed.dart';
part 'update/driller.dart';
part 'update/axis.dart';
part 'update/bringers.dart';
part 'update/liners.dart';
part 'update/bird.dart';
part 'update/fan.dart';
part 'update/ants.dart';
part 'update/karls.dart';
part 'update/puzzle.dart';
part 'update/pmerge.dart';
part 'update/gate.dart';
part 'update/autoflag.dart';
part 'update/stoppers.dart';
part 'update/mechs.dart';
part 'update/hungry_trash.dart';
part 'update/darty.dart';
part 'update/mirror.dart';
part 'update/quantum.dart';
part 'update/antigen.dart';
part 'update/heat.dart';
part 'update/timetravel.dart';
part 'update/biomes.dart';
part 'update/plant.dart';
part 'update/automata.dart';
part 'update/memgen.dart';
part 'update/spreaders.dart';
part 'update/floppy.dart';
part 'update/math.dart';

extension SetX on Set<String> {
  bool containsAny(List<String> strings) {
    for (var s in this) {
      if (strings.contains(s)) {
        return true;
      }
    }

    return false;
  }
}

String findAssetDirPath() {
  // print(path.absolute(
  //   'build',
  //   'linux',
  //   'x64',
  //   'debug',
  //   'bundle',
  //   'data',
  //   'flutter_assets',
  // ));

  if (Directory(
    path.absolute(
      'build',
      'windows',
      'runner',
      'Debug',
      'data',
      'flutter_assets',
    ),
  ).existsSync()) {
    return path.absolute(
      'build',
      'windows',
      'runner',
      'Debug',
      'data',
      'flutter_assets',
    );
  }

  if (Directory(
    path.absolute(
      'build',
      'linux',
      'x64',
      'debug',
      'bundle',
      'data',
      'flutter_assets',
    ),
  ).existsSync()) {
    return path.absolute(
      'build',
      'linux',
      'x64',
      'debug',
      'bundle',
      'data',
      'flutter_assets',
    );
  }

  return path.absolute('data', 'flutter_assets');
}

late SharedPreferences storage;

final String assetsPath = findAssetDirPath();

Future<void> fixStorage() async {
  if (storage.getString("lang") != null) {
    loadLangByName(storage.getString("lang")!);
  }

  worldManager.loadWorldsFromSettings();

  if (storage.getDouble('ui_scale') == null) {
    await storage.setDouble('ui_scale', 1);
  }

  if (storage.getDouble('music_volume') == null) {
    await storage.setDouble('music_volume', 0.5);
  }

  if (storage.getStringList('servers') == null) {
    await storage.setStringList('servers', []);
  }

  if (storage.getInt('coins') == null) {
    await storage.setInt('coins', 0);
  }

  if (storage.getStringList('skins') == null) {
    await storage.setStringList('skins', <String>[]);
  }

  if (storage.getStringList('usedSkins') == null) {
    await storage.setStringList('usedSkins', <String>[]);
  }

  if (storage.getBool("invert_zoom_scroll") == null) {
    await storage.setBool("invert_zoom_scroll", true);
  }

  if (isDesktop) {
    if (storage.getBool("fullscreen") != null) {
      await windowManager.setFullScreen(storage.getBool("fullscreen")!);
    }
  }

  await applyTexturePackSettings();
}
