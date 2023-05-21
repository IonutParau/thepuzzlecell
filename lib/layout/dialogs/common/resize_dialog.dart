import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import '../../layout.dart';
import '../../tools/tools.dart';

enum ResizeCorner {
  topleft,
  topright,
  bottomright,
  bottomleft,
}

class ResizeDialog extends StatefulWidget {
  @override
  _ResizeDialogState createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<ResizeDialog> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  var corner = ResizeCorner.topleft;

  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _widthController.text = grid.width.toString();
    _heightController.text = grid.height.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("resize", "Resize")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    SizedBox(
                      width: constraints.maxWidth / 3,
                      height: 7.h,
                      child: TextBox(
                        prefix: Text('Width'),
                        controller: _widthController,
                      ),
                    ),
                    SizedBox(width: constraints.maxWidth / 10),
                    SizedBox(
                      width: constraints.maxWidth / 3,
                      height: 7.h,
                      child: TextBox(
                        prefix: Text('Height'),
                        controller: _heightController,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(width: constraints.maxWidth / 10),
                SizedBox(
                  width: constraints.maxWidth / 1.2,
                  height: 7.h,
                  child: DropDownButton(
                    title: Text(lang("resize_corner", "Resizing Corner") + ": " + cornerToString(corner.index)),
                    items: [
                      for (var i = 0; i < 4; i++)
                        MenuFlyoutItem(
                          text: Text(cornerToString(i)),
                          onPressed: () {
                            setState(() {
                              corner = ResizeCorner.values[i % ResizeCorner.values.length];
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("resize", "Resize")),
          onPressed: () {
            final w = int.tryParse(_widthController.text) ?? grid.width;
            final h = int.tryParse(_heightController.text) ?? grid.height;
            if (game.running) {
              game.playPause();
              game.running = false;
              game.buttonManager.buttons['play-btn']!.texture = "mover.png";
              game.buttonManager.buttons['play-btn']!.rotation = 0;
            }
            if (game.onetick) {
              game.onetick = false;
            }
            game.isinitial = true;
            game.initial = grid.copy;
            game.itime = 0;
            final g = Grid(w, h);
            g.title = grid.title;
            g.desc = grid.desc;
            final area = w * h;

            switch (corner) {
              case ResizeCorner.topleft:
                if (area < grid.width * grid.height) {
                  g.forEach(
                    (_, x, y) {
                      if (grid.inside(x, y)) {
                        g.set(x, y, grid.at(x, y));
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                } else {
                  grid.forEach(
                    (cell, x, y) {
                      if (g.inside(x, y)) {
                        g.set(x, y, cell);
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                }
                break;
              case ResizeCorner.topright:
                if (area < grid.width * grid.height) {
                  g.forEach(
                    (_, x, y) {
                      final cx = x + grid.width - g.width;
                      if (grid.inside(cx, y)) {
                        g.set(x, y, grid.at(cx, y));
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                } else {
                  grid.forEach(
                    (cell, x, y) {
                      final cx = x + g.width - grid.width;
                      if (g.inside(cx, y)) {
                        g.set(cx, y, cell);
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                }
                break;
              case ResizeCorner.bottomright:
                if (area < grid.width * grid.height) {
                  g.forEach(
                    (_, x, y) {
                      final cx = x + grid.width - g.width;
                      final cy = y + grid.height - g.height;
                      if (grid.inside(cx, cy)) {
                        g.set(x, y, grid.at(cx, cy));
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                } else {
                  grid.forEach(
                    (cell, x, y) {
                      final cx = x + g.width - grid.width;
                      final cy = y + g.height - grid.height;
                      if (g.inside(cx, cy)) {
                        g.set(cx, cy, cell);
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                }
                break;
              case ResizeCorner.bottomleft:
                if (area < grid.width * grid.height) {
                  g.forEach(
                    (_, x, y) {
                      final cy = y + grid.height - g.height;
                      if (grid.inside(x, cy)) {
                        g.set(x, y, grid.at(x, cy));
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                } else {
                  grid.forEach(
                    (cell, x, y) {
                      final cy = y + g.height - grid.height;
                      if (g.inside(x, cy)) {
                        g.set(x, cy, cell);
                        g.setPlace(x, y, grid.placeable(x, y));
                      }
                    },
                  );
                }
                break;
              default:
                break;
            }

            if (game.isMultiplayer) {
              game.sendToServer(
                'setinit',
                {"code": SavingFormat.encodeGrid(g, title: g.title, description: g.desc)},
              );
            } else {
              grid = g;
            }
            game.buildEmpty();
            game.overlays.remove("EditorMenu");
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
