import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import 'package:the_puzzle_cell/layout/tools/tools.dart';

class SaveLevelDialog extends StatelessWidget {
  final String saveCode;

  const SaveLevelDialog(this.saveCode);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('saved_level', 'Saved Level')),
      content: Text(lang('saved_level_desc', 'Saved level to clipboard')),
      actions: [
        if (game.edType == EditorType.making && worldIndex == null)
          Button(
            child: Text(lang('rename', 'Rename')),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => RenameSaveDialog(saveCode),
              );
            },
          ),
        Button(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
