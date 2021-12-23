part of layout;

late PuzzleGame game;

TextStyle fontSize(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
  );
}

Map<LogicalKeyboardKey, bool> keys = {};

const halfPi = pi / 2;

const cellSize = 40;

final cells = [
  "empty",
  "place",
  "wall",
  "ghost",
  "mover",
  "puller",
  "liner",
  "bird",
  "releaser",
  "wormhole",
  "generator",
  "generator_cw",
  "generator_ccw",
  "triplegen",
  "constructorgen",
  "crossgen",
  "replicator",
  "karl",
  "push",
  "slide",
  "rotator_cw",
  "rotator_ccw",
  "gear_cw",
  "gear_ccw",
  "mirror",
  "enemy",
  "trash",
  "puzzle",
  "lock",
  "unlock",
  "key",
  "flag",
  "antipuzzle",
];

var cellsPerPage = 9;

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
              child: MaterialButton(
                onPressed: () => setState(() => game.currentSeletion = index),
                child: Opacity(
                  opacity: game.currentSeletion == index ? 1 : 0.3,
                  child: RotatedBox(
                    quarterTurns: game.currentRotation,
                    child:
                        Image.asset('assets/images/$cell.png', scale: 20 / 3.w),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Center(
          child: GameWidget(
            game: game,
            overlayBuilderMap: {
              'CellBar': (ctx, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 100.w,
                            height: 8.w,
                            color: Colors.grey[900],
                            child: Scrollbar(
                              controller: scrollController,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                controller: scrollController,
                                itemCount: (game.edType == EditorType.making
                                            ? cells
                                            : game.cellsToPlace)
                                        .length +
                                    1,
                                itemBuilder: (ctx, i) {
                                  if (i == 0) {
                                    return MaterialButton(
                                      height: 5.w,
                                      child: Text(
                                        "Back",
                                        style: fontSize(
                                          6.sp,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    );
                                  }
                                  return cellToImage(
                                      (game.edType == EditorType.making
                                          ? cells
                                          : game.cellsToPlace)[i - 1]);
                                },
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
                return SizedBox(
                  width: 100.w,
                  height: 92.w,
                  child: Center(
                    child: Column(
                      children: [
                        Spacer(),
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
                        Spacer(),
                      ],
                    ),
                  ),
                );
              }
            },
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
  final off = (o2 - o1) * t;

  return (o1 + off);
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

  double offX = 0;
  double offY = 0;

  int updates = 0;

  bool running = false;

  double itime = 0;
  double delay = 0.15;

  late Grid initial;

  var cellsToPlace = <String>["empty"];
  var cellsCount = <int>[1];

  var bgX = 0.0;
  var bgY = 0.0;

  @override
  Future<void>? onLoad() async {
    keys = {};
    puzzleWin = false;
    await Flame.images.loadAll(cells.map((name) => "$name.png").toList());
    await Flame.images.load("enemy_particles.png");

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    this.canvas = canvas;

    canvas.drawRect(Offset.zero & Size(canvasSize.x, canvasSize.y),
        Paint()..color = Colors.grey[900]!);

    //canvas.save();

    canvas.translate(offX, offY);

    final sx = max(floor(-offX / cellSize), 0);
    final sy = max(floor(-offY / cellSize), 0);
    final ex = min(ceil((canvasSize.x - offX) / cellSize), grid.width);
    final ey = min(ceil((canvasSize.y - offY) / cellSize), grid.height);

    for (var x = sx; x < ex; x++) {
      for (var y = sy; y < ey; y++) {
        renderEmpty(grid.at(x, y), x, y);
      }
    }
    for (var x = sx; x < ex; x++) {
      for (var y = sy; y < ey; y++) {
        renderCell(grid.at(x, y), x, y);
      }
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

    final past = cell.lastvars.lastPos * cellSize.toDouble() + center;
    final current =
        Offset(x.toDouble(), y.toDouble()) * cellSize.toDouble() + center;

    final off = rotateOff(
            (running && cell.id != "empty")
                ? interpolate(past, current, itime / delay)
                : current,
            -rot) -
        center;

    canvas.rotate(rot);
    Sprite(Flame.images.fromCache('${cell.id}.png')).render(
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
    overlays.remove('CellBar');
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

        grid.update(); // Update the cells boizz
      }
    }

    if ((!running || keys[LogicalKeyboardKey.controlLeft] == true) &&
        keys[LogicalKeyboardKey.altLeft] != true) {
      const speed = 600;
      if (keys[LogicalKeyboardKey.keyW] == true) {
        offY += speed * dt;
      }
      if (keys[LogicalKeyboardKey.keyS] == true) {
        offY -= speed * dt;
      }
      if (keys[LogicalKeyboardKey.keyA] == true) {
        offX += speed * dt;
      }
      if (keys[LogicalKeyboardKey.keyD] == true) {
        offX -= speed * dt;
      }
    }

    super.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (running || puzzleWin) {
      return super.onTapDown(info);
    }
    mouseDown = true;

    final cx = (info.eventPosition.widget.x - offX) ~/ cellSize;
    final cy = (info.eventPosition.widget.y - offY) ~/ cellSize;
    if (edType == EditorType.making) {
      grid.set(
        cx,
        cy,
        Cell(cx, cy)
          ..id = cells[currentSeletion]
          ..rot = currentRotation
          ..lastvars.lastRot = currentRotation,
      );
    } else if (edType == EditorType.loaded) {
      if (cellsToPlace.isNotEmpty && grid.placeable(cx, cy)) {
        if (cellsToPlace[currentSeletion] == "empty" &&
            grid.at(cx, cy).id != "empty") {
          if (!cellsToPlace.contains(grid.at(cx, cy).id)) {
            cellsToPlace.add(grid.at(cx, cy).id);
            cellsCount.add(1);
          } else {
            cellsCount[cellsToPlace.indexOf(grid.at(cx, cy).id)]++;
          }
        }
        if (cellsToPlace[currentSeletion] != "empty" &&
            grid.at(cx, cy).id != "empty") return;
        grid.set(
          cx,
          cy,
          Cell(cx, cy)
            ..id = cellsToPlace[currentSeletion]
            ..rot = currentRotation
            ..lastvars.lastRot = currentRotation,
        );
        if (cellsToPlace[currentSeletion] != "empty") {
          cellsCount[currentSeletion]--;
          if (cellsCount[currentSeletion] == 0) {
            cellsToPlace.removeAt(currentSeletion);
            cellsCount.removeAt(currentSeletion);
          }
          if (cellsToPlace.isNotEmpty) {
            //currentSeletion -= 1;
            currentSeletion =
                (currentSeletion + cellsToPlace.length) % cellsToPlace.length;
          }
          overlays.remove("CellBar");
        }
      }
    }
    super.onTapDown(info);
  }

  @override
  void onTapUp(TapUpInfo info) {
    mouseDown = false;
    super.onTapUp(info);
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

      offX *= sX;
      offY *= sY;
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.altLeft)) {
        if (keysPressed.contains(LogicalKeyboardKey.keyW) &&
            edType == EditorType.making) {
          grid.wrap = !grid.wrap;
        }
      } else {
        if (keysPressed.contains(LogicalKeyboardKey.keyQ)) {
          currentRotation--;
          currentRotation %= 4;
          overlays.remove('CellBar');
        } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
          currentRotation++;
          currentRotation %= 4;
          overlays.remove('CellBar');
        } else if (keysPressed.contains(LogicalKeyboardKey.space) &&
            !(keys[LogicalKeyboardKey.space] == true)) {
          running = !running;
          if (running) {
            initial = grid.copy;
            playerKeys = 0;
            overlays.remove('Info');
          } else {
            grid = initial;
            overlays.remove('Info');
            if (overlays.isActive("Win")) {
              overlays.remove("Win");
              puzzleWin = false;
            }
          }
        } else if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
            keysPressed.contains(LogicalKeyboardKey.keyS)) {
          FlutterClipboard.controlC(saveGrid(grid));
        } else if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
            keysPressed.contains(LogicalKeyboardKey.keyL) &&
            !running) {
          try {
            FlutterClipboard.paste().then(
              (val) {
                try {
                  grid = loadGrid(jsonDecode(val));
                  cellsToPlace = ["empty"];
                  cellsCount = [1];
                } catch (e) {}
              },
            );
          } catch (e) {}
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
            keys[LogicalKeyboardKey.arrowLeft] != true) {
          currentSeletion = (currentSeletion -
                  1 +
                  (edType == EditorType.making ? cells : cellsToPlace).length) %
              (edType == EditorType.making ? cells : cellsToPlace).length;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) &&
            keys[LogicalKeyboardKey.arrowRight] != true) {
          currentSeletion = (currentSeletion + 1) %
              (edType == EditorType.making ? cells : cellsToPlace).length;
        }
      }
      keys[event.logicalKey] = true;
      return KeyEventResult.handled;
    } else if (event is RawKeyUpEvent) {
      keys[event.logicalKey] = false;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
