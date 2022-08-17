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

  CellCursor(this.x, this.y, this.selection, this.rotation, this.texture);

  Vector2 get pos => Vector2(x, y);
}
