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

import 'package:the_puzzle_cell/logic/logic.dart';

late FluentThemeData td;

final deflate = ZLibCodec();

Future<void> benchmarkSelf() async {
  storage = await SharedPreferences.getInstance();
  game = PuzzleGame();
  grid = Grid(100, 100);
  grid.set(30, 20, Cell(30, 20)..id = "generator_cw");
  grid.set(
      29,
      20,
      Cell(29, 20)
        ..id = "generator_cw"
        ..rot = 2);
  game.initial = grid;
  print("Starting 20s benchmark...");
  final stopwatch = Stopwatch()..start();
  var slowest = 0.0;
  var fastest = double.infinity;
  while (stopwatch.elapsedMilliseconds < 20000) {
    var time = stopwatch.elapsedMilliseconds;
    grid.update();
    var elapsed = (stopwatch.elapsedMilliseconds - time) / 1000;

    if (elapsed > slowest) slowest = elapsed;
    if (elapsed < fastest) fastest = elapsed;
  }
  stopwatch.stop();

  print("Ticks Executed: ${grid.tickCount}");
  print(
      "Average Tick Execution: ${(stopwatch.elapsedMilliseconds / grid.tickCount) / 1000}s");
  print("Slowest Tick Execution: ${slowest}s");
  print("Fastest Tick Execution: ${fastest}s");
  print(
      "Average Ticks Per Second: ${grid.tickCount / (stopwatch.elapsedMilliseconds / 1000)}");
  print("Slowest Ticks Per Second: ${1 / slowest}");
  print("Fastest Ticks Per Second: ${1 / fastest}");
}

void main(List<String> args) async {
    try {
  if (args.isNotEmpty) {
    if (args[0] == "bench") {
      await benchmarkSelf();
      return;
    }
  }

  if (bool.fromEnvironment("bench")) {
    await benchmarkSelf();
    return;
  }

  //await Flame.device.setLandscape();

  WidgetsFlutterBinding.ensureInitialized();

  await loadAllPuzzles();
  await loadBlueprints();
  addBlueprints();

  final defaultMaterialTheme = MaterialStuff.ThemeData().textTheme;

  const font =
      GoogleFonts.oxygen; // Just grab the constructor, nothing too cursed

  // Text stuff
  final typography = Typography.raw(
    body: font(textStyle: defaultMaterialTheme.bodyMedium, color: Colors.white),
    bodyLarge:
        font(textStyle: defaultMaterialTheme.bodyLarge, color: Colors.white),
    bodyStrong:
        font(textStyle: defaultMaterialTheme.bodyMedium, color: Colors.white),
    title:
        font(textStyle: defaultMaterialTheme.titleMedium, color: Colors.white),
    titleLarge:
        font(textStyle: defaultMaterialTheme.titleLarge, color: Colors.white),
    subtitle:
        font(textStyle: defaultMaterialTheme.titleSmall, color: Colors.white),
    caption: font(
        textStyle: defaultMaterialTheme.headlineSmall, color: Colors.white),
    display: font(
        textStyle: defaultMaterialTheme.displayMedium, color: Colors.white),
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

  runApp(const MyApp());
    } catch(e, st) {
        runApp(MyAppCrashed(err: e, trace: st));
    }
}

class MyAppCrashed extends StatelessWidget {
    final dynamic err;
    final StackTrace trace;

    const MyAppCrashed({super.key, required this.err, required this.trace});

    @override
    Widget build(BuildContext context) {
        return FluentApp(
            title: 'TPC Crash Report (${err.runtimeType.toString()})',
            theme: td,
            darkTheme: td,
            debugShowCheckedModeBanner: false,
            home: ScaffoldPage(
                header: Center(child: Text('$err')),
                content: Center(
                    child: Text('Trace: $trace'),
                ),
            ),
        );
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
            details.stack != null
                ? "Stack Trace:\n${details.stack.toString()}"
                : "No stack trace available",
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
