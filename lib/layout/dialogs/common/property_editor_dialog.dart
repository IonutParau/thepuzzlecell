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

    final displayName = lang("property.${game.currentSelection}.${property.key}.name", property.name);

    final textStyle = TextStyle(fontSize: 5.sp);

    if (property.type == CellPropertyType.cellID) {
      final currentID = controllers[i].text;
      final tp = textureMap['$currentID.png'] ?? '$currentID.png';
      return DropDownButton(
        placement: FlyoutPlacementMode.bottomCenter,
        leading: Image.asset(
          'assets/images/$tp',
          fit: BoxFit.fill,
          colorBlendMode: BlendMode.clear,
          filterQuality: FilterQuality.none,
          isAntiAlias: true,
          width: 3.h,
          height: 3.h,
        ),
        title: Text("$displayName: " + idToString(currentID), style: textStyle),
        items: [
          for (var id in (cells..removeWhere((v) => backgrounds.contains(v))))
            MenuFlyoutItem(
              leading: Image.asset(
                'assets/images/${textureMap["$id.png"] ?? "$id.png"}',
                fit: BoxFit.fill,
                colorBlendMode: BlendMode.clear,
                filterQuality: FilterQuality.none,
                isAntiAlias: true,
                width: 3.h,
                height: 3.h,
              ),
              text: Text(idToString(id), style: textStyle),
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
        placement: FlyoutPlacementMode.bottomCenter,
        title: Text("$displayName: " + rotToString(rot)),
        items: [
          for (var r = 0; r < 4; r++)
            MenuFlyoutItem(
              text: Text(rotToString(rot), style: textStyle),
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
        placement: FlyoutPlacementMode.bottomCenter,
        leading: Transform.rotate(
          angle: parseJointCellStr(current)[1] * halfPi,
          child: Image.asset(
            idToTexture(parseJointCellStr(current)[0]),
            fit: BoxFit.fill,
            colorBlendMode: BlendMode.clear,
            filterQuality: FilterQuality.none,
            isAntiAlias: true,
            width: 3.h,
            height: 3.h,
          ),
        ),
        title: Text("$displayName: " + idToString(parseJointCellStr(current)[0]) + " (" + rotToString(parseJointCellStr(current)[1]) + ")", style: textStyle),
        items: [
          for (var id in (cells..removeWhere((v) => backgrounds.contains(v))))
            for (var r = 0; r < 4; r++)
              MenuFlyoutItem(
                leading: Transform.rotate(
                  angle: r * halfPi,
                  child: Image.asset(
                    idToTexture(id),
                    fit: BoxFit.fill,
                    colorBlendMode: BlendMode.clear,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: true,
                    width: 3.h,
                    height: 3.h,
                  ),
                ),
                text: Text(idToString(id) + " (" + rotToString(r) + ")", style: textStyle),
                onPressed: () {
                  controllers[i].text = "$id!$r";
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
        placement: FlyoutPlacementMode.bottomCenter,
        leading: Image.asset(
          'assets/images/$tp',
          fit: BoxFit.fill,
          colorBlendMode: BlendMode.clear,
          filterQuality: FilterQuality.none,
          isAntiAlias: true,
          width: 3.h,
          height: 3.h,
        ),
        title: Text("$displayName: " + idToString(currentID), style: textStyle),
        items: [
          for (var id in backgrounds)
            MenuFlyoutItem(
              leading: Image.asset(
                'assets/images/${textureMap["$id.png"] ?? "$id.png"}',
                fit: BoxFit.fill,
                colorBlendMode: BlendMode.clear,
                filterQuality: FilterQuality.none,
                isAntiAlias: true,
                width: 3.h,
                height: 3.h,
              ),
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
          setState(() {});
        },
        content: Text(displayName, style: textStyle),
      );
    }
    return TextBox(
      prefix: Text(displayName, style: textStyle),
      controller: controllers[i],
      style: textStyle,
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.25.h),
                  child: SizedBox(
                    width: constraints.maxWidth * 0.7,
                    height: 7.h,
                    child: propToTile(i),
                  ),
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
                value = double.tryParse(text);
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
