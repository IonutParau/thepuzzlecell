part of error_dialogs;

class BasicErrorDialog extends StatelessWidget {
  final String error;

  const BasicErrorDialog(this.error);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('error', 'Error')),
      content: Text(error),
      actions: [
        Button(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
