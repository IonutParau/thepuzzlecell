part of logic;

class LastVars {
  Offset lastPos;
  int lastRot;

  LastVars(this.lastRot, num x, num y)
      : lastPos = Offset(
          x.toDouble(),
          y.toDouble(),
        );

  LastVars get copy => LastVars(lastRot, lastPos.dx, lastPos.dy);
}

// For cells destroyed by entering destruction cells
class BrokenCell {
  String id;
  int rot;
  int x;
  int y;
  LastVars lv;
  String type;
  Map<String, dynamic> data;
  bool invisible;

  BrokenCell(this.id, this.rot, this.x, this.y, this.lv, this.type, this.data, this.invisible);

  void render(Canvas canvas, double t) {
    final screenRot = lerpRotation(lv.lastRot, rot, t) * halfPi;
    final sx = lerp(lv.lastPos.dx, x, t);
    final sy = lerp(lv.lastPos.dy, y, t);
    var paint = Paint();

    if (invisible) paint.color = Colors.white.withOpacity(0.1);

    var screenSize = Vector2(cellSize, cellSize);

    var screenPos = Vector2(sx, sy) * cellSize + screenSize / 2;

    if (type == "silent_shrinking" || type == "shrinking") {
      var off = lerp(1, 0, t);
      screenSize *= off;
      if (off == 0) screenSize = Vector2.zero();
    }

    screenPos = rotateOff(screenPos.toOffset(), -screenRot).toVector2();

    screenPos -= screenSize / 2;

    canvas.save();

    canvas.rotate(screenRot);

    if (!cells.contains(id)) id = "base";
    final trickAs = data["trick_as"];
    if (trickAs != null && game.edType == EditorType.loaded) {
      id = trickAs;
    }

    Sprite(Flame.images.fromCache(textureMap['$id.png'] ?? '$id.png')).render(canvas, position: screenPos, size: screenSize, overridePaint: paint);

    if (trickAs != null && game.edType == EditorType.making) {
      final texture = textureMap[data["trick_as"] + '.png'] ?? "${data["trick_as"]}.png";
      final rotoff = (data["trick_rot"] ?? 0) * halfPi;
      var trick_off = rotateOff(Offset(screenPos.x + screenSize.y / 2, screenPos.y + screenSize.y / 2), -rotoff);

      canvas.rotate(rotoff);

      Sprite(Flame.images.fromCache(texture))
        ..render(
          canvas,
          position: Vector2(trick_off.dx, trick_off.dy),
          size: screenSize / 2,
          anchor: Anchor.center,
          overridePaint: paint,
        );

      canvas.rotate(-rotoff);
    }

    canvas.restore();
  }
}

class Cell {
  String id = "empty";
  int rot = 0;
  LastVars lastvars;
  bool updated = false;
  Map<String, dynamic> data = {};
  Set<String> tags = {};
  int lifespan = 0;
  bool invisible = false;
  int? cx;
  int? cy;

  Cell(int x, int y, [int rot = 0])
      : lastvars = LastVars(rot, x, y),
        cx = x,
        cy = y;

  Map<String, dynamic> get toMap {
    return {
      "id": id,
      "rot": rot,
      "data": data,
      "tags": tags,
      "lifespan": lifespan,
      "invisible": invisible,
    };
  }

  static Cell fromMap(Map<String, dynamic> map, int x, int y) {
    final cell = Cell(x, y, map["rot"].toInt());

    cell.id = map["id"] ?? "empty";
    cell.rot = (map["rot"] ?? 0).toInt();
    cell.data = map["data"] as Map<String, dynamic>;
    cell.tags = map["tags"] ?? {};
    cell.lifespan = map["lifespan"] ?? 0;
    cell.invisible = map["invisible"] ?? false;
    cell.lastvars = LastVars(cell.rot, x, y);
    cell.cx = x;
    cell.cy = y;

    return cell;
  }

  Cell get copy {
    final c = Cell(lastvars.lastPos.dx.toInt(), lastvars.lastPos.dy.toInt());

    c.id = id;
    c.rot = rot;
    c.updated = updated;
    c.lastvars.lastRot = lastvars.lastRot;
    c.lifespan = lifespan;
    c.invisible = invisible;

    data.forEach((key, value) => c.data[key] = value);
    for (var tag in tags) {
      c.tags.add(tag);
    }

    return c;
  }

  String toString() => "[Cell]\nID: $id\nRot: $rot\nData: $data\nTags: $tags\nInvisible: $invisible\nStored CX: $cx\nStored CY: $cy";

  void rotate(int amount) {
    lastvars.lastRot = rot;
    rot += amount;
    while (rot < 0) rot += 4;
    rot %= 4;
  }

  bool operator ==(Object other) {
    if (other is Cell) {
      return (mapEquals(toMap, other.toMap));
    }

    return false;
  }
}
