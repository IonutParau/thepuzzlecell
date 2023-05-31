import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/scripts/scripts.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/logic.dart';

class ModsUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ModsUIState();
  }
}

class _ModsUIState extends State<ModsUI> {
  List<ModInfo> modsInfo = [];

  @override
  void initState() {
    getModsInfo();
    super.initState();
  }

  void getModsInfo() {
    modsInfo.clear();

    final mods = scriptingManager.getScripts();

    for (var mod in mods) {
      modsInfo.add(
        ModInfo(
          scriptingManager.modName(mod),
          scriptingManager.modDesc(mod),
          scriptingManager.modAuthor(mod),
          scriptingManager.modIcon(mod),
          scriptingManager.modDir(mod),
          scriptingManager.modCells(mod),
          scriptingManager.modReadme(mod),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        child: Row(
          children: [
            Spacer(),
            Text(
              lang('mods', 'Mods'),
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        color: Colors.grey[100],
      ),
      content: ListView.builder(
        itemCount: modsInfo.length,
        itemBuilder: (ctx, i) {
          final info = modsInfo[i];

          return ListTile(
            title: Text(info.title + ' (' + info.author + ')',
                style: fontSize(7.sp)),
            subtitle: Text(info.desc, style: fontSize(5.sp)),
            leading: Image.asset(
              info.icon,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              width: 5.w,
              height: 5.w,
            ),
            trailing: Row(
              children: [
                if (info.readme != null)
                  Button(
                    child: Text(lang("view_readme", "View README"),
                        style: fontSize(7.sp)),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (ctx) => ContentDialog(
                          title: Text("${info.title}'s README"),
                          content: Markdown(
                            data: info.readme!,
                            onTapLink: (text, href, title) {
                              if (href != null) {
                                launchUrl(Uri.parse(href));
                              }
                            },
                            styleSheet: MarkdownStyleSheet(
                              blockSpacing: 3.2.h,
                              textScaleFactor: 2.3,
                            ),
                          ),
                          constraints: BoxConstraints.tight(Size(80.w, 80.h)),
                          actions: [
                            Button(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                Button(
                  child: Text(lang('view_cells', 'View Cells'),
                      style: fontSize(7.sp)),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (ctx) => ViewModCellsDialog(info));
                    setState(() {});
                  },
                ),
                Button(
                  child: Text(lang('open', 'Open'), style: fontSize(7.sp)),
                  onPressed: () {
                    openFileManager(info.dir);
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Text(
              lang('view_modules', 'View Modules'),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) => ModulesDialog(),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
