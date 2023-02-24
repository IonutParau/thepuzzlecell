import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:glue_lang/vm.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/scripts/glue_scripting.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class TerminalDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TerminalDialogState();
}

class _TerminalDialogState extends State<TerminalDialog> {
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final terminalSession = GlueScript.noFile("terminal");
  final terminalStack = GlueStack();

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void jumpToEnd() {
    if (terminalSession.output.isEmpty) return;
    Future.delayed(Duration(milliseconds: 250)).then((v) {
      try {
        scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
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
    return ContentDialog(
      title: Text(lang("terminal-btn.title", "Terminal")),
      content: StreamBuilder<bool>(
          stream: terminalSession.printController.stream,
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
                          child: (terminalSession.output.isNotEmpty)
                              ? SizedBox(
                                  width: constraints.maxWidth,
                                  height: 20.h,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: terminalSession.output.length,
                                    padding: EdgeInsets.symmetric(vertical: 0.7.h, horizontal: 0.7.w),
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        width: constraints.maxWidth * 0.8,
                                        child: ListTile(
                                          title: SelectableText(terminalSession.output[index]),
                                          tileColor: ConstantColorButtonState(Colors.grey[130]),
                                          onPressed: () {
                                            inputController.text += terminalSession.output[index];
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(""),
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
                            controller: inputController,
                            prefix: Text(lang('run_command', 'Run Command')),
                            onSubmitted: (val) {
                              terminalSession.output.add("Command > $val");
                              try {
                                terminalSession.runCode(val, terminalStack);
                              } catch (e) {
                                terminalSession.output.add(e.toString());
                              }
                              terminalSession.printController.sink.add(true);
                              inputController.clear();
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
          child: Text(lang("clear", "Clear")),
          onPressed: () {
            terminalSession.output.clear();
            setState(() {});
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
