import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class DeleteBlueprintDialog extends StatefulWidget {
  @override
  _StateDeleteBlueprintDialog createState() => _StateDeleteBlueprintDialog();
}

class _StateDeleteBlueprintDialog extends State<DeleteBlueprintDialog> {
  final Map<int, bool> _blueprints = {};

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang("select_blueprints", "Select Blueprints")),
      content: SizedBox(
        width: 40.w,
        height: 30.h,
        child: ListView.builder(
          itemCount: blueprints.length,
          itemBuilder: (ctx, i) {
            final bpSegs = blueprints[i].split(";");

            return SizedBox(
              width: 30.w,
              height: 5.h,
              child: Center(
                child: ListTile(
                  title: Text(bpSegs[1]),
                  leading: Checkbox(
                    checked: _blueprints[i] ?? false,
                    onChanged: (v) {
                      setState(() => _blueprints[i] = (v ?? false));
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        Button(
          child: Text(lang("delete", "Delete")),
          onPressed: () {
            final toDelete = <String>{};

            _blueprints.forEach((index, v) {
              if (v) toDelete.add(blueprints[index]);
            });

            toDelete.forEach(removeBlueprint);

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
