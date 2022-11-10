import 'dart:io';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ClipboardData;
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/other/credits.dart';
import 'package:the_puzzle_cell/layout/other/texturepacks_ui.dart';
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
  DateTime lastLoadTime = DateTime.utc(2000);

  @override
  Widget build(BuildContext context) {
    return ScaleAssist(
      builder: (ctx, size) {
        return StreamBuilder(
          stream: langEvents.stream,
          builder: (context, snapshot) {
            return NavigationView(
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
                        fit: BoxFit.fill,
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
                    body: Editor(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.puzzle),
                    title: Text(lang('puzzles', 'Puzzles')),
                    body: Puzzles(),
                  ),
                  PaneItem(
                    icon: Icon(FontAwesomeIcons.earthEurope),
                    title: Text(lang('worlds', 'Worlds')),
                    body: WorldUI(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.my_network),
                    title: Text(lang('multiplayer', 'Multiplayer')),
                    body: MultiplayerPage(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.store_logo16),
                    title: Text(lang('shop', 'In-Game Shop')),
                    body: Shop(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.settings),
                    title: Text(lang('settings', 'Settings')),
                    body: SettingsPage(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.list),
                    title: Text(lang('achievements', 'Achievements')),
                    body: AchievementsUI(),
                  ),
                  if (isDesktop) ...[
                    PaneItem(
                      icon: Icon(FluentIcons.picture),
                      title: Text(lang('texture_packs', 'Texture Packs')),
                      body: TexturePacksUI(),
                    ),
                    PaneItem(
                      icon: Icon(FluentIcons.locale_language),
                      title: Text(lang('languages', 'Languages')),
                      body: LangsUI(),
                    ),
                  ],
                  PaneItem(
                    icon: Icon(FluentIcons.text_document),
                    title: Text(lang('credits', 'Credits')),
                    body: CreditsPage(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.change_entitlements),
                    title: Text(lang('version', 'Version')),
                    body: VersionPage(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.update_restore),
                    title: Text(lang('update', 'Update')),
                    body: UpdateUI(),
                  ),
                  PaneItemAction(
                    icon: Icon(FluentIcons.clipboard_list),
                    title: Text(lang('loadLevel', 'Load Level')),
                    onTap: () {
                      final now = DateTime.now();
                      if (now.millisecondsSinceEpoch - lastLoadTime.millisecondsSinceEpoch < 500) {
                        return;
                      }
                      lastLoadTime = now;
                      try {
                        FlutterClipboard.controlV().then(
                          (str) {
                            if (str is ClipboardData) {
                              try {
                                grid = loadStr(str.text ?? "");
                                game = PuzzleGame();
                                Navigator.pushNamed(context, '/game-loaded');
                              } catch (e) {
                                print(e);
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return LoadSaveErrorDialog(e.toString());
                                  },
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return LoadSaveErrorDialog("Clipboard does not contain text");
                                },
                              );
                            }
                          },
                        );
                      } catch (e) {
                        print(e.toString());
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return LoadSaveErrorDialog(e.toString());
                          },
                        );
                      }
                    },
                  ),
                  if (isDesktop)
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
