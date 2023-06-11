import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart' as path;

import 'package:the_puzzle_cell/logic/logic.dart';

class ModulesDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ModulesDialogState();
  }
}

class _ModulesDialogState extends State<ModulesDialog> {
  List<File> _modules = [];

  void getModules() {
    if (isDesktop) {
      _modules = Directory(path.join(assetsPath, 'modules'))
          .listSync()
          .whereType<File>()
          .where((e) => e.path.endsWith('.lua'))
          .toList();
    }
  }

  @override
  void initState() {
    getModules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("view_modules", "View Modules")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: ListView.builder(
                itemCount: _modules.length,
                itemBuilder: (ctx, i) {
                  return ListTile(
                    tileColor: ConstantColorButtonState(Colors.grey[130]),
                    title: Text(path.split(_modules[i].path).last),
                    subtitle: Button(
                      child: Text(lang('delete', 'Delete')),
                      onPressed: () {
                        _modules[i].deleteSync();
                        setState(getModules);
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        Button(
          child: Text(lang("install_from_file", "Install from File")),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              allowedExtensions: ['.lua'],
            );

            if (result != null) {
              if (result.files.isNotEmpty) {
                for (var platformFile in result.paths) {
                  final file = File(platformFile!);

                  file.copySync(path.absolute(
                      assetsPath, 'modules', path.split(file.path).last));
                }
              }
            }

            setState(getModules);
          },
        ),
        Button(
          child: Text(lang("open", "Open")),
          onPressed: () {
            openFileManager(Directory(path.join(assetsPath, 'modules')));
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
