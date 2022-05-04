import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, ContentDialog, TextBox;
import '../../logic/logic.dart' show grid, lang, worldIndex, worldManager;

class WorldUI extends StatefulWidget {
  const WorldUI({Key? key}) : super(key: key);

  @override
  State<WorldUI> createState() => _WorldUIState();
}

class _WorldUIState extends State<WorldUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(1.w),
        child: ListView.builder(
          itemCount: worldManager.worldLength,
          itemBuilder: (ctx, i) => WorldTile(
            index: i,
            whenPressed: () => setState(() {}),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 12.sp,
          color: Colors.grey[150],
        ),
        backgroundColor: Colors.orange,
        onPressed: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (ctx) => WorldCreate(),
              ),
            )
            .then(
              (v) => setState(
                () {},
              ),
            ),
      ),
    );
  }
}

class WorldTile extends StatelessWidget {
  final int index;
  final Function() whenPressed;

  const WorldTile({Key? key, required this.index, required this.whenPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final world = worldManager.worldAt(index);
    final worldPart = world.split(';');
    return Padding(
      padding: EdgeInsets.all(0.2.w),
      child: Container(
        color: Colors.grey[150],
        padding: EdgeInsets.all(0.5.w),
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
                          "${lang(
                            "world_del_title",
                            "Are you sure you want to delete \"${worldPart[1]}\"?",
                            {
                              "world": worldPart[1],
                            },
                          )}",
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
                              worldManager.DeleteWorld(index);
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

class WorldCreate extends StatefulWidget {
  const WorldCreate({Key? key}) : super(key: key);

  @override
  State<WorldCreate> createState() => _WorldCreateState();
}

class _WorldCreateState extends State<WorldCreate> {
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(lang('create_world', 'Create A World')),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(flex: 10),
            Container(
              width: 40.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Column(
                children: [
                  Spacer(),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        '${lang('title_box', 'Title')}: ',
                        style: TextStyle(
                          fontSize: 9.sp,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                        child: TextBox(
                          controller: titleController,
                          style: TextStyle(
                            fontSize: 7.sp,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        '${lang('description', 'Description')}: ',
                        style: TextStyle(
                          fontSize: 9.sp,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                        child: TextBox(
                          controller: descController,
                          style: TextStyle(
                            fontSize: 7.sp,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        '${lang('width', 'Width')}: ',
                        style: TextStyle(
                          fontSize: 9.sp,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                        child: TextBox(
                          controller: widthController,
                          style: TextStyle(
                            fontSize: 7.sp,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        '${lang('height', 'Height')}: ',
                        style: TextStyle(
                          fontSize: 9.sp,
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                        child: TextBox(
                          controller: heightController,
                          style: TextStyle(
                            fontSize: 7.sp,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            ),
            Spacer(),
            MaterialButton(
              child: Text(
                lang('add', 'Add'),
                style: fontSize(
                  7.sp,
                ),
              ),
              color: Colors.blue,
              onPressed: () {
                try {
                  worldManager.AddWorld(
                    titleController.text,
                    descController.text,
                    int.parse(widthController.text),
                    int.parse(heightController.text),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text("An error has occured"),
                        content: Text("An error has occured.\nError: $e"),
                      );
                    },
                  );
                }
              },
            ),
            Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}
