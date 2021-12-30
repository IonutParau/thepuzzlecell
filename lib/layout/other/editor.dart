import 'dart:math';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

num clamp(num n, num minimum, num maximum) => min(max(n, minimum), maximum);

class Editor extends StatefulWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  int width = 50;
  int height = 50;

  TextStyle fontSize(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
    );
  }

  void play() {
    grid = Grid(width, height);
    puzzleIndex = null;
    discord.updatePresence(
      DiscordPresence(
        details: 'Making a level',
        largeImageKey: 'tpc_logo',
        startTimeStamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Editor', style: fontSize(12.sp)),
      ),
      body: Column(
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              Container(
                width: 60.w,
                height: 40.h,
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Spacer(),
                    SizedBox(
                      height: 10.h,
                      child: Row(
                        children: [
                          Spacer(),
                          SizedBox(
                            width: 25.w,
                            child: TextField(
                              controller: widthController,
                              onChanged: (str) => setState(
                                () => width =
                                    clamp(int.tryParse(str) ?? width, 1, 999)
                                        .toInt(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 25.w,
                            child: TextField(
                              controller: heightController,
                              onChanged: (str) => setState(
                                () => height =
                                    clamp(int.tryParse(str) ?? height, 1, 999)
                                        .toInt(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          child: Text(
                            'Play!',
                            style: fontSize(12.sp),
                          ),
                          onPressed: () => setState(play),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
