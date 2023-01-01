import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/scripts/scripts.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import '../../layout.dart';

class SearchFilter {
  String name;
  String content;

  SearchFilter(this.name, this.content);
}

class SearchQueryResult {
  String cell;
  String categoryPath;

  SearchQueryResult(this.cell, this.categoryPath);

  bool get isVanilla => !isModded;
  bool get isModded => modded.contains(cell);

  bool fromModID(String modID) {
    return scriptingManager.modOrigin(cell).toLowerCase() == modID.toLowerCase();
  }

  bool fromModName(String name) {
    return scriptingManager.modName(scriptingManager.modOrigin(cell)).toLowerCase() == name.toLowerCase();
  }
}

class ViewModCellsDialog extends StatefulWidget {
  final ModInfo info;

  ViewModCellsDialog(this.info);

  @override
  State<StatefulWidget> createState() => _ViewModCellsDialog();
}

class _ViewModCellsDialog extends State<ViewModCellsDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.info.title + ' (${widget.info.cells.length})'),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              itemCount: widget.info.cells.length,
              itemBuilder: (ctx, i) {
                final cell = widget.info.cells.elementAt(i);
                return SizedBox(
                  width: constraints.maxWidth * 0.8,
                  child: ListTile(
                    leading: Image.asset(
                      idToTexture(cell),
                      width: 5.h,
                      height: 5.h,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.cover,
                    ),
                    title: Text(idToString(cell)),
                    subtitle: Text(idToDesc(cell)),
                    tileColor: ConstantColorButtonState(Colors.grey[130]),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
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
