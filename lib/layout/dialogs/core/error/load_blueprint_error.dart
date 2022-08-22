part of error_dialogs;

class LoadBlueprintErrorDialog extends StatelessWidget {
  final String error;

  LoadBlueprintErrorDialog(this.error);

  @override
  Widget build(BuildContext context) {
    return BasicErrorDialog(
      lang(
        "load_blueprint_error",
        "Could not load blueprint: $error",
        {"error": error},
      ),
    );
  }
}
