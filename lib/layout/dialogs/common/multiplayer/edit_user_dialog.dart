import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class EditUserDialog extends StatefulWidget {
  final String user;
  EditUserDialog(this.user, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late UserRole role;

  @override
  void initState() {
    role = game.roles[widget.user] ?? UserRole.guest;

    super.initState();
  }

  String roleName(UserRole role) {
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
    return roleStr;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.user),
      content: SizedBox(
        height: 30.h,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final ourRole = game.roles[game.clientID] ?? UserRole.guest;

            return SizedBox(
              width: constraints.maxWidth,
              child: ListView(
                children: [
                  for (var userRole in UserRole.values)
                    RadioButton(
                      content: Text(roleName(userRole)),
                      checked: role == userRole,
                      onChanged: (((role == UserRole.owner ||
                                      role == UserRole.admin ||
                                      userRole == UserRole.owner) &&
                                  ourRole == UserRole.admin) ||
                              widget.user == game.clientID)
                          ? null
                          : (value) {
                              setState(
                                () {
                                  role = userRole;
                                  game.sendToServer('set-role', {
                                    "id": widget.user,
                                    "role": role
                                        .toString()
                                        .replaceAll('UserRole.', '')
                                  });
                                },
                              );
                            },
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        Button(
          child: Text('Kick'),
          onPressed: () {
            game.sendToServer('kick', {"id": widget.user});
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
