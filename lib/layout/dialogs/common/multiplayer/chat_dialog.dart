import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class ChatDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    msgController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void jumpToEnd() {
    if (game.msgs.isEmpty) return;
    Future.delayed(Duration(milliseconds: 250)).then((v) {
      try {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState() {
    jumpToEnd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    game.msgsListener = StreamController<String>();
    return ContentDialog(
      title: Text(lang("chat_msg", "Send Chat Message")),
      content: StreamBuilder(
          stream: game.msgsListener.stream,
          builder: (context, snapshot) {
            return SizedBox(
              height: 30.h,
              child: LayoutBuilder(builder: (ctx, constraints) {
                jumpToEnd();
                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Container(
                        width: constraints.maxWidth,
                        height: 21.h,
                        color: Colors.grey[150],
                        child: Center(
                          child: (game.msgs.isNotEmpty)
                              ? SizedBox(
                                  width: constraints.maxWidth,
                                  height: 20.h,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: game.msgs.length,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0.7.h, horizontal: 0.7.w),
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        width: constraints.maxWidth * 0.8,
                                        child: ListTile(
                                          title: Text(game.msgs[index]),
                                          tileColor: ConstantColorButtonState(
                                              Colors.grey[130]),
                                          onPressed: () {
                                            final i = game.msgs[index]
                                                .indexOf("] > ");
                                            msgController.text +=
                                                "@[${game.msgs[index].substring(1, i)}]";
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(lang("no_msgs", "No Messages")),
                                ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Spacer(),
                        SizedBox(
                          width: constraints.maxWidth * 0.7,
                          height: 7.h,
                          child: TextBox(
                            controller: msgController,
                            prefix: Text(lang('msg', 'Message')),
                            onSubmitted: (val) {
                              game.sendMessageToServer(val);
                              msgController.clear();
                            },
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                );
              }),
            );
          }),
      actions: [
        Button(
          child: Text(lang("send", "Send")),
          onPressed: () {
            game.sendMessageToServer(msgController.text);
            msgController.clear();
          },
        ),
        Button(
          child: Text(lang("clear", "Clear")),
          onPressed: () {
            game.msgs.clear();
            game.msgsListener.sink.add("");
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
