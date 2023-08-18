part of layout;

late PuzzleGame game;

double get uiScale => storage.getDouble('ui_scale')!;

TextStyle fontSize(double fontSize) {
  return TextStyle(
    fontSize: fontSize,
  );
}

Map<String, bool> keys = {};
Map<String ,bool> lastTickKeys = {};

const halfPi = pi / 2;

num abs(num n) => n < 0 ? -n : n;

class GameUI extends StatefulWidget {
  final EditorType editorType;
  final String? ip;

  const GameUI({Key? key, this.editorType = EditorType.making, this.ip}) : super(key: key);

  @override
  State<GameUI> createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> with TickerProviderStateMixin {
  final scrollController = ScrollController();

  int page = 0;

  @override
  void dispose() {
    timeGrid = null;
    scrollController.dispose();

    if (game.isMultiplayer) {
      game.channel.sink.close();
      game.multiplayerListener.cancel(); // Memory management
    }

    game.msgsListener.sink.close();

    super.dispose();
  }

  @override
  void initState() {
    game = PuzzleGame();
    game.edType = widget.editorType;
    game.ip = widget.ip; 

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
                game.scrollDelta += (event.scrollDelta.dy.abs()) * storage.getDouble("cursor_scroll_scale")!;
                const amount = 50;
                while (game.scrollDelta > amount) {
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

                  game.scrollDelta -= amount;
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
                        color: settingsColor('editor_menu_bg', Colors.grey.withOpacity(0.7)),
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
                                  "${lang('update_delay', "Update Delay")}: ${game.delay}",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(builder: (context, cons) {
                                  return Container(
                                    width: min(40.w, cons.maxWidth),
                                    height: 10.h,
                                    padding: EdgeInsets.all(2.w),
                                    child: Slider(
                                      style: SliderThemeData(
                                        activeColor: settingsColor("editor_menu_slider_active", Colors.blue).state,
                                        inactiveColor: settingsColor("editor_menu_slider_inactive", Colors.black).state,
                                        useThumbBall: true,
                                      ),
                                      value: game.delay,
                                      min: 0.01,
                                      max: 5,
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
                                  "${lang('music_volume', 'Music Volume')}: ${getMusicVolume() * 100}% ",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(
                                  builder: (context, cons) {
                                    return Container(
                                      width: min(40.w, cons.maxWidth),
                                      height: 10.h,
                                      padding: EdgeInsets.all(2.w),
                                      child: Slider(
                                        style: SliderThemeData(
                                          activeColor: settingsColor("editor_menu_slider_active", Colors.blue).state,
                                          inactiveColor: settingsColor("editor_menu_slider_inactive", Colors.black).state,
                                          useThumbBall: true,
                                        ),
                                        value: getMusicVolume(),
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
                                  "${lang('sfx_volume', 'SFX Volume')}: ${(storage.getDouble("sfx_volume") ?? 1) * 100}% ",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Spacer(),
                                LayoutBuilder(
                                  builder: (context, cons) {
                                    return Container(
                                      width: min(40.w, cons.maxWidth),
                                      height: 10.h,
                                      padding: EdgeInsets.all(2.w),
                                      child: Slider(
                                        style: SliderThemeData(
                                          activeColor: settingsColor("editor_menu_slider_active", Colors.blue).state,
                                          inactiveColor: settingsColor("editor_menu_slider_inactive", Colors.black).state,
                                          useThumbBall: true,
                                        ),
                                        value: storage.getDouble("sfx_volume") ?? 1,
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
                                    child: Opacity(
                                      opacity: storage.getDouble("editor_menu_button_opacity")!,
                                      child: Image.asset(
                                        'assets/images/interface/back.png',
                                        fit: BoxFit.fill,
                                        colorBlendMode: BlendMode.clear,
                                        filterQuality: FilterQuality.none,
                                        isAntiAlias: true,
                                        width: 5.w,
                                        height: 5.w,
                                      ),
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
                                      await showDialog<void>(context: context, builder: (ctx) => ClearDialog());
                                    },
                                    child: Opacity(
                                      opacity: storage.getDouble("editor_menu_button_opacity")!,
                                      child: Image.asset(
                                        'assets/images/${textureMap['trash.png']!}',
                                        fit: BoxFit.fill,
                                        colorBlendMode: BlendMode.clear,
                                        filterQuality: FilterQuality.none,
                                        isAntiAlias: true,
                                        width: 5.w,
                                        height: 5.w,
                                      ),
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
                                      await showDialog<void>(context: context, builder: (ctx) => ResizeDialog());
                                    },
                                    child: Opacity(
                                      opacity: storage.getDouble("editor_menu_button_opacity")!,
                                      child: Image.asset(
                                        'assets/images/${textureMap['cancer.png']!}',
                                        fit: BoxFit.fill,
                                        colorBlendMode: BlendMode.clear,
                                        filterQuality: FilterQuality.none,
                                        isAntiAlias: true,
                                        width: 5.w,
                                        height: 5.w,
                                      ),
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
                              if (game.gridHistory.isNotEmpty) ...[
                                Spacer(),
                                Column(
                                  children: [
                                    MaterialButton(
                                      onPressed: () async {
                                        await showDialog<void>(context: context, builder: (ctx) => LevelHistoryDialog());
                                      },
                                      child: Opacity(
                                        opacity: storage.getDouble("editor_menu_button_opacity")!,
                                        child: Image.asset(
                                          'assets/images/${textureMap['time_trash.png']!}',
                                          fit: BoxFit.fill,
                                          colorBlendMode: BlendMode.clear,
                                          filterQuality: FilterQuality.none,
                                          isAntiAlias: true,
                                          width: 5.w,
                                          height: 5.w,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      game.isMultiplayer ? lang('session_history', 'Session History') : lang('grid_history', 'Grid History'),
                                      style: TextStyle(
                                        fontSize: 7.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (!game.isMultiplayer || game.isLan) ...[
                                Spacer(),
                                Column(
                                  children: [
                                    MaterialButton(
                                      onPressed: () async {
                                        if (game.isLan) {
                                          await closeLanServer();
                                          game.isLan = false;
                                          game.ip = null;
                                          game.multiplayerListener.cancel();
                                          game.loadAllButtons();
                                        } else {
                                          await setupLanServer();
                                          game.isLan = true;
                                          const ip = "ws://0.0.0.0:3000";
                                          game.channel = WebSocketChannel.connect(Uri.parse(ip));
                                          game.multiplayerListener = game.channel.stream.listen(
                                            game.multiplayerCallback,
                                            onDone: () {
                                              Navigator.of(context).popUntil((route) {
                                                return route.settings.name == "/main";
                                              });
                                              showDialog<void>(
                                                context: context,
                                                builder: (ctx) {
                                                  return DisconnectionDialog();
                                                },
                                              );
                                            },
                                            onError: (dynamic e) {
                                              Navigator.of(context).popUntil((route) {
                                                return route.settings.name == "/main";
                                              });
                                              showDialog<void>(
                                                context: context,
                                                builder: (ctx) {
                                                  return BasicErrorDialog(e.toString());
                                                },
                                              );
                                            },
                                          );
                                          game.ip = "https://0.0.0.0:3000";
                                          game.clientID = storage.getString('clientID') ?? '@uuid';

                                          while (game.clientID.contains('@uuid')) {
                                            game.clientID = game.clientID.replaceFirst('@uuid', Uuid().v4());
                                          }
                                          game.sendToServer('token', {"version": currentVersion.split(' ').first, "clientID": game.clientID});
                                          game.loadAllButtons();
                                        }
                                      },
                                      child: Opacity(
                                        opacity: storage.getDouble("editor_menu_button_opacity")!,
                                        child: Image.asset(
                                          'assets/images/${textureMap['displayer.png']!}',
                                          fit: BoxFit.fill,
                                          colorBlendMode: BlendMode.clear,
                                          filterQuality: FilterQuality.none,
                                          isAntiAlias: true,
                                          width: 5.w,
                                          height: 5.w,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      game.isLan ? lang('close_lan', 'Close LAN') : lang('open_lan', 'Open LAN'),
                                      style: TextStyle(
                                        fontSize: 7.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
  if (r == 0) {
    return o;
  }
  if (r == pi * 2) {
    return -o;
  }
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
  return a + (b - a) * min(max(t, 0), 1);
}

double lerpRotation(num old, num newR, double t) {
  return lerp(old, old + ((newR - old + 2) % 4 - 2), t);
}

int ceil(num n) => floor(n + 0.999);

Future<void> loadSkinTextures() async {
  await Flame.images.loadAll([
    "skins/hands.png",
    "skins/computer.png",
    "skins/christmas.png",
  ]);
  return;
}

Future<void> loadAllButtonTextures() async {
  await Flame.images.loadAll([
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
    "interface/chat.png",
    "interface/see_online.png",
    "interface/search_cell.png",
    "interface/terminal.png",
  ]);
  return;
}

enum ButtonAlignment {
  topLeft,
  bottomLeft,
  topRight,
  bottomRight,
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
  bool isCellButton;

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

  VirtualButton(this.position, Vector2 size, this.texture, this.alignment, this.callback, this.shouldRender,
      {this.title = "Untitled", this.description = "No description", this.id, this.isCellButton = false})
      : rotation = 0,
        lastRot = 0,
        startPos = position * storage.getDouble('ui_scale')!,
        size = size * storage.getDouble('ui_scale')! {
    position *= storage.getDouble('ui_scale')!;
    translate();
  } // Constructors

  void translate() {
    if (isCellButton) {
      return;
    }
    if (id != null) {
      title = lang("$id.title", title);
      description = lang("$id.desc", description);
    }
  }

  void render(Canvas canvas, Vector2 canvasSize) {
    this.canvasSize = canvasSize;
    late Vector2 screenPos;

    var center = size / 2;

    var opacity = isCellButton ? storage.getDouble("cell_button_opacity")! : storage.getDouble("ui_button_opacity")!;

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
      if (time / duration > 1) {
        return;
      }
      untranslatedPostion = position.clone();
      untranslatedPostion.lerp(
        startPos,
        time / duration,
      );
      seenSize = size * (1 - (time / duration));
    }
    if (alignment == ButtonAlignment.topLeft) {
      screenPos = untranslatedPostion.clone();
    } else if (alignment == ButtonAlignment.topRight) {
      screenPos = Vector2(canvasSize.x - untranslatedPostion.x - size.x, untranslatedPostion.y);
    } else if (alignment == ButtonAlignment.bottomLeft) {
      screenPos = Vector2(untranslatedPostion.x, canvasSize.y - untranslatedPostion.y);
    } else if (alignment == ButtonAlignment.bottomRight) {
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
              ? Colors.white.withOpacity(opacity)
              : Colors.white.withOpacity(
                  0.8 * opacity,
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

    if (alignment == ButtonAlignment.topLeft) {
      screenPos = position.clone();
    } else if (alignment == ButtonAlignment.topRight) {
      screenPos = Vector2(canvasSize.x - position.x - size.x, position.y);
    } else if (alignment == ButtonAlignment.bottomLeft) {
      screenPos = Vector2(position.x, canvasSize.y - position.y);
    } else if (alignment == ButtonAlignment.bottomRight) {
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
    if (!button.isCellButton) {
      button.translate();
    }
  }

  void forEach(void Function(String key, VirtualButton button) callback) => buttons.forEach(callback);

  void removeButton(String key) => buttons.remove(key);

  void clear() => buttons.clear();
}

void renderInfoBox(Canvas canvas, String title, String description) {
  final mouseX = max(game.mouseX, 10).toDouble();
  final mouseY = max(game.mouseY, 10).toDouble();

  final scale = storage.getDouble('infobox_scale')!;

  final titleTP = TextPainter(textWidthBasis: TextWidthBasis.longestLine, textDirection: TextDirection.ltr);
  final descriptionTP = TextPainter(textDirection: TextDirection.ltr);

  final titleColor = settingsColor("infobox_title", Colors.white);
  final descColor = settingsColor("infobox_desc", Colors.white);

  titleTP.text = TextSpan(
    text: title,
    style: TextStyle(
      color: titleColor,
      fontSize: 9.sp * scale,
    ),
  );

  descriptionTP.text = TextSpan(
    text: description,
    style: TextStyle(
      color: descColor,
      fontSize: 7.sp * scale,
    ),
  );

  titleTP.layout();
  final width = max(titleTP.width, 20.w * scale);
  descriptionTP.layout(maxWidth: width);
  final height = titleTP.height + descriptionTP.height;

  var size = Size(width + 20 * scale, height + 20 * scale);
  var off = Offset(mouseX, mouseY);
  if (off.dx + size.width > game.canvasSize.x) {
    off = Offset(game.canvasSize.x - size.width - 10 * scale, off.dy);
  }
  if (off.dy + size.height > game.canvasSize.y) {
    off = Offset(off.dx, game.canvasSize.y - size.height - 10 * scale);
  }

  final rect = off & size;

  final background = settingsColor('infobox_background', Colors.grey[180]);
  final border = settingsColor('infobox_border', Colors.white);

  canvas.drawRect(
    rect,
    Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 * scale,
  );
  canvas.drawRect(
    rect,
    Paint()..color = background,
  );
  titleTP.paint(canvas, Offset(off.dx + 10 * scale, off.dy + 10 * scale));
  descriptionTP.paint(canvas, Offset(off.dx + 10 * scale, off.dy + titleTP.height + 20 * scale));
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
    for (var particle in particles) {
      particle.update(dt);
    }

    particles.removeWhere((p) => p.lifetime >= lifespan);
  }

  void render(Canvas canvas) {
    for (var particle in particles) {
      final lerped = (lifespan - particle.lifetime) / lifespan;
      final s = Size.square(particle.size) * lerped;
      canvas.drawRect(
        (particle.off * cellSize - (s * cellSize / 2).toOffset()) & (s * cellSize),
        Paint()
          ..color = (color!.withOpacity(
            lerped,
          )),
      );
    }
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
