import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class DisconnectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(lang('disconnected', 'Disconnected')),
      content: Text(lang('disconnected_desc',
          'You got kicked. This means either the server closed or your internet cut off')),
      actions: [
        Button(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
