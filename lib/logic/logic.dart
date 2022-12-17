library logic;

// All the high-quality code I didn't bother writing
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:http/http.dart' as http show get;
import 'package:the_puzzle_cell/scripts/scripts.dart';
import 'package:yaml/yaml.dart' show loadYaml;
import '../layout/tools/tools.dart';
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';
import 'package:window_manager/window_manager.dart';

// Stuffz
part 'grid/grid.dart';
part 'grid/cell.dart';
part 'grid/subticks.dart';
part 'performance/quad_chunks.dart';
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
part 'update/master.dart';
part 'update/spikefactory.dart';
part 'update/factory.dart';
part 'update/checkpoint.dart';
part 'update/lofter.dart';
part 'update/code.dart';

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
    path.join(
      'build',
      'windows',
      'runner',
      'Debug',
      'data',
      'flutter_assets',
    ),
  ).existsSync()) {
    return path.join(
      'build',
      'windows',
      'runner',
      'Debug',
      'data',
      'flutter_assets',
    );
  }

  if (Directory(
    path.join(
      'build',
      'linux',
      'x64',
      'debug',
      'bundle',
      'data',
      'flutter_assets',
    ),
  ).existsSync()) {
    return path.join(
      'build',
      'linux',
      'x64',
      'debug',
      'bundle',
      'data',
      'flutter_assets',
    );
  }

  if (Directory(path.join('Resources', 'flutter_assets')).existsSync()) {
    return path.join('Resources', 'flutter_assets');
  }

  return path.join('data', 'flutter_assets');
}

late SharedPreferences storage;

final String assetsPath = findAssetDirPath();

File assetToFile(String p) {
  return File(path.joinAll([assetsPath, 'assets', ...(p.split('/'))]));
}

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
    await storage.setBool("invert_zoom_scroll", false);
  }

  if (storage.getInt("cursor_precision") == null) {
    await storage.setInt("cursor_precision", 3);
  }
  if (storage.getInt("packet_queue_limit") == null) {
    await storage.setInt("packet_queue_limit", 1000000);
  }
  if (storage.getDouble("grid_opacity") == null) {
    await storage.setDouble("grid_opacity", 1);
  }
  if (storage.getDouble("ui_button_opacity") == null) {
    await storage.setDouble("ui_button_opacity", 1);
  }
  if (storage.getDouble("cell_button_opacity") == null) {
    await storage.setDouble("cell_button_opacity", 1);
  }
  if (storage.getDouble("editor_menu_button_opacity") == null) {
    await storage.setDouble("editor_menu_button_opacity", 1);
  }
  if (storage.getBool("queue_updates") == null) {
    await storage.setBool("queue_updates", true);
  }
  if (storage.getInt("update_queue_runs") == null) {
    await storage.setInt("update_queue_runs", 20000000);
  }
  if (isDesktop) {
    if (storage.getBool("fullscreen") != null) {
      await windowManager.setFullScreen(storage.getBool("fullscreen")!);
    }
  }

  await applyTexturePackSettings();
}

List parseJointCellStr(String str) {
  final s = str.split('!');
  if (s.length == 1) s.add("0");

  return [s[0], int.parse(s[1])];
}

String rotToString(int rot) {
  if (rot == 0) return lang("right", "Right");
  if (rot == 1) return lang("down", "Down");
  if (rot == 2) return lang("left", "Left");
  if (rot == 3) return lang("up", "Up");
  return "Unknown";
}

String idToString(String id) {
  return lang("$id.title", (cellInfo[id] ?? defaultProfile).title);
}

String idToDesc(String id) {
  return lang("$id.desc", (cellInfo[id] ?? defaultProfile).description);
}

String idToTexture(String id) {
  return "assets/images/${textureMap['$id.png'] ?? '$id.png'}";
}

String cornerToString(int rot) {
  if (rot == 0) return lang("top_left", "Top Left");
  if (rot == 1) return lang("top_right", "Top Right");
  if (rot == 2) return lang("bottom_right", "Bottom Right");
  if (rot == 3) return lang("bottom_left", "Bottom Left");

  return "Unknown";
}
