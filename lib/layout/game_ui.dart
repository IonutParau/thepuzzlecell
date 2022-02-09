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

var cellsPerPage = 9;

num abs(num n) => n < 0 ? -n : n;

class GameUI extends StatefulWidget {
  final EditorType editorType;

  GameUI({Key? key, this.editorType = EditorType.making}) : super(key: key);

  @override
  _GameUIState createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> {
  final scrollController = ScrollController();

  int page = 0;

  void clampPage() {
    page = min(max(page, 0), cells.length ~/ cellsPerPage);
  }

  @override
  void initState() {
    game = PuzzleGame();
    game.edType = widget.editorType;

    super.initState();
  }

  Widget cellToImage(String cell) {
    final index = (game.edType == EditorType.making ? cells : game.cellsToPlace)
        .indexOf(cell);
    return Container(
      child: SizedBox(
        width: 8.w,
        height: 8.w,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Tooltip(
                message: profileToMessage(cellInfo[cell] ?? defaultProfile),
                textStyle: TextStyle(
                  fontSize: 5.sp,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(0.5.sp),
                ),
                preferBelow: false,
                child: MaterialButton(
                  onPressed: () => setState(() => game.currentSeletion = index),
                  height: 2.w,
                  minWidth: 2.w,
                  child: Opacity(
                    opacity: (game.currentSeletion == index) ? 1 : 0.3,
                    child: MouseRegion(
                      child: RotatedBox(
                        quarterTurns: game.currentRotation,
                        child: Image.asset(
                          'assets/images/$cell.png',
                          width: 2.w,
                          height: 2.w,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (cell != "empty" && game.edType == EditorType.loaded)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  game.cellsCount[index].toString(),
                  style: fontSize(
                    7.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget categoryToImage(CellCategory category) {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: Tooltip(
        message: '${category.title} - ${category.description}',
        textStyle: TextStyle(
          fontSize: 5.sp,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(0.5.sp),
        ),
        preferBelow: false,
        margin: EdgeInsets.all(2.w),
        child: Container(
          color: Colors.grey[850],
          child: MaterialButton(
            child: Center(
              child: Image.asset(
                'assets/images/${category.look}.png',
                width: 3.w,
                height: 3.w,
                fit: BoxFit.fill,
              ),
            ),
            onPressed: () {
              category.opened = !category.opened;
            },
          ),
        ),
      ),
    );
  }

  void goLeft() {
    setState(
      () {
        page--;
        clampPage();
      },
    );
  }

  void goRight() {
    setState(
      () {
        page++;
        clampPage();
      },
    );
  }

  void nextPuzzle() {
    if (puzzleIndex != null) {
      puzzleIndex = puzzleIndex! + 1;
      if (puzzleIndex! >= puzzles.length) {
        Navigator.pop(context);
        puzzleIndex = null;
        return;
      }
      game.running = false;
      game = PuzzleGame();
      loadPuzzle(puzzleIndex!);
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/game-loaded');
    }
  }

  List<Widget> cellbarItems() {
    final list = <Widget>[];
    list.add(
      MaterialButton(
        height: 5.w,
        child: Text(
          "Back",
          style: fontSize(
            6.sp,
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("Confirm exit?"),
                content: Text(
                    "You have pressed the Back button, which exits the game. Do you confirm exit?"),
                actions: [
                  MaterialButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  MaterialButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    if (game.edType == EditorType.loaded) {
      for (var cell in game.cellsToPlace) {
        list.add(cellToImage(cell));
      }
    }

    if (game.edType == EditorType.making) {
      for (var category in categories) {
        list.add(categoryToImage(category));
        if (category.opened) {
          for (var cell in category.items) {
            list.add(cellToImage(cell));
          }
        }
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    game.context = context;
    return Scaffold(
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Center(
          child: MouseRegion(
            onExit: (e) => game.onMouseExit(),
            onEnter: game.onMouseEnter,
            onHover: (e) {
              game.mouseX = e.localPosition.dx;
              game.mouseY = e.localPosition.dy;
            },
            child: Listener(
              onPointerDown: game.onPointerDown,
              onPointerMove: game.onPointerMove,
              onPointerUp: game.onPointerUp,
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  if (event.scrollDelta.dy < 0) {
                    game.zoomin();
                  } else if (event.scrollDelta.dy > 0) {
                    game.zoomout();
                  }
                }
              },
              child: GameWidget(
                game: game,
                initialActiveOverlays: [],
                overlayBuilderMap: {
                  'ActionBar': (ctx, _) {
                    return LayoutBuilder(
                      builder: (ctx, size) {
                        final s = 8.sp;
                        return Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 100.w,
                            height: 5.h,
                            child: Container(
                              color: Colors.grey[900],
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  if (game.running)
                                    Tooltip(
                                      message:
                                          'Change the delay inbetween ticks. Current: ${game.delay}s',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: Slider(
                                        value: max(min(game.delay, 5), 0.01),
                                        onChanged: (n) => setState(
                                          () => game.delay = n,
                                        ),
                                        min: 0.01,
                                        max: 5,
                                      ),
                                    ),
                                  Tooltip(
                                    message: 'Save grid to clipboard',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: Image.asset(
                                        'assets/interface/save.png',
                                        width: s,
                                        height: s,
                                        fit: BoxFit.fill,
                                      ),
                                      onPressed: () =>
                                          FlutterClipboard.controlC(
                                        P2.encodeGrid(grid),
                                      ),
                                    ),
                                  ),
                                  if (game.edType == EditorType.making)
                                    Tooltip(
                                      message: 'Load grid from clipboard',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: MaterialButton(
                                        child: Image.asset(
                                          'assets/interface/load.png',
                                          width: s,
                                          height: s,
                                          fit: BoxFit.fill,
                                        ),
                                        onPressed: () {
                                          if (!game.running) {
                                            try {
                                              FlutterClipboard.paste().then(
                                                (val) {
                                                  try {
                                                    grid = loadStr(val);
                                                    game.cellsToPlace = [
                                                      "empty"
                                                    ];
                                                    game.cellsCount = [1];
                                                  } catch (e) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Invalid save code',
                                                          ),
                                                          content: Text(
                                                            'You are trying to load a corrupted, invalid or unsupported level code.',
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                              );
                                            } catch (e) {}
                                          }
                                        },
                                      ),
                                    ),
                                  if (game.edType == EditorType.making) ...[
                                    Tooltip(
                                      message: 'Toggle SELECT mode',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: Opacity(
                                        opacity: game.selecting ? 1 : 0.2,
                                        child: MaterialButton(
                                          child: Image.asset(
                                            'assets/interface/select.png',
                                            width: s,
                                            height: s,
                                            fit: BoxFit.fill,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              game.selecting = !game.selecting;
                                              if (!game.selecting) {
                                                game.setPos = false;
                                                game.dragPos = false;
                                              }
                                              game.pasting = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Copy selected area',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: MaterialButton(
                                        child: Image.asset(
                                          'assets/interface/copy.png',
                                          width: s,
                                          height: s,
                                          fit: BoxFit.fill,
                                        ),
                                        onPressed: () {
                                          if (game.selecting && game.setPos) {
                                            game.copy();
                                          }
                                        },
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Paste copied area',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: MaterialButton(
                                        child: Image.asset(
                                          'assets/interface/paste.png',
                                          width: s,
                                          height: s,
                                          fit: BoxFit.fill,
                                        ),
                                        onPressed: () {
                                          if (game.pasting) {
                                            game.pasting = false;
                                          } else {
                                            game.pasting = true;
                                            game.selecting = false;
                                            game.setPos = false;
                                            game.dragPos = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                  if (game.edType == EditorType.making)
                                    Tooltip(
                                      message:
                                          'Toggle WRAP mode, if enabled makes cells wrap around the grid',
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 7.sp,
                                        color: Colors.white,
                                      ),
                                      child: Opacity(
                                        opacity: grid.wrap ? 1 : 0.2,
                                        child: MaterialButton(
                                          child: Image.asset(
                                            'assets/interface/wrap.png',
                                            width: s,
                                            height: s,
                                            fit: BoxFit.fill,
                                          ),
                                          onPressed: () {
                                            if (!game.running) {
                                              grid.wrap = !grid.wrap;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  Tooltip(
                                    message: 'Play / Retry the game',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: RotatedBox(
                                        quarterTurns: game.running ? 1 : 0,
                                        child: Image.asset(
                                          game.running
                                              ? 'assets/images/slide.png'
                                              : 'assets/images/mover.png',
                                          width: s,
                                          height: s,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      onPressed: game.playPause,
                                    ),
                                  ),
                                  Tooltip(
                                    message:
                                        'Rotate CellBar 90 degrees clockwise',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: Image.asset(
                                        'assets/images/rotator_cw.png',
                                        width: s,
                                        height: s,
                                        fit: BoxFit.fill,
                                      ),
                                      onPressed: game.e,
                                    ),
                                  ),
                                  Tooltip(
                                    message:
                                        'Rotate CellBar 90 degrees counter-clockwise',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: Image.asset(
                                        'assets/images/rotator_ccw.png',
                                        width: s,
                                        height: s,
                                        fit: BoxFit.fill,
                                      ),
                                      onPressed: game.q,
                                    ),
                                  ),
                                ].reversed.toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  'CellBar': (ctx, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () => game.mouseDown = false,
                                child: Container(
                                  width: 100.w,
                                  height: 8.h,
                                  color: Colors.grey[900],
                                  child: Scrollbar(
                                    thickness: 0.5.h,
                                    controller: scrollController,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      controller: scrollController,
                                      cacheExtent: 0,
                                      addAutomaticKeepAlives: false,
                                      children: cellbarItems(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  "Info": (ctx, _) {
                    var infoText = "";
                    if (game.running) infoText += "[Playing] ";
                    if (grid.wrap && game.edType == EditorType.making)
                      infoText += "[Wrap Mode] ";
                    return Text(infoText);
                  },
                  "Win": (ctx, _) {
                    return Stack(
                      children: [
                        Center(
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
                        ),
                      ],
                    );
                  }
                },
              ),
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

void loadAllButtonTextures() {
  Flame.images.loadAll([
    "back.png",
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

  VirtualButton(this.position, Vector2 size, this.texture, this.alignment,
      this.callback, this.shouldRender,
      {this.title = "Untitled", this.description = "No description"})
      : rotation = 0,
        lastRot = 0,
        startPos = position * storage.getDouble('ui_scale')!,
        this.size = size * storage.getDouble('ui_scale')! {
    position *= storage.getDouble('ui_scale')!;
  } // Constructors

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

    if (shouldRender()) {
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
      screenPos = Vector2(
          canvasSize.x - untranslatedPostion.x - size.x, untranslatedPostion.y);
    } else if (alignment == ButtonAlignment.BOTTOMLEFT) {
      screenPos =
          Vector2(untranslatedPostion.x, canvasSize.y - untranslatedPostion.y);
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

    if (mouseX >= screenPos.x &&
        mouseX <= screenPos.x + size.x &&
        mouseY >= screenPos.y &&
        mouseY <= screenPos.y + size.y) {
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
  }

  void forEach(void Function(String key, VirtualButton button) callback) {
    buttons.forEach(callback);
  }

  void removeButton(String key) {
    buttons.remove(key);
  }
}

void renderInfoBox(Canvas canvas, String title, String description) {
  final mouseX = max(game.mouseX, 10).toDouble();
  final mouseY = max(game.mouseY, 10).toDouble();

  final titleTP = TextPainter(
      textWidthBasis: TextWidthBasis.longestLine,
      textDirection: TextDirection.ltr);
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
  final width = max(titleTP.width, 10.w);
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
    Paint()..color = Colors.grey[800]!,
  );
  titleTP.paint(canvas, Offset(off.dx + 10, off.dy + 10));
  descriptionTP.paint(
      canvas, Offset(off.dx + 10, off.dy + titleTP.height + 20));
}

class PuzzleGame extends FlameGame with TapDetector, KeyboardEvents {
  late Canvas canvas;

  bool firstRender = true;

  late BuildContext context;

  bool mouseDown = false;

  EditorType edType = EditorType.making;

  int currentSeletion = 0;

  int currentRotation = 0;

  double mouseX = 0;
  double mouseY = 0;
  var mouseButton = -1;

  double get offX =>
      (storedOffX - canvasSize.x / 2) * (cellSize / wantedCellSize) +
      canvasSize.x / 2;
  double get offY =>
      (storedOffY - canvasSize.y / 2) * (cellSize / wantedCellSize) +
      canvasSize.y / 2;

  var storedOffX = 0.0;
  var storedOffY = 0.0;

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

  void back() {
    Navigator.of(context).pop();
    resetAllCategories();
  }

  void paste() {
    if (gridClip.active) {
      gridClip.place(cellMouseX, cellMouseY);
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

  void properlyChangeZoom(int oldzoom, int newzoom) {
    final scale = newzoom / oldzoom;

    storedOffX = (storedOffX - canvasSize.x / 2) * scale + canvasSize.x / 2;
    storedOffY = (storedOffY - canvasSize.y / 2) * scale + canvasSize.y / 2;
  }

  void onPointerMove(PointerMoveEvent event) {
    mouseX = event.position.dx;
    mouseY = event.position.dy;
  }

  void onMouseExit() {
    mouseDown = false;
    mouseInside = false;
  }

  late ButtonManager buttonManager;

  @override
  Future<void>? onLoad() async {
    loadAllButtonTextures();
    if (edType == EditorType.loaded) {
      storedOffX = canvasSize.x / 2 - (grid.width / 2) * defaultCellSize;
      storedOffY = canvasSize.y / 2 - (grid.height / 2) * defaultCellSize;
    }
    await Flame.images.loadAll(
      cells.map((name) => textureMap["$name.png"] ?? "$name.png").toList(),
    );
    await Flame.images.load('pixel_on.png');
    await Flame.images.load("enemy_particles.png");
    buttonManager = ButtonManager(this);

    buttonManager.setButton(
      "back-btn",
      VirtualButton(
        Vector2.zero(),
        Vector2.all(80),
        "back.png",
        ButtonAlignment.TOPLEFT,
        back,
        () => true,
        title: 'Back',
        description: 'Sends you back',
      ),
    );

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
        title: 'Play / Pause',
        description: 'Play or Pause the simulation',
      ),
    );

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
          FlutterClipboard.controlC(P2.encodeGrid(grid));
        },
        () => true,
        title: 'Save to clipboard',
        description:
            'Save the simulation as a encoded string into your clipboard',
      ),
    );

    var catOff = 80.0;
    var catSize = 60.0;

    var cellSize = 40.0;

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
          title: 'Rotate CW',
          description:
              'Rotates the cells in the UI or what you are about to paste clockwise',
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
          title: 'Rotate CCW',
          description:
              'Rotates the cells in the UI or what you are about to paste counter-clockwise',
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
              buttonManager.buttons['select-btn']?.texture =
                  "interface/select_on.png";
            }
            if (!game.selecting) {
              buttonManager.buttons['select-btn']?.texture =
                  "interface/select.png";
              game.setPos = false;
              game.dragPos = false;
            }
            game.pasting = false;
            buttonManager.buttons['paste-btn']?.texture = 'interface/paste.png';
          },
          () => true,
          title: 'Toggle Select Mode',
          description:
              'In Select Mode you drag an area and can copy, cut, or paste it',
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
          description: 'Copy selected area',
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
            for (var x = 0; x <= selW; x++) {
              for (var y = 0; y <= selH; y++) {
                final cx = selX + x;
                final cy = selY + y;
                if (grid.inside(cx, cy)) {
                  grid.set(cx, cy, Cell(cx, cy));
                }
              }
            }
          },
          () => selecting && !dragPos,
          title: 'Cut',
          description: 'Copy and delete selected area',
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
                  grid.set(cx, cy, Cell(cx, cy));
                }
              }
            }
          },
          () => selecting && !dragPos,
          title: 'Delete',
          description: 'Delete selected area',
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

            buttonManager.buttons['paste-btn']?.texture =
                game.pasting ? 'interface/paste_on.png' : 'interface/paste.png';
          },
          () => gridClip.active,
          title: 'Paste',
          description: 'Paste what you have copied',
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
          description: 'Steps the simulation forward by 1 tick',
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
          description: 'Restores the simulation to the initial state',
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
          description:
              'Sets the simulation\'s current state as the initial state',
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
              FlutterClipboard.paste().then(
                (str) {
                  grid = loadStr(str);
                  initial = grid.copy;
                  isinitial = true;
                  running = false;
                  buttonManager.buttons['play-btn']?.texture = 'mover.png';
                  buttonManager.buttons['play-btn']?.rotation = 0;
                  buttonManager.buttons['wrap-btn']?.title =
                      grid.wrap ? "Wrap Mode (ON)" : "Wrap Mode (OFF)";
                },
              );
            } catch (e) {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text(
                      'Invalid save code',
                    ),
                    content: Text(
                      'You are trying to load a corrupted, invalid or unsupported level code.',
                    ),
                  );
                },
              );
            }
          },
          () => true,
          title: 'Load from clipboard',
          description:
              'Sets the grid to the level stored in the string in your clipboard',
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
            grid.wrap = !grid.wrap;
            buttonManager.buttons['wrap-btn']?.title =
                grid.wrap ? "Wrap Mode (ON)" : "Wrap Mode (OFF)";
          },
          () => true,
          title: 'Wrap Mode (OFF)',
          description: 'When Wrap mode is on, cells will wrap around the grid',
        ),
      );
      for (var i = 0; i < categories.length; i++) {
        buttonManager.setButton(
          'cat$i',
          VirtualButton(
            Vector2((catOff - catSize) / 2 + i * catOff, catOff),
            Vector2(catSize, catSize),
            categories[i].look + '.png',
            ButtonAlignment.BOTTOMLEFT,
            () {
              final cat = categories[i]; // Kitty
              resetAllCategories(cat);

              cat.opened = !cat.opened;

              for (var j = 0; j < cat.items.length; j++) {
                buttonManager.buttons['cat${i}cell$j']?.time = 0;
                buttonManager.buttons['cat${i}cell$j']?.startPos =
                    (Vector2((catOff - catSize) / 2 + i * catOff, catOff) +
                            Vector2.all((catSize - cellSize) / 2)) *
                        uiScale;
              }
            },
            () => true,
            title: categories[i].title,
            description: categories[i].description,
          ),
        );
        for (var j = 0; j < categories[i].items.length; j++) {
          final isCategory = (categories[i].items[j] is CellCategory);
          buttonManager.setButton(
            'cat${i}cell$j',
            VirtualButton(
              Vector2(
                  (catOff - catSize) / 2 +
                      i * catOff +
                      (catSize - cellSize) / 2,
                  catOff + cellSize * (j + 1)),
              Vector2(cellSize, cellSize),
              isCategory
                  ? '${categories[i].items[j].look}.png'
                  : '${categories[i].items[j]}.png',
              ButtonAlignment.BOTTOMLEFT,
              () {
                if (isCategory) {
                  categories[i].items[j].opened =
                      !(categories[i].items[j].opened);

                  final isOpen = categories[i].items[j].opened;

                  resetAllCategories(categories[i]);

                  categories[i].items[j].opened = isOpen;

                  for (var k = 0;
                      k < categories[i].items[j].items.length;
                      k++) {
                    buttonManager.buttons['cat${i}cell${j}sub$k']?.time = 0;
                    buttonManager.buttons['cat${i}cell${j}sub$k']?.startPos =
                        Vector2(
                                (catOff - catSize) / 2 +
                                    i * catOff +
                                    (catSize - cellSize) / 2,
                                catOff + cellSize * (j + 1)) *
                            uiScale;
                  }
                } else {
                  game.currentSeletion = cells.indexOf(
                    categories[i].items[j],
                  );
                }
              },
              () {
                return categories[i].opened;
              },
              title: isCategory
                  ? categories[i].items[j].title
                  : (cellInfo[categories[i].items[j]] ?? defaultProfile).title,
              description: isCategory
                  ? categories[i].items[j].description
                  : (cellInfo[categories[i].items[j]] ?? defaultProfile)
                      .description,
            )..time = 50,
          );

          buttonManager.buttons['cat${i}cell$j']?.duration += 0.005 * j;

          if (isCategory) {
            final cat = categories[i].items[j] as CellCategory;
            final catPos = Vector2(
                (catOff - catSize) / 2 + i * catOff + (catSize - cellSize) / 2,
                catOff + cellSize * (j + 1));
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
                  () => game.currentSeletion = cells.indexOf(cell),
                  () => cat.opened,
                  title: (cellInfo[cell] ?? defaultProfile).title,
                  description: (cellInfo[cell] ?? defaultProfile).description,
                )
                  ..time = 50
                  ..duration += k * 0.005,
              );
            }
          }
        }
      }
    }

    wantedCellSize = defaultCellSize;
    cellSize = defaultCellSize.toDouble();
    keys = {};
    puzzleWin = false;
    delay = storage.getDouble("delay") ?? 0.15;
    realisticRendering = storage.getBool("realistic_render") ?? true;

    return super.onLoad();
  }

  int get cellMouseX => (mouseX - offX) ~/ cellSize;
  int get cellMouseY => (mouseY - offY) ~/ cellSize;

  @override
  void render(Canvas canvas) {
    this.canvas = canvas;

    canvas.drawRect(Offset.zero & Size(canvasSize.x, canvasSize.y),
        Paint()..color = Colors.grey[900]!);

    //canvas.save();

    canvas.translate(offX, offY);

    var sx = floor((-offX - cellSize) / cellSize);
    var sy = floor((8.h - offY - cellSize) / cellSize);
    var ex = ceil((canvasSize.x - offX) / cellSize);
    var ey = ceil((92.h - offY) / cellSize);

    sx = max(sx, 0);
    sy = max(sy, 0);
    ex = min(ex, grid.width);
    ey = min(ey, grid.height);

    if (realisticRendering) {
      final extra = 5;
      sx = max(sx - extra, 0);
      sy = max(sy - extra, 0);
      ex = min(ex + extra, grid.width);
      ey = min(ey + extra, grid.height);
    }

    final xs = [];
    final ys = [];

    for (var x = sx; x < ex; x++) {
      for (var y = sy; y < ey; y++) {
        if (grid.inside(x, y)) {
          if (grid.at(x, y).id != "empty") {
            xs.add(x);
            ys.add(y);
          }
          renderEmpty(grid.at(x, y), x, y);
        }
      }
    }

    if (realisticRendering && running) {
      for (var b in grid.brokenCells) {
        b.render(canvas, (itime % delay) / delay);
      }
    }

    for (var x = sx; x < ex; x++) {
      for (var y = sy; y < ey; y++) {
        if (grid.inside(x, y)) {
          if (grid.at(x, y).id != "empty") {
            renderCell(grid.at(x, y), x, y);
          }
        }
      }
    }

    if (edType == EditorType.making &&
        realisticRendering &&
        mouseInside &&
        !(pasting || selecting)) {
      var mx = cellMouseX; // shorter names
      var my = cellMouseY; // shorter names
      if (grid.inside(mx, my)) {
        if (grid.wrap) {
          mx += grid.width;
          mx %= grid.width;
          my += grid.height;
          my %= grid.height;
        }
        renderCell(
          Cell(mx, my)
            ..id = cells[currentSeletion]
            ..rot = currentRotation
            ..lastvars.lastRot = currentRotation,
          mx,
          my,
          Paint()..color = Colors.white.withOpacity(0.5),
        );
      }
    }

    if (edType == EditorType.loaded &&
        cells[currentSeletion] != "empty" &&
        mouseInside &&
        !running) {
      final c = Cell(0, 0);
      c.lastvars = LastVars(currentRotation, 0, 0);
      c.lastvars.lastPos = Offset(
        (mouseX - offX) / cellSize,
        (mouseY - offY) / cellSize,
      );
      c.id = cells[currentSeletion];
      c.rot = currentRotation;
      renderCell(
        c,
        (mouseX - offX) / cellSize - 0.5,
        (mouseY - offY) / cellSize - 0.5,
      );
    }

    if (pasting) {
      final mx =
          grid.wrap ? (cellMouseX + grid.width) % grid.width : cellMouseX;

      final my =
          grid.wrap ? (cellMouseY + grid.height) % grid.height : cellMouseY;
      gridClip.render(canvas, mx, my);
    } else if (selecting && setPos) {
      final selScreenX = (selX * cellSize);
      final selScreenY = (selY * cellSize);
      canvas.drawRect(
        Offset(selScreenX, selScreenY) & Size(selW * cellSize, selH * cellSize),
        Paint()..color = (Colors.grey[300]!.withOpacity(0.4)),
      );
    }
    //grid.forEach(renderCell);

    canvas.restore();

    buttonManager.forEach(
      (key, button) {
        button.canvasSize = canvasSize;
        button.render(canvas, canvasSize);
      },
    );

    if (storage.getBool('show_titles') ?? true) {
      buttonManager.forEach(
        (key, button) {
          if (button.isHovered(mouseX.toInt(), mouseY.toInt()) &&
              button.shouldRender() &&
              mouseInside &&
              !key.startsWith('hidden-')) {
            renderInfoBox(canvas, button.title, button.description);
          }
        },
      );
    }

    canvas.translate(offX, offY);

    super.render(canvas);
  }

  void renderEmpty(Cell cell, int x, int y) {
    final off = Vector2(x * cellSize.toDouble(), y * cellSize.toDouble());
    if (true) {
      Sprite(Flame.images.fromCache('empty.png')).render(
        canvas,
        position: off,
        size: Vector2(
          cellSize.toDouble(),
          cellSize.toDouble(),
        ),
      );
      if (grid.placeable(x, y) != "empty") {
        Sprite(Flame.images
                .fromCache('backgrounds/${grid.placeable(x, y)}.png'))
            .render(
          canvas,
          position: off,
          size: Vector2(
            cellSize.toDouble(),
            cellSize.toDouble(),
          ),
        );
      }
    }
  }

  void renderCell(Cell cell, num x, num y, [Paint? paint]) {
    if (cell.id == "empty") return;
    final rot = (running || onetick
            ? lerpRotation(cell.lastvars.lastRot, cell.rot, itime / delay)
            : cell.rot) *
        halfPi;
    final center = Offset(cellSize.toDouble(), cellSize.toDouble()) / 2;

    const scaleX = 1;
    const scaleY = 1;

    canvas.save();

    final cx = (x + grid.width) % grid.width;
    final cy = (y + grid.height) % grid.height;

    var lx = cell.lastvars.lastPos.dx.toInt();
    var ly = cell.lastvars.lastPos.dy.toInt();

    final dx = lx - cx;
    final dy = ly - cy;

    final past =
        Offset((x + dx).toDouble(), (y + dy).toDouble()) * cellSize.toDouble() +
            center;
    final current =
        Offset(x.toDouble(), y.toDouble()) * cellSize.toDouble() + center;

    final off = rotateOff(
            ((running || onetick) && cell.id != "empty")
                ? interpolate(past, current, itime / delay)
                : current,
            -rot) -
        center;

    canvas.rotate(rot);
    var file = cell.id;

    if ((cell.id == "pixel" && MechanicalManager.on(cell))) {
      file = 'pixel_on';
    }
    var sprite = spriteCache['$file.png'];
    if (sprite == null) {
      sprite = Sprite(
          Flame.images.fromCache(textureMap['$file.png'] ?? '$file.png'));
      spriteCache['$file.png'] = sprite;
    }
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

    canvas.restore();
  }

  @override
  void update(double dt) {
    updates++;
    buttonManager.forEach(
      (key, button) {
        button.time += dt;
        button.timeRot += dt;
      },
    );
    if (realisticRendering) {
      cellSize = lerp(cellSize, wantedCellSize.toDouble(), dt * 10);
    } else {
      cellSize = wantedCellSize.toDouble();
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
    if (puzzleWin && !overlays.isActive("Win")) {
      overlays.add("Win");
    }
    if (puzzleWin) return;
    if (running || onetick) {
      itime += dt;

      while (itime > delay) {
        itime -= delay;
        if (onetick) {
          onetick = false;
        } else {
          if (storage.getBool("update_visible") == true) {
            final sx = max(floor(-offX / cellSize), 0);
            final sy = max(floor(-offY / cellSize), 0);
            final ex = min(ceil((canvasSize.x - offX) / cellSize), grid.width);
            final ey = min(ceil((canvasSize.y - offY) / cellSize), grid.height);
            grid.setConstraints(sx, sy, ex, ey);
          }
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
        final cx = (mouseX - offX) ~/ cellSize;
        final cy = (mouseY - offY) ~/ cellSize;
        if (grid.inside(cx, cy)) {
          if (mouseButton == kPrimaryMouseButton) {
            placeCell(currentSeletion, currentRotation, cx, cy);
          } else if (mouseButton == kSecondaryMouseButton) {
            placeCell(0, 0, cx, cy);
          } else if (mouseButton == kMiddleMouseButton) {
            final id = grid.at(cx, cy).id;

            if (edType == EditorType.making) {
              currentSeletion = cells.indexOf(id);
            } else if (edType == EditorType.loaded) {
              if (cellsToPlace.contains(id)) {
                currentSeletion = cells.indexOf(id);
              }
            }
          }
        }
      }
    }

    super.update(dt);
  }

  void onMouseEnter(PointerEvent e) {
    mouseX = e.localPosition.dx;
    mouseY = e.localPosition.dy;
    mouseInside = true;
  }

  String originalPlace = "empty";

  void placeCell(int id, int rot, int cx, int cy) {
    if (!grid.inside(cx, cy)) return;
    if (edType == EditorType.making) {
      grid.set(
        cx,
        cy,
        Cell(cx, cy)
          ..id = cells[id]
          ..rot = rot
          ..lastvars.lastRot = rot,
      );
      if (cells[id] == "empty" &&
          backgrounds.contains(cells[currentSeletion])) {
        grid.setPlace(cx, cy, "empty");
      }
    } else if (edType == EditorType.loaded) {
      if (grid.placeable(cx, cy) == "rotatable") {
        grid.at(cx, cy).rot++;
        grid.at(cx, cy).rot %= 4;
        return;
      }
      if (cells[id] == "empty" && grid.at(cx, cy).id != "empty") {
        currentSeletion = cells.indexOf(grid.at(cx, cy).id);
        currentRotation = grid.at(cx, cy).rot;
        originalPlace = grid.placeable(cx, cy);
        grid.set(cx, cy, Cell(cx, cy));
      } else if (grid.at(cx, cy).id == "empty" &&
          grid.placeable(cx, cy) == originalPlace) {
        grid.set(
          cx,
          cy,
          Cell(cx, cy)
            ..id = cells[id]
            ..rot = rot
            ..lastvars.lastRot = rot,
        );
        currentSeletion = cells.indexOf("empty");
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
            buttonManager
                .buttons[
                    'cat${categories.indexOf(category)}cell${category.items.indexOf(item)}']
                ?.time = 0;
          }
        }
      }
      for (var item in category.items) {
        if (item is CellCategory) {
          final wasopen = item.opened;
          item.opened = false;
          if (wasopen) {
            for (var subitem in item.items) {
              final btn = buttonManager.buttons[
                  'cat${categories.indexOf(category)}cell${category.items.indexOf(item)}sub${item.items.indexOf(subitem)}'];
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

  Future<void> onPointerDown(PointerDownEvent event) async {
    if (event.down && event.kind == PointerDeviceKind.mouse) {
      mouseX = event.position.dx;
      mouseY = event.position.dy;
      if (true) {
        mouseButton = event.buttons;
        mouseDown = true;
        buttonManager.forEach((key, button) {
          if (button.shouldRender() &&
              button.isHovered(mouseX.toInt(), mouseY.toInt())) {
            button.callback();
            mouseDown = false;
          }
        });
        if (edType == EditorType.loaded && mouseDown && !running) {
          mouseDown = false;
          if (grid.inside(cellMouseX, cellMouseY) &&
              grid.placeable(cellMouseX, cellMouseY) != "empty") {
            placeCell(currentSeletion, currentRotation, cellMouseX, cellMouseY);
          }
          return;
        }
        if (puzzleWin) mouseDown = false;
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
        }
      }
      // if (event.buttons == kSecondaryMouseButton) {
      //   final cx = (event.position.dx - offX) ~/ cellSize;
      //   final cy = (event.position.dy - offY) ~/ cellSize;
      //   if (grid.inside(cx, cy)) {
      //     placeCell(0, 0, cx, cy);
      //   }
      // } else if (event.buttons == kMiddleMouseButton) {
      //   final cx = (event.position.dx - offX) ~/ cellSize;
      //   final cy = (event.position.dy - offY) ~/ cellSize;

      //   if (grid.inside(cx, cy)) {
      //     final id = grid.at(cx, cy).id;

      //     if (edType == EditorType.making) {
      //       currentSeletion = cells.indexOf(id);
      //     } else if (edType == EditorType.loaded) {
      //       if (cellsToPlace.contains(id)) {
      //         currentSeletion = cells.indexOf(id);
      //       }
      //     }
      //   }
      // }
    }
  }

  @override
  void onGameResize(Vector2 screenSize) {
    super.onGameResize(screenSize);
    if (canvasSize.x != screenSize.x || canvasSize.y != screenSize.y) {
      final sX = screenSize.x / canvasSize.x;
      final sY = screenSize.y / canvasSize.y;

      storedOffX *= sX;
      storedOffY *= sY;
      wantedCellSize = (wantedCellSize * sX) ~/ 1;
      cellSize *= sX;
    }
  }

  void zoomout() {
    if (wantedCellSize > (defaultCellSize) / 16) {
      final lastZoom = wantedCellSize;
      wantedCellSize ~/= 2;
      properlyChangeZoom(lastZoom, wantedCellSize);
    }
  }

  void zoomin() {
    if (wantedCellSize < (defaultCellSize) * 256) {
      final lastZoom = wantedCellSize;
      wantedCellSize *= 2;
      properlyChangeZoom(lastZoom, wantedCellSize);
    }
  }

  void setInitial() {
    initial = grid.copy;
    isinitial = true;
    running = false;
    buttonManager.buttons["play-btn"]!.texture = "mover.png";
    buttonManager.buttons["play-btn"]!.rotation = 0;
  }

  void restoreInitial() {
    grid = initial.copy;
    isinitial = true;
    running = false;
    buttonManager.buttons["play-btn"]!.texture = "mover.png";
    buttonManager.buttons["play-btn"]!.rotation = 0;
  }

  bool onetick = false;

  void oneTick() {
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
    running = !running;
    if (edType == EditorType.loaded) {
      isinitial = true;
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
    } else {
      if (puzzleWin == true || edType == EditorType.loaded) {
        restoreInitial();
      }
      puzzleWin = false;
      overlays.remove("Win");
      buttonManager.buttons["play-btn"]!.texture = "mover.png";
      buttonManager.buttons["play-btn"]!.rotation = 0;
    }
  }

  void q() {
    if (!game.running || edType == EditorType.making) {
      if (pasting) {
        gridClip.rotate(RotationalType.counter_clockwise);
      } else {
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.lastRot = game.currentRotation;
          buttonManager.buttons['cat$i']!.timeRot = 0;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.lastRot =
                game.currentRotation;
            buttonManager.buttons['cat${i}cell$j']!.timeRot = 0;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.lastRot =
                    game.currentRotation;
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
            buttonManager.buttons['cat${i}cell$j']!.rotation =
                game.currentRotation;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.rotation =
                    game.currentRotation;
              }
            }
          }
        }
      }
    }
  }

  void e() {
    if (!game.running || edType == EditorType.making) {
      if (pasting) {
        gridClip.rotate(RotationalType.clockwise);
      } else {
        for (var i = 0; i < categories.length; i++) {
          buttonManager.buttons['cat$i']!.lastRot = game.currentRotation;
          buttonManager.buttons['cat$i']!.timeRot = 0;
          for (var j = 0; j < categories[i].items.length; j++) {
            buttonManager.buttons['cat${i}cell$j']!.lastRot =
                game.currentRotation;
            buttonManager.buttons['cat${i}cell$j']!.timeRot = 0;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.lastRot =
                    game.currentRotation;
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
            buttonManager.buttons['cat${i}cell$j']!.rotation =
                game.currentRotation;

            if (categories[i].items[j] is CellCategory) {
              for (var k = 0; k < categories[i].items[j].items.length; k++) {
                buttonManager.buttons['cat${i}cell${j}sub$k']!.rotation =
                    game.currentRotation;
              }
            }
          }
        }
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.altLeft)) {
        // Alternative stuffz
      } else {
        if (keysPressed.contains(LogicalKeyboardKey.keyQ)) {
          q();
        } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
          e();
        } else if (keysPressed.contains(LogicalKeyboardKey.space) &&
            !(keys[LogicalKeyboardKey.space.keyId] == true)) {
          playPause();
        } else if (keysPressed.contains(LogicalKeyboardKey.escape) ||
            keysPressed.contains(LogicalKeyboardKey.backspace)) {
          if (pasting) {
            pasting = false;
          }
        } else if (keysPressed.contains(LogicalKeyboardKey.keyF) &&
            edType == EditorType.making) {
          oneTick();
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
