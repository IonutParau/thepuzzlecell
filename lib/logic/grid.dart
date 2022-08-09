part of logic;

var inBruteForce = false;

final useSnowflake = false;

final subticks = [
  biome,
  stoppers,
  heat,
  mechs,
  automata,
  spreaders,
  quantums,
  hungryTrashes,
  mirrors,
  gens,
  supgens,
  memgens,
  reps,
  tunnels,
  transformers,
  rots,
  gears,
  grabbers,
  speeds,
  drillers,
  pullers,
  movers,
  liners,
  bringers,
  axis,
  birds,
  fans,
  ants,
  plants,
  karls,
  dartys,
  floppys,
  puzzles,
  pmerges,
  gates,
  autoflag,
  timetravel,
];

class LastVars {
  Offset lastPos;
  int lastRot;

  LastVars(this.lastRot, int x, int y)
      : lastPos = Offset(
          x.toDouble(),
          y.toDouble(),
        );

  LastVars get copy => LastVars(lastRot, lastPos.dx.toInt(), lastPos.dy.toInt());
}

// For cells destroyed by entering destruction cells
class BrokenCell {
  String id;
  int rot;
  int x;
  int y;
  LastVars lv;
  String type;

  BrokenCell(this.id, this.rot, this.x, this.y, this.lv, this.type);

  void render(Canvas canvas, double t) {
    final screenRot = lerpRotation(lv.lastRot, rot, t) * halfPi;
    final sx = lerp(lv.lastPos.dx, x, t);
    final sy = lerp(lv.lastPos.dy, y, t);

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

    Sprite(Flame.images.fromCache(textureMap['$id.png'] ?? '$id.png')).render(canvas, position: screenPos, size: screenSize);

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
    };
  }

  static Cell fromMap(Map<String, dynamic> map, int x, int y) {
    final cell = Cell(x, y, map["rot"]);

    cell.id = map["id"];
    cell.rot = map["rot"];
    cell.data = map["data"] as Map<String, dynamic>;
    cell.tags = map["tags"];
    cell.lifespan = map["lifespan"];
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

    data.forEach((key, value) => c.data[key] = value);
    for (var tag in tags) {
      c.tags.add(tag);
    }

    return c;
  }

  String toString() => "[Cell]\nID: $id\nRot: $rot\nData: $data\nTags: $tags";

  void rotate(int amount) {
    lastvars.lastRot = rot;
    rot += amount;
    while (rot < 0) rot += 4;
    rot %= 4;
  }
}

var grid = Grid(100, 100);

List<String> backgrounds = [
  "place",
  "red_place",
  "blue_place",
  "yellow_place",
  "rotatable",
  ...biomes,
];

class Grid {
  late List<List<Cell>> grid;
  late List<List<String>> place;
  late List<List<Set<String>>> chunks;

  String title = "";
  String desc = "";

  List<BrokenCell> brokenCells = [];

  void addBroken(Cell cell, int dx, int dy, [String type = "normal", int? rlvx, int? rlvy]) {
    final b = BrokenCell(cell.id, cell.rot, dx, dy, cell.lastvars, type);

    b.lv.lastPos = Offset(rlvx?.toDouble() ?? b.lv.lastPos.dx, rlvy?.toDouble() ?? b.lv.lastPos.dy);

    brokenCells.add(b);
  }

  final chunkSize = 25;

  int width;
  int height;

  List<int> chunkXList = [];
  List<int> chunkYList = [];

  void create() {
    grid = [];
    place = [];
    for (var x = 0; x < width; x++) {
      grid.add([]);
      place.add([]);
      for (var y = 0; y < height; y++) {
        grid.last.add(Cell(x, y));
        place.last.add("empty");
      }
    }

    final cx = ceil(width / chunkSize);
    final cy = ceil(height / chunkSize);

    chunks = [];

    for (var x = 0; x < cx; x++) {
      chunks.add([]);
      for (var y = 0; y < cy; y++) {
        chunks.last.add({});
      }
    }

    for (var i = 0; i < cx; i++) {
      for (var j = 0; j < chunkSize; j++) {
        chunkXList.add(i);
      }
    }
    for (var i = 0; i < cy; i++) {
      for (var j = 0; j < chunkSize; j++) {
        chunkYList.add(i);
      }
    }
  }

  int x(int rawX) => wrap ? ((rawX + width) % width) : rawX;
  int y(int rawY) => wrap ? ((rawY + height) % height) : rawY;

  bool inside(int x, int y) {
    if (wrap) return true;

    return (x >= 0 && x < width && y >= 0 && y < height);
  }

  Cell at(int x, int y) {
    return grid[this.x(x)][this.y(y)];
  }

  Cell? get(int x, int y) {
    if (inside(x, y)) {
      return at(x, y);
    } else {
      return null;
    }
  }

  void set(int x, int y, Cell cell) {
    genOptimizer.remove(x, y);

    x = this.x(x);
    y = this.y(y);

    if (backgrounds.contains(cell.id)) {
      setPlace(x, y, cell.id);
      return;
    }

    if (inside(x, y)) {
      grid[x][y] = cell;
      cell.cx = x;
      cell.cy = y;
      setChunk(x, y, cell.id);
    }
  }

  void setPlace(int x, int y, String id) {
    x = this.x(x);
    y = this.y(y);
    if (inside(x, y)) {
      place[x][y] = id;
      setChunk(x, y, id);
    }
  }

  int cx(int x) => x ~/ chunkSize;
  int cy(int y) => y ~/ chunkSize;

  int chunkToCellX(int x) => x * chunkSize;
  int chunkToCellY(int y) => y * chunkSize;

  void setChunk(int x, int y, String id) {
    chunks[cx(x)][cy(y)].add(id);
  }

  bool inChunk(int x, int y, String id) {
    if (id == "*") return true;
    if (id == "all") return chunks[cx(x)][cy(y)].isNotEmpty;

    return chunks[cx(x)][cy(y)].contains(id);
  }

  String placeable(int x, int y) {
    if (wrap) {
      return place[(x + width) % width][(y + height) % height];
    }
    if (!inside(x, y)) return "empty";
    return place[x][y];
  }

  Grid get copy {
    final grid = Grid(width, height);
    grid.wrap = wrap;
    grid.title = title;
    grid.desc = desc;
    forEach(
      (cell, x, y) {
        grid.setPlace(x, y, placeable(x, y));
        grid.set(x, y, cell.copy);
      },
    );
    return grid;
  }

  bool get movable {
    if (cells.contains("empty")) return true;
    for (var passThrough in justMoveInsideOf) {
      if (cells.contains(passThrough)) return true;
    }
    if (cells.containsAny(trashes)) return true;
    if (cells.containsAny(enemies)) return true;
    if (cells.contains("semi_enemy") || cells.contains("semi_trash")) return true;
    return false;
  }

  void updateCell(void Function(Cell cell, int x, int y) callback, int? rot, String id, {bool invertOrder = false}) {
    //if (!cells.contains(id)) return;

    if (rot == null) {
      // Update statically
      loopChunks(id, invertOrder ? GridAlignment.topleft : GridAlignment.bottomright, callback, filter: (cell, x, y) => cell.id == id && !cell.updated);
    } else {
      loopChunks(
        id,
        fromRot((rot + (invertOrder ? 2 : 0)) % 4),
        callback,
        filter: (cell, x, y) {
          return ((cell.id == id) && (cell.rot == rot) && (!cell.updated));
        },
      );
    }
  }

  void loopChunks(String chunkID, GridAlignment alignment, void Function(Cell cell, int x, int y) callback, {bool Function(Cell cell, int x, int y)? filter}) {
    if (filter == null) {
      filter = (Cell c, int x, int y) {
        if (chunkID == "all") return true;
        return c.id == chunkID;
      };
    }

    // 0,0 to w,h
    if (alignment == fromRot(2)) {
      var x = 0;
      var y = 0;

      while (y < height) {
        while (x < width) {
          if (this.inChunk(x, y, chunkID)) {
            if (filter(at(x, y), x, y)) {
              if (chunkID != "all") at(x, y).updated = true;
              callback(at(x, y), x, y);
            }
            x++;
          } else {
            x = chunkToCellX(cx(x) + 1);
          }
        }
        y++;
        x = 0;
      }
    }

    // w,h to 0,0
    if (alignment == fromRot(0)) {
      var x = width - 1;
      var y = height - 1;

      while (y >= 0) {
        while (x >= 0) {
          if (this.inChunk(x, y, chunkID)) {
            if (filter(at(x, y), x, y)) {
              if (chunkID != "all") at(x, y).updated = true;
              callback(at(x, y), x, y);
            }
            x--;
          } else {
            x = chunkToCellX(cx(x)) - 1;
          }
        }
        y--;
        x = width - 1;
      }
    }

    // 0,h to w,0
    if (alignment == fromRot(1)) {
      var x = 0;
      var y = height - 1;

      while (x < width) {
        while (y >= 0) {
          if (this.inChunk(x, y, chunkID)) {
            if (filter(at(x, y), x, y)) {
              if (chunkID != "all") at(x, y).updated = true;
              callback(at(x, y), x, y);
            }
            y--;
          } else {
            y = chunkToCellY(cy(y)) - 1;
          }
        }
        x++;
        y = height - 1;
      }
    }

    // w,0 to 0,h
    if (alignment == fromRot(3)) {
      var x = width - 1;
      var y = 0;

      while (x >= 0) {
        while (y < height) {
          if (this.inChunk(x, y, chunkID)) {
            if (filter(at(x, y), x, y)) {
              if (chunkID != "all") at(x, y).updated = true;
              callback(at(x, y), x, y);
            }
            y++;
          } else {
            y = chunkToCellY(cy(y) + 1);
          }
        }
        x--;
        y = 0;
      }
    }
  }

  void forEach(void Function(Cell cell, int x, int y) callback) {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        callback(at(x, y), x, y);
      }
    }
  }

  void clearChunks() {
    final cx = ceil(width / chunkSize);
    final cy = ceil(width / chunkSize);

    for (var x = 0; x < cx; x++) {
      for (var y = 0; y < cy; y++) {
        chunks[x][y].clear();
      }
    }
  }

  Grid(this.width, this.height) {
    create();
  }

  int tickCount = 0;

  bool wrap = false;

  Set<String> cells = {};

  Set<String> prepareTick() {
    final types = <String>{};
    for (var bcell in brokenCells) {
      types.add(bcell.type);
    }
    if (types.contains("normal") || types.contains("shrinking")) {
      playSound(destroySound);
    }
    brokenCells = [];
    final cells = <String>{};

    //if (tickCount % 100 == 0) clearChunks();

    forEach(
      (cell, x, y) {
        cell.updated = false;
        cell.lastvars = LastVars(cell.rot, x, y);
        cell.tags.clear();
        cell.cx = x;
        cell.cy = y;
        cell.lifespan++;
        if (cell.id != "empty") {
          cells.add(cell.id);
        }
        cells.add(place[x][y]);
        if (tickCount % 100 == 0) {
          setChunk(x, y, cell.id);
        }
      },
    );

    return cells;
  }

  void rotate(int x, int y, int rot) {
    genOptimizer.remove(x, y);
    if (!inside(x, y)) return;
    final id = at(x, y).id;
    if (id == "anchor") {
      doAnchor(x, y, rot);
      return;
    }
    if (id == "empty" || id == "wall_puzzle" || id == "wall" || id == "ghost") return;
    if (!breakable(
      at(x, y),
      x,
      y,
      rot,
      BreakType.rotate,
    )) {
      return;
    }
    at(x, y).rot += rot;
    at(x, y).rot %= 4;
  }

  void update() {
    tickCount++;
    cells = prepareTick();
    //print(cells);

    final subticking = storage.getBool('subtick') ?? false;
    if (subticking) {
      if ((puzzleWin || puzzleLost) && game.edType == EditorType.loaded) return;
      var subtick = subticks[tickCount % subticks.length];
      if (subtick is void Function(Set<String>)) {
        subtick(cells);
      } else {
        subtick();
      }
      if (tickCount % subticks.length == 0) {
        QueueManager.runQueue("newtick");
      }
    } else {
      for (var subtick in subticks) {
        if ((puzzleWin || puzzleLost) && game.edType == EditorType.loaded) return;
        if (subtick is void Function(Set<String>)) {
          subtick(cells);
        } else {
          subtick();
        }
      }
      QueueManager.runQueue("newtick");
    }
  }
}

enum GridAlignment {
  topleft,
  topright,
  bottomright,
  bottomleft,
}

GridAlignment fromRot(int rot) => GridAlignment.values[fixRot(rot)];

// Grid Clipboard
class GridClip {
  int width = 0;
  int height = 0;

  List<List<Cell>> cells = [];

  bool active = false;

  void activate(int width, int height, List<List<Cell>> cells) {
    this.width = width;
    this.height = height;
    this.cells = cells;
    this.active = true;
  }

  void place(int x, int y) {
    for (var cx = 0; cx < cells.length; cx++) {
      for (var cy = 0; cy < cells[cx].length; cy++) {
        final sx = cx + x;
        final sy = cy + y;
        if (grid.inside(sx, sy) && cells[cx][cy].id != "empty") {
          cells[cx][cy].lastvars = LastVars(cells[cx][cy].rot, sx, sy);
          if (!game.isMultiplayer) grid.set(sx, sy, cells[cx][cy].copy);
          game.sendToServer(
            "place $sx $sy ${cells[cx][cy].id} ${cells[cx][cy].rot} ${game.cellDataStr(cells[cx][cy].data)}",
          );
        }
      }
    }
  }

  void render(Canvas canvas, int x, int y) {
    for (var cx = 0; cx < cells.length; cx++) {
      for (var cy = 0; cy < cells[cx].length; cy++) {
        if (cells[cx][cy].id != "empty") {
          canvas.save();
          final rot = cells[cx][cy].rot * halfPi;
          var sx = cx + x;
          var sy = cy + y;
          if (grid.inside(sx, sy)) {
            if (grid.wrap) {
              sx += grid.width;
              sx %= grid.width;
              sy += grid.height;
              sy %= grid.height;
            }
            final off = rotateOff(
                  Offset(sx * cellSize + cellSize / 2, sy * cellSize + cellSize / 2),
                  -rot,
                ) -
                Offset(
                      cellSize,
                      cellSize,
                    ) /
                    2;
            canvas.rotate(rot);
            final file = textureMap['${cells[cx][cy].id}.png'] ?? '${cells[cx][cy].id}.png';
            (Sprite(Flame.images.fromCache(file))..paint = (Paint()..color = Colors.white.withOpacity(0.2))).render(
              canvas,
              position: Vector2(off.dx, off.dy),
              size: Vector2.all(
                cellSize.toDouble(),
              ),
            );
          }
          canvas.restore();
        }
      }
    }
  }

  void rotate(RotationalType rt) {
    if (rt == RotationalType.clockwise) {
      final copy = <List<Cell>>[];
      for (var i = 0; i < height; i++) {
        copy.add(<Cell>[]);
        for (var j = 0; j < width; j++) {
          copy.last.add(Cell(j, i));
        }
      }

      for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
          copy[y][x] = this.cells[x][height - y - 1].copy;
          copy[y][x].rot += 1;
          copy[y][x].rot %= 4;
        }
      }

      this.cells = copy;
      game.selH = width;
      game.selW = height;
      final tmp = width;
      width = height;
      height = tmp;
    } else if (rt == RotationalType.counter_clockwise) {
      final copy = <List<Cell>>[];
      for (var i = 0; i < height; i++) {
        copy.add(<Cell>[]);
        for (var j = 0; j < width; j++) {
          copy.last.add(Cell(j, i));
        }
      }

      for (var x = 0; x < width; x++) {
        for (var y = 0; y < height; y++) {
          copy[y][x] = this.cells[width - x - 1][y];
          copy[y][x].rot += 3;
          copy[y][x].rot %= 4;
        }
      }

      this.cells = copy;
      game.selH = width;
      game.selW = height;
      final tmp = width;
      width = height;
      height = tmp;
    }
  }
}
