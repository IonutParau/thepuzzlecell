part of logic;

class LastVars {
  Offset lastPos;
  int lastRot;
  String id;

  LastVars(this.lastRot, num x, num y, this.id)
      : lastPos = Offset(
          x.toDouble(),
          y.toDouble(),
        );

  LastVars get copy => LastVars(lastRot, lastPos.dx, lastPos.dy, id);

  @override
  String toString() {
    return "${lastPos.dx} ${lastPos.dy} $lastRot";
  }
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

  BrokenCell(this.id, this.rot, this.x, this.y, this.lv, this.type, this.data,
      this.invisible);

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

    Sprite(Flame.images.fromCache(textureMap['$id.png'] ?? '$id.png')).render(
        canvas,
        position: screenPos,
        size: screenSize,
        overridePaint: paint);

    if (trickAs != null && game.edType == EditorType.making) {
      final texture =
          textureMap[data["trick_as"] + '.png'] ?? "${data["trick_as"]}.png";
      final rotoff = (data["trick_rot"] ?? 0) * halfPi;
      var trick_off = rotateOff(
          Offset(
              screenPos.x + screenSize.y / 2, screenPos.y + screenSize.y / 2),
          -rotoff);

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

class FakeCell {
  int lifespan;
  Cell cell;
  num x;
  num y;
  num sx;
  num sy;
  num rot;

  FakeCell(
      this.cell, this.x, this.y, this.rot, this.sx, this.sy, this.lifespan);

  void render(Canvas canvas) {
    game.renderCell(cell, x, y, null, sx, sy, rot);
  }

  void tick() {
    lifespan--;
  }

  bool get dead => lifespan <= 0;
}

// ignore: must_be_immutable
class Cell extends Equatable {
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
      : lastvars = LastVars(rot, x, y, "empty"),
        cx = x,
        cy = y;

  Map<String, dynamic> get toMap {
    return {
      "id": id,
      "rot": rot,
      "data": {...data},
      "tags": {...tags},
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
    cell.lastvars = LastVars(cell.rot, x, y, cell.id);
    cell.cx = x;
    cell.cy = y;

    return cell;
  }

  Cell get copy {
    final c = Cell(lastvars.lastPos.dx.toInt(), lastvars.lastPos.dy.toInt());

    c.id = id;
    c.rot = rot;
    c.updated = updated;
    c.lastvars = lastvars.copy;
    c.lifespan = lifespan;
    c.invisible = invisible;

    data.forEach((key, value) => c.data[key] = value);
    for (var tag in tags) {
      c.tags.add(tag);
    }

    return c;
  }

  String toString() =>
      "[Cell]\nID: $id\nRot: $rot\nData: $data\nTags: $tags\nInvisible: $invisible\nStored CX: $cx\nStored CY: $cy";

  void rotate(int amount) {
    lastvars.lastRot = rot;
    rot += amount;
    while (rot < 0) rot += 4;
    rot %= 4;
  }

  @override
  List<Object?> get props => [id, rot, data, lifespan, invisible];
}

String countToString(num? count) {
  if (count == double.infinity) return "inf";
  if (count == double.negativeInfinity) return "-inf";
  if (count == double.nan) return "nan";

  return count.toString();
}

String textToRenderOnCell(Cell cell) {
  var text = "";

  if (cell.id == "counter" ||
      cell.id == "math_number" ||
      cell.id == "math_safe_number") {
    text = countToString(cell.data['count']);
  }

  if (cell.id == "bulldozer" && (cell.data['bias'] != 1)) {
    text = countToString(cell.data['bias']);
  }

  if ((cell.id == "debt" || cell.id == "mech_debt") &&
      (cell.data['debt'] != 1)) {
    text = (cell.data['debt'] ?? 1).toString();
  }

  if (cell.id == "mech_trash") {
    text = "${cell.data['countdown'] ?? 0}";
    if (text == "0") text = "";
  }

  if (cell.id == "math_memwriter" || cell.id == "math_memreader") {
    text = "${cell.data['channel'] ?? 0}\n\n${cell.data['index'] ?? 0}";
  }

  if (cell.id == "math_to_mech") {
    text = "${countToString(cell.data['offset'])}";
    if ((cell.data['offset'] ?? 0) == 0) {
      text = "";
    }
  }
  if (cell.id == "mech_to_math") {
    text = "x${countToString(cell.data['scale'] ?? 1)}";
    if ((cell.data['scale'] ?? 1) == 1) {
      text = "";
    }
  }
  if (cell.id == "math_wireless_tunnel") {
    text = "${cell.data['id'] ?? 0}\n\n${cell.data['target']}";
  }

  if (cell.id == "spikefactory") {
    text =
        "${countToString(cell.data['interval'] ?? 1)}\n${cell.data['radius'] ?? 1}";
    if ((cell.data['interval'] ?? 1) == 1 || (cell.data['radius'] ?? 1) == 1) {
      text = "";
    }
  }

  if (cell.id == "trash_can") {
    text = "${cell.data['remaining'] ?? 10}";
  }

  if (["fire", "plasma", "lava", "cancer", "crystal"].contains(cell.id) &&
      (cell.data['id'] ?? 0) != 0) {
    text = "${cell.data['id'] ?? 0}";
  }

  if ([
        "transformer",
        "transformer_cw",
        "transformer_ccw",
        "triple_transformer",
        "mech_comparator",
        "mech_sensor",
        "transform_puzzle"
      ].contains(cell.id) &&
      (cell.data['offset'] ?? 1) != 1) {
    text = "${cell.data['offset'] ?? 1}";
  }

  if (cell.id == "text") {
    text = "${cell.data['text'] ?? ""}";
  }

  if (cell.id == "custom_weight") {
    text = "${cell.data['mass'] ?? 1}";
  }

  if (cell.id == "portal_c") {
    text = "${cell.data["id"] ?? ""} -> ${cell.data["target_id"] ?? ""}";
  }

  if (cell.id == "electric_container") {
    text = "${cell.data["electric_power"] ?? 0}";
  }

  if (cell.id == "electric_battery") {
    final bool useCapacity = (cell.data['use_capacity'] ?? false);
    final power = electricManager.directlyReadPower(cell);
    final double capacity = ((cell.data['capacity'] ?? 0) as num).toDouble();
    text = useCapacity ? "${(power / capacity * 100).toInt()}%" : "$power";
  }

  return text;
}
