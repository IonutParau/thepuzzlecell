import 'dart:io';

import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show AppBar, Scaffold;
import 'package:flutter/material.dart' as MaterialStuff;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/other/credits.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/scripts/scripts.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/layout/layout.dart';

import 'logic/logic.dart';

late FluentThemeData td;

final deflate = ZLibCodec();

void main() async {
  //await Flame.device.setLandscape();

  WidgetsFlutterBinding.ensureInitialized();

  await loadAllPuzzles();
  await loadBlueprints();
  addBlueprints();

  final defaultMaterialTheme = MaterialStuff.ThemeData().textTheme;

  final font = GoogleFonts.oxygen; // Just grab the constructor, nothing too cursed

  // Text stuff
  final typography = Typography.raw(
    body: font(textStyle: defaultMaterialTheme.bodyMedium, color: Colors.white),
    bodyLarge: font(textStyle: defaultMaterialTheme.bodyLarge, color: Colors.white),
    bodyStrong: font(textStyle: defaultMaterialTheme.bodyMedium, color: Colors.white),
    title: font(textStyle: defaultMaterialTheme.titleMedium, color: Colors.white),
    titleLarge: font(textStyle: defaultMaterialTheme.titleLarge, color: Colors.white),
    subtitle: font(textStyle: defaultMaterialTheme.titleSmall, color: Colors.white),
    caption: font(textStyle: defaultMaterialTheme.headlineSmall, color: Colors.white),
    display: font(textStyle: defaultMaterialTheme.displayMedium, color: Colors.white),
  );

  td = FluentThemeData(
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    typography: typography,
  );

  storage = await SharedPreferences.getInstance();

  await fixStorage();

  initSound();

  markdownManager.init();

  final stopwatch = Stopwatch()..start();
  var tc = 0;
  game = PuzzleGame();
  final grid = Grid(100, 100);
  game.initial = grid;
  grid.set(30, 20, Cell(30, 20, 0)..id = "generator_cw");
  grid.set(
      29,
      20,
      Cell(29, 20, 2)
        ..id = "generator_cw"
        ..rot = 2);

  while (stopwatch.elapsedMilliseconds < 10000) {
    grid.update();
    tc++;
  }

  stopwatch.stop();

  print("Milliseconds per tick: ${stopwatch.elapsedMilliseconds / tc}");
  print("TPS: ${tc / (stopwatch.elapsedMilliseconds / 1000)}");

  runApp(const MyApp());
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
    if (isDesktop) {
      loadTexturePacks();
      applyTexturePackSettings().then((v) => applyTexturePacks());
      scriptingManager.loadScripts();
      scriptingManager.initScripts();
    }
    ErrorWidget.builder = (details) {
      return Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Spacer(),
                Text('Error: ${details.exception.toString()}'),
                Spacer(),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
          body: Text(
            details.stack != null ? "Stack Trace:\n${details.stack.toString()}" : "No stack trace available",
            textAlign: TextAlign.left,
          ),
        );
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  var splashScreenOver = false;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'The Puzzle Cell',
      theme: td,
      debugShowCheckedModeBanner: false,
      home: FlameSplashScreen(
        controller: _splashController,
        theme: FlameSplashTheme(
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            logoBuilder: (ctx) {
              return ScaleAssist(builder: (context, size) {
                return FluentTheme(
                  data: td,
                  child: ScaffoldPage(
                    content: Center(
                      child: Column(
                        children: [
                          Spacer(),
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                          Text(
                            'The Puzzle Cell',
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            'by Atomical#1595',
                            style: TextStyle(
                              fontSize: 5.sp,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              });
            }),
        onFinish: (ctx) {
          if (!splashScreenOver) {
            splashScreenOver = true;
            setLoopSoundVolume(
              music,
              storage.getDouble('music_volume')!,
            );
            //playOnLoop(floatMusic, storage.getDouble('music_volume')!);
            Navigator.of(ctx).pushNamed('/main');
          }
        },
      ),
      routes: {
        '/main': (ctx) => MainScreen(),
        '/editor': (ctx) => Editor(),
        '/game': (ctx) {
          game = PuzzleGame();
          return Container(child: GameUI());
        },
        '/game-loaded': (ctx) {
          game = PuzzleGame();
          return Container(child: GameUI(editorType: EditorType.loaded));
        },
        '/puzzles': (ctx) => Puzzles(),
        '/settings': (ctx) => SettingsPage(),
        '/version': (ctx) => VersionPage(),
        '/credits': (ctx) => CreditsPage(),
        '/multiplayer': (ctx) => MultiplayerPage(),
        '/worlds': (ctx) => WorldUI(),
      },
    );
  }
}

class ConstantButtonValue<T> extends ButtonState<T> {
  final T value;

  ConstantButtonValue(this.value);

  @override
  T resolve(Set<ButtonStates> states) {
    return value;
  }
}
