import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import '../../layout.dart';
import '../../tools/tools.dart';

class ResizeDialog extends StatefulWidget {
  @override
  _ResizeDialogState createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<ResizeDialog> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

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
            child: Row(
              children: [
                Spacer(),
                SizedBox(
                  width: constraints.maxWidth / 3,
                  height: 7.h,
                  child: TextBox(
                    header: 'Width',
                    controller: _widthController,
                  ),
                ),
                SizedBox(width: constraints.maxWidth / 10),
                SizedBox(
                  width: constraints.maxWidth / 3,
                  height: 7.h,
                  child: TextBox(
                    header: 'Height',
                    controller: _heightController,
                  ),
                ),
                Spacer(),
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
            final area = w * h;

            // Insane optimization
            if (area < grid.width * grid.height) {
              g.forEach(
                (_, x, y) {
                  if (grid.inside(x, y)) {
                    g.set(x, y, grid.at(x, y));
                  }
                },
              );
            } else {
              grid.forEach(
                (cell, x, y) {
                  if (g.inside(x, y)) {
                    g.set(x, y, cell);
                  }
                },
              );
            }

            if (game.isMultiplayer) {
              game.sendToServer(
                'setinit ${P4.encodeGrid(g)}',
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
