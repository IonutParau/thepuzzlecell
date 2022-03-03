import 'package:flame/flame.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
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

  storage = await SharedPreferences.getInstance();

  if (storage.getDouble('ui_scale') == null) {
    await storage.setDouble('ui_scale', 1);
  }

  if (storage.getDouble('music_volume') == null) {
    await storage.setDouble('music_volume', 0.5);
  }

  if (storage.getStringList('servers') == null) {
    await storage.setStringList('servers', []);
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
  final _splashController = FlameSplashController(
    fadeInDuration: Duration(milliseconds: 500),
    fadeOutDuration: Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(LifecycleEventHandler());
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  var splashScreenOver = false;

  @override
  Widget build(BuildContext context) {
    return ScaleAssist(
      builder: (context, orientation) {
        return MaterialApp(
          title: 'The Puzzle Cell',
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: FlameSplashScreen(
            controller: _splashController,
            onFinish: (ctx) {
              if (!splashScreenOver) {
                splashScreenOver = true;
                playOnLoop(floatMusic, storage.getDouble('music_volume')!);
                Navigator.of(ctx).pushNamed('/main');
              }
            },
            theme: FlameSplashTheme.dark,
            showBefore: (ctx) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    children: [
                      Spacer(),
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      Text(
                        'The Puzzle Cell',
                        style: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        'by A Monitor#1595',
                        style: TextStyle(
                          fontSize: 5.sp,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              );
            },
            showAfter: (ctx) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    children: [
                      Spacer(),
                      FlutterLogo(
                        size: 20.w,
                      ),
                      Text(
                        'Made with Flutter',
                        style: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              );
            },
          ),
          routes: {
            '/main': (ctx) => MainScreen(),
            '/editor': (ctx) => Editor(),
            '/game': (ctx) => GameUI(),
            '/game-loaded': (ctx) => GameUI(editorType: EditorType.loaded),
            '/puzzles': (ctx) => Puzzles(),
            '/settings': (ctx) => SettingsPage(),
            '/version': (ctx) => VersionPage(),
            '/credits': (ctx) => CreditsPage(),
            '/multiplayer': (ctx) => MultiplayerPage(),
          },
        );
      },
    );
  }
}
