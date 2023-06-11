import 'package:clipboard/clipboard.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart' show MaterialButton;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart' show PuzzleGame, grid, lang, worldIndex, worldManager;

class WorldUI extends StatefulWidget {
  const WorldUI({Key? key}) : super(key: key);

  @override
  State<WorldUI> createState() => _WorldUIState();
}

class _WorldUIState extends State<WorldUI> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        child: Row(
          children: [
            Spacer(),
            Text(
              lang('worlds', 'Worlds'),
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        color: Colors.grey[100],
      ),
      content: Padding(
        padding: EdgeInsets.all(1.w),
        child: ListView.builder(
          itemCount: worldManager.worldLength,
          itemBuilder: (ctx, i) => WorldTile(
            index: i,
            whenPressed: () => setState(() {}),
          ),
        ),
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Text(
              lang("create", "Create"),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            onPressed: () => showDialog(context: context, builder: (ctx) => AddWorldDialog()).then(
              (v) => setState(
                () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorldTile extends StatelessWidget {
  final int index;
  final void Function() whenPressed;

  const WorldTile({Key? key, required this.index, required this.whenPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final world = worldManager.worldAt(index);
    final worldPart = world.split(';');
    return Padding(
      padding: EdgeInsets.all(0.2.w),
      child: Container(
        color: Colors.grey[150],
        padding: EdgeInsets.all(0.5.w),
        width: 15.w,
        height: 10.h,
        child: ListTile(
          title: Row(
            children: [
              Text(
                worldPart[1],
                style: TextStyle(
                  fontSize: 7.sp,
                ),
              ),
              Spacer(),
              MaterialButton(
                child: Text(
                  lang('editor', 'Editor'),
                  style: TextStyle(
                    fontSize: 5.sp,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  game = PuzzleGame();
                  grid = loadStr(worldManager.worldAt(index));
                  puzzleIndex = null;
                  worldIndex = index;
                  Navigator.of(context).pushNamed('/game');
                  whenPressed();
                },
                color: Colors.orange,
              ),
              MaterialButton(
                child: Text(
                  lang('puzzle', 'Puzzle'),
                  style: TextStyle(
                    fontSize: 5.sp,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  game = PuzzleGame();
                  grid = loadStr(worldManager.worldAt(index));
                  puzzleIndex = null;
                  //worldIndex = index;
                  Navigator.of(context).pushNamed('/game-loaded');
                  whenPressed();
                },
                color: Colors.blue,
              ),
              MaterialButton(
                child: Text(
                  lang('export', 'Export'),
                  style: TextStyle(
                    fontSize: 5.sp,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  await FlutterClipboard.copy(worldManager.worldAt(index));

                  showDialog(context: context, builder: (ctx) => ExportWorldDialog());
                },
                color: Colors.teal,
              ),
              MaterialButton(
                child: Text(
                  lang('delete', 'Delete'),
                  style: TextStyle(
                    fontSize: 5.sp,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return ContentDialog(
                        title: Text(
                          lang(
                            "world_del_title",
                            "Are you sure you want to delete \"${worldPart[1]}\"?",
                            {
                              "world": worldPart[1],
                            },
                          ),
                        ),
                        content: Text(
                          lang(
                            "world_del_content",
                            "You have pressed the delete button for this world. If you click Yes, it will be deleted forever with no way to bring it back.",
                          ),
                        ),
                        actions: [
                          MaterialButton(
                            child: Text(lang("yes", "Yes")),
                            onPressed: () {
                              Navigator.pop(context);
                              worldManager.deleteWorld(index);
                              whenPressed();
                            },
                            color: Colors.red,
                          ),
                          MaterialButton(
                            child: Text(lang("no", "No")),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                color: Colors.red,
              ),
            ],
          ),
          subtitle: Text(
            worldPart[2],
            style: TextStyle(
              fontSize: 3.sp,
            ),
          ),
        ),
      ),
    );
  }
}
