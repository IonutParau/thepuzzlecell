part of error_dialogs;

class LoadSaveErrorDialog extends StatelessWidget {
  final String error;

  LoadSaveErrorDialog(this.error);

  @override
  Widget build(BuildContext context) {
    return BasicErrorDialog(
      lang(
        "saveErrorDesc",
        "Could not load save code: $error",
        {"error": error},
      ),
    );
  }
}
