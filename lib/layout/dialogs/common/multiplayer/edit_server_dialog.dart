import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class EditServerDialog extends StatefulWidget {
  final int i;
  final String title;
  final String ip;
  final void Function()? refresh;

  const EditServerDialog(this.i, this.title, this.ip, {this.refresh});

  @override
  State<StatefulWidget> createState() => _EditServerDialogState();
}

class _EditServerDialogState extends State<EditServerDialog> {
  final _titleController = TextEditingController();
  final _ipController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.title;
    _ipController.text = widget.ip;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("edit_server", "Edit a server")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (ctx, constraints) {
          return ListView(
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.7,
                height: 7.h,
                child: TextBox(
                  controller: _titleController,
                  prefix: Text(lang('title_box', 'Title')),
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.7,
                height: 7.h,
                child: TextBox(
                  controller: _ipController,
                  prefix: Text(lang('ip_address', 'IP / Address')),
                ),
              ),
            ],
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("edit", "Edit")),
          onPressed: () async {
            final strList = storage.getStringList("servers")!;

            strList[widget.i] = "${_titleController.text};${_ipController.text}";

            storage.setStringList('servers', strList);

            widget.refresh?.call();

            Navigator.pop(context);
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
