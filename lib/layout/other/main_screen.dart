import 'dart:io';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ClipboardData;
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/other/credits.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

bool get isDesktop {
  if (kIsWeb) return false;

  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

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

  @override
  void initState() {
    super.initState();
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat();

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaleAssist(
      builder: (ctx, size) {
        return StreamBuilder(
          stream: langEvents.stream,
          builder: (context, snapshot) {
            return NavigationView(
              content: NavigationBody(
                index: _navIndex,
                children: [
                  Editor(),
                  Puzzles(),
                  WorldUI(),
                  MultiplayerPage(),
                  Shop(),
                  SettingsPage(),
                  if (isDesktop) LangsUI(),
                  CreditsPage(),
                  VersionPage(),
                  UpdateUI(),
                ],
              ),
              pane: NavigationPane(
                selected: _navIndex,
                onChanged: (i) => setState(() => _navIndex = i),
                displayMode: PaneDisplayMode.auto,
                header: Padding(
                  padding: EdgeInsets.all(0.1.w),
                  child: Row(
                    children: [
                      Spacer(flex: 10),
                      Image.asset(
                        'assets/images/logo.png',
                        filterQuality: FilterQuality.none,
                        width: 2.w,
                        height: 2.w,
                      ),
                      Spacer(),
                      Text(
                        "The Puzzle Cell",
                        style: fontSize(
                          6.sp,
                        ),
                      ),
                      Spacer(flex: 10),
                    ],
                  ),
                ),
                items: [
                  PaneItem(
                    icon: Icon(FluentIcons.edit),
                    title: Text(lang('editor', 'Editor')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.puzzle),
                    title: Text(lang('puzzles', 'Puzzles')),
                  ),
                  PaneItem(
                    icon: Icon(FontAwesomeIcons.earthEurope),
                    title: Text(lang('worlds', 'Worlds')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.my_network),
                    title: Text(lang('multiplayer', 'Multiplayer')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.store_logo16),
                    title: Text(lang('shop', 'In-Game Shop')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.settings),
                    title: Text(lang('settings', 'Settings')),
                  ),
                  if (isDesktop)
                    PaneItem(
                      icon: Icon(FluentIcons.locale_language),
                      title: Text(lang('languages', 'Languages')),
                    ),
                  PaneItem(
                    icon: Icon(FluentIcons.text_document),
                    title: Text(lang('credits', 'Credits')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.change_entitlements),
                    title: Text(lang('version', 'Version')),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.update_restore),
                    title: Text(lang('update', 'Update')),
                  ),
                  PaneItemAction(
                    icon: Icon(FluentIcons.clipboard_list),
                    title: Text(lang('loadLevel', 'Load Level')),
                    onTap: () {
                      try {
                        FlutterClipboard.controlV().then(
                          (str) {
                            if (str is ClipboardData) {
                              game = PuzzleGame();
                              try {
                                grid = loadStr(str.text ?? "");
                                Navigator.pushNamed(context, '/game-loaded');
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return ContentDialog(
                                      title: Text(
                                        lang(
                                          'saveError',
                                          'Invalid save code',
                                        ),
                                      ),
                                      content: Text(
                                        '${lang(
                                          'saveErrorDesc',
                                          'You are trying to load a corrupted, invalid or unsupported level code.',
                                          {"error": e.toString()},
                                        )}',
                                      ),
                                      actions: [
                                        Button(
                                          child: Text('Ok'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return ContentDialog(
                                    title: Text(
                                      lang(
                                        'noStringLoad',
                                        'Invalid clipboard format',
                                      ),
                                    ),
                                    content: Text(
                                      '${lang(
                                        'noStringLoadDesc',
                                        'The clipboard data you have in your clipboard is not text',
                                        {"error": e.toString()},
                                      )}',
                                    ),
                                    actions: [
                                      Button(
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        );
                      } catch (e) {
                        //print(e);
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return ContentDialog(
                              title: Text(
                                lang(
                                  'saveError',
                                  'Invalid save code',
                                ),
                              ),
                              content: Text(
                                '${lang(
                                  'saveErrorDesc',
                                  'You are trying to load a corrupted, invalid or unsupported level code. Error: $e',
                                  {"error": e.toString()},
                                )}',
                              ),
                              actions: [
                                Button(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  PaneItemAction(
                    icon: Icon(FluentIcons.leave),
                    title: Text(lang('quit', 'Quit')),
                    onTap: () {
                      exit(0);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
