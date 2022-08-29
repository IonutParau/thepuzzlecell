import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class AddServerDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<AddServerDialog> {
  final _titleController = TextEditingController();
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("add_server", "Add a server")),
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
                  header: lang('title_box', 'Title'),
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.7,
                height: 7.h,
                child: TextBox(
                  controller: _ipController,
                  header: lang('ip_address', 'IP / Address'),
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
            await storage.setStringList(
              "servers",
              storage.getStringList("servers")!
                ..add(
                  "${_titleController.text};${_ipController.text}",
                ),
            );
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
