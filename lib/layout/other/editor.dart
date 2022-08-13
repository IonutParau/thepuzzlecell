import 'dart:math';

import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:fluent_ui/fluent_ui.dart';

num clamp(num n, num minimum, num maximum) => min(max(n, minimum), maximum);

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int width = 100;
  int height = 100;

  TextStyle fontSize(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
    );
  }

  void play() {
    grid = Grid(width, height);
    puzzleIndex = null;
    Navigator.of(context).pushNamed('/game');
  }

  final widthController = TextEditingController();
  final heightController = TextEditingController();

  @override
  void initState() {
    widthController.text = width.toString();
    heightController.text = height.toString();
    super.initState();
  }

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              lang("editor", "Editor"),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      content: Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            children: [
              Spacer(flex: 10),
              Row(
                children: [
                  Spacer(flex: 5),
                  SizedBox(
                    width: 20.w,
                    child: TextBox(
                      header: lang('width', 'Width'),
                      keyboardType: TextInputType.number,
                      placeholder: '100',
                      onChanged: (v) => setState(
                        () => width = clamp(
                                int.tryParse(v) ?? (v == "" ? 100 : width),
                                1,
                                999)
                            .toInt(),
                      ),
                      keyboardAppearance: Brightness.dark,
                      decoration: BoxDecoration(
                        color: Colors.grey[180],
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 20.w,
                    child: TextBox(
                      header: lang('height', 'Height'),
                      keyboardType: TextInputType.number,
                      placeholder: '100',
                      onChanged: (v) => setState(
                        () => height = clamp(
                                int.tryParse(v) ?? (v == "" ? 100 : height),
                                1,
                                999)
                            .toInt(),
                      ),
                      keyboardAppearance: Brightness.dark,
                      decoration: BoxDecoration(
                        color: Colors.grey[180],
                      ),
                    ),
                  ),
                  Spacer(flex: 5),
                ],
              ),
              Spacer(),
              Button(
                child: Text(
                  lang('play', 'Play!'),
                  style: fontSize(
                    12.sp,
                  ),
                ),
                onPressed: () => setState(play),
              ),
              Spacer(flex: 10),
            ],
          ),
        ),
      ),
    );
  }
}
