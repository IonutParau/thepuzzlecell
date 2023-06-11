library layout;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Tab, TabView, showDialog;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ButtonStyle, Chip, Colors, ListTile, Slider, SliderThemeData;
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:the_puzzle_cell/layout/other/other.dart';
import 'package:the_puzzle_cell/logic/core/lan.dart' show closeLanServer, setupLanServer;
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/logic/performance/grid_benchmark.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
export 'other/other.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'game_ui.dart';
part 'game_audio.dart';
part 'puzzles.dart';
part 'settings.dart';
part 'langs.dart';
part 'shopui.dart';
part 'achievement.dart';

class ConstantColorButtonState extends ButtonState<Color> {
  final Color color;

  ConstantColorButtonState(this.color) : super();

  @override
  Color resolve(Set<ButtonStates> states) {
    return color;
  }
}

extension on Color {
  ConstantColorButtonState get state => ConstantColorButtonState(this);
}
