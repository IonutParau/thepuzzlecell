import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/dialogs/dialogs.dart';
import 'package:the_puzzle_cell/logic/performance/unzip_on_thread.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../logic/logic.dart';

class TexturePacksUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TexturePacksUIState();
}

class _TexturePacksUIState extends State<TexturePacksUI> {
  // Keep track of if we should continue to exist lmao
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Widget tile(TexturePack tp) {
    return ListTile(
      title: Text(tp.title),
      leading: Row(
        children: [
          Checkbox(
            checked: tp.enabled,
            onChanged: (v) async {
              if (v != null && v != tp.enabled) {
                await tp.toggle();
                await applyTexturePackSettings();
                applyTexturePacks();
                setState(() {});
              }
            },
          ),
          Image.asset(tp.icon),
        ],
      ),
      trailing: Row(
        children: [
          Button(
            child: Text(lang("modify", "Modify")),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) {
                  return ModifyTexturePackDialog(tp);
                },
              );
              loadTexturePacks();
              await applyTexturePackSettings();
              applyTexturePacks();
              setState(() {});
            },
          ),
          Button(
            child: Text(lang("delete", "Delete")),
            onPressed: () async {
              await tp.dir.delete(recursive: true);
              loadTexturePacks();
              await applyTexturePackSettings();
              applyTexturePacks();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            Spacer(),
            Text(
              lang("texture_packs", "Texture Packs"),
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Text(lang("install_from_file", "Install from File"), style: TextStyle(fontSize: 7.sp)),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['zip'],
              );

              // Result is null if user cancelled the file picking attempt
              if (result != null) {
                final zip = File(result.files.single.path!);
                final dir = Directory(path.join(assetsPath, "assets", "images", "texture_packs"));

                final future = unzipOnThread(dir, zip);
                // Rerender once done, if we should still... well... exist
                future.then((v) async {
                  if (!disposed) {
                    loadTexturePacks();
                    await applyTexturePackSettings();
                    applyTexturePacks();
                    setState(() {});
                  }
                });

                await showDialog(
                  context: context,
                  builder: (ctx) {
                    return LoadingDialog(future: future, title: "Unzipping... (may take a while)");
                  },
                );
              }
            },
          ),
          Button(
            child: Text(lang("enable_all", "Enable All"), style: TextStyle(fontSize: 7.sp)),
            onPressed: () async {
              await storage.remove("disabled_texturepacks");
              await applyTexturePackSettings();
              applyTexturePacks();
              setState(() {});
            },
          ),
          Button(
            child: Text(lang("reload", "Reload"), style: TextStyle(fontSize: 7.sp)),
            onPressed: () async {
              loadTexturePacks();
              await applyTexturePackSettings();
              applyTexturePacks();
              setState(() {});
            },
          ),
          Button(
            child: Text(lang("create", "Create"), style: TextStyle(fontSize: 7.sp)),
            onPressed: () async {
              await showDialog(context: context, builder: (ctx) => CreateTexturePackDialog());
              loadTexturePacks();
              await applyTexturePackSettings();
              applyTexturePacks();
              setState(() {});
            },
          ),
        ],
      ),
      content: texturePacks.isEmpty
          ? Center(
              child: Text(lang("no_texturepacks", "Couldn't find texture packs"), style: TextStyle(fontSize: 12.sp)),
            )
          : ListView(
              children: texturePacks.map<Widget>(tile).toList(),
            ),
    );
  }
}
