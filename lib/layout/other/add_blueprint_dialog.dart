import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class AddBlueprintDialog extends StatefulWidget {
  final String bpCode;

  AddBlueprintDialog(this.bpCode);

  @override
  _AddBlueprintDialogState createState() => _AddBlueprintDialogState();
}

class _AddBlueprintDialogState extends State<AddBlueprintDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("blueprint_name_and_description", "Blueprint Name & Description")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
            child: Column(
              children: [
                Spacer(),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  height: 7.h,
                  child: TextBox(
                    header: 'Title',
                    controller: _titleController,
                  ),
                ),
                SizedBox(width: constraints.maxWidth / 10),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  height: 7.h,
                  child: TextBox(
                    header: 'Description',
                    controller: _descController,
                  ),
                ),
                Spacer(),
              ],
            ),
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("add", "Add")),
          onPressed: () async {
            final title = _titleController.text;
            final desc = _descController.text;

            final bpCode = widget.bpCode.replaceFirst("Unnamed Blueprint", title).replaceFirst("This blueprint currently has no name", desc);

            await FlutterClipboard.copy(bpCode);

            await addBlueprint(bpCode);

            Navigator.of(context).pop();
          },
        ),
        Button(
          child: Text(lang("cancel", "Cancel")),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
