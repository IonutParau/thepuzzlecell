import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/other/credits.dart';
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
  playOnLoop(floatMusic, 0.5);

  storage = await SharedPreferences.getInstance();

  if (storage.getDouble('ui_scale') == null) {
    await storage.setDouble('ui_scale', 1);
  }

  runApp(const MyApp());
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler();

//  @override
//  Future<bool> didPopRoute()

//  @override
//  void didHaveMemoryPressure()

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(LifecycleEventHandler());
  }

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
            '/version': (ctx) => VersionPage(),
            '/credits': (ctx) => CreditsPage(),
          },
        );
      },
    );
  }
}
