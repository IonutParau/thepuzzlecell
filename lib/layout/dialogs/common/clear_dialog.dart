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
            if (game.isMultiplayer) {
              game.sendToServer(
                'setinit ${P4.encodeGrid(Grid(w, h))}',
              );
            } else {
              grid = Grid(w, h);
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
