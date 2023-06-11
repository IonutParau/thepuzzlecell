import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import 'package:the_puzzle_cell/layout/layout.dart';

class LevelHistoryDialog extends StatefulWidget {
  @override
  State<LevelHistoryDialog> createState() => _LevelHistoryDialogState();
}

class _LevelHistoryDialogState extends State<LevelHistoryDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(game.isMultiplayer ? lang('session_history', 'Session History') : lang('grid_history', 'Grid History')),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          if (game.gridHistory.isEmpty) {
            return Center(
              child: Text(lang("history_is_empty", "No History Found")),
            );
          }
          return SizedBox(
            width: constraints.maxWidth,
            child: ListView.builder(
              itemCount: game.gridHistory.length,
              itemBuilder: (ctx, i) {
                i = (game.gridHistory.length - i - 1);
                final lvl = game.gridHistory[i];
                final segs = lvl.split(';');

                return ListTile(
                  title: Wrap(children: [Text(segs[1] == "" ? "Unnamed" : segs[1])]),
                  subtitle: Text(segs[2]),
                  trailing: Row(
                    children: [
                      Button(
                        child: Text(lang("load", "Load")),
                        onPressed: () {
                          game.loadFromText(lvl);
                          Navigator.pop(context);
                        },
                      ),
                      Button(
                        child: Text(lang("delete", "Delete")),
                        onPressed: () {
                          game.gridHistory.removeAt(i);
                          game.saveHistory();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return ContentDialog(
                          title: Text(lang('level_from_history', 'Stored Level $i', {"index": i.toString()})),
                          content: Text(lvl),
                          actions: [
                            Button(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("clear", "Clear")),
          onPressed: () {
            game.gridHistory.clear();
            game.saveHistory();
            Navigator.pop(context);
          },
        ),
        Button(
          child: Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
