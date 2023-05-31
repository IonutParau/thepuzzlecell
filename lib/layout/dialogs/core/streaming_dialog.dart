import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

class StreamingDialog extends StatefulWidget {
  final Stream<dynamic> stream;
  final String title;

  const StreamingDialog({Key? key, required this.stream, required this.title}) : super(key: key);

  @override
  State<StreamingDialog> createState() => _StreamingDialogState();
}

class _StreamingDialogState extends State<StreamingDialog> {
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 30.w,
        height: 20.h,
        child: Center(
          child: StreamBuilder(
            stream: widget.stream,
            builder: (ctx, snap) {
              if (snap.hasError) {
                return SingleChildScrollView(child: Text(snap.error!.toString(), style: TextStyle(fontSize: 7.sp)));
              }

              if (snap.hasData) {
                _messages.add(snap.data.toString());
                return SingleChildScrollView(reverse: true, child: Text(_messages.join("\n\n"), style: TextStyle(fontSize: 7.sp)));
              }

              return CircularProgressIndicator.adaptive();
            },
          ),
        ),
      ),
      actions: [
        Button(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
