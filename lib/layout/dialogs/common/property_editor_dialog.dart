import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class PropertyEditorDialog extends StatefulWidget {
  @override
  _PropertyEditorDialogState createState() => _PropertyEditorDialogState();
}

class _PropertyEditorDialogState extends State<PropertyEditorDialog> {
  final controllers = <TextEditingController>[];

  @override
  void dispose() {
    controllers.forEach((v) => v.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final p = props[game.currentSelection]!;

    for (var i = 0; i < p.length; i++) {
      final v = game.currentData[p[i].key] ?? p[i].def;
      controllers.add(TextEditingController(text: v == null ? null : v.toString()));
    }
  }

  Widget propToTile(int i) {
    final property = props[game.currentSelection]![i];
    if (property.type == CellPropertyType.cellID) {
      final currentID = controllers[i].text;
      final tp = textureMap['$currentID.png'] ?? '$currentID.png';
      return DropDownButton(
        placement: FlyoutPlacement.start,
        leading: Image.asset('assets/images/$tp'),
        title: Text(idToString(currentID)),
        items: [
          for (var id in (cells..removeWhere((v) => backgrounds.contains(v))))
            MenuFlyoutItem(
              leading: Image.asset('assets/images/${textureMap["$id.png"] ?? "$id.png"}'),
              text: Text(idToString(id)),
              onPressed: () {
                controllers[i].text = id;
                setState(() {});
              },
            ),
        ],
      );
    }
    if (property.type == CellPropertyType.cellRot) {
      final currentID = controllers[i].text;
      final rot = int.tryParse(currentID) ?? 0;

      return DropDownButton(
        placement: FlyoutPlacement.start,
        title: Text(rotToString(rot)),
        items: [
          for (var r = 0; r < 4; r++)
            MenuFlyoutItem(
              text: Text(rotToString(rot)),
              onPressed: () {
                controllers[i].text = r.toString();
                setState(() {});
              },
            ),
        ],
      );
    }
    if (property.type == CellPropertyType.cell) {
      final current = controllers[i].text;

      return DropDownButton(
        placement: FlyoutPlacement.start,
        leading: Transform.rotate(
          angle: parseJointCellStr(current)[1] * halfPi,
          child: Image.asset(parseJointCellStr(current)[0]),
        ),
        title: Text(idToString(parseJointCellStr(current)[0])),
        items: [
          for (var id in (cells..removeWhere((v) => backgrounds.contains(v))))
            for (var r = 0; r < 4; r++)
              MenuFlyoutItem(
                leading: Transform.rotate(
                  angle: r * halfPi,
                  child: Image.asset(idToTexture(id)),
                ),
                text: Text(idToString(id) + " "),
                onPressed: () {
                  controllers[i].text = "$id:$r";
                  setState(() {});
                },
              ),
        ],
      );
    }
    if (property.type == CellPropertyType.background) {
      final currentID = controllers[i].text;
      final tp = textureMap['$currentID.png'] ?? '$currentID.png';
      return DropDownButton(
        placement: FlyoutPlacement.start,
        leading: Image.asset('assets/images/$tp'),
        title: Text(idToString(currentID)),
        items: [
          for (var id in backgrounds)
            MenuFlyoutItem(
              leading: Image.asset('assets/images/${textureMap["$id.png"] ?? "$id.png"}'),
              text: Text(idToString(id)),
              onPressed: () {
                controllers[i].text = id;
                setState(() {});
              },
            ),
        ],
      );
    }
    if (property.type == CellPropertyType.boolean) {
      return Checkbox(
        checked: controllers[i].text == "true",
        onChanged: (v) {
          controllers[i].text = (v == true) ? "true" : "false";
        },
        content: Text(property.name),
      );
    }
    return TextBox(
      header: property.name,
      controller: controllers[i],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("prop-edit-btn.title", "Property Editor")),
      content: SizedBox(
        height: 20.h,
        child: LayoutBuilder(builder: (context, constraints) {
          return ListView(
            children: [
              for (var i = 0; i < props[game.currentSelection]!.length; i++)
                SizedBox(
                  width: constraints.maxWidth * 0.7,
                  height: 7.h,
                  child: propToTile(i),
                ),
            ],
          );
        }),
      ),
      actions: [
        Button(
          child: Text(lang("cancel", "Cancel")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Button(
          child: Text("Ok"),
          onPressed: () {
            final p = props[game.currentSelection]!;

            for (var i = 0; i < p.length; i++) {
              final property = p[i];

              final text = controllers[i].text;
              final key = property.key;
              final type = property.type;

              dynamic value = text;

              if (type == CellPropertyType.integer || type == CellPropertyType.cellRot) {
                value = int.tryParse(text);
              } else if (type == CellPropertyType.number) {
                value = num.tryParse(text);
                if (text == "inf" || text == "infinity") value = double.infinity;
                if (text == "-inf" || text == "-infinity") value = double.negativeInfinity;
                if (text == "pi") value = pi;
                if (text == "e") value = e;
                if (text == "phi") value = (1 + sqrt(5)) / 2;
              } else if (type == CellPropertyType.boolean) {
                value = (text == "true");
              }

              if (value == null) value = property.def;

              game.currentData[key] = value;
            }

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
