import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:path/path.dart' as path;

class CreateTexturePackDialog extends StatefulWidget {
  @override
  State<CreateTexturePackDialog> createState() => _CreateTexturePackDialogState();
}

class _CreateTexturePackDialogState extends State<CreateTexturePackDialog> {
  late TextEditingController idController;
  late TextEditingController titleController;

  @override
  void dispose() {
    idController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    idController = TextEditingController();
    titleController = TextEditingController();

    idController.text = "my_texturepack";
    titleController.text = "My Texture Pack";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('create_tp', 'Create Texture Pack')),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (ctx, constraints) {
          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.25.h),
                child: TextBox(
                  prefix: Text('ID'),
                  controller: idController,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.25.h),
                child: TextBox(
                  prefix: Text(lang('title_box', 'Title')),
                  controller: titleController,
                ),
              ),
            ],
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang('cancel', 'Cancel')),
          onPressed: () => Navigator.pop(context),
        ),
        Button(
          child: Text(lang('create', 'Create')),
          onPressed: () {
            final texturepackDir = Directory(path.join(tpDir.path, idController.text))..createSync();

            final file = File(path.join(texturepackDir.path, 'pack.json'))..createSync();

            file.writeAsStringSync(jsonEncode({
              "title": titleController.text,
              "icon": "icon.png",
            }));

            File(path.join(assetsPath, 'assets', 'images', 'logo.png')).copySync(path.join(texturepackDir.path, 'icon.png'));

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
