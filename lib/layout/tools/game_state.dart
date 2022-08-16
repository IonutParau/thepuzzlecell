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
