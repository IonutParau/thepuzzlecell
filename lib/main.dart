import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'logic/logic.dart';

void main() async {
  //await Flame.device.setLandscape();
  WidgetsFlutterBinding.ensureInitialized();
  DartVLC.initialize();
  await Flame.device.fullScreen();
  SystemChrome.setApplicationSwitcherDescription(
    ApplicationSwitcherDescription(
      label: "The Puzzle Cell",
    ),
  );

  initSound();

  storage = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScaleAssist(
      builder: (context, orientation) {
        return MaterialApp(
          title: 'The Puzzle Cell',
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: const MainScreen(),
          routes: {
            '/editor': (ctx) => Editor(),
            '/game': (ctx) => GameUI(),
            '/game-loaded': (ctx) => GameUI(editorType: EditorType.loaded),
            '/puzzles': (ctx) => Puzzles(),
            '/settings': (ctx) => SettingsPage(),
          },
        );
      },
    );
  }
}
