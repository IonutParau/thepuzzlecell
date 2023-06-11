part of tools;

enum EditorType {
  loaded,
  making,
}

class CellHover {
  double x;
  double y;
  String id;
  int rot;
  Map<String, dynamic> data;

  CellHover(this.x, this.y, this.id, this.rot, this.data);
}

class CellCursor {
  double x;
  double y;
  String selection;
  int rotation;
  String texture;
  Map<String, dynamic> data;

  CellCursor(
      this.x, this.y, this.selection, this.rotation, this.texture, this.data);

  Vector2 get pos => Vector2(x, y);
}

enum UserRole {
  guest,
  member,
  admin,
  owner,
}

UserRole? getRoleStr(String role) {
  for (var r in UserRole.values) {
    if (r.toString() == ("UserRole.${role.toLowerCase()}")) {
      return r;
    }
  }

  return null;
}
