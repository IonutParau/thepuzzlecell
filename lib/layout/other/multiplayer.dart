import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:flutter/material.dart';
import '../../logic/logic.dart' show storage;

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
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
      ),
      width: 10.w,
      child: ListTile(
        minLeadingWidth: 10.w,
        tileColor: Colors.grey[700],
        title: Text(
          title,
          style: TextStyle(
            fontSize: 7.sp,
          ),
        ),
        leading: SizedBox(
          width: 10.w,
          height: 15.h,
          child: Row(
            children: [
              IconButton(
                tooltip: "Connect",
                icon: Icon(Icons.connect_without_contact, color: Colors.blue),
                onPressed: () => connectMultiplayer(context, ip),
              ),
              IconButton(
                tooltip: "Delete",
                icon: Icon(Icons.delete, color: Colors.red),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Servers'),
      ),
      body: ListView.builder(
        itemCount: storage.getStringList("servers")!.length,
        itemBuilder: (ctx, i) {
          return serverToTile(storage.getStringList("servers")![i]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
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
        title: Text("Add a server"),
      ),
      body: Center(
        child: Container(
          width: 80.w,
          height: 60.w,
          child: Center(
            child: Column(
              children: [
                Spacer(flex: 2),
                Row(
                  children: [
                    Text(
                      "Title: ",
                      style: TextStyle(
                        fontSize: 5.sp,
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                      child: TextField(
                        controller: titleController,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      "IP / Address: ",
                      style: TextStyle(
                        fontSize: 5.sp,
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                      child: TextField(
                        controller: ipController,
                      ),
                    ),
                  ],
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text("Add"),
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

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) {
        return GameUI(editorType: EditorType.making, ip: ip);
      },
    ),
  );
}
