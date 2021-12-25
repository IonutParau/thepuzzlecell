library logic;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/layout.dart';

part 'grid.dart';
part 'update.dart';
part 'move.dart';

late SharedPreferences storage;
