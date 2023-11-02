import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class ClearDialog extends StatefulWidget {
  const ClearDialog({Key? key}) : super(key: key);

  @override
  State<ClearDialog> createState() => _ClearDialogState();
}

class _ClearDialogState extends State<ClearDialog> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  var useBorder = false;

  @override
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
      title: Text(lang("resize_and_clear", "Resize & Clear")),
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
                SizedBox(height: constraints.maxHeight / 20),
                Row(
                  children: [
                    Spacer(),
                    Text("Use Selected Cell as Border"),
                    SizedBox(width: constraints.maxWidth / 20),
                    Checkbox(checked: useBorder, onChanged: (v) => setState(() => useBorder = v ?? useBorder)),
                    Spacer(),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("clear", "Clear")),
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
            if(useBorder) {
              final c = game.currentSelection;

              for(var x = 0; x < w; x++) {
                g.set(x, 0, Cell(x, 0)..id = c);
                g.set(x, h - 1, Cell(x, h - 1)..id = c);
              }

              for(var y = 0; y < h; y++) {
                g.set(0, y, Cell(0, y)..id = c);
                g.set(w - 1, y, Cell(w - 1, y)..id = c);
              }
            }

            if (game.isMultiplayer) {
              game.sendToServer(
                'setinit',
                {"code": SavingFormat.encodeGrid(g)},
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
