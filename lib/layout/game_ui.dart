part of layout;

late PuzzleGame game;

TextStyle fontSize(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
  );
}

Map<PhysicalKeyboardKey, bool> keys = {};

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
      padding: EdgeInsets.all(2.w),
      child: SizedBox(
        width: 8.w,
        height: 8.w,
        child: Stack(
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
                margin: EdgeInsets.all(2.w),
                child: MaterialButton(
                  onPressed: () => setState(() => game.currentSeletion = index),
                  child: Opacity(
                    opacity: game.currentSeletion == index ? 1 : 0.3,
                    child: RotatedBox(
                      quarterTurns: game.currentRotation,
                      child: Image.asset(
                        'assets/images/$cell.png',
                        width: 3.w,
                        height: 3.w,
                        fit: BoxFit.fill,
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
              setState(
                () {
                  category.opened = !category.opened;
                },
              );
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
        setDefaultPresence();
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
                      setDefaultPresence();
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
          list.add(
            VerticalDivider(
              width: 1.w,
            ),
          );
          for (var cell in category.items) {
            list.add(cellToImage(cell));
          }
          list.add(
            VerticalDivider(
              width: 1.w,
            ),
          );
        }
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Center(
          child: MouseRegion(
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
                initialActiveOverlays: [
                  "CellBar",
                  "ActionBar",
                ],
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
                                        P1Plus.encodeGrid(grid),
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
                                      child: MaterialButton(
                                        child: Image.asset(
                                          'assets/interface/select.png',
                                          width: s,
                                          height: s,
                                          fit: BoxFit.fill,
                                        ),
                                        onPressed: () {
                                          game.selecting = !game.selecting;
                                          if (!game.selecting) {
                                            game.setPos = false;
                                            game.dragPos = false;
                                          }
                                          game.pasting = false;
                                        },
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
                                  Tooltip(
                                    message: 'Zoom in',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: Image.asset(
                                        'assets/interface/zoomin.png',
                                        width: s,
                                        height: s,
                                        fit: BoxFit.fill,
                                      ),
                                      onPressed: game.zoomin,
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Zoom out',
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 7.sp,
                                      color: Colors.white,
                                    ),
                                    child: MaterialButton(
                                      child: Image.asset(
                                        'assets/interface/zoomout.png',
                                        width: s,
                                        height: s,
                                        fit: BoxFit.fill,
                                      ),
                                      onPressed: game.zoomout,
                                    ),
                                  ),
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
                                            game.overlays.remove('Info');
                                          }
                                        },
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
                                  height: 16.h,
                                  color: Colors.grey[900],
                                  child: Scrollbar(
                                    controller: scrollController,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      controller: scrollController,
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
  return a + (b - a) * t;
}

double lerpRotation(int old, int newR, double t) {
  return lerp(old, old + ((newR - old + 2) % 4 - 2), t);
}

int ceil(num n) => floor(n + 0.999);

class PuzzleGame extends FlameGame with TapDetector, KeyboardEvents {
  late Canvas canvas;

  bool firstRender = true;

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

  double itime = 0;
  double delay = 0.15;

  late Grid initial;

  var cellsToPlace = <String>["empty"];
  var cellsCount = <int>[1];

  var bgX = 0.0;
  var bgY = 0.0;

  late bool realisticRendering;

  bool get validPlacePos => ((mouseY > 5.h) && (mouseY < 84.h));

  var selecting = false;
  var pasting = false;
  var gridClip = GridClip();

  var selX = 0;
  var selY = 0;
  var selW = 0;
  var selH = 0;
  var setPos = false;
  var dragPos = false;

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

    selW++;
    selH++;
  }

  void properlyChangeZoom(int oldzoom, int newzoom) {
    final scale = newzoom / oldzoom;

    storedOffX = (storedOffX - canvasSize.x / 2) * scale + canvasSize.x / 2;
    storedOffY = (storedOffY - canvasSize.y / 2) * scale + canvasSize.y / 2;
  }

  void onPointerMove(PointerMoveEvent event) {
    mouseX = event.position.dx;
    mouseY = event.position.dy;
  }

  @override
  Future<void>? onLoad() async {
    wantedCellSize = defaultCellSize;
    cellSize = defaultCellSize.toDouble();
    keys = {};
    puzzleWin = false;
    await Flame.images.loadAll(cells.map((name) => "$name.png").toList());
    await Flame.images.load("enemy_particles.png");
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
    var sy = floor((-offY - cellSize) / cellSize);
    var ex = ceil((canvasSize.x - offX) / cellSize);
    var ey = ceil((canvasSize.y - offY) / cellSize);

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

    for (var x = sx; x < ex; x++) {
      for (var y = sy; y < ey; y++) {
        if (grid.inside(x, y)) {
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
          final cell = grid.at(x, y);
          renderCell(cell, x, y);
        }
      }
    }

    if (pasting) {
      gridClip.render(canvas, cellMouseX, cellMouseY);
    } else if (selecting && setPos) {
      final selScreenX = (selX * cellSize);
      final selScreenY = (selY * cellSize);
      canvas.drawRect(
        Offset(selScreenX, selScreenY) & Size(selW * cellSize, selH * cellSize),
        Paint()..color = (Colors.grey[300]!.withOpacity(0.4)),
      );
    }
    //grid.forEach(renderCell);

    //canvas.restore();

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
      if (grid.placeable(x, y)) {
        Sprite(Flame.images.fromCache('place.png')).render(
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

  void renderCell(Cell cell, int x, int y) {
    if (cell.id == "empty") return;
    final rot = (running
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
            (running && cell.id != "empty")
                ? interpolate(past, current, itime / delay)
                : current,
            -rot) -
        center;

    canvas.rotate(rot);
    var file = cell.id;

    if ((cell.id == "pixel" && MechanicalManager.on(cell))) {
      file = 'pixel_on';
    }
    Sprite(Flame.images.fromCache('$file.png')).render(
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
    if (realisticRendering) {
      cellSize = lerp(cellSize, wantedCellSize.toDouble(), dt * 5);
    } else {
      cellSize = wantedCellSize.toDouble();
    }
    if (overlays.isActive('CellBar')) {
      overlays.remove('CellBar');
    }
    if (!overlays.isActive('CellBar')) {
      overlays.add('CellBar');
    }
    if (!overlays.isActive('Info')) {
      overlays.add('Info');
    }
    if (puzzleWin && !overlays.isActive("Win")) {
      overlays.add("Win");
    }
    if (puzzleWin) return;
    if (running) {
      itime += dt;

      while (itime > delay) {
        itime -= delay;
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

    bool canMoveCam = true;
    if (running) {
      canMoveCam = (keys[PhysicalKeyboardKey.shiftLeft] == true) &&
          (keys[PhysicalKeyboardKey.altLeft] != true);
    }

    if ((canMoveCam) && keys[LogicalKeyboardKey.altLeft] != true) {
      const speed = 600;
      if (keys[PhysicalKeyboardKey.keyW] == true) {
        storedOffY += speed * dt;
      }
      if (keys[PhysicalKeyboardKey.keyS] == true) {
        storedOffY -= speed * dt;
      }
      if (keys[PhysicalKeyboardKey.keyA] == true) {
        storedOffX += speed * dt;
      }
      if (keys[PhysicalKeyboardKey.keyD] == true) {
        storedOffX -= speed * dt;
      }
    }

    if (selecting && dragPos && setPos) {
      final ex = min(cellMouseX, grid.width);
      final ey = min(cellMouseY, grid.height);

      selW = ex - selX + 1;
      selH = ey - selY + 1;
    }

    if (!(running || pasting || selecting)) {
      if (mouseDown) {
        final cell = (edType == EditorType.making
            ? cells
            : cellsToPlace)[currentSeletion];
        if (validPlacePos && cell != "place") {
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
        } else {
          mouseDown = false;
        }
      }
    }

    super.update(dt);
  }

  void placeCell(int id, int rot, int cx, int cy) {
    if (!validPlacePos) {
      return;
    }
    if (edType == EditorType.making) {
      grid.set(
        cx,
        cy,
        Cell(cx, cy)
          ..id = cells[id]
          ..rot = rot
          ..lastvars.lastRot = rot,
      );
    } else if (edType == EditorType.loaded) {
      if (cellsToPlace.isNotEmpty && grid.placeable(cx, cy)) {
        if (cellsToPlace[id] == "empty" && grid.at(cx, cy).id != "empty") {
          if (!cellsToPlace.contains(grid.at(cx, cy).id)) {
            cellsToPlace.add(grid.at(cx, cy).id);
            cellsCount.add(1);
          } else {
            cellsCount[cellsToPlace.indexOf(grid.at(cx, cy).id)]++;
          }
        }
        if (cellsToPlace[id] != "empty" && grid.at(cx, cy).id != "empty")
          return;
        grid.set(
          cx,
          cy,
          Cell(cx, cy)
            ..id = cellsToPlace[id]
            ..rot = rot
            ..lastvars.lastRot = rot,
        );
        if (cellsToPlace[id] != "empty") {
          cellsCount[id]--;
          if (cellsCount[id] == 0) {
            cellsToPlace.removeAt(id);
            cellsCount.removeAt(id);
            if (cellsToPlace.length == 1) {
              mouseDown = false;
            }
          }
          if (cellsToPlace.isNotEmpty) {
            //currentSeletion -= 1;
            currentSeletion = min(currentSeletion, cellsToPlace.length - 1);
          }
          //overlays.remove("CellBar");
        }
      }
    }
  }

  void onTapDown(TapDownInfo info) {
    final cx = (info.eventPosition.global.x - offX) ~/ cellSize;
    final cy = (info.eventPosition.global.y - offY) ~/ cellSize;
    final cell =
        (edType == EditorType.making ? cells : cellsToPlace)[currentSeletion];

    if (grid.inside(cx, cy) && cell == "place") {
      placeCell(currentSeletion, 0, cx, cy);
    }
  }

  Future<void> onPointerUp(PointerUpEvent event) async {
    mouseDown = false;
    if (selecting && setPos) {
      dragPos = false;
    }
  }

  Future<void> onPointerDown(PointerDownEvent event) async {
    if (running || puzzleWin) {
      return;
    }
    if (event.down && event.kind == PointerDeviceKind.mouse) {
      mouseX = event.position.dx;
      mouseY = event.position.dy;
      if (validPlacePos) {
        mouseButton = event.buttons;
        mouseDown = true;
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
      } else {
        mouseDown = false;
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
      if (overlays.isActive('CellBar') && updates > 0) {
        overlays.remove('CellBar');
      }
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

  void playPause() {
    running = !running;
    if (running) {
      initial = grid.copy;
      playerKeys = 0;
      overlays.remove('Info');
      overlays.remove('ActionBar');
      overlays.add('ActionBar');
    } else {
      grid = initial;
      overlays.remove('Info');
      overlays.remove('ActionBar');
      overlays.add('ActionBar');
      if (overlays.isActive("Win")) {
        overlays.remove("Win");
        puzzleWin = false;
      }
    }
  }

  void q() {
    if (!game.running) {
      if (pasting) {
        gridClip.rotate(RotationalType.counter_clockwise);
      } else {
        game.currentRotation += 3;
        game.currentRotation %= 4;
        game.overlays.remove('CellBar');
      }
    }
  }

  void e() {
    if (!game.running) {
      if (pasting) {
        gridClip.rotate(RotationalType.clockwise);
      } else {
        game.currentRotation++;
        game.currentRotation %= 4;
        game.overlays.remove('CellBar');
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
            !(keys[PhysicalKeyboardKey.space] == true)) {
          playPause();
        } else if (keysPressed.contains(LogicalKeyboardKey.equal) &&
            keys[LogicalKeyboardKey.equal] != true) {
          zoomin();
        } else if (keysPressed.contains(LogicalKeyboardKey.minus) &&
            keys[LogicalKeyboardKey.minus] != true) {
          zoomout();
        } else if (keys[PhysicalKeyboardKey.keyC] == true &&
            keys[PhysicalKeyboardKey.controlLeft] == true) {
          if (game.selecting && game.setPos) {
            game.copy();
          }
        }
      }
      keys[event.physicalKey] = true;
      return KeyEventResult.handled;
    } else if (event is RawKeyUpEvent) {
      keys[event.physicalKey] = false;
      //keysPressed.forEach((e) => keys[e] = true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
