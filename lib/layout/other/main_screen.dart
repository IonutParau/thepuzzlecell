import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TextStyle fontSize(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
    );
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat();

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleAssist(
      builder: (context, orientation) {
        final buttonPadding = EdgeInsets.all(1.2.w);

        final buttonStyle = fontSize(12.sp);

        return Scaffold(
          appBar: AppBar(
            title: Text('The Puzzle Cell', style: fontSize(10.sp)),
            actions: [],
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                    animation: _controller,
                    child: Image.asset(
                      'assets/images/logo.png',
                      scale: 200 / 50.w,
                    ),
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Transform.rotate(
                            angle: -_controller.value * pi * 4,
                            child: child,
                          ),
                        ],
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Spacer(),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Puzzles', style: buttonStyle),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/puzzles'),
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Editor', style: buttonStyle),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/editor');
                            },
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Multiplayer', style: buttonStyle),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/multiplayer');
                            },
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Load Level', style: buttonStyle),
                            onPressed: () {
                              FlutterClipboard.controlV().then(
                                (clipboard) {
                                  try {
                                    if (clipboard is ClipboardData) {
                                      game = PuzzleGame();
                                      grid = loadStr(clipboard.text!);
                                      puzzleIndex = null;
                                      Navigator.of(context)
                                          .pushNamed('/game-loaded');
                                    } else {
                                      throw "wtf";
                                    }
                                  } catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: Text('Invalid code'),
                                          content: Text(
                                            "The code you have in your clipboard is not valid code or can not pe properly loaded. Please try again after getting a proper level code\n$e",
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              );
                            },
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Quit', style: buttonStyle),
                            onPressed: () {
                              exit(0);
                            },
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Spacer(),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Settings', style: buttonStyle),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/settings'),
                            hoverColor: Colors.blue,
                          ),
                        ),
                        // Padding(
                        //   padding: buttonPadding,
                        //   child: MaterialButton(
                        //     child: Text('Texture Packs', style: buttonStyle),
                        //     onPressed: () =>
                        //         Navigator.of(context).pushNamed('/texturepack'),
                        //     hoverColor: Colors.blue,
                        //   ),
                        // ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Credits', style: buttonStyle),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/credits'),
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Padding(
                          padding: buttonPadding,
                          child: MaterialButton(
                            child: Text('Version', style: buttonStyle),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/version'),
                            hoverColor: Colors.blue,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
