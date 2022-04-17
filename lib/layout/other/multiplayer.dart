import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, TextBox;
import '../../logic/logic.dart' show Grid, grid, lang, storage;

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({Key? key}) : super(key: key);

  @override
  _MultiplayerPageState createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  Widget serverToTile(String server) {
    final title = server.split(";").first;

    final ip = server.split(";")[1];

    return Container(
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
      ),
      width: 10.w,
      child: ListTile(
        minLeadingWidth: 10.w,
        tileColor: Colors.grey[130],
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 7.sp,
              ),
            ),
            Spacer(),
            MaterialButton(
              child: Text(
                lang("connect", "Connect"),
                style: TextStyle(
                  fontSize: 7.sp,
                ),
              ),
              onPressed: () => connectMultiplayer(context, ip),
              color: Colors.blue,
            ),
            MaterialButton(
              child: Text(
                lang("remove", "Remove"),
                style: TextStyle(
                  fontSize: 7.sp,
                ),
              ),
              onPressed: () => storage
                  .setStringList(
                    "servers",
                    storage.getStringList("servers")!..remove(server),
                  )
                  .then(
                    (v) => setState(
                      () {},
                    ),
                  ),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(
              lang('multiplayer_servers', 'Multiplayer Servers'),
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: storage.getStringList("servers")!.length,
        itemBuilder: (ctx, i) {
          return serverToTile(storage.getStringList("servers")![i]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 12.sp,
        ),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => AddServer(),
                ),
              )
              .then(
                (v) => setState(
                  () {},
                ),
              );
        },
      ),
    );
  }
}

class AddServer extends StatefulWidget {
  const AddServer({Key? key}) : super(key: key);

  @override
  _AddServerState createState() => _AddServerState();
}

class _AddServerState extends State<AddServer> {
  final titleController = TextEditingController();
  final ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang("add_server", "Add a server")),
      ),
      body: Center(
        child: Container(
          width: 80.w,
          height: 80.h,
          child: Center(
            child: Column(
              children: [
                Spacer(flex: 2),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  width: 60.w,
                  height: 30.h,
                  padding: EdgeInsets.all(1.w),
                  child: Column(
                    children: [
                      Spacer(flex: 5),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            "${lang('title_box', 'Title')}: ",
                            style: TextStyle(
                              fontSize: 5.sp,
                            ),
                          ),
                          SizedBox(
                            width: 30.w,
                            child: TextBox(
                              controller: titleController,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            "${lang('ip_address', 'IP / Address')}: ",
                            style: TextStyle(
                              fontSize: 5.sp,
                            ),
                          ),
                          SizedBox(
                            width: 30.w,
                            child: TextBox(
                              controller: ipController,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Spacer(flex: 5),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.h),
                  child: Row(
                    children: [
                      Spacer(),
                      MaterialButton(
                        color: Colors.blue,
                        child: Text(lang("add", "Add")),
                        onPressed: () async {
                          await storage.setStringList(
                            "servers",
                            storage.getStringList("servers")!
                              ..add(
                                "${titleController.text};${ipController.text}",
                              ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void connectMultiplayer(BuildContext context, String ip) {
  if (!ip.contains(r"://")) ip = "ws://$ip";

  grid = Grid(100, 100);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) {
        return GameUI(editorType: EditorType.making, ip: ip);
      },
    ),
  );
}
