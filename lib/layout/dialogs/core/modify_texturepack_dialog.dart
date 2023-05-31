import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:path/path.dart' as path;

class ModifyTexturePackDialog extends StatefulWidget {
  final TexturePack tp;

  ModifyTexturePackDialog(this.tp);

  @override
  State<ModifyTexturePackDialog> createState() =>
      _ModifyTexturePackDialogState();
}

class _ModifyTexturePackDialogState extends State<ModifyTexturePackDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang(
          'modify_tp', 'Modify ${widget.tp.title}', {'name': widget.tp.title})),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (ctx, constraints) {
          final tpCells = widget.tp.retextured;

          return ListView.builder(
            itemCount: cells.length,
            itemBuilder: (context, i) {
              final cell = cells[i];
              final isMade = tpCells.contains(cell);

              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.25.h),
                child: SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: ListTile(
                    leading: Image.asset(
                      idToTexture(cell),
                      width: 5.w,
                      height: 5.w,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                    title: Text(idToString(cell)),
                    trailing: Button(
                      child: Text(isMade
                          ? lang("delete", "Delete")
                          : lang("create", "Create")),
                      onPressed: () {
                        if (isMade) {
                          final p = widget.tp.fix(cell);
                          final f = assetToFile('images/$p');
                          f.deleteSync();
                          final m = widget.tp.getMap();
                          m.remove(cell);
                          widget.tp.setMap(m);
                          setState(() {});
                        } else {
                          final relativeFilePath =
                              textureMapBackup['$cell.png'] ?? '$cell.png';

                          final f = File(path.join(widget.tp.dir.path,
                              path.joinAll(relativeFilePath.split('/'))));
                          f.createSync(recursive: true);
                          final bytes =
                              assetToFile('images/' + relativeFilePath)
                                  .readAsBytesSync();
                          f.writeAsBytesSync(bytes);
                          final m = widget.tp.getMap();
                          m[cell] = relativeFilePath;
                          widget.tp.setMap(m);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      actions: [
        Button(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
