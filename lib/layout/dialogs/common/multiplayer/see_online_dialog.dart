import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class SeeOnlineDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SeeOnlineDialogState();
}

class _SeeOnlineDialogState extends State<SeeOnlineDialog> {
  @override
  Widget build(BuildContext context) {
    final online = game.cursors.keys.toList();

    return ContentDialog(
      title: Text(lang("see-online-btn.title", "See Online")),
      content: SizedBox(
        height: 30.h,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: ListView.builder(
                itemCount: online.length,
                padding:
                    EdgeInsets.symmetric(vertical: 0.7.h, horizontal: 0.7.w),
                itemBuilder: (context, index) {
                  final cursorTexture = game.cursors[online[index]]?.texture;
                  final role = game.roles[online[index]] ?? UserRole.guest;
                  String roleStr = "";
                  if (role == UserRole.guest) {
                    roleStr = lang("guest", "Guest");
                  }
                  if (role == UserRole.member) {
                    roleStr = lang("member", "Member");
                  }
                  if (role == UserRole.admin) {
                    roleStr = lang("admin", "Admin");
                  }
                  if (role == UserRole.owner) {
                    roleStr = lang("owner", "Owner");
                  }
                  return SizedBox(
                    width: constraints.maxWidth * 0.8,
                    child: ListTile(
                      leading: Image.asset(
                        "assets/images/" +
                            ((cursorTexture ?? "cursor") == "cursor"
                                ? "interface/cursor.png"
                                : (textureMap["$cursorTexture.png"] ??
                                    "$cursorTexture.png")),
                        width: 5.h,
                        height: 5.h,
                        filterQuality: FilterQuality.none,
                        fit: BoxFit.cover,
                      ),
                      title: Text(online[index]),
                      subtitle: Text(roleStr),
                      tileColor: ConstantColorButtonState(Colors.grey[130]),
                      onPressed: () {
                        final ourRole = game.roles[game.clientID];
                        if (ourRole == UserRole.admin ||
                            ourRole == UserRole.owner) {
                          showDialog(
                              context: context,
                              builder: (ctx) => EditUserDialog(online[index]));
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
