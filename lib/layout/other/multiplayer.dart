import 'package:http/http.dart' as http;

import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:fluent_ui/fluent_ui.dart' show Colors, FluentIcons, TextBox;
import '../../logic/logic.dart' show Grid, grid, lang, storage;

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({Key? key}) : super(key: key);

  @override
  _MultiplayerPageState createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  Widget serverToTile(String server, int index) {
    final title = server.split(";").first;

    final ip = server.split(";")[1];

    final uri = Uri.parse(ip);

    print(
      "Host: ${uri.host != "" ? uri.host : uri.path} Port: ${uri.hasPort ? uri.port : 3000}",
    );

    var pingIp = ip.replaceAll('wss', 'https').replaceAll('ws', 'http');

    if (!pingIp.startsWith('http://') && !pingIp.startsWith('https://')) {
      pingIp = "https://" + pingIp;
    }

    if (!pingIp.contains(':')) {
      pingIp += ":3000";
    }

    if (!pingIp.endsWith('/')) {
      pingIp += '/';
    }

    print(pingIp);

    return Container(
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
      ),
      width: 10.w,
      child: ListTile(
        tileColor: Colors.grey[130],
        leading: FutureBuilder<http.Response>(
            future: http.post(Uri.parse(pingIp)),
            builder: (ctx, snap) {
              if (snap.hasError) {
                print(snap.error);
                return Icon(Icons.error, color: Colors.red["light"]);
              }
              if (snap.hasData) {
                final response = snap.data!;
                if (response.statusCode != 200) {
                  return Icon(Icons.error, color: Colors.red["light"]);
                }
                return Icon(
                  Icons.check_box_rounded,
                  color: Colors.green["light"],
                );
              }
              return Icon(FluentIcons.clock, color: Colors.blue);
            }),
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
                lang("edit", "Edit"),
                style: TextStyle(
                  fontSize: 7.sp,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EditServerPage(
                      title: title,
                      ip: ip,
                      index: index,
                      refresh: () => setState(() {}),
                    ),
                  ),
                );
              },
              color: Colors.orange,
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
          return serverToTile(storage.getStringList("servers")![i], i);
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
  void dispose() {
    titleController.dispose();
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(lang("add_server", "Add a server")),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
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
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  width: 40.w,
                  height: 20.h,
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
                        child: Padding(
                          padding: EdgeInsets.all(0.2.w),
                          child: Text(
                            lang("add", "Add"),
                            style: TextStyle(
                              fontSize: 7.sp,
                            ),
                          ),
                        ),
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

class EditServerPage extends StatefulWidget {
  EditServerPage(
      {Key? key,
      required this.title,
      required this.ip,
      required this.index,
      this.refresh})
      : super(key: key);

  final String title;
  final String ip;
  final int index;
  final Function? refresh;

  @override
  State<EditServerPage> createState() => _EditServerPageState();
}

class _EditServerPageState extends State<EditServerPage> {
  final titleController = TextEditingController();
  final ipController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    ipController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    titleController.text = widget.title;
    ipController.text = widget.ip;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Text(lang("edit_server", "Edit server")),
            Spacer(),
          ],
        ),
        backgroundColor: Colors.grey[100],
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
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  width: 40.w,
                  height: 20.h,
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
                        child: Padding(
                          padding: EdgeInsets.all(0.2.w),
                          child: Text(
                            lang("edit", "Edit"),
                            style: TextStyle(
                              fontSize: 7.sp,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final strList = storage.getStringList("servers")!;

                          strList[widget.index] =
                              "${titleController.text};${ipController.text}";

                          storage.setStringList('servers', strList);

                          widget.refresh?.call();

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
