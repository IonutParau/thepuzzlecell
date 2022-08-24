part of layout;

late PuzzleGame game;

double get uiScale => storage.getDouble('ui_scale')!;

TextStyle fontSize(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
  );
}

Map<String, bool> keys = {};

const halfPi = pi / 2;

num abs(num n) => n < 0 ? -n : n;

class GameUI extends StatefulWidget {
  final EditorType editorType;
  final String? ip;

  GameUI({Key? key, this.editorType = EditorType.making, this.ip}) : super(key: key);

  @override
  _GameUIState createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> with TickerProviderStateMixin {
  final scrollController = ScrollController();

  int page = 0;

  // late final AnimationController _rotcontroller = AnimationController(
  //   duration: const Duration(seconds: 5),
  //   vsync: this,
  // )..repeat();

  void dispose() {
    //game.dispose();
    timeGrid = null;
    // _rotcontroller.stop();
    // _rotcontroller.dispose();
    scrollController.dispose();

    if (game.isMultiplayer) {
      game.channel.sink.close();
      game.multiplayerListener.cancel(); // Memory management
    }

    super.dispose();
  }

  @override
  void initState() {
    game = PuzzleGame();
    game.edType = widget.editorType;
    game.ip = widget.ip;
    // editorMenuWidthController.addListener(
    //   () {
    //     print(editorMenuWidthController.text);
    //     // game.overlays.remove('EditorMenu');
    //     // game.overlays.add('EditorMenu');
    //   },
    // );
    // editorMenuHeightController.addListener(
    //   () {
    //     // game.overlays.remove('EditorMenu');
    //     // game.overlays.add('EditorMenu');
    //   },
    // );

    super.initState();
  }

  void nextPuzzle() async {
    if (puzzleIndex != null) {
      puzzleIndex = puzzleIndex! + 1;
      if (puzzleIndex! >= puzzles.length) {
        Navigator.pop(context);
        puzzleIndex = null;
        return;
      }
      game.running = false;
      // game = PuzzleGame();
      // game.edType = EditorType.loaded;
      // game.context = context;
      loadPuzzle(puzzleIndex!);
      puzzleWin = false;
      puzzleLost = false;
      final mouseX = game.mouseX;
      final mouseY = game.mouseY;
      setState(() {
        game.edType = EditorType.loaded;
        game.mouseX = mouseX;
        game.mouseY = mouseY;
        game.mouseInside = false;
        game.context = context;
      });
      //Navigator.of(context).pop();
      //Navigator.of(context).pushNamed('/game-loaded');
    }
  }

  var borderMode = 0;

  @override
  Widget build(BuildContext context) {
    game.context = context;
    return Scaffold(
      body: Center(
        child: MouseRegion(
          onExit: (e) => game.onMouseExit(),
          onEnter: game.onMouseEnter,
          onHover: (e) {
            game.mouseX = e.localPosition.dx;
            game.mouseY = e.localPosition.dy;
            game.mouseInside = true;
          },
          child: Listener(
            onPointerDown: game.onPointerDown,
            onPointerMove: game.onPointerMove,
            onPointerUp: game.onPointerUp,
            onPointerSignal: (PointerSignalEvent event) {
              if (event is PointerScrollEvent) {
                if (keys[LogicalKeyboardKey.controlLeft.keyLabel] == true) {
                  if (keys[LogicalKeyboardKey.altLeft.keyLabel] == true) {
                    if (event.scrollDelta.dy < 0) {
                      game.increaseTemp();
                    } else if (event.scrollDelta.dy > 0) {
                      game.decreaseTemp();
                    }
                  } else {
                    if (event.scrollDelta.dy < 0) {
                      game.increaseBrush();
                    } else if (event.scrollDelta.dy > 0) {
                      game.decreaseBrush();
                    }
                  }
                } else {
                  final inv = storage.getBool("invert_zoom_scroll") ?? true;
                  if (event.scrollDelta.dy > 0) {
                    inv ? game.zoomin() : game.zoomout();
                  } else if (event.scrollDelta.dy < 0) {
                    inv ? game.zoomout() : game.zoomin();
                  }
                }
              }
            },
            child: GameWidget(
              game: game,
              initialActiveOverlays: [],
              overlayBuilderMap: {
                'loading': (ctx, _) {
                  //final rng = Random();

                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Image.asset(
                            'assets/images/puzzle/puzzle.png',
                            filterQuality: FilterQuality.none,
                            width: 10.w,
                            height: 10.w,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Spacer(flex: 100),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              'Waiting for the server response',
                              style: TextStyle(
                                fontSize: 7.sp,
                              ),
                            ),
                            Spacer(),
                            Button(
                              child: Text(
                                'Click to go back',
                                style: TextStyle(
                                  fontSize: 7.sp,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Spacer(flex: 100),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                'EditorMenu': (ctx, _) {
                  void refreshMenu() {
                    game.overlays.remove('EditorMenu');
                    game.overlays.add('EditorMenu');
                  }

                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      width: 70.w,
                      height: 70.h,
                      child: Column(
                        children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(1.w),
                            child: Row(
                              children: [
                                Text(
                                  lang('update_delay', "Update Delay") + ": ${game.delay}",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(builder: (context, cons) {
                                  return Container(
                                    width: min(20.w, cons.maxWidth),
                                    height: 10.h,
                                    padding: EdgeInsets.all(2.w),
                                    child: Slider(
                                      style: SliderThemeData(
                                        thumbColor: Colors.black,
                                        activeColor: Colors.blue,
                                        inactiveColor: Colors.black,
                                        disabledActiveColor: Colors.black,
                                        disabledInactiveColor: Colors.black,
                                        disabledThumbColor: Colors.black,
                                        useThumbBall: true,
                                      ),
                                      value: game.delay,
                                      min: 0.01,
                                      max: 1,
                                      onChanged: (newVal) {
                                        game.delay = (newVal * 100 ~/ 1) / 100;
                                        refreshMenu();
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(1.w),
                            child: Row(
                              children: [
                                Text(
                                  lang('music_volume', 'Music Volume') + ": ${getMusicVolume() * 100}% ",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(
                                  builder: (context, cons) {
                                    return Container(
                                      width: min(20.w, cons.maxWidth),
                                      height: 10.h,
                                      padding: EdgeInsets.all(2.w),
                                      child: Slider(
                                        style: SliderThemeData(
                                          thumbColor: Colors.black,
                                          activeColor: Colors.blue,
                                          inactiveColor: Colors.black,
                                          disabledActiveColor: Colors.black,
                                          disabledInactiveColor: Colors.black,
                                          disabledThumbColor: Colors.black,
                                          useThumbBall: true,
                                        ),
                                        value: getMusicVolume(),
                                        min: 0,
                                        max: 1,
                                        onChanged: (newVal) async {
                                          await setLoopSoundVolume(
                                            music,
                                            floor(newVal * 100) / 100,
                                          );
                                          await storage.setDouble(
                                            'music_volume',
                                            floor(newVal * 100) / 100,
                                          );
                                          refreshMenu();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.all(1.w),
                            child: Row(
                              children: [
                                Text(
                                  lang('sfx_volume', 'SFX Volume') + ": ${(storage.getDouble("sfx_volume") ?? 1) * 100}% ",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(
                                  builder: (context, cons) {
                                    return Container(
                                      width: min(20.w, cons.maxWidth),
                                      height: 10.h,
                                      padding: EdgeInsets.all(2.w),
                                      child: Slider(
                                        style: SliderThemeData(
                                          thumbColor: Colors.black,
                                          activeColor: Colors.blue,
                                          inactiveColor: Colors.black,
                                          disabledActiveColor: Colors.black,
                                          disabledInactiveColor: Colors.black,
                                          disabledThumbColor: Colors.black,
                                          useThumbBall: true,
                                        ),
                                        value: storage.getDouble("sfx_volume") ?? 1,
                                        min: 0,
                                        max: 1,
                                        onChanged: (newVal) async {
                                          await storage.setDouble(
                                            'sfx_volume',
                                            floor(newVal * 100) / 100,
                                          );
                                          refreshMenu();
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Spacer(flex: 2),
                          Row(
                            children: [
                              Spacer(flex: 5),
                              Column(
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      game.exit();
                                    },
                                    child: Image.asset(
                                      'assets/images/interface/back.png',
                                      fit: BoxFit.fill,
                                      colorBlendMode: BlendMode.clear,
                                      filterQuality: FilterQuality.none,
                                      isAntiAlias: true,
                                      cacheWidth: 10.w.toInt(),
                                      cacheHeight: 10.w.toInt(),
                                      scale: 32 / 5.w,
                                    ),
                                  ),
                                  Text(
                                    lang("exit", 'Exit Editor'),
                                    style: TextStyle(
                                      fontSize: 7.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  MaterialButton(
                                    onPressed: () async {
                                      await showDialog(context: context, builder: (ctx) => ClearDialog());
                                    },
                                    child: Image.asset(
                                      'assets/images/' + textureMap['trash.png']!,
                                      fit: BoxFit.fill,
                                      colorBlendMode: BlendMode.clear,
                                      filterQuality: FilterQuality.none,
                                      isAntiAlias: true,
                                      cacheWidth: 10.w.toInt(),
                                      cacheHeight: 10.w.toInt(),
                                      scale: 32 / 5.w,
                                    ),
                                  ),
                                  Text(
                                    lang('clear', 'Clear'),
                                    style: TextStyle(
                                      fontSize: 7.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  MaterialButton(
                                    onPressed: () async {
                                      await showDialog(context: context, builder: (ctx) => ResizeDialog());
                                    },
                                    child: Image.asset(
                                      'assets/images/' + textureMap['cancer.png']!,
                                      fit: BoxFit.fill,
                                      colorBlendMode: BlendMode.clear,
                                      filterQuality: FilterQuality.none,
                                      isAntiAlias: true,
                                      cacheWidth: 10.w.toInt(),
                                      cacheHeight: 10.w.toInt(),
                                      scale: 32 / 5.w,
                                    ),
                                  ),
                                  Text(
                                    lang('resize', 'Resize'),
                                    style: TextStyle(
                                      fontSize: 7.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(flex: 5),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  );
                },
                "Win": (ctx, _) {
                  return Center(
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: Column(
                        children: [
                          Text(
                            "You win!",
                            style: fontSize(27.sp),
                          ),
                          if (puzzleIndex != null)
                            MaterialButton(
                              child: Text(
                                "Next puzzle",
                                style: fontSize(12.sp),
                              ),
                              onPressed: nextPuzzle,
                            ),
                        ],
                      ),
                    ),
                  );
                },
                "Lose": (ctx, _) {
                  return Center(
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: Column(
                        children: [
                          Text(
                            "You lost :(",
                            style: fontSize(27.sp),
                          ),
                          if (puzzleIndex != null)
                            MaterialButton(
                              child: Text(
                                "Retry puzzle",
                                style: fontSize(12.sp),
                              ),
                              onPressed: () {
                                puzzleIndex = puzzleIndex! - 1;
                                nextPuzzle(); // We are going back then loading the next, very smart.
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              },
            ),
          ),
        ),
      ),
    );
  }
}

Offset rotateOff(Offset o, double r) {
  if (r == 0) return o;
  if (r == pi * 2) return -o;
  final or = atan2(o.dy, o.dx) + r;
  final om = sqrt(o.dy * o.dy + o.dx * o.dx);

  return Offset(cos(or) * om, sin(or) * om);
}

Offset interpolate(Offset o1, Offset o2, double t) {
  final ax = lerp(o1.dx, o2.dx, t);
  final ay = lerp(o1.dy, o2.dy, t);

  return Offset(ax, ay);
}

double lerp(num a, num b, double t) {
  return a + (b - a) * min(t, 1);
}

double lerpRotation(int old, int newR, double t) {
  return lerp(old, old + ((newR - old + 2) % 4 - 2), t);
}

int ceil(num n) => floor(n + 0.999);

Map<String, Sprite> spriteCache = {};

Future loadSkinTextures() {
  return Flame.images.loadAll([
    "skins/hands.png",
    "skins/computer.png",
    "skins/christmas.png",
  ]);
}

Future loadAllButtonTextures() {
  return Flame.images.loadAll([
    "interface/back.png",
    "interface/save.png",
    "interface/load.png",
    "interface/select.png",
    "interface/copy.png",
    "interface/paste.png",
    "interface/wrap.png",
    "interface/zoomin.png",
    "interface/zoomout.png",
    "interface/select_on.png",
    "interface/paste_on.png",
    "interface/cut.png",
    "interface/del.png",
    "interface/menu.png",
    "interface/tools.png",
    "interface/blueprints.png",
    "interface/increase_brush.png",
    "interface/decrease_brush.png",
    "interface/inctab.png",
    "interface/dectab.png",
    "interface/save_bp.png",
    "interface/load_bp.png",
    "interface/tools/invis_tool.png",
    "interface/tools/trick_tool.png",
    "interface/del_bp.png",
    "interface/property_editor.png",
    "math/math_block.png",
  ]);
}

enum ButtonAlignment {
  TOPLEFT,
  BOTTOMLEFT,
  TOPRIGHT,
  BOTTOMRIGHT,
}

class VirtualButton {
  Vector2 position;
  Vector2 size;
  String texture;
  int rotation;
  int lastRot;
  ButtonAlignment alignment;
  void Function() callback;
  bool Function() shouldRender;

  late Vector2 canvasSize;

  double time = 0;
  double duration = 0.1;
  Vector2 startPos;

  double timeRot = 0;
  double rotDuration = 0.1;

  String title;
  String description;

  bool hasRendered = true;
  bool isRendering = false;

  String? id;

  VirtualButton(this.position, Vector2 size, this.texture, this.alignment, this.callback, this.shouldRender, {this.title = "Untitled", this.description = "No description", this.id})
      : rotation = 0,
        lastRot = 0,
        startPos = position * storage.getDouble('ui_scale')!,
        this.size = size * storage.getDouble('ui_scale')! {
    position *= storage.getDouble('ui_scale')!;
    translate();
  } // Constructors

  void translate() {
    if (id != null) {
      title = lang("$id.title", title);
      description = lang("$id.desc", description);
    }
  }

  void render(Canvas canvas, Vector2 canvasSize) {
    this.canvasSize = canvasSize;
    late Vector2 screenPos;

    var center = size / 2;

    var untranslatedPostion = startPos.clone();
    untranslatedPostion.lerp(
      position,
      min(
        time / duration,
        1,
      ),
    );

    var rot = lerpRotation(
      lastRot,
      rotation,
      min(timeRot / rotDuration, 1),
    );

    var seenSize = size * min(time / duration, 1);

    bool hovered = isHovered(game.mouseX.toInt(), game.mouseY.toInt());

    isRendering = shouldRender();
    if (isRendering) {
      hasRendered = true;
    } else if (hasRendered) {
      if (time / duration > 1) return;
      untranslatedPostion = position.clone();
      untranslatedPostion.lerp(
        startPos,
        time / duration,
      );
      seenSize = size * (1 - (time / duration));
    }
    if (alignment == ButtonAlignment.TOPLEFT) {
      screenPos = untranslatedPostion.clone();
    } else if (alignment == ButtonAlignment.TOPRIGHT) {
      screenPos = Vector2(canvasSize.x - untranslatedPostion.x - size.x, untranslatedPostion.y);
    } else if (alignment == ButtonAlignment.BOTTOMLEFT) {
      screenPos = Vector2(untranslatedPostion.x, canvasSize.y - untranslatedPostion.y);
    } else if (alignment == ButtonAlignment.BOTTOMRIGHT) {
      screenPos = canvasSize - untranslatedPostion - size;
    }
    screenPos += center;

    screenPos.rotate(-rot * halfPi);

    canvas.save();
    canvas.rotate(rot * halfPi);

    (Sprite(Flame.images.fromCache(
      textureMap[texture] ?? texture,
    ))
          ..paint.color = hovered
              ? Colors.white
              : Colors.white.withOpacity(
                  0.8,
                ))
        .render(
      canvas,
      position: (screenPos - center) + (size - seenSize) / 2,
      size: seenSize,
    );
    canvas.restore();
  }

  bool isHovered(int mouseX, int mouseY) {
    late Vector2 screenPos;

    if (alignment == ButtonAlignment.TOPLEFT) {
      screenPos = position.clone();
    } else if (alignment == ButtonAlignment.TOPRIGHT) {
      screenPos = Vector2(canvasSize.x - position.x - size.x, position.y);
    } else if (alignment == ButtonAlignment.BOTTOMLEFT) {
      screenPos = Vector2(position.x, canvasSize.y - position.y);
    } else if (alignment == ButtonAlignment.BOTTOMRIGHT) {
      screenPos = canvasSize - position - size;
    }

    if (mouseX >= screenPos.x && mouseX <= screenPos.x + size.x && mouseY >= screenPos.y && mouseY <= screenPos.y + size.y) {
      return true;
    }
    return false;
  }

  void click(int mouseX, int mouseY) {
    if (isHovered(mouseX, mouseY)) {
      callback();
    }
  }
}

class ButtonManager {
  PuzzleGame game;
  Map<String, VirtualButton> buttons = {};

  ButtonManager(this.game);

  void setButton(String key, VirtualButton button) {
    buttons[key] = button;
    button.id = key;
    button.translate();
  }

  void forEach(void Function(String key, VirtualButton button) callback) => buttons.forEach(callback);

  void removeButton(String key) => buttons.remove(key);

  void clear() => buttons.clear();
}

void renderInfoBox(Canvas canvas, String title, String description) {
  final mouseX = max(game.mouseX, 10).toDouble();
  final mouseY = max(game.mouseY, 10).toDouble();

  final titleTP = TextPainter(textWidthBasis: TextWidthBasis.longestLine, textDirection: TextDirection.ltr);
  final descriptionTP = TextPainter(textDirection: TextDirection.ltr);

  titleTP.text = TextSpan(
    text: title,
    style: TextStyle(
      color: Colors.white,
      fontSize: 9.sp,
    ),
  );

  descriptionTP.text = TextSpan(
    text: description,
    style: TextStyle(
      color: Colors.white,
      fontSize: 7.sp,
    ),
  );

  titleTP.layout();
  final width = max(titleTP.width, 20.w);
  descriptionTP.layout(maxWidth: width);
  final height = titleTP.height + descriptionTP.height;

  var size = Size(width + 20, height + 20);
  var off = Offset(mouseX, mouseY);
  if (off.dx + size.width > game.canvasSize.x) {
    off = Offset(game.canvasSize.x - size.width - 10, off.dy);
  }
  if (off.dy + size.height > game.canvasSize.y) {
    off = Offset(off.dx, game.canvasSize.y - size.height - 10);
  }

  final rect = off & size;

  canvas.drawRect(
    rect,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10,
  );
  canvas.drawRect(
    rect,
    Paint()..color = Colors.grey[180],
  );
  titleTP.paint(canvas, Offset(off.dx + 10, off.dy + 10));
  descriptionTP.paint(canvas, Offset(off.dx + 10, off.dy + titleTP.height + 20));
}

class PuzzleGame extends FlameGame with TapDetector, KeyboardEvents {
  late Canvas canvas;

  double sfxVolume = 1;

  bool firstRender = true;

  late BuildContext context;

  bool mouseDown = false;

  EditorType edType = EditorType.making;

  String? ip;

  bool get isMultiplayer => ip != null;

  late WebSocketChannel channel;

  // ignore: cancel_subscriptions
  late StreamSubscription multiplayerListener;

  String currentSelection = "empty";

  int currentRotation = 0;

  Map<String, dynamic> currentData = {};

  double mouseX = 0;
  double mouseY = 0;
  var mouseButton = -1;

  double get offX => (smoothOffX - canvasSize.x / 2) * (cellSize / wantedCellSize) + canvasSize.x / 2;
  double get offY => (smoothOffY - canvasSize.y / 2) * (cellSize / wantedCellSize) + canvasSize.y / 2;

  var storedOffX = 0.0;
  var storedOffY = 0.0;

  var smoothOffX = 0.0;
  var smoothOffY = 0.0;

  int updates = 0;

  bool running = false;
  bool isinitial = true;

  double itime = 0;
  double delay = 0.15;

  late Grid initial;

  var cellsToPlace = <String>["empty"];
  var cellsCount = <int>[1];

  var bgX = 0.0;
  var bgY = 0.0;

  late bool realisticRendering;

  bool get validPlacePos => ((mouseY > 5.h) && (mouseY < 92.h));

  var selecting = false;
  var pasting = false;
  var gridClip = GridClip();

  var selX = 0;
  var selY = 0;
  var selW = 0;
  var selH = 0;
  var setPos = false;
  var dragPos = false;

  // Particles
  final redparticles = ParticleSystem(5, 2, 0.25, 0.125, 1, Colors.red);
  final blueparticles = ParticleSystem(5, 2, 0.25, 0.125, 1, Colors.blue);
  final greenparticles = ParticleSystem(5, 2, 0.25, 0.125, 1, Colors.green);
  final yellowparticles = ParticleSystem(5, 2, 0.25, 0.125, 1, Colors.yellow);

  Rect? viewbox = null;

  // Brush stuff
  var brushSize = 0;
  var brushTemp = 0;

  final gridTab = <int, Grid>{0: grid};
  final cachedGridEmpties = <int, Sprite?>{};
  var gridTabIndex = 0;

  void changeTab(int newTabIndex) {
    if (edType != EditorType.making || isMultiplayer) return;
    if (worldIndex != null) {
      worldManager.saveWorld(worldIndex!);
      worldIndex = newTabIndex % worldManager.worldLength;
      gridTabIndex = worldIndex!;
      grid = loadStr(worldManager.worldAt(worldIndex!));
      buildEmpty();
      return;
    }
    if (!isinitial) return;
    gridTab[gridTabIndex] = grid;
    cachedGridEmpties[gridTabIndex] = emptyImage;
    if (gridTab[newTabIndex] == null) {
      gridTab[newTabIndex] = Grid(grid.width, grid.height);
    }
    if (cachedGridEmpties[newTabIndex] == null) {
      buildEmpty();
    } else {
      emptyImage = cachedGridEmpties[newTabIndex];
    }
    grid = gridTab[newTabIndex]!;
    gridTabIndex = newTabIndex;
  }

  void increaseTab() {
    changeTab(gridTabIndex + 1);
  }

  void decreaseTab() {
    changeTab(gridTabIndex - 1);
  }

  void increaseBrush() => brushSize++;
  void decreaseBrush() => brushSize = max(brushSize - 1, 0);

  void increaseTemp() => brushTemp++;
  void decreaseTemp() => brushTemp--;

  void whenSelected(String newSelection) {
    if (newSelection.startsWith("blueprint ")) {
      // Blueprint code
      loadBlueprint(int.parse(newSelection.split(' ')[1]));
    } else if (newSelection == "inc_brush") {
      increaseBrush();
    } else if (newSelection == "dec_brush") {
      decreaseBrush();
    } else if (newSelection == "zoomin") {
      zoomin();
    } else if (newSelection == "zoomout") {
      zoomout();
    } else if (newSelection == "inctab") {
      increaseTab();
    } else if (newSelection == "dectab") {
      decreaseTab();
    } else if (newSelection.startsWith("trick_tool")) {
      if (currentSelection.startsWith("totrick_")) {
        return;
      } else if (cells.contains(currentSelection) && currentSelection != "empty") {
        currentSelection = "totrick_$currentSelection";
        currentData = {};
        animatePropertyEditor();
      }
    } else {
      currentSelection = newSelection;
      currentData = {};
      final p = props[currentSelection];
      if (p != null) {
        p.forEach((prop) {
          if (prop.def != null) currentData[prop.key] = prop.def;
        });
      }
      animatePropertyEditor();
    }
  }

  void animatePropertyEditor() {
    final btn = buttonManager.buttons['prop-edit-btn']!;
    if (btn.isRendering != btn.shouldRender()) {
      btn.time = 0;
      btn.duration = 0.25;
    }
  }

  void exit() {
    showDialog(
      context: context,
      builder: (ctx) {
        return ContentDialog(
          title: Text(
            lang(
              "confirm_exit",
              "Confirm exit?",
            ),
          ),
          content: Text(
            lang(
              "confirm_exit_desc",
              "You have pressed the Exit Editor button, which exits the game.\nAny unsaved progress will be gone forever.\nAre you sure you want to exit?",
            ),
          ),
          actions: [
            Button(
              child: Text(lang("yes", "Yes")),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                if (worldIndex != null) {
                  worldManager.saveWorld(
                    worldIndex!,
                  );
                }
                worldIndex = null;
                puzzleIndex = null;
              },
            ),
            Button(
              child: Text(lang("no", "No")),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void back() {
    if (edType == EditorType.making) {
      if (overlays.isActive('EditorMenu')) {
        overlays.remove('EditorMenu');
      } else {
        overlays.add('EditorMenu');
      }
    } else {
      exit();
    }
  }

  void paste() {
    if (gridClip.active) {
      gridClip.place(cellMouseX, cellMouseY);
      buttonManager.buttons['select-btn']!.texture = "interface/select.png";
      buttonManager.buttons['paste-btn']!.texture = "interface/paste.png";
      selecting = false;
      setPos = false;
    }
  }

  void copy() {
    if (selW < 0) {
      selW *= -1;
      selX -= selW;
    }
    if (selH < 0) {
      selH *= -1;
      selY -= selH;
    }

    final g = <List<Cell>>[];

    selW--;
    selH--;

    for (var x = 0; x <= selW; x++) {
      g.add(<Cell>[]);
      for (var y = 0; y <= selH; y++) {
        final cx = selX + x;
        final cy = selY + y;
        if (grid.inside(cx, cy)) {
          g.last.add(grid.at(cx, cy).copy);
        }
      }
    }

    gridClip.activate(selW + 1, selH + 1, g);

    selecting = false;
    setPos = false;
    dragPos = false;
    pasting = true;
    buttonManager.buttons['paste-btn']?.texture = 'interface/paste_on.png';

    selW++;
    selH++;
  }

  bool mouseInside = true;

  void properlyChangeZoom(double oldzoom, double newzoom) {
    final scale = newzoom / oldzoom;

    storedOffX = (storedOffX - canvasSize.x / 2) * scale + canvasSize.x / 2;
    storedOffY = (storedOffY - canvasSize.y / 2) * scale + canvasSize.y / 2;

    smoothOffX = (smoothOffX - canvasSize.x / 2) * scale + canvasSize.x / 2;
    smoothOffY = (smoothOffY - canvasSize.y / 2) * scale + canvasSize.y / 2;
  }

  void onPointerMove(PointerMoveEvent event) {
    final dx = event.position.dx - mouseX;
    final dy = event.position.dy - mouseY;

    mouseX = event.position.dx;
    mouseY = event.position.dy;

    if (middleMove && mouseDown && mouseButton == kMiddleMouseButton) {
      storedOffX += dx;
      storedOffY += dy;
    }
  }

  void onMouseExit() {
    mouseDown = false;
    mouseInside = false;
  }

  late ButtonManager buttonManager;

  Map<String, dynamic> parseCellDataStr(String str) {
    if (num.tryParse(str) != null) {
      return {"heat": num.parse(str)};
    }
    final pairs = fancySplit(str, ':');
    final m = <String, dynamic>{};

    for (var pair in pairs) {
      final segs = fancySplit(pair, '=');
      m[segs[0]] = P4.decodeValue(segs[1]);
    }

    return m;
  }

  void multiplayerCallback(data) {
    if (data is String) {
      final cmd = data.split(' ').first;
      final args = data.split(' ').sublist(1);

      if (cmd == "place") {
        if (isinitial) {
          grid.grid[int.parse(args[0])][int.parse(args[1])].id = args[2];
          grid.grid[int.parse(args[0])][int.parse(args[1])].rot = int.parse(args[3]);
          if (args.length > 4) {
            grid.grid[int.parse(args[0])][int.parse(args[1])].data = parseCellDataStr(args[4]);
          }
          grid.setChunk(int.parse(args[0]), int.parse(args[1]), args[2]);
          grid.at(int.parse(args[0]), int.parse(args[1])).invisible = false;
        } else {
          initial.grid[int.parse(args[0])][int.parse(args[1])].id = args[2];
          initial.grid[int.parse(args[0])][int.parse(args[1])].rot = int.parse(args[3]);
          initial.setChunk(int.parse(args[0]), int.parse(args[1]), args[2]);
        }
      } else if (cmd == "bg") {
        if (isinitial) {
          grid.place[int.parse(args[0])][int.parse(args[1])] = args[2];
        } else {
          initial.place[int.parse(args[0])][int.parse(args[1])] = args[2];
        }
      } else if (cmd == "wrap") {
        if (isinitial) {
          grid.wrap = !grid.wrap;
          buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");
        } else {
          initial.wrap = !initial.wrap;
        }
      } else if (cmd == "setinit") {
        if (isinitial) {
          grid = loadStr(args.first);
          timeGrid = null;
          initial = grid.copy;
          isinitial = true;
          running = false;
          buttonManager.buttons['play-btn']?.texture = 'mover.png';
          buttonManager.buttons['play-btn']?.rotation = 0;
          buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");

          buildEmpty();
        } else {
          initial = loadStr(args.first);
        }
      } else if (cmd == "grid") {
        if (overlays.isActive("loading")) {
          overlays.remove("loading");
          AchievementManager.complete("friends");
        }
        if (isinitial) {
          grid = loadStr(args.first);
          initial = grid.copy;
          isinitial = true;
          running = false;
          buttonManager.buttons['play-btn']?.texture = 'mover.png';
          buttonManager.buttons['play-btn']?.rotation = 0;
          buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");

          buildEmpty();
        } else {
          initial = loadStr(args.first);
        }
      } else if (cmd == "edtype") {
        edType = args.first == "puzzle" ? EditorType.loaded : EditorType.making;

        loadAllButtons();
      } else if (cmd == "new-hover") {
        hovers[args.first] = CellHover(
          double.parse(args[1]),
          double.parse(args[2]),
          args[3],
          int.parse(
            args[4],
          ),
          P4.decodeValue(args.sublist(5).join(" ")),
        );
      } else if (cmd == "set-hover") {
        hovers[args.first]!.x = double.parse(args[1]);
        hovers[args.first]!.y = double.parse(args[2]);
      } else if (cmd == "drop-hover") {
        hovers.remove(args.first);
        if (args.first == clientID) {
          currentSelection = "empty";
          currentRotation = 0;
          currentData = {};
        }
      } else if (cmd == "set-cursor") {
        if (cursors[args.first] == null) {
          cursors[args.first] = CellCursor(
            double.parse(args[1]),
            double.parse(args[2]),
            args[3],
            int.parse(args[4]),
            args[5],
          );
        } else {
          cursors[args.first]!.x = double.parse(args[1]);
          cursors[args.first]!.y = double.parse(args[2]);
          cursors[args.first]!.selection = args[3];
          cursors[args.first]!.rotation = int.parse(args[4]);
          //cursors[args.first]!.texture = args[5];
        } // I will try to avoid reinstantiation of classes
      } else if (cmd == "remove-cursor") {
        cursors.remove(args.first);
      } else if (cmd == "toggle-invis") {
        final x = int.parse(args[0]);
        final y = int.parse(args[1]);

        grid.at(x, y).invisible = !grid.at(x, y).invisible;
      }
    }
  }

  String clientID = "";

  Map<String, CellHover> hovers = {};

  void sendToServer(String packet) {
    if (isMultiplayer && isinitial) {
      channel.sink.add(packet);
      if (proxyMirror) {
        if (packet.startsWith('toggle-invis') || packet.startsWith('wrap')) {
          return;
        }
        multiplayerCallback(packet);
      }
    }
  }

  void loadAllButtons() {
    buttonManager = ButtonManager(this);

    buttonManager.setButton(
      "back-btn",
      VirtualButton(
        Vector2.zero(),
        Vector2.all(80),
        edType == EditorType.making ? "interface/menu.png" : "interface/back.png",
        ButtonAlignment.TOPLEFT,
        back,
        () => true,
        title: edType == EditorType.making ? lang('editor_menu', 'Editor Menu') : lang('exit', 'Exit Editor'),
        description: edType == EditorType.making ? lang('editor_menu_desc', 'Opens the Editor Menu') : lang('exit_desc', 'Exits the editor'),
      ),
    );

    if (edType == EditorType.making) {
      buttonManager.setButton(
        "prop-edit-btn",
        VirtualButton(
          Vector2(0, 90),
          Vector2.all(80),
          "interface/property_editor.png",
          ButtonAlignment.TOPLEFT,
          () {
            showDialog(context: context, builder: (ctx) => PropertyEditorDialog());
          },
          () => props[currentSelection] != null,
          title: 'Property Editor',
          description: 'It looks like you have selected a cell with adjustable properties.\nClick on this button to edit them',
        )..startPos = Vector2(-90, 90),
      );
    }

    buttonManager.setButton(
      "play-btn",
      VirtualButton(
        Vector2(
          20,
          30,
        ),
        Vector2.all(40),
        "mover.png",
        ButtonAlignment.TOPRIGHT,
        playPause,
        () => true,
        title: lang('playPause.title', 'Play / Pause'),
        description: lang('playPause.desc', 'Play or Pause the simulation\n(Space key)'),
      ),
    );

    if (isMultiplayer && edType == EditorType.loaded) {
      buttonManager.setButton(
        "m-load-btn",
        VirtualButton(
          Vector2(
            20,
            80,
          ),
          Vector2.all(40),
          "interface/load.png",
          ButtonAlignment.TOPRIGHT,
          () {
            try {
              FlutterClipboard.controlV().then(
                (str) {
                  if (str is ClipboardData) {
                    grid = loadStr(str.text ?? "");
                    QueueManager.runQueue("post-game-init");
                    timeGrid = null;
                    initial = grid.copy;
                    isinitial = true;
                    running = false;
                    buttonManager.buttons['play-btn']?.texture = 'mover.png';
                    buttonManager.buttons['play-btn']?.rotation = 0;
                    buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");

                    sendToServer('setinit ${P4.encodeGrid(grid)}');

                    hovers.forEach(
                      (key, value) {
                        sendToServer('drop-hover $key');
                      },
                    );

                    buildEmpty();
                  }
                },
              );
            } catch (e) {
              print(e);
              showDialog(
                context: context,
                builder: (ctx) {
                  return LoadSaveErrorDialog(e.toString());
                },
              );
            }
          },
          () => isinitial,
          title: lang('loadNewPuzzle.title', 'Load New Puzzle'),
          description: lang(
            'loadNewPuzzle.desc',
            'Load a new puzzle to play, please do not abuse this mechanic!',
          ),
        ),
      );
    }

    buttonManager.setButton(
      "save-btn",
      VirtualButton(
        Vector2(
          edType == EditorType.making ? 120 : 70,
          30,
        ),
        Vector2.all(40),
        "interface/save.png",
        ButtonAlignment.TOPRIGHT,
        () {
          final c = P4.encodeGrid(grid);
          FlutterClipboard.copy(c);
          if (worldIndex != null) {
            worldManager.saveWorld(worldIndex!);
          } else {
            showDialog(context: context, builder: (ctx) => SaveLevelDialog(c));
          }
        },
        () => true,
        title: lang("save.title", 'Save to clipboard'),
        description: lang(
          'save.desc',
          'Save the simulation as an encoded string into your clipboard',
        ),
      ),
    );

    if (edType == EditorType.making) {
      buttonManager.setButton(
        "rot-cw-btn",
        VirtualButton(
          Vector2(
            70,
            30,
          ),
          Vector2.all(40),
          "rotator_cw.png",
          ButtonAlignment.TOPRIGHT,
          e,
          () => true,
          title: lang('rotate_cw.title', 'Rotate CW'),
          description: lang(
            'rotate_cw.desc',
            'Rotates the cells in the UI or what you are about to paste clockwise\n(E key)',
          ),
        ),
      );

      buttonManager.setButton(
        "rot-ccw-btn",
        VirtualButton(
          Vector2(
            70,
            80,
          ),
          Vector2.all(40),
          "rotator_ccw.png",
          ButtonAlignment.TOPRIGHT,
          q,
          () => true,
          title: lang('rotate_ccw.title', 'Rotate CCW'),
          description: lang(
            'rotate_ccw.desc',
            'Rotates the cells in the UI or what you are about to paste counter-clockwise\n(Q key)',
          ),
        ),
      );

      buttonManager.setButton(
        "select-btn",
        VirtualButton(
          Vector2(
            170,
            30,
          ),
          Vector2.all(40),
          "interface/select.png",
          ButtonAlignment.TOPRIGHT,
          () {
            game.selecting = !game.selecting;
            if (game.selecting) {
              buttonManager.buttons['select-btn']?.texture = "interface/select_on.png";
            }
            if (!game.selecting) {
              buttonManager.buttons['select-btn']?.texture = "interface/select.png";
              game.setPos = false;
              game.dragPos = false;
            }
            game.pasting = false;
            buttonManager.buttons['paste-btn']?.texture = 'interface/paste.png';
          },
          () => true,
          title: 'Toggle Select Mode',
          description:
              'In Select Mode you drag an area and can copy, cut, or paste it\nArrow keys move the selected area\nCtrl+arrow keys resize the selection area\nShift + arrow keys move the selection area',
        ),
      );

      buttonManager.setButton(
        "copy-btn",
        VirtualButton(
          Vector2(
            170,
            80,
          ),
          Vector2.all(40),
          "interface/copy.png",
          ButtonAlignment.TOPRIGHT,
          copy,
          () => selecting && !dragPos,
          title: 'Copy',
          description: 'Copy selected area\n(Ctrl + C)',
        ),
      );

      buttonManager.setButton(
        "cut-btn",
        VirtualButton(
          Vector2(
            170,
            130,
          ),
          Vector2.all(40),
          "interface/cut.png",
          ButtonAlignment.TOPRIGHT,
          () {
            copy();
            for (var x = 0; x < selW; x++) {
              for (var y = 0; y < selH; y++) {
                final cx = selX + x;
                final cy = selY + y;
                if (grid.inside(cx, cy)) {
                  if (!isMultiplayer) grid.set(cx, cy, Cell(cx, cy));
                  sendToServer('place $cx $cy empty 0 0');
                }
              }
            }
          },
          () => selecting && !dragPos,
          title: 'Cut',
          description: 'Copy and delete selected area\n(Ctrl + X)',
        ),
      );

      buttonManager.setButton(
        "del-btn",
        VirtualButton(
          Vector2(
            170,
            180,
          ),
          Vector2.all(40),
          "interface/del.png",
          ButtonAlignment.TOPRIGHT,
          () {
            if (selW < 0) {
              selW *= -1;
              selX -= selW;
            }
            if (selH < 0) {
              selH *= -1;
              selY -= selH;
            }

            selW--;
            selH--;

            for (var x = 0; x <= selW; x++) {
              for (var y = 0; y <= selH; y++) {
                final cx = selX + x;
                final cy = selY + y;
                if (grid.inside(cx, cy)) {
                  if (!isMultiplayer) grid.set(cx, cy, Cell(cx, cy));
                  sendToServer('place $cx $cy empty 0 0');
                }
              }
            }

            selecting = false;
            buttonManager.buttons['select-btn']!.texture = "interface/select.png";
          },
          () => selecting && !dragPos,
          title: 'Delete',
          description: 'Delete selected area',
        ),
      );

      buttonManager.setButton(
        "save-blueprint-btn",
        VirtualButton(
          Vector2(
            170,
            230,
          ),
          Vector2.all(40),
          "interface/save_bp.png",
          ButtonAlignment.TOPRIGHT,
          () {
            if (selW < 0) {
              selW *= -1;
              selX -= selW;
            }
            if (selH < 0) {
              selH *= -1;
              selY -= selH;
            }

            final g = <List<Cell>>[];

            selW--;
            selH--;

            for (var x = 0; x <= selW; x++) {
              g.add(<Cell>[]);
              for (var y = 0; y <= selH; y++) {
                final cx = selX + x;
                final cy = selY + y;
                if (grid.inside(cx, cy)) {
                  g.last.add(grid.at(cx, cy).copy);
                }
              }
            }

            final bp = Grid(g.length, g.isEmpty ? 0 : g.first.length);
            bp.grid = g;
            final bpSave = P4.encodeGrid(bp, title: "Unnamed Blueprint", description: "This blueprint currently has no name");

            FlutterClipboard.controlC(bpSave).then((v) {
              if (v) {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return SaveBlueprintDialog(bpSave);
                  },
                );
              }
            });

            selecting = false;
            setPos = false;
            dragPos = false;

            selW++;
            selH++;

            buttonManager.buttons['select-btn']!.texture = "interface/select.png";
          },
          () => selecting && !dragPos,
          title: 'Save as Blueprint',
          description: 'Saves selected area to clipboard as a blueprint',
        ),
      );

      buttonManager.setButton(
        "load-blueprint-btn",
        VirtualButton(
          Vector2(120, 180),
          Vector2.all(40),
          "interface/load_bp.png",
          ButtonAlignment.TOPRIGHT,
          () {
            try {
              FlutterClipboard.paste().then((txt) {
                try {
                  final blueprint = loadStr(txt, false);
                  gridClip.activate(blueprint.width, blueprint.height, blueprint.grid);
                  selecting = false;
                  setPos = false;
                  dragPos = false;
                  pasting = true;
                  buttonManager.buttons['paste-btn']?.texture = 'interface/paste_on.png';
                } catch (e) {
                  print(e);
                  showDialog(
                    context: context,
                    builder: (context) => LoadBlueprintErrorDialog(e.toString()),
                  );
                }
              });
            } catch (e) {
              print(e);
              showDialog(
                context: context,
                builder: (context) => LoadBlueprintErrorDialog(e.toString()),
              );
            }
          },
          () => true,
          title: 'Load as Blueprint',
          description: 'Loads a blueprint from your clipboard (using a P4 level code)',
        ),
      );

      buttonManager.setButton(
        "del-blueprint-btn",
        VirtualButton(
          Vector2(120, 230),
          Vector2.all(40),
          "interface/del_bp.png",
          ButtonAlignment.TOPRIGHT,
          () async {
            await showDialog(
              context: context,
              builder: (ctx) {
                return DeleteBlueprintDialog();
              },
            );
          },
          () => true,
          title: 'Delete Blueprints',
          description: 'Will reveal a popup where you can select which blueprints you want to delete',
        ),
      );

      buttonManager.setButton(
        "paste-btn",
        VirtualButton(
          Vector2(
            220,
            30,
          ),
          Vector2.all(40),
          "interface/select.png",
          ButtonAlignment.TOPRIGHT,
          () {
            game.pasting = !game.pasting;

            buttonManager.buttons['paste-btn']?.texture = game.pasting ? 'interface/paste_on.png' : 'interface/paste.png';

            buttonManager.buttons['select-btn']?.texture = "interface/select.png";
          },
          () => gridClip.active,
          title: 'Paste',
          description: 'Paste what you have copied\n(Ctrl + V)',
        ),
      );

      buttonManager.setButton(
        "onetick-btn",
        VirtualButton(
          Vector2(
            20,
            80,
          ),
          Vector2.all(40),
          "redirector.png",
          ButtonAlignment.TOPRIGHT,
          oneTick,
          () => true,
          title: 'Advance one tick',
          description: 'Steps the simulation forward by 1 tick\n(F key)',
        ),
      );

      buttonManager.setButton(
        "restore-btn",
        VirtualButton(
          Vector2(
            20,
            130,
          ),
          Vector2.all(40),
          "rotator_180.png",
          ButtonAlignment.TOPRIGHT,
          restoreInitial,
          () => !isinitial,
          title: 'Restore to initial state',
          description: 'Restores the simulation to the initial state\n(Ctrl + R)',
        ),
      );
      buttonManager.setButton(
        "setinitial-btn",
        VirtualButton(
          Vector2(
            20,
            180,
          ),
          Vector2.all(40),
          "generator.png",
          ButtonAlignment.TOPRIGHT,
          setInitial,
          () => !isinitial,
          title: 'Set Initial',
          description: 'Sets the simulation\'s current state as the initial state\n(Ctrl + I)',
        ),
      );
      buttonManager.setButton(
        "load-btn",
        VirtualButton(
          Vector2(
            120,
            80,
          ),
          Vector2.all(40),
          "interface/load.png",
          ButtonAlignment.TOPRIGHT,
          () {
            try {
              FlutterClipboard.controlV().then(
                (str) {
                  if (str is ClipboardData) {
                    isinitial = true;
                    running = false;

                    if (isMultiplayer) {
                      sendToServer('setinit ${str.text}');
                    } else {
                      try {
                        grid = loadStr(str.text ?? "");
                        QueueManager.runQueue("post-game-init");
                        timeGrid = null;
                        initial = grid.copy;
                        buttonManager.buttons['play-btn']?.texture = 'mover.png';
                        buttonManager.buttons['play-btn']?.rotation = 0;
                        buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");
                      } catch (e) {
                        showDialog(context: context, builder: (ctx) => LoadSaveErrorDialog(e.toString()));
                      }
                    }

                    buildEmpty();
                  }
                },
              );
            } catch (e) {
              print(e);
              showDialog(
                context: context,
                builder: (ctx) {
                  return LoadSaveErrorDialog(e.toString());
                },
              );
            }
          },
          () => true,
          title: 'Load from clipboard',
          description: 'Sets the grid to the level stored in the string in your clipboard',
        ),
      );
      buttonManager.setButton(
        "wrap-btn",
        VirtualButton(
          Vector2(
            120,
            130,
          ),
          Vector2.all(40),
          "interface/wrap.png",
          ButtonAlignment.TOPRIGHT,
          () {
            if (isMultiplayer) {
              sendToServer('wrap');
            } else {
              grid.wrap = !grid.wrap;
              buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");
            }
          },
          () => true,
          title: lang("wrapModeOff", 'Wrap Mode (OFF)'),
          description: 'When Wrap mode is on, cells will wrap around the grid',
        ),
      );

      loadCellButtons();

      buttonManager.buttons.forEach((id, btn) {
        btn.time = 500;
      });
    }
  }

  void loadCellButtons() {
    var catOff = 80.0;
    var leftCatOff = 80.0;
    var catSize = 60.0;

    var cellSize = 40.0;

    for (var i = 0; i < categories.length; i++) {
      buttonManager.setButton(
        'cat$i',
        VirtualButton(
          Vector2((leftCatOff - catSize) / 2 + i * catOff, catOff),
          Vector2(catSize, catSize),
          categories[i].look + '.png',
          ButtonAlignment.BOTTOMLEFT,
          () {
            final cat = categories[i]; // Kitty
            resetAllCategories(cat);

            cat.opened = !cat.opened;

            AchievementManager.complete("overload");

            for (var j = 0; j < cat.items.length; j++) {
              buttonManager.buttons['cat${i}cell$j']?.time = 0;
              buttonManager.buttons['cat${i}cell$j']?.startPos = (Vector2((leftCatOff - catSize) / 2 + i * catOff, catOff) + Vector2.all((catSize - cellSize) / 2)) * uiScale;
            }
          },
          () => true,
          title: lang("${categories[i]}.title", categories[i].title),
          description: lang(
                "${categories[i]}.desc",
                categories[i].description,
              ) +
              (debugMode ? "\nID: ${categories[i]}" : ""),
        ),
      );
      for (var j = 0; j < categories[i].items.length; j++) {
        final isCategory = (categories[i].items[j] is CellCategory);
        buttonManager.setButton(
          'cat${i}cell$j',
          VirtualButton(
            Vector2((leftCatOff - catSize) / 2 + i * catOff + (catSize - cellSize) / 2, catOff + cellSize * (j + 1)),
            Vector2(cellSize, cellSize),
            isCategory ? '${categories[i].items[j].look}.png' : '${categories[i].items[j]}.png',
            ButtonAlignment.BOTTOMLEFT,
            () {
              if (isCategory) {
                categories[i].items[j].opened = !(categories[i].items[j].opened);

                final isOpen = categories[i].items[j].opened;

                AchievementManager.complete("subcells");

                resetAllCategories(categories[i]);

                categories[i].items[j].opened = isOpen;

                for (var k = 0; k < categories[i].items[j].items.length; k++) {
                  buttonManager.buttons['cat${i}cell${j}sub$k']?.time = 0;
                  buttonManager.buttons['cat${i}cell${j}sub$k']?.startPos = Vector2((leftCatOff - catSize) / 2 + i * catOff + (catSize - cellSize) / 2, catOff + cellSize * (j + 1)) * uiScale;
                }
              } else {
                whenSelected(categories[i].items[j]);
              }
            },
            () {
              return categories[i].opened;
            },
            title: isCategory
                ? lang("${categories[i]}.${categories[i].items[j]}.title", categories[i].items[j].title)
                : lang("${categories[i].items[j]}.title", (cellInfo[categories[i].items[j]] ?? defaultProfile).title),
            description: isCategory
                ? lang('${categories[i]}.${categories[i].items[j]}.desc', categories[i].items[j].description) +
                    (debugMode ? "\nID: ${categories[i].toString()}.${categories[i].items[j].toString()}" : "")
                : lang("${categories[i].items[j].toString()}.desc", (cellInfo[categories[i].items[j]] ?? defaultProfile).description) + (debugMode ? "\nID: ${categories[i].items[j]}" : ""),
          )..time = 50,
        );

        buttonManager.buttons['cat${i}cell$j']?.duration += 0.005 * j;

        if (isCategory) {
          final cat = categories[i].items[j] as CellCategory;
          final catPos = Vector2((leftCatOff - catSize) / 2 + i * catOff + (catSize - cellSize) / 2, catOff + cellSize * (j + 1));
          for (var k = 0; k < cat.items.length; k++) {
            final cell = cat.items[k] as String;

            final xOff = cellSize + (k % cat.max) * cellSize;
            final yOff = (k ~/ cat.max) * cellSize;

            final off = Vector2(xOff, yOff);

            buttonManager.setButton(
              'cat${i}cell${j}sub$k',
              VirtualButton(
                catPos + off,
                Vector2.all(cellSize),
                "$cell.png",
                ButtonAlignment.BOTTOMLEFT,
                () => whenSelected(cell),
                () => cat.opened,
                title: lang(
                  "$cell.title",
                  (cellInfo[cell] ?? defaultProfile).title,
                ),
                description: lang(
                  "$cell.desc",
                  (cellInfo[cell] ?? defaultProfile).description + (debugMode ? "\nID: $cell" : ""),
                ),
              )
                ..time = 50
                ..duration += k * 0.005,
            );
          }
        }
      }
    }
  }

  Sprite? emptyImage;

  Future buildEmpty() async {
    final e = Flame.images.fromCache('empty.png');
    final rowCompose = ImageComposition();
    for (var x = 0; x < grid.width; x++) {
      rowCompose.add(e, Vector2(x * e.width.toDouble(), 0));
    }
    final rowImage = await rowCompose.compose();
    final emptyCompose = ImageComposition(
      defaultBlendMode: BlendMode.color,
    );
    for (var y = 0; y < grid.height; y++) {
      emptyCompose.add(
        rowImage,
        Vector2(0, y.toDouble()) * rowImage.height.toDouble(),
      );
    }
    emptyImage = Sprite(await emptyCompose.compose());
  }

  var debugMode = false;
  var interpolation = true;
  var cellbar = false;
  var altRender = false;
  var middleMove = false;
  var cursorTexture = "cursor";
  var proxyMirror = false;

  @override
  Future<void>? onLoad() async {
    debugMode = storage.getBool("debug") ?? false;
    interpolation = storage.getBool("interpolation") ?? true;
    cellbar = storage.getBool("cellbar") ?? false;
    altRender = storage.getBool("alt_render") ?? false;
    middleMove = storage.getBool("middle_move") ?? false;
    cursorTexture = storage.getString("cursor_texture") ?? "cursor";
    proxyMirror = storage.getBool("local_packet_mirror") ?? false;

    if (worldIndex != null) gridTabIndex = worldIndex!;

    await loadAllButtonTextures();

    await Flame.images.load('base.png');
    await Flame.images.load('empty.png');

    // Load effects
    await Flame.images.loadAll([
      "effects/stopped.png",
      "effects/started.png",
      "effects/heat.png",
      "effects/cold.png",
      "effects/consistent.png",
    ]);

    await loadSkinTextures();

    if (edType == EditorType.making) {
      // In sandbox
      AchievementManager.complete("editor");
    } else if (edType == EditorType.loaded) {
      // In puzzle
      AchievementManager.complete("solving");
    }

    await buildEmpty();

    // Handle multiplayer
    if (isMultiplayer) {
      channel = WebSocketChannel.connect(Uri.parse(ip!));

      loadAllButtons();

      multiplayerListener = channel.stream.listen(
        multiplayerCallback,
        onDone: () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (ctx) {
              return DisconnectionDialog();
            },
          );
        },
        onError: (e) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (ctx) {
              return BasicErrorDialog(e.toString());
            },
          );
        },
      );

      clientID = storage.getString('clientID') ?? '@uuid';

      while (clientID.contains('@uuid')) {
        clientID = clientID.replaceFirst('@uuid', Uuid().v4());
      }
      //sendToServer('version ${currentVersion.split(' ').first}');
      sendToServer('token ${jsonEncode({
            "version": currentVersion.split(' ').first,
            "clientID": clientID,
          })}');

      Flame.images.load('interface/cursor.png');

      overlays.add('loading');
    }

    cellSize = defaultCellSize.toDouble();
    if (edType == EditorType.loaded) {
      wantedCellSize /= (max(grid.width, grid.height) / 2);
      storedOffX = canvasSize.x / 2 - (grid.width / 2) * cellSize;
      storedOffY = canvasSize.y / 2 - (grid.height / 2) * cellSize;
      smoothOffX = storedOffX;
      smoothOffY = storedOffY;
    }
    await Flame.images.loadAll(
      cells.map((name) => textureMap["$name.png"] ?? "$name.png").toList(),
    );

    await Flame.images.load('mechanical/pixel_on.png');

    loadAllButtons();

    wantedCellSize = defaultCellSize;
    cellSize = defaultCellSize.toDouble();
    keys = {};
    puzzleWin = false;
    puzzleLost = false;
    delay = storage.getDouble("delay") ?? 0.15;
    realisticRendering = storage.getBool("realistic_render") ?? true;

    QueueManager.runQueue("post-game-init");

    return super.onLoad();
  }

  int get cellMouseX => (mouseX - offX) ~/ cellSize;
  int get cellMouseY => (mouseY - offY) ~/ cellSize;

  Map<String, CellCursor> cursors = {};

  void fancyRender(Canvas canvas) {
    if (realisticRendering && (running || onetick)) {
      for (var b in grid.brokenCells) {
        b.render(canvas, interpolation ? (itime % delay) / delay : 1);
      }
    }
  }

  @override
  // Main game rendering
  void render(Canvas canvas) {
    try {
      this.canvas = canvas;

      if (overlays.isActive("loading")) {
        canvas.drawRect(
          Offset.zero & Size(canvasSize.x, canvasSize.y),
          Paint()..color = Colors.black,
        );
        return;
      }

      if (emptyImage == null) {
        canvas.drawRect(
          Offset.zero & Size(canvasSize.x, canvasSize.y),
          Paint()..color = Colors.black,
        );
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: 'Building Empty Image composition',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        );
        tp.layout();

        final pos = (canvasSize - tp.size.toVector2()) / 2;

        tp.paint(
          canvas,
          pos.toOffset(),
        );
        return;
      }

      canvas.drawRect(
        Offset.zero & Size(canvasSize.x, canvasSize.y),
        Paint()..color = Colors.black,
      );

      //canvas.save();

      canvas.translate(offX, offY);

      if (!firstRender) {
        emptyImage!.render(
          canvas,
          position: Vector2.zero(),
          size: Vector2(
            grid.width * cellSize,
            grid.height * cellSize,
          ),
        );
      }

      firstRender = false;

      var sx = floor((-offX - cellSize) / cellSize);
      var sy = floor((-offY - cellSize) / cellSize);
      var ex = ceil((canvasSize.x - offX) / cellSize);
      var ey = ceil((canvasSize.y - offY) / cellSize);

      sx = max(sx, 0);
      sy = max(sy, 0);
      ex = min(ex, grid.width);
      ey = min(ey, grid.height);

      if (viewbox != null) {
        sx = viewbox!.topLeft.dx.toInt();
        sy = viewbox!.topLeft.dy.toInt();
        ex = viewbox!.bottomRight.dx.toInt();
        ey = viewbox!.bottomRight.dy.toInt();
      }

      if (realisticRendering) {
        final extra = 5;
        sx = max(sx - extra, 0);
        sy = max(sy - extra, 0);
        ex = min(ex + extra, grid.width);
        ey = min(ey + extra, grid.height);
      }

      final renderMap = <int, List<int>>{};

      for (var x = sx; x < ex; x++) {
        for (var y = sy; y < ey; y++) {
          if (!grid.inChunk(x, y, "*")) {
            x = grid.chunkToCellX(grid.cx(x) + 1); // Skip chunk
          } else {
            if (grid.inside(x, y)) {
              if (grid.at(x, y).id != "empty") {
                renderMap[x] ??= [];
                renderMap[x]!.add(y);
              }
              renderEmpty(grid.at(x, y), x, y);
            }
          }
        }
      }

      fancyRender(canvas);

      renderMap.forEach(
        (x, ys) => ys.forEach(
          (y) => renderCell(
            grid.at(x, y),
            x,
            y,
          ),
        ),
      );

      // grid.loopChunks(
      //   "all",
      //   GridAlignment.BOTTOMLEFT,
      //   renderCell,
      //   // minx: sx,
      //   // miny: sy,
      //   // maxx: ex,
      //   // maxy: ey,
      //   fastChunk: false, // Fast chunk has some problems
      //   filter: (cell, x, y) => cell.id != "empty",
      // );

      if (edType == EditorType.making && realisticRendering && mouseInside && !(pasting || selecting)) {
        var mx = cellMouseX; // shorter names
        var my = cellMouseY; // shorter names
        for (var cx = mx - brushSize; cx <= mx + brushSize; cx++) {
          for (var cy = my - brushSize; cy <= my + brushSize; cy++) {
            if (grid.inside(cx, cy)) {
              final ocx = cx;
              final ocy = cy;
              if (grid.wrap) {
                cx += grid.width;
                cx %= grid.width;
                cy += grid.height;
                cy %= grid.height;
              }
              renderCell(
                Cell(cx, cy)
                  ..id = currentSelection
                  ..rot = currentRotation
                  ..lastvars.lastRot = currentRotation
                  ..data = currentData,
                cx,
                cy,
                Paint()..color = Colors.white.withOpacity(0.5),
              );
              cx = ocx;
              cy = ocy;
            }
          }
        }
      }

      if (edType == EditorType.loaded && currentSelection != "empty" && mouseInside && !running) {
        final c = Cell(0, 0);
        c.lastvars = LastVars(currentRotation, 0, 0);
        c.lastvars.lastPos = Offset(
          (mouseX - offX) / cellSize,
          (mouseY - offY) / cellSize,
        );
        c.id = currentSelection;
        c.rot = currentRotation;
        c.data = currentData;
        renderCell(
          c,
          (mouseX - offX) / cellSize - 0.5,
          (mouseY - offY) / cellSize - 0.5,
        );
      }
      if (isMultiplayer && !running) {
        hovers.forEach(
          (id, hover) {
            if (id != clientID) {
              renderCell(
                Cell(0, 0)
                  ..id = hover.id
                  ..rot = hover.rot
                  ..data = hover.data,
                hover.x,
                hover.y,
              );
            }
          },
        );
      }

      if (pasting) {
        final mx = grid.wrap ? (cellMouseX + grid.width) % grid.width : cellMouseX;

        final my = grid.wrap ? (cellMouseY + grid.height) % grid.height : cellMouseY;
        gridClip.render(canvas, mx, my);
      } else if (selecting && setPos) {
        final selScreenX = (selX * cellSize);
        final selScreenY = (selY * cellSize);
        canvas.drawRect(
          Offset(selScreenX, selScreenY) & Size(selW * cellSize, selH * cellSize),
          Paint()..color = (Colors.grey[100].withOpacity(0.4)),
        );
      }

      redparticles.render(canvas);
      blueparticles.render(canvas);
      greenparticles.render(canvas);
      yellowparticles.render(canvas);

      //grid.forEach(renderCell);

      canvas.restore();

      if (!running) {
        cursors.forEach(
          (id, cursor) {
            if (id != clientID) {
              if (cursor.selection != "empty" && edType == EditorType.making) {
                renderCell(
                  Cell(0, 0)
                    ..id = cursor.selection
                    ..rot = cursor.rotation,
                  cursor.x + offX / cellSize,
                  cursor.y + offY / cellSize,
                );
              }

              final p = (cursor.pos + Vector2.all(0.5)) * cellSize + Vector2(offX, offY);

              var c = 'interface/cursor.png';
              // Haha cool
              if (cursor.texture != "cursor") {
                c = textureMap["${cursor.texture}.png"] ?? "${cursor.texture}.png";
              }
              if (!Flame.images.containsKey(c) || !cursorTextures.contains(cursor.texture)) c = 'base.png'; // No crashing rendering or setting stuff to other things :trell:
              // Haha cooln't
              Sprite(Flame.images.fromCache(c)).render(
                canvas,
                position: p,
                size: Vector2.all(cellSize / 2),
              );

              if (debugMode) {
                final tp = TextPainter(
                  textDirection: TextDirection.ltr,
                  text: TextSpan(
                    text: id,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: cellSize / 3,
                    ),
                  ),
                );
                tp.layout();
                tp.paint(canvas, p.toOffset());
              }
            }
          },
        );
      }

      if (cellbar && edType == EditorType.making) {
        canvas.drawRect(
          Offset(0, canvasSize.y - 110 * uiScale) & Size(canvasSize.x, 110 * uiScale),
          Paint()..color = Colors.grey[180],
        );

        final w = 5.0 * uiScale;

        canvas.drawRect(
          Offset(w, canvasSize.y - 110 * uiScale + w) & Size(canvasSize.x - w, 110 * uiScale - w),
          Paint()
            ..color = Colors.grey[60]
            ..style = PaintingStyle.stroke
            ..strokeWidth = w,
        );
      }

      AchievementRenderer.draw(canvas, canvasSize);

      buttonManager.forEach(
        (key, button) {
          button.canvasSize = canvasSize;
          button.render(canvas, canvasSize);
        },
      );

      if (debugMode && !isinitial) {
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: 'Tick Count: ${grid.tickCount}',
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
        );

        tp.layout();

        tp.paint(canvas, Offset(10 * uiScale, 70 * uiScale));
      }
      if (storage.getBool('show_titles') ?? true) {
        var hasShown = false;
        buttonManager.forEach(
          (key, button) {
            if (button.isHovered(mouseX.toInt(), mouseY.toInt()) && button.shouldRender() && mouseInside && !key.startsWith('hidden-') && !hasShown) {
              hasShown = true;
              renderInfoBox(canvas, button.title, button.description);
            }
          },
        );
      }

      if (keys[LogicalKeyboardKey.shiftLeft.keyLabel] == true && !selecting) {
        final mx = cellMouseX;
        final my = cellMouseY;

        final c = safeAt(mx, my);

        if (c != null) {
          var id = c.id;

          if (id == "empty") {
            id = grid.placeable(mx, my);
          }

          if (c.data["trick_as"] != null && edType == EditorType.loaded) {
            id = c.data["trick_as"];
          }

          renderInfoBox(canvas, (cellInfo[id] ?? defaultProfile).title, (cellInfo[id] ?? defaultProfile).description + (debugMode ? "\nID: $id" : ""));
        }
      }

      if (grid.title != "") {
        // Render title and description

        final titletp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: grid.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40 * uiScale,
            ),
          ),
        );

        titletp.layout();

        titletp.paint(
          canvas,
          Offset(
            (canvasSize.x - titletp.width) / 2,
            50 * uiScale,
          ),
        );

        if (grid.desc != "") {
          final descriptiontp = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            text: TextSpan(
              text: grid.desc,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30 * uiScale,
              ),
            ),
          );

          descriptiontp.layout(maxWidth: 50.w);

          descriptiontp.paint(
            canvas,
            Offset((canvasSize.x - descriptiontp.width) / 2, 70 * uiScale + titletp.height),
          );
        }
      }

      canvas.translate(offX, offY);

      super.render(canvas);
    } catch (e) {
      print(e);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ErrorWidget(e),
      ));
    }
  }

  void renderEmpty(Cell cell, int x, int y) {
    if (grid.placeable(x, y) != "empty" && backgrounds.contains(grid.placeable(x, y))) {
      final off = Vector2(x * cellSize.toDouble(), y * cellSize.toDouble());
      Sprite(Flame.images.fromCache(textureMap[grid.placeable(x, y) + '.png'] ?? 'backgrounds/${grid.placeable(x, y)}.png')).render(
        canvas,
        position: off,
        size: Vector2(
          cellSize.toDouble(),
          cellSize.toDouble(),
        ),
      );
    }
  }

  void drawSkin(String skin, Offset off, Paint? paint) {
    if (SkinManager.skinEnabled(skin)) {
      Sprite(Flame.images.fromCache('skins/$skin.png'))
        ..paint = paint ?? Paint()
        ..render(
          canvas,
          position: Vector2(off.dx, off.dy),
          size: Vector2.all(cellSize.toDouble()),
        );
    }
  }

  void renderCell(Cell cell, num x, num y, [Paint? paint]) {
    if ((paint?.color.opacity ?? 0) < 1 && cell.id == "empty") {
      final p = Offset(x.toDouble(), y.toDouble()) * cellSize;
      final r = p & Size(cellSize, cellSize);

      canvas.drawRect(
        r,
        Paint()
          ..color = (Colors.black.withOpacity(
            paint?.color.opacity ?? 0.5,
          )),
      );

      return;
    } // Help

    if (cell.id == "empty") return;
    if (cell.invisible) {
      if (edType == EditorType.making) {
        paint ??= Paint()..color = Colors.white.withOpacity(0.1);
      } else {
        return;
      }
    }
    var file = cell.id;

    var ignoreSafety = false;

    if ((cell.id == "pixel" && MechanicalManager.on(cell))) {
      file = 'pixel_on';
      ignoreSafety = true;
    }

    if (cell.id == "invis_tool") {
      file = "interface/tools/invis_tool";
      ignoreSafety = true;
    }

    if (file.startsWith('totrick_')) {
      file = "interface/tools/trick_tool";
      ignoreSafety = true;
    }

    if (cell.data["trick_as"] != null) {
      if (edType == EditorType.loaded) {
        file = cell.data["trick_as"]!;
      }
    }

    if (cell.id == "trick_tool") {
      file = "interface/tools/trick_tool";
      ignoreSafety = true;
    }

    if (!ignoreSafety && !cells.contains(file)) {
      file = "base";
    }

    var sprite = spriteCache['$file.png'];
    if (sprite == null) {
      sprite = Sprite(
        Flame.images.fromCache(textureMap['$file.png'] ?? '$file.png'),
      );
      spriteCache['$file.png'] = sprite;
    }
    final rot =
        (((running || onetick) && interpolation ? lerpRotation(cell.lastvars.lastRot, cell.rot, itime / delay) : cell.rot) + (edType == EditorType.loaded ? cell.data["trick_rot"] ?? 0 : 0) % 4) *
            halfPi;
    final center = Offset(cellSize.toDouble(), cellSize.toDouble()) / 2;

    const scaleX = 1;
    const scaleY = 1;

    canvas.save();

    final lp = cell.lastvars.lastPos;
    final past = Offset(
              (lp.dx + grid.width) % grid.width,
              (lp.dy + grid.height) % grid.height,
            ) *
            cellSize.toDouble() +
        center;
    final current = Offset(x.toDouble(), y.toDouble()) * cellSize.toDouble() + center;

    var off = ((running || onetick) && interpolation) ? interpolate(past, current, itime / delay) : current;

    canvas.rotate(rot);

    off = rotateOff(off, -rot) - center;

    sprite
      ..paint = paint ?? Paint()
      ..render(
        canvas,
        position: Vector2(off.dx * scaleX, off.dy * scaleY),
        size: Vector2(
          cellSize.toDouble() * scaleX,
          cellSize.toDouble() * scaleY,
        ),
      );

    if (edType == EditorType.making && cell.data["trick_as"] != null) {
      final texture = textureMap[cell.data["trick_as"] + '.png'] ?? "${cell.data["trick_as"]}.png";
      final rotoff = (cell.data["trick_rot"] ?? 0) * halfPi;
      var trick_off = rotateOff(Offset(off.dx + cellSize / 2, off.dy + cellSize / 2), -rotoff);

      canvas.rotate(rotoff);

      Sprite(Flame.images.fromCache(texture))
        ..paint = paint ?? Paint()
        ..render(
          canvas,
          position: Vector2(trick_off.dx * scaleX, trick_off.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX / 2,
            cellSize.toDouble() * scaleY / 2,
          ),
          anchor: Anchor.center,
        );

      canvas.rotate(-rotoff);
    }

    if (edType == EditorType.making && cell.id.startsWith('totrick_')) {
      final trickAs = cell.id.substring(8);
      final texture = textureMap['$trickAs.png'] ?? "$trickAs.png";

      Sprite(Flame.images.fromCache(texture))
        ..paint = paint ?? Paint()
        ..render(
          canvas,
          position: Vector2(off.dx * scaleX + cellSize / 2, off.dy * scaleY + cellSize / 2),
          size: Vector2(
            cellSize.toDouble() * scaleX / 2,
            cellSize.toDouble() * scaleY / 2,
          ),
          anchor: Anchor.center,
        );
    }

    // Skins
    if (cell.id == "puzzle") {
      drawSkin('computer', off, paint);
      drawSkin('hands', off, paint);
      drawSkin('christmas', off, paint);
    }

    // Effects
    if ((paint != null && brushTemp != 0) || ((cell.data['heat'] ?? 0) != 0 && !(cell.id == "magma" || cell.id == "snow"))) {
      final heat = paint == null ? (cell.data['heat'] ?? 0) : brushTemp;

      Sprite(Flame.images.fromCache(heat > 0 ? 'effects/heat.png' : 'effects/cold.png'))
        ..paint = paint ?? Paint()
        ..render(
          canvas,
          position: Vector2(off.dx * scaleX, off.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX,
            cellSize.toDouble() * scaleY,
          ),
        );

      final tp = TextPainter(
        text: TextSpan(
          text: "${abs(heat)}",
          style: TextStyle(
            fontSize: cellSize * 0.25,
            color: heat > 0 ? Colors.orange["light"] : Color.fromARGB(255, 33, 162, 194),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          off.dx * scaleX + cellSize * 0.3,
          off.dy * scaleY - cellSize * 0.07,
        ),
      );
    }

    final effects = <String>{};

    if (cell.tags.contains("consistent")) {
      effects.add("consistent");
    }
    if (cell.tags.contains("stopped")) {
      effects.add("stopped");
    }

    for (var effect in effects) {
      Sprite(Flame.images.fromCache("effects/$effect.png"))
        ..paint = paint ?? Paint()
        ..render(
          canvas,
          position: Vector2(off.dx * scaleX, off.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX,
            cellSize.toDouble() * scaleY,
          ),
        );
    }

    // Custom cell stuff

    var text = "";

    String countToString(num? count) {
      if (count == double.infinity) return "inf";
      if (count == double.negativeInfinity) return "-inf";
      if (count == double.nan) return "nan";

      return count.toString();
    }

    if (cell.id == "counter" || cell.id == "math_number") {
      text = countToString(cell.data['count']);
    }

    if (cell.id == "mech_trash") {
      text = "${cell.data['countdown'] ?? 0}";
      if (text == "0") text = "";
    }

    if (cell.id == "math_memwriter" || cell.id == "math_memreader") {
      text = "${cell.data['channel'] ?? 0}\n\n${cell.data['index'] ?? 0}";
    }

    if (text != "") {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: cellSize * 0.25,
            color: paint?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          off.dx * scaleX + cellSize / 2 - tp.width / 2,
          off.dy * scaleY + cellSize / 2 - tp.height / 2,
        ),
      );
    }

    canvas.restore();
  }

  // Main game update
  @override
  void update(double dt) {
    try {
      if (overlays.isActive("loading")) {
        return;
      }
      if (rerenderOverlays) {
        rerenderOverlays = false;
        final openOverlays = Set.from(overlays.value);
        for (var open in openOverlays) {
          // Force a rerender
          overlays.remove(open);
          overlays.add(open);
        }
      }
      updates++;
      if (edType == EditorType.making) {
        puzzleWin = false;
        puzzleLost = false;
      }
      redparticles.update(dt);
      blueparticles.update(dt);
      greenparticles.update(dt);
      yellowparticles.update(dt);

      AchievementRenderer.update(dt);
      buttonManager.forEach(
        (key, button) {
          button.time += dt;
          button.timeRot += dt;
        },
      );
      if (isMultiplayer && mouseInside) {
        final mx = (mouseX - offX) / cellSize - 0.5;
        final my = (mouseY - offY) / cellSize - 0.5;
        if (hovers[clientID] != null) {
          if (hovers[clientID]!.x != mx || hovers[clientID]!.y != my) {
            sendToServer(
              'set-hover $clientID $mx $my',
            );
          }
        }
        var shouldCursor = false;
        if (cursors[clientID] == null) {
          shouldCursor = true;
        } else {
          final c = cursors[clientID]!;
          shouldCursor = (c.x != mx || c.y != my || c.selection != currentSelection || c.rotation != currentRotation || c.texture != cursorTexture);
        }
        if (shouldCursor) {
          sendToServer(
            'set-cursor $clientID $mx $my $currentSelection $currentRotation $cursorTexture',
          );
        }
      }
      if (realisticRendering) {
        final speed = storage.getDouble("lerp_speed") ?? 10.0;
        final t = dt * speed;
        cellSize = lerp(cellSize, wantedCellSize.toDouble(), t);
        smoothOffX = lerp(smoothOffX, storedOffX, t);
        smoothOffY = lerp(smoothOffY, storedOffY, t);
      } else {
        cellSize = wantedCellSize.toDouble();
        smoothOffX = storedOffX;
        smoothOffY = storedOffY;
      }
      // if (overlays.isActive('CellBar')) {
      //   overlays.remove('CellBar');
      // }
      // if (!overlays.isActive('CellBar')) {
      //   overlays.add('CellBar');
      // }
      // if (!overlays.isActive('ActionBar')) {
      //   overlays.add('ActionBar');
      // }
      // if (!overlays.isActive('Info')) {
      //   overlays.add('Info');
      // }
      if (puzzleLost && edType == EditorType.loaded) {
        if (!overlays.isActive("Lose")) {
          overlays.add("Lose");
          AchievementManager.complete("loser");
        }
        return;
      }
      if (puzzleWin && edType == EditorType.loaded) {
        if ((!overlays.isActive("Win"))) {
          overlays.add("Win");
          CoinManager.give(Random().nextInt(7) + 3);
          AchievementManager.complete("winner");
        }
        return;
      }
      if (!overlays.isActive("EditorMenu")) {
        if ((running || onetick)) {
          itime += dt;

          while (itime > delay) {
            itime -= delay;
            if (onetick) {
              onetick = false;
              itime = 0;
            } else {
              grid.update(); // Update the cells boizz
            }
          }
        }

        const speed = 600;
        if (keys[LogicalKeyboardKey.keyW.keyLabel] == true) {
          storedOffY += speed * dt;
        }
        if (keys[LogicalKeyboardKey.keyS.keyLabel] == true) {
          storedOffY -= speed * dt;
        }
        if (keys[LogicalKeyboardKey.keyA.keyLabel] == true) {
          storedOffX += speed * dt;
        }
        if (keys[LogicalKeyboardKey.keyD.keyLabel] == true) {
          storedOffX -= speed * dt;
        }

        if (selecting && dragPos && setPos) {
          final ex = max(min(cellMouseX, grid.width - 1), -1);
          final ey = max(min(cellMouseY, grid.height - 1), -1);

          selW = ex - selX + 1;
          selH = ey - selY + 1;
        }

        if (!(pasting || selecting || edType == EditorType.loaded)) {
          if (mouseDown) {
            final mx = (mouseX - offX) ~/ cellSize;
            final my = (mouseY - offY) ~/ cellSize;
            for (var cx = mx - brushSize; cx <= mx + brushSize; cx++) {
              for (var cy = my - brushSize; cy <= my + brushSize; cy++) {
                if (grid.inside(cx, cy)) {
                  if (mouseButton == kPrimaryMouseButton) {
                    placeCell(currentSelection, currentRotation, cx, cy);
                  } else if (mouseButton == kSecondaryMouseButton) {
                    placeCell("empty", 0, cx, cy);
                  }
                }
              }
            }
            if (mouseButton == kMiddleMouseButton && !middleMove) {
              if (grid.inside(mx, my)) {
                final id = grid.at(mx, my).id;
                final p = grid.placeable(mx, my);

                if (edType == EditorType.making) {
                  if (cells.contains(id)) {
                    currentSelection = id;
                    animatePropertyEditor();
                    if (id == "empty" && cells.contains(p)) {
                      currentSelection = p;
                    } else {
                      currentRotation = grid.at(mx, my).rot;
                      currentData = {...grid.at(mx, my).data};
                    }
                  }
                }
              }
            }
          }
        }
      }

      super.update(dt);
    } catch (e) {
      print(e);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ErrorWidget(e),
      ));
    }
  }

  bool get inMenu => overlays.isActive('EditorMenu');

  void onMouseEnter(PointerEvent e) {
    mouseX = e.localPosition.dx;
    mouseY = e.localPosition.dy;
    mouseInside = true;
  }

  String originalPlace = "empty";

  String cellDataStr(Map<String, dynamic> cellData) {
    if (cellData.isEmpty) return "0";

    final l = [];

    cellData.forEach((key, value) {
      l.add("$key=${P4.encodeValue(value)}");
    });

    return l.join(':');
  }

  void placeCell(String id, int rot, int cx, int cy) {
    if (id == "invis_tool") {
      mouseDown = false;
      if (grid.inside(cx, cy) && grid.at(cx, cy).id != "empty") {
        if (isinitial && isMultiplayer) {
          sendToServer("toggle-invis $cx $cy");
        } else {
          grid.at(cx, cy).invisible = !grid.at(cx, cy).invisible;
        }
      }
      return;
    }
    if (id.startsWith('totrick_')) {
      mouseDown = false;
      if (grid.inside(cx, cy)) {
        final trickAs = id.substring(8);
        final trickRotOff = (rot - grid.at(cx, cy).rot) % 4;
        if (isinitial && isMultiplayer) {
          final d = Map<String, dynamic>.from(grid.at(cx, cy).data);
          d["trick_as"] = trickAs;
          d["trick_rot"] = trickRotOff;
          sendToServer("place $cx $cy ${grid.at(cx, cy).id} ${grid.at(cx, cy).rot} ${cellDataStr(d)}");
        } else {
          grid.at(cx, cy).data["trick_as"] = trickAs;
          grid.at(cx, cy).data["trick_rot"] = trickRotOff;
        }
      }
      return;
    }
    if (!grid.inside(cx, cy)) return;
    if (edType == EditorType.making) {
      //if (grid.at(cx, cy).id == id && grid.at(cx, cy).rot == rot) return;
      if (!isMultiplayer || !isinitial)
        grid.set(
          cx,
          cy,
          Cell(cx, cy)
            ..id = id
            ..rot = rot
            ..lastvars.lastRot = rot
            ..data = {...currentData},
        );
      if (brushTemp != 0) {
        if (!isMultiplayer) grid.at(cx, cy).data['heat'] = brushTemp;
      }
      if (id == "empty" && backgrounds.contains(currentSelection)) {
        if (!isMultiplayer) grid.setPlace(cx, cy, "empty");
        sendToServer("bg $cx $cy empty");
      } else {
        if (backgrounds.contains(id)) {
          sendToServer(
            "bg $cx $cy $id",
          );
        } else {
          sendToServer(
            "place $cx $cy $id $rot ${cellDataStr({...currentData, "heat": brushTemp})}",
          );
        }
      }
    } else if (edType == EditorType.loaded) {
      if (grid.placeable(cx, cy) == "rotatable") {
        if (!isMultiplayer) {
          grid.at(cx, cy).rot++;
          grid.at(cx, cy).rot %= 4;
        }
        sendToServer(
          'place $cx $cy ${grid.at(cx, cy).id} ${grid.at(cx, cy).rot} ${cellDataStr(grid.at(cx, cy).data)}',
        );
        return;
      }
      if (biomes.contains(grid.placeable(cx, cy))) return;
      if (id == "empty" && grid.at(cx, cy).id != "empty") {
        currentSelection = grid.at(cx, cy).id;
        animatePropertyEditor();
        currentRotation = grid.at(cx, cy).rot;
        originalPlace = grid.placeable(cx, cy);
        currentData = grid.at(cx, cy).data;
        if (!isMultiplayer) grid.set(cx, cy, Cell(cx, cy));
        sendToServer('place $cx $cy empty 0 0');
        sendToServer(
          'new-hover $clientID $cx $cy $currentSelection $currentRotation ${P4.encodeValue(currentData)}',
        );
      } else if (grid.at(cx, cy).id == "empty" && grid.placeable(cx, cy) == originalPlace) {
        if (!isMultiplayer) {
          grid.set(
            cx,
            cy,
            Cell(cx, cy)
              ..id = id
              ..rot = rot
              ..lastvars.lastRot = rot
              ..data = {...currentData},
          );
        }
        currentSelection = "empty";
        animatePropertyEditor();
        currentRotation = 0;
        sendToServer(
          'place $cx $cy $id $rot ${cellDataStr(currentData)}',
        );
        currentData = {};
        sendToServer('drop-hover $clientID');
      }
    }
  }

  // void onTapDown(TapDownInfo info) {
  //   final cx = (info.eventPosition.global.x - offX) ~/ cellSize;
  //   final cy = (info.eventPosition.global.y - offY) ~/ cellSize;
  //   final cell = cells[currentSeletion];

  //   if (grid.inside(cx, cy) && cell == "place") {
  //     placeCell(currentSeletion, 0, cx, cy);
  //   }
  // }

  Future<void> onPointerUp(PointerUpEvent event) async {
    mouseDown = false;
    if (selecting && setPos) {
      dragPos = false;
    }
  }

  void resetAllCategories([CellCategory? except]) {
    for (var category in categories) {
      var wasOpened = category.opened;
      if (category != except) {
        category.opened = false;
        for (var item in category.items) {
          if (wasOpened) {
            buttonManager.buttons['cat${categories.indexOf(category)}cell${category.items.indexOf(item)}']?.time = 0;
          }
        }
      }
      for (var item in category.items) {
        if (item is CellCategory) {
          final wasopen = item.opened;
          item.opened = false;
          if (wasopen) {
            for (var subitem in item.items) {
              final btn = buttonManager.buttons['cat${categories.indexOf(category)}cell${category.items.indexOf(item)}sub${item.items.indexOf(subitem)}'];
              if (btn != null) {
                if (btn.hasRendered) {
                  btn.time = 0;
                }
              }
            }
          }
        }
      }
    }
  }

  double get globalMouseX => (mouseX - offX) / cellSize - 0.5;
  double get globalMouseY => (mouseY - offY) / cellSize - 0.5;

  Future<void> onPointerDown(PointerDownEvent event) async {
    if (overlays.isActive("loading")) {
      return;
    }
    if (event.down && event.kind == PointerDeviceKind.mouse) {
      mouseX = event.position.dx;
      mouseY = event.position.dy;
      if (true) {
        mouseButton = event.buttons;
        mouseDown = true;
        buttonManager.forEach((key, button) {
          if (button.shouldRender() && button.isHovered(mouseX.toInt(), mouseY.toInt())) {
            button.callback();
            mouseDown = false;
          }
        });
        if (mouseY > (canvasSize.y - 110 * uiScale) && cellbar && edType == EditorType.making) {
          mouseDown = false;
        }
        if (edType == EditorType.loaded && mouseDown && !running) {
          mouseDown = false;
          bool hijacked = false;
          final gmx = globalMouseX;
          final gmy = globalMouseY;
          String hijackedHover = "";
          if (currentSelection == "empty") {
            hovers.forEach(
              (id, hover) {
                if (gmx >= hover.x - 0.5 && gmx <= hover.x + 0.5 && gmy >= hover.y - 0.5 && gmy < hover.y + 0.5) {
                  hijacked = true;
                  sendToServer(
                    'new-hover $clientID $cellMouseX $cellMouseY ${hover.id} ${hover.rot} ${P4.encodeValue(hover.data)}',
                  );
                  currentSelection = hover.id;
                  currentRotation = hover.rot;
                  originalPlace = backgrounds.first;
                  currentData = Map.from(hover.data);
                  hijackedHover = id;
                }
              },
            );
          }
          if (hijackedHover != "") {
            sendToServer('drop-hover $hijackedHover');
          }
          if (hijacked) return;
          if (grid.inside(cellMouseX, cellMouseY) && grid.placeable(cellMouseX, cellMouseY) != "empty") {
            placeCell(
              currentSelection,
              currentRotation,
              cellMouseX,
              cellMouseY,
            );
          }
          return;
        }
        if (puzzleWin || puzzleLost) mouseDown = false;
        if (!mouseDown) return;
        if (selecting) {
          setPos = true;
          dragPos = true;
          selX = max((mouseX - offX) ~/ cellSize, 0);
          selY = max((mouseY - offY) ~/ cellSize, 0);
        } else if (pasting) {
          paste();
          pasting = false;
          selecting = false;
          setPos = false;
          dragPos = false;
          mouseDown = false;
          buttonManager.buttons['select-btn']!.texture = "interface/select.png";
          buttonManager.buttons['paste-btn']!.texture = "interface/paste.png";
          selecting = false;
          setPos = false;
        }
      }
    }
  }

  var rerenderOverlays = false;

  @override
  void onGameResize(Vector2 screenSize) {
    super.onGameResize(screenSize);
    ScaleAssist.setNewSize(screenSize.toOffset());
    rerenderOverlays = true;
  }

  void zoomout() {
    if (inMenu) return;
    if (wantedCellSize > (defaultCellSize) / 16) {
      final lastZoom = wantedCellSize;
      wantedCellSize /= 2;
      wantedCellSize = max(
        wantedCellSize,
        (defaultCellSize / 16),
      );
      properlyChangeZoom(lastZoom, wantedCellSize);
    }
  }

  void zoomin() {
    if (inMenu) return;
    if (wantedCellSize < (defaultCellSize) * 512) {
      final lastZoom = wantedCellSize;
      wantedCellSize *= 2;
      wantedCellSize = min(wantedCellSize, defaultCellSize * 512);
      properlyChangeZoom(lastZoom, wantedCellSize);
    }
  }

  void setInitial() {
    if (inMenu) return;
    genOptimizer.clear();
    initial = grid.copy;
    isinitial = true;
    running = false;
    buttonManager.buttons["play-btn"]!.texture = "mover.png";
    buttonManager.buttons["play-btn"]!.rotation = 0;
    timeGrid = null;
    if (isMultiplayer) sendToServer('setinit ${P4.encodeGrid(grid)}');
    grid.tickCount = 0;
  }

  void restoreInitial() {
    if (inMenu) return;
    genOptimizer.clear();
    bool differentSize = (grid.width != initial.width || grid.height != initial.height);
    grid = initial.copy;
    isinitial = true;
    puzzleWin = false;
    puzzleLost = false;
    overlays.remove('Win');
    running = false;
    buttonManager.buttons['wrap-btn']?.title = grid.wrap ? lang('wrapModeOn', "Wrap Mode (ON)") : lang("wrapModeOff", "Wrap Mode (OFF)");
    buttonManager.buttons["play-btn"]!.texture = "mover.png";
    buttonManager.buttons["play-btn"]!.rotation = 0;
    if (differentSize) buildEmpty();
    timeGrid = null;
    grid.tickCount = 0;
  }

  bool onetick = false;

  void oneTick() {
    if (inMenu) return;
    if (!running) {
      if (isinitial) {
        initial = grid.copy;
      }
      grid.update();
      itime = 0;
      isinitial = false;
      onetick = true;
    }
  }

  void playPause() {
    if (inMenu) return;
    running = !running;
    if (edType == EditorType.loaded) {
      isinitial = true;
      if (currentSelection != "empty") return;
    }
    if (running) {
      if (isinitial) {
        initial = grid.copy;
      }
      isinitial = false;
      playerKeys = 0;
      buttonManager.buttons["play-btn"]!.texture = "slide.png";
      buttonManager.buttons["play-btn"]!.rotation = 1;
      itime = delay;
      AchievementManager.complete("start");
    } else {
      if (edType == EditorType.loaded) {
        restoreInitial();
      }
      puzzleWin = false;
      puzzleLost = false;
      overlays.remove("Win");
      overlays.remove("Lose");
      buttonManager.buttons["play-btn"]!.texture = "mover.png";
      buttonManager.buttons["play-btn"]!.rotation = 0;
    }
  }

  void q() {
    if (inMenu) return;
    if (edType == EditorType.making) {
      if (pasting) {
        gridClip.rotate(RotationalType.counter_clockwise);
      } else {
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.lastRot = game.currentRotation;
          buttonManager.buttons['cat$i']!.timeRot = 0;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.lastRot = game.currentRotation;
            buttonManager.buttons['cat${i}cell$j']!.timeRot = 0;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.lastRot = game.currentRotation;
                buttonManager.buttons['cat${i}cell${j}sub$k']!.timeRot = 0;
              }
            }
          }
        }
        game.currentRotation += 3;
        game.currentRotation %= 4;
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.rotation = game.currentRotation;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.rotation = game.currentRotation;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.rotation = game.currentRotation;
              }
            }
          }
        }
      }
    }
  }

  void e() {
    if (inMenu) return;
    if (edType == EditorType.making) {
      if (pasting) {
        gridClip.rotate(RotationalType.clockwise);
      } else {
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.lastRot = game.currentRotation;
          buttonManager.buttons['cat$i']!.timeRot = 0;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.lastRot = game.currentRotation;
            buttonManager.buttons['cat${i}cell$j']!.timeRot = 0;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.lastRot = game.currentRotation;
                buttonManager.buttons['cat${i}cell${j}sub$k']!.timeRot = 0;
              }
            }
          }
        }
        game.currentRotation += 1;
        game.currentRotation %= 4;
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.rotation = game.currentRotation;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.rotation = game.currentRotation;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.rotation = game.currentRotation;
              }
            }
          }
        }
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      final keysDown = keysPressed.map<String>((e) => e.keyLabel).toSet();
      if (keysPressed.contains(LogicalKeyboardKey.altLeft)) {
        // Alternative stuffz
      } else {
        if (keysDown.contains(LogicalKeyboardKey.keyQ.keyLabel)) {
          q();
        } else if (keysDown.contains(LogicalKeyboardKey.keyE.keyLabel)) {
          e();
        } else if (keysDown.contains(LogicalKeyboardKey.space.keyLabel) && !(keys[LogicalKeyboardKey.space.keyLabel] == true)) {
          playPause();
        } else if (keysDown.contains(LogicalKeyboardKey.escape.keyLabel) || keysDown.contains(LogicalKeyboardKey.backspace.keyLabel)) {
          if (pasting) {
            pasting = false;
            buttonManager.buttons['select-btn']!.texture = "interface/select.png";
            buttonManager.buttons['paste-btn']!.texture = "interface/paste.png";
          } else {
            if (edType == EditorType.making) {
              if (!overlays.isActive("EditorMenu")) {
                overlays.add("EditorMenu");
              } else {
                overlays.remove("EditorMenu");
              }
            }
          }
        } else if (keysDown.contains(LogicalKeyboardKey.keyF.keyLabel) && edType == EditorType.making) {
          oneTick();
        } else if (keysDown.contains(LogicalKeyboardKey.escape.keyLabel) && edType == EditorType.making) {
          if (!overlays.isActive("EditorMenu")) {
            overlays.add("EditorMenu");
          } else {
            overlays.remove("EditorMenu");
          }
        } else if (keysDown.contains(LogicalKeyboardKey.keyZ.keyLabel)) {
          delay /= 2;
          delay = max(delay, 0.01);
        } else if (keysDown.contains(LogicalKeyboardKey.keyX.keyLabel) && !keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          delay *= 2;
          delay = min(delay, 1);
        } else if (keysDown.contains(LogicalKeyboardKey.keyI.keyLabel) && keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          if (edType == EditorType.making) setInitial();
        } else if (keysDown.contains(LogicalKeyboardKey.keyR.keyLabel) && keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          if (edType == EditorType.making) restoreInitial();
        } else if (keysDown.contains(LogicalKeyboardKey.keyV.keyLabel) && keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          game.pasting = !game.pasting;

          buttonManager.buttons['paste-btn']?.texture = game.pasting ? 'interface/paste_on.png' : 'interface/paste.png';

          buttonManager.buttons['select-btn']?.texture = "interface/select.png";
        } else if (keysDown.contains(LogicalKeyboardKey.keyC.keyLabel) && keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          if (selecting) copy();
        } else if (keysDown.contains(LogicalKeyboardKey.keyX.keyLabel) && keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
          if (selecting) {
            copy();
            for (var x = 0; x < selW; x++) {
              for (var y = 0; y < selH; y++) {
                final cx = selX + x;
                final cy = selY + y;
                if (grid.inside(cx, cy)) {
                  if (!isMultiplayer) grid.set(cx, cy, Cell(cx, cy));
                  sendToServer('place $cx $cy empty 0 0');
                }
              }
            }
          }
        }

        final arrowKeys = [
          LogicalKeyboardKey.arrowUp.keyLabel,
          LogicalKeyboardKey.arrowDown.keyLabel,
          LogicalKeyboardKey.arrowLeft.keyLabel,
          LogicalKeyboardKey.arrowRight.keyLabel,
        ];

        if (keysDown.containsAny(arrowKeys) && selecting) {
          if (keysDown.contains(LogicalKeyboardKey.shiftLeft.keyLabel)) {
            if (keysDown.contains(arrowKeys[0])) {
              selY--;
            }
            if (keysDown.contains(arrowKeys[1])) {
              selY++;
            }
            if (keysDown.contains(arrowKeys[2])) {
              selX--;
            }
            if (keysDown.contains(arrowKeys[3])) {
              selX++;
            }
          } else if (keysDown.contains(LogicalKeyboardKey.controlLeft.keyLabel)) {
            if (keysDown.contains(arrowKeys[0])) {
              selH--;
            }
            if (keysDown.contains(arrowKeys[1])) {
              selH++;
            }
            if (keysDown.contains(arrowKeys[2])) {
              selW--;
            }
            if (keysDown.contains(arrowKeys[3])) {
              selW++;
            }
          } else {
            if (selW < 0) {
              selW *= -1;
              selX -= selW;
            }
            if (selH < 0) {
              selH *= -1;
              selY -= selH;
            }

            var nsx = selX;
            var nsy = selY;

            if (keysDown.contains(arrowKeys[0])) {
              nsy--;
            }
            if (keysDown.contains(arrowKeys[1])) {
              nsy++;
            }
            if (keysDown.contains(arrowKeys[2])) {
              nsx--;
            }
            if (keysDown.contains(arrowKeys[3])) {
              nsx++;
            }
            var shouldMove = true;

            if (nsx < 0) {
              shouldMove = false;
            }
            if (nsy < 0) {
              shouldMove = false;
            }
            if (nsx > grid.width - selW) {
              shouldMove = false;
            }
            if (nsy > grid.height - selH) {
              shouldMove = false;
            }

            if (shouldMove) {
              final s = [];

              for (var x = 0; x < selW; x++) {
                for (var y = 0; y < selH; y++) {
                  final cx = selX + x;
                  final cy = selY + y;
                  if (grid.inside(cx, cy)) {
                    s.add(grid.at(cx, cy).copy);
                    if (!isMultiplayer) grid.set(cx, cy, Cell(cx, cy));
                    sendToServer('place $cx $cy empty 0 0');
                  }
                }
              }

              var i = 0;
              for (var x = 0; x < selW; x++) {
                for (var y = 0; y < selH; y++) {
                  final cx = nsx + x;
                  final cy = nsy + y;
                  if (grid.inside(cx, cy)) {
                    final c = s[i];
                    i++;
                    if (!isMultiplayer) grid.set(cx, cy, c);
                    sendToServer('place $cx $cy ${c.id} ${c.rot} ${cellDataStr(c.data)}');
                    if (c.invisible) sendToServer('toggle-invis $cx $cy');
                  }
                }
              }

              selX = nsx;
              selY = nsy;
            }
          }
        }
      }
      for (var key in keysPressed) {
        //print(key);
        keys[key.keyLabel] = true;
      }
      return KeyEventResult.handled;
    } else if (event is RawKeyUpEvent) {
      for (var key in LogicalKeyboardKey.knownLogicalKeys) {
        keys[key.keyLabel] = event.isKeyPressed(key);
      }
      //keysPressed.forEach((e) => keys[e] = true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class EnemyParticle {
  Offset off;
  late final Offset dir;
  double lifetime = 0;
  double speed;
  double size;

  EnemyParticle(this.off, this.speed, this.size) {
    dir = Offset.fromDirection(Random().nextDouble() * 2 * pi);
  }

  void update(double dt) {
    off += dir * speed * dt;
    lifetime += dt;
  }
}

class ParticleSystem {
  final particles = <EnemyParticle>[];

  final double size;
  final double minsize;
  final double minspeed;
  final double speed;
  final double lifespan;
  final Color? color;

  ParticleSystem(
    this.speed,
    this.minspeed,
    this.size,
    this.minsize,
    this.lifespan,
    this.color,
  );

  void update(double dt) {
    particles.forEach(
      (particle) {
        particle.update(dt);
      },
    );

    particles.removeWhere((p) => p.lifetime >= lifespan);
  }

  void render(Canvas canvas) {
    particles.forEach(
      (particle) {
        final s = Size.square(particle.size);
        canvas.drawRect(
            (particle.off * cellSize - (s * cellSize / 2).toOffset()) & (s * cellSize),
            Paint()
              ..color = (color!.withOpacity(
                (lifespan - particle.lifetime) / lifespan,
              )));
      },
    );
  }

  void emit(int amount, int x, int y) {
    for (var i = 0; i < amount; i++) {
      particles.add(
        EnemyParticle(
          Offset(x.toDouble() + 0.5, y.toDouble() + 0.5),
          Random().nextDouble() * (speed - minspeed) + minspeed,
          Random().nextDouble() * (size - minsize) + minsize,
        ),
      );
    }
  }
}

// extension on ui.Size {
//   ui.Offset toOffset() {
//     return Offset(width, height);
//   }
// }
