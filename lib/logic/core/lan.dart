import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as sio;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

HttpServer? server;
List<WebSocketChannel> webSockets = [];
Map<WebSocketChannel, String> clientIDs = {};
List<String> clientIDList = [];

void removeWS(WebSocketChannel ws) {
  ws.sink.close();
  webSockets.remove(ws);
  final id = clientIDs[ws];
  if (id != null) {
    for (var ws in webSockets) {
      ws.sink.add(jsonEncode({"pt": "remove-cursor", "id": id}));
      ws.sink.add(jsonEncode({"pt": "del-role", "id": id}));
    }
    clientIDList.remove(id);
  }
  clientIDs.remove(ws);
}

Future<HttpServer> _lanServer() async {
  final wsHandler = webSocketHandler((WebSocketChannel connection) {
    webSockets.add(connection);

    connection.stream.listen(
      (data) {
        if (data is String) {
          execPacket(data, connection);
        }
      },
      onDone: () => removeWS(connection),
      onError: (e) => removeWS(connection),
    );

    connection.sink.add(jsonEncode({
      "pt": "grid",
      "code": SavingFormat.encodeGrid(game.running ? game.initial : grid),
    }));

    if (game.edType == EditorType.loaded) {
      connection.sink.add(jsonEncode({"pt": "edtype", "et": "puzzle"}));

      game.hovers.forEach((uuid, hover) {
        connection.sink.add(
          jsonEncode({
            "pt": "new-hover",
            "uuid": uuid,
            "x": hover.x,
            "y": hover.y,
            "id": hover.id,
            "rot": hover.rot,
            "data": hover.data,
          }),
        );
      });
    }

    game.cursors.forEach((id, cursor) {
      connection.sink.add(jsonEncode({
        "pt": "set-cursor",
        "x": cursor.x,
        "y": cursor.y,
        "selection": cursor.selection,
        "texture": cursor.rotation,
        "rot": cursor.rotation,
        "data": cursor.data,
      }));
    });
  });

  return sio.serve(wsHandler, "0.0.0.0", 3000);
}

Future<HttpServer> setupLanServer() async {
  if (server != null) await closeLanServer();
  server = await _lanServer();
  return server!;
}

Future<void> closeLanServer() async {
  await server?.close();
  for (var ws in webSockets) {
    await ws.sink.close();
  }
  webSockets.clear();
  clientIDs.clear();
  clientIDList.clear();
  server = null;
}

void kickWS(WebSocketChannel ws) {
  removeWS(ws);
}

bool isValidID(String id) {
  return true;
}

UserRole getRole(WebSocketChannel ws) =>
    game.roles[clientIDs[ws] ?? "Unknown"] ?? UserRole.member;

void sendRoles() {
  for (var ws in webSockets) {
    game.roles.forEach((id, role) {
      ws.sink.add(jsonEncode({
        "pt": "set-role",
        "id": id,
        "role": role.toString().replaceAll('UserRole.', ''),
      }));
    });
  }
}

void execPacket(String data, WebSocketChannel sender) {
  // if (!(data.startsWith('{') && data.endsWith('}'))) return legacyExecPacket(data, sender); // Legacy packet usage not yet supported

  if (!webSockets.contains(sender)) return;

  try {
    final packet = jsonDecode(data) as Map<String, dynamic>;

    final packetType = packet["pt"].toString();

    // If the user tries to do anything but login without logging in, kick them.
    if (packetType != "token" && clientIDs[sender] == null) {
      kickWS(sender);
      return;
    }

    final role = getRole(sender);

    if (packetType == "token") {
      final id = packet["clientID"] as String;

      if (id.length > 500 || !isValidID(id)) {
        kickWS(sender);
        return;
      }

      if (clientIDList.contains(id)) {
        kickWS(sender);
        return;
      }

      clientIDs[sender] = id;
      game.roles[id] = game.clientID == id ? UserRole.owner : UserRole.member;
      sendRoles();
      clientIDList.add(id);
    } else if (packetType == "chat") {
      var shouldKick = false;

      try {
        final signed = packet["author"].toString();
        if (signed.toLowerCase() == "server") {
          throw "User attempted to forge a message as server";
        }

        final id = clientIDs[sender];
        if (id == null) throw "Pending User tried to send message";

        if (!clientIDList.contains(id)) {
          shouldKick = true;
          throw "User with foreign ID tried to send message";
        }

        if (id != signed) {
          shouldKick = true;
          throw "User($id) attempted to forge signature of User($signed)";
        }
      } catch (e) {
        sender.sink.add(jsonEncode({
          "pt": "chat",
          "author": "Server",
          "content": e.toString(),
        }));
        print("A user sent an invalid message and an error was raised: $e");
      }

      if (shouldKick) {
        kickWS(sender);
      } else {
        for (var ws in webSockets) {
          ws.sink.add(data);
        }
      }
    } else if (packetType == "set-role") {
      final id = packet["id"];
      final userRole = getRole(sender);
      final role = getRoleStr(packet["role"]);

      final otherRole = game.roles[id] ?? UserRole.member;

      if (userRole == UserRole.member || userRole == UserRole.guest) return;

      // Only owner can change admin and owner role
      if (otherRole == UserRole.owner || otherRole == UserRole.admin) {
        if (userRole != UserRole.owner) {
          return;
        }
      }

      // Only owner can promote to owner
      if (role == UserRole.owner && userRole != UserRole.owner) {
        return;
      }

      if (role == null) {
        kickWS(sender);
        return;
      }

      game.roles[id] = role;

      for (var ws in webSockets) {
        ws.sink.add(data);
      }
    } else if (packetType == "kick") {
      final id = packet["id"];
      if (role != UserRole.admin && role != UserRole.owner) {
        return;
      }

      if (!clientIDList.contains(id)) return;

      WebSocketChannel? user;

      clientIDs.forEach((iuser, uid) {
        if (id == uid) {
          user = iuser;
        }
      });

      if (user != null) {
        kickWS(user!);
      }
    } else {
      for (var ws in webSockets) {
        ws.sink.add(data);
      }
    }
  } catch (e) {
    print("[ Error happened while executing a packet ]");
    print("Error: $e");
    print("Packet: $data");
  }
}
