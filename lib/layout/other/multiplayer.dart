import 'package:http/http.dart' as http;

import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart' show Icons, MaterialButton, MaterialPageRoute;
import 'package:fluent_ui/fluent_ui.dart';
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

    return Container(
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
      ),
      width: 10.w,
      height: 10.h,
      child: ListTile(
        tileColor: ConstantColorButtonState(Colors.grey[130]),
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
                showDialog(
                  context: context,
                  builder: (ctx) => EditServerDialog(
                    index,
                    title,
                    ip,
                    refresh: () => setState(() {}),
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
    return ScaffoldPage(
      header: Container(
        child: Row(
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
        color: Colors.grey[100],
      ),
      content: ListView.builder(
        itemCount: storage.getStringList("servers")!.length,
        itemBuilder: (ctx, i) {
          return serverToTile(storage.getStringList("servers")![i], i);
        },
      ),
      bottomBar: Row(
        children: [
          Spacer(),
          Button(
            child: Text(
              lang("add", "Add"),
              style: TextStyle(fontSize: 10.sp),
            ),
            onPressed: () {
              // Bootiful cod
              showDialog(
                context: context,
                builder: (ctx) => AddServerDialog(),
              ).then(
                (v) => setState(() {}),
              );
            },
          ),
        ],
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
