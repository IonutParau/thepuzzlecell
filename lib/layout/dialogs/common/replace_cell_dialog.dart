import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class ReplaceCellDialog extends StatefulWidget {
  @override
  _ReplaceCellDialogState createState() => _ReplaceCellDialogState();
}

class _ReplaceCellDialogState extends State<ReplaceCellDialog> {
  final controllers = <TextEditingController>[];

  final ids = [
    "Replace",
    "With",
  ];

  @override
  void dispose() {
    controllers.forEach((v) => v.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < ids.length; i++) {
      controllers.add(
        TextEditingController(
          text: game.currentSelection,
        ),
      );
    }
  }

  Widget idTile(int i, String displayName) {
    final textStyle = TextStyle(fontSize: 5.sp);

    final currentID = controllers[i].text;
    final tp = textureMap['$currentID.png'] ?? '$currentID.png';
    return DropDownButton(
      placement: FlyoutPlacementMode.bottomCenter,
      leading: Image.asset(
        'assets/images/$tp',
        fit: BoxFit.fill,
        colorBlendMode: BlendMode.clear,
        filterQuality: FilterQuality.none,
        isAntiAlias: true,
        width: 3.h,
        height: 3.h,
      ),
      title: Text("$displayName: " + idToString(currentID), style: textStyle),
      items: [
        for (var id in (cells..removeWhere((v) => backgrounds.contains(v))))
          MenuFlyoutItem(
            leading: Image.asset(
              'assets/images/${textureMap["$id.png"] ?? "$id.png"}',
              fit: BoxFit.fill,
              colorBlendMode: BlendMode.clear,
              filterQuality: FilterQuality.none,
              isAntiAlias: true,
              width: 3.h,
              height: 3.h,
            ),
            text: Text(idToString(id), style: textStyle),
            onPressed: () {
              controllers[i].text = id;
              setState(() {});
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("prop-edit-btn.title", "Property Editor")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return ListView(
            children: [
              for (var i = 0; i < ids.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.25.h),
                  child: SizedBox(
                    width: constraints.maxWidth * 0.7,
                    height: 7.h,
                    child: idTile(i, ids[i]),
                  ),
                ),
            ],
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("cancel", "Cancel")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Button(
          child: Text("Ok"),
          onPressed: () {
            if (game.selW < 0) {
              game.selW *= -1;
              game.selX -= game.selW;
            }
            if (game.selH < 0) {
              game.selH *= -1;
              game.selY -= game.selH;
            }

            game.selW--;
            game.selH--;

            print(ids);

            for (var x = 0; x <= game.selW; x++) {
              for (var y = 0; y <= game.selH; y++) {
                final cx = game.selX + x;
                final cy = game.selY + y;
                if (grid.inside(cx, cy)) {
                  final c = grid.at(cx, cy);
                  if (c.id == controllers[0].text) {
                    c.id = controllers[1].text;
                  }
                }
              }
            }

            game.selecting = false;
            game.setPos = false;
            game.dragPos = false;
            game.pasting = false;

            game.selW++;
            game.selH++;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
