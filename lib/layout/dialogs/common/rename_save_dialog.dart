import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class RenameSaveDialog extends StatefulWidget {
  final String saveCode;

  RenameSaveDialog(this.saveCode);

  @override
  _RenameSaveDialogState createState() => _RenameSaveDialogState();
}

class _RenameSaveDialogState extends State<RenameSaveDialog> {
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
      title: Text(lang("change_name_and_description", "Change Name & Description")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return Center(
            child: Column(
              children: [
                Spacer(),
                SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: TextBox(
                    header: 'Title',
                    controller: _titleController,
                  ),
                ),
                SizedBox(width: constraints.maxWidth / 10),
                SizedBox(
                  width: constraints.maxWidth * 0.7,
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
          child: Text(lang("rename", "Rename")),
          onPressed: () async {
            final title = _titleController.text;
            final desc = _descController.text;

            final segs = widget.saveCode.split(";");

            segs[1] = title;
            segs[2] = desc;

            final newSave = segs.join(';');

            await FlutterClipboard.copy(newSave);

            Navigator.of(context).pop();
          },
        ),
        Button(
          child: Text(lang("cancel", "Cancel")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
