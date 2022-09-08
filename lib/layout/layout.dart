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
import 'package:flame/input.dart';
import 'package:fluent_ui/fluent_ui.dart' hide showDialog, Tab, TabView;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Colors, ButtonStyle, Slider, SliderThemeData, Chip, ListTile;
import 'package:flutter/services.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:the_puzzle_cell/layout/other/other.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/logic/performance/grid_benchmark.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'tools/tools.dart';
export 'other/other.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'game_ui.dart';
part 'game_audio.dart';
part 'puzzles.dart';
part 'settings.dart';
part 'langs.dart';
part 'shopui.dart';
part 'achievement.dart';
