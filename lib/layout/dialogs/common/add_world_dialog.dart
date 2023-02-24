import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/dialogs/core/core.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class AddWorldDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddWorldDialogState();
}

class _AddWorldDialogState extends State<AddWorldDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("create_world", "Create a world")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (ctx, constraints) {
          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(1.w),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: TextBox(
                    controller: _titleController,
                    prefix: Text(lang('title_box', 'Title')),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.w),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: TextBox(
                    controller: _descController,
                    prefix: Text(lang('description', 'Description')),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.w),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: TextBox(
                    controller: _widthController,
                    prefix: Text(lang('width', 'Width')),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.w),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: TextBox(
                    controller: _heightController,
                    prefix: Text(lang('height', 'Height')),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("add", "Add")),
          onPressed: () async {
            try {
              worldManager.addWorld(
                _titleController.text,
                _descController.text,
                int.parse(_widthController.text),
                int.parse(_heightController.text),
              );
              Navigator.of(context).pop();
            } catch (e) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) {
                  return BasicErrorDialog(
                    e.toString(),
                  );
                },
              );
            }
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
