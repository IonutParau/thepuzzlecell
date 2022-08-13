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

  CellHover(this.x, this.y, this.id, this.rot);
}
