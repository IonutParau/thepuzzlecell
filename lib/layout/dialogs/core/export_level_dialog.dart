import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class ExportWorldDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('exported_level', 'Exported Level')),
      content: Text(lang('exported_level_desc', 'Exported level to clipboard')),
      actions: [
        Button(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
