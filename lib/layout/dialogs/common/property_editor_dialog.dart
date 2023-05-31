import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show VerticalDivider;
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

      final (currentId, currentRot) = parseJointCellStr(current);

      return DropDownButton(
        leading: Transform.rotate(
          angle: currentRot * halfPi,
          child: Image.asset(
            idToTexture(currentId),
            fit: BoxFit.fill,
            colorBlendMode: BlendMode.clear,
            filterQuality: FilterQuality.none,
            isAntiAlias: true,
            width: 3.h,
            height: 3.h,
          ),
        ),
        title: Text("$displayName: ${idToString(currentId)} (${rotToString(currentRot)})", style: textStyle),
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
                text: Text("${idToString(id)} (${rotToString(r)})", style: textStyle),
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
        leading: Image.asset(
          'assets/images/$tp',
          fit: BoxFit.fill,
          colorBlendMode: BlendMode.clear,
          filterQuality: FilterQuality.none,
          isAntiAlias: true,
          width: 3.h,
          height: 3.h,
        ),
        title: Text("$displayName: ${idToString(currentID)}", style: textStyle),
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

  Widget indexToBody(int i) {
    final textStyle = TextStyle(fontSize: 5.sp);
    final property = props[game.currentSelection]![i];

    if (property.type == CellPropertyType.cellID) {
      final currentID = controllers[i].text;
      final tp = textureMap['$currentID.png'] ?? '$currentID.png';
      return DropDownButton(
        leading: Image.asset(
          'assets/images/$tp',
          fit: BoxFit.fill,
          colorBlendMode: BlendMode.clear,
          filterQuality: FilterQuality.none,
          isAntiAlias: true,
          width: 3.h,
          height: 3.h,
        ),
        title: Text("Current: ${idToString(currentID)}", style: textStyle),
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
        title: Text("Current: ${rotToString(rot)}"),
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

      final (currentId, currentRot) = parseJointCellStr(current);

      return DropDownButton(
        leading: Transform.rotate(
          angle: currentRot * halfPi,
          child: Image.asset(
            idToTexture(currentId),
            fit: BoxFit.fill,
            colorBlendMode: BlendMode.clear,
            filterQuality: FilterQuality.none,
            isAntiAlias: true,
            width: 3.h,
            height: 3.h,
          ),
        ),
        title: Text("Current: ${idToString(currentId)} (${rotToString(currentRot)})", style: textStyle),
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
                text: Text("${idToString(id)} (${rotToString(r)})", style: textStyle),
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
        leading: Image.asset(
          'assets/images/$tp',
          fit: BoxFit.fill,
          colorBlendMode: BlendMode.clear,
          filterQuality: FilterQuality.none,
          isAntiAlias: true,
          width: 3.h,
          height: 3.h,
        ),
        title: Text("Current: ${idToString(currentID)}", style: textStyle),
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
      return Row(
        children: [
          Spacer(),
          Text("Enabled:", style: textStyle),
          SizedBox(width: 2.w),
          Checkbox(
            checked: controllers[i].text == "true",
            onChanged: (v) {
              controllers[i].text = (v == true) ? "true" : "false";
              setState(() {});
            },
          ),
          Spacer(),
        ],
      );
    }

    return TextBox(controller: controllers[i], style: textStyle);
  }

  int? currentProperty;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(
        minWidth: 60.w,
        maxWidth: 80.w,
        minHeight: 60.h,
        maxHeight: 80.h,
      ),
      title: Text(lang("prop-edit-btn.title", "Property Editor")),
      content: SizedBox(
        width: 70.w,
        height: 80.h,
        child: LayoutBuilder(builder: (context, constraints) {
          final p = props[game.currentSelection] ?? [];
          return Row(
            children: [
              Container(
                width: constraints.maxWidth * 0.3,
                height: constraints.maxHeight,
                child: ListView.builder(
                  itemCount: p.length,
                  itemBuilder: (ctx, i) {
                    final prop = p[i];

                    return SizedBox(
                      width: constraints.maxWidth * 0.23,
                      child: ListTile(
                        title: Text(prop.name),
                        onPressed: () {
                          currentProperty = i;
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
              VerticalDivider(),
              if (currentProperty != null)
                SizedBox(
                  width: constraints.maxWidth * 0.45,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      Text(
                        p[currentProperty!].name,
                        style: TextStyle(fontSize: 9.sp),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Text(
                          p[currentProperty!].description,
                          style: TextStyle(fontSize: 7.sp),
                        ),
                      ),
                      indexToBody(currentProperty!),
                    ],
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
                if (text == "inf" || text == "infinity") {
                  value = double.infinity;
                }
                if (text == "-inf" || text == "-infinity") {
                  value = double.negativeInfinity;
                }
                if (text == "pi") {
                  value = pi;
                }
                if (text == "e") {
                  value = e;
                }
                if (text == "phi") {
                  value = (1 + sqrt(5)) / 2;
                }
              } else if (type == CellPropertyType.boolean) {
                value = (text == "true");
              }

              value ??= property.def;

              game.currentData[key] = value;
            }

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
