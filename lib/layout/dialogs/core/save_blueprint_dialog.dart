import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import '../common/blueprints/add_blueprint_dialog.dart';
import '../common/rename_blueprint_dialog.dart';

class SaveBlueprintDialog extends StatelessWidget {
  final String bpSave;

  SaveBlueprintDialog(this.bpSave);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('saved_blueprint', 'Saved Blueprint')),
      content: Text(
        lang(
          'saved_blueprint_desc',
          'The blueprint has been saved to your clipboard. You can change \"Unnamed Blueprint\" and \"This blueprint currently has no name\" to change title and description. Then you can put it in your blueprints file to use it later.',
        ),
      ),
      actions: [
        Button(
          child: Text(lang('add_to_builtin', 'Add to\nbuilt-in')),
          onPressed: () {
            Navigator.pop(context);
            showDialog(context: context, builder: (ctx) => AddBlueprintDialog(bpSave));
          },
        ),
        Button(
          child: Text(lang('change_name_and_description', 'Change Name & Description')),
          onPressed: () {
            Navigator.pop(context);
            showDialog(context: context, builder: (ctx) => RenameBlueprintDialog(bpSave));
          },
        ),
        Button(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
