part of logic;

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
  late List<List<HashSet<String>>> chunks;

  late QuadChunk quadChunk;
  final codeManager = CodeCellManager();

  HashMap<int, HashMap<int, num>> memory = HashMap<int, HashMap<int, num>>();

  String title = "";
  String desc = "";

  List<BrokenCell> brokenCells = [];

  List<FakeCell> fakeCells = [];

  void addBroken(Cell cell, int dx, int dy, [String type = "normal", int? rlvx, int? rlvy]) {
    if (cell.invisible && game.edType == EditorType.loaded) return;
    if (cell.id == "empty") return;

    final b = BrokenCell(cell.id, cell.rot, dx, dy, cell.lastvars, type, cell.data, cell.invisible);

    b.lv.lastPos = Offset(rlvx?.toDouble() ?? b.lv.lastPos.dx, rlvy?.toDouble() ?? b.lv.lastPos.dy);

    brokenCells.add(b);
  }

  int get chunkSize => storage.getInt("chunk_size") ?? 25;

  int width;
  int height;

  void create() {
    place = [];
    grid = List.generate(width, (x) {
      place.add([]);
      return List.generate(height, (y) {
        place.last.add("empty");
        return Cell(x, y);
      });
    });

    final cx = ceil(width / chunkSize);
    final cy = ceil(height / chunkSize);

    chunks = List.generate(cx, (_) => List.generate(cy, (_) => HashSet<String>()));

    quadChunk = QuadChunk(0, 0, width - 1, height - 1);
  }

  int x(int rawX) => wrap ? ((rawX + width) % width) : rawX;
  int y(int rawY) => wrap ? ((rawY + height) % height) : rawY;

  bool inside(int x, int y) {
    if (wrap) return true;

    return (x >= 0 && x < width && y >= 0 && y < height);
  }

  Cell at(int x, int y) {
    return grid[this.x(x)][this.y(y)]
      ..cx = this.x(x)
      ..cy = this.y(y);
  }

  Cell? get(int x, int y) {
    if (inside(x, y)) {
      return at(x, y);
    } else {
      return null;
    }
  }

  void set(int x, int y, Cell cell) {
    if (cell != get(x, y)) genOptimizer.remove(x, y);
    if (cell.id != "empty") {
      cells.add(cell.id);
    }

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
    if (id == "empty") return;
    cells.add(id);
    chunks[cx(x)][cy(y)].add(id);
    quadChunk.insert(x, y, id);
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
    memory.forEach((key, value) {
      grid.memory[key] = HashMap.from(value);
    });
    return grid;
  }

  bool get movable {
    if (cells.contains("empty")) return true;
    for (var passThrough in justMoveInsideOf) {
      if (cells.contains(passThrough)) return true;
    }
    if (cells.containsAny(trashes)) return true;
    if (cells.containsAny(enemies)) return true;
    return false;
  }

  void updateCell(void Function(Cell cell, int x, int y) callback, int? rot, String id, {bool invertOrder = false, bool useQuadChunks = false}) {
    //if (!cells.contains(id)) return;

    if (useQuadChunks) {
      final pos = quadChunk.fetch(id);

      if (rot == null) {
        for (var p in pos) {
          final c = at(p[0], p[1]);
          if (c.id == id) callback(c, p[0], p[1]);
        }
      }

      return;
    }

    if (rot == null) {
      // Update statically
      loopChunks(
        id,
        invertOrder ? GridAlignment.topleft : GridAlignment.bottomright,
        //(cell, x, y) => QueueManager.add("cell-updates", () => callback(cell, x, y)),
        callback,
        filter: (cell, x, y) => cell.id == id && !cell.updated,
      );
    } else {
      loopChunks(
        id,
        fromRot((rot + (invertOrder ? 2 : 0)) % 4),
        //(cell, x, y) => QueueManager.add("cell-updates", () => callback(cell, x, y)),
        callback,
        filter: (cell, x, y) {
          return ((cell.id == id) && (cell.rot == rot) && (!cell.updated));
        },
      );
    }
  }

  bool inChunk(int x, int y, String id) {
    if (id == "*") return true;
    if (id == "all") return chunks[cx(x)][cy(y)].isNotEmpty;

    return chunks[cx(x)][cy(y)].contains(id);
  }

  void loopChunks(String chunkID, GridAlignment alignment, void Function(Cell cell, int x, int y) callback, {bool Function(Cell cell, int x, int y)? filter, bool shouldUpdate = true}) {
    if (chunkID == "all") {
      if (cells.isEmpty) return;
    } else if (chunkID != "*") {
      if (!cells.contains(chunkID)) return;
    }

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
              if (chunkID != "all" && shouldUpdate) at(x, y).updated = true;
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
              if (chunkID != "all" && shouldUpdate) at(x, y).updated = true;
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
              if (chunkID != "all" && shouldUpdate) at(x, y).updated = true;
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
              if (chunkID != "all" && shouldUpdate) at(x, y).updated = true;
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
    brokenCells = [];
    final cells = <String>{};

    final cellPos = quadChunk.fetch("all");

    if (cellPos.length < width * height) cells.add("empty"); // If we skipped some its guaranteed we have some empties

    for (var p in cellPos) {
      var x = p[0];
      var y = p[1];
      var cell = at(x, y);
      cell.updated = false;
      cell.lastvars = LastVars(cell.rot, x, y, cell.id);
      cell.tags.clear();
      cell.cx = x;
      cell.cy = y;
      cell.lifespan++;
      cells.add(cell.id);
      if (place[x][y] != "empty") cells.add(place[x][y]);
    }

    if (tickCount % 100 == 0) quadChunk.reload();

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

  void handleBrokenCellSounds() {
    final types = <String>{};
    for (var bcell in brokenCells) {
      types.add(bcell.type);
    }
    if (types.contains("normal") || types.contains("shrinking")) {
      playSound(destroySound);
    }
  }

  void update() {
    tickCount++;
    cells = prepareTick();
    for (var fc in fakeCells) {
      fc.tick();
    }
    //print(cells);

    final subticking = storage.getBool('subtick') ?? false;
    if (subticking) {
      if ((puzzleWin || puzzleLost) && game.edType == EditorType.loaded) return;
      var subtick = subticks[tickCount % subticks.length];
      if (subtick is void Function(Set<String>)) {
        // QueueManager.add("subticks", () => subtick(cells));
        subtick(cells);
      } else if (subtick is void Function()) {
        // QueueManager.add("subticks", subtick);
        subtick();
      }
    } else {
      for (var subtick in subticks) {
        if ((puzzleWin || puzzleLost) && game.edType == EditorType.loaded) return;
        if (subtick is void Function(Set<String>)) {
          // QueueManager.add("subticks", () => subtick(cells));
          subtick(cells);
        } else if (subtick is void Function()) {
          // QueueManager.add("subticks", subtick);
          subtick();
        }
      }
    }
    handleBrokenCellSounds();
  }

  String encode() {
    if (currentSavingFormat == CurrentSavingFormat.VX) return VX.encodeGrid(this, title: title, desc: desc);

    return SavingFormat.encodeGrid(this, title: title, description: desc);
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
          cells[cx][cy].lastvars = LastVars(cells[cx][cy].rot, sx, sy, cells[cx][cy].id);
          if (!game.isMultiplayer) grid.set(sx, sy, cells[cx][cy].copy);
          game.sendToServer('place', {"x": sx, "y": sy, "id": cells[cx][cy].id, "rot": cells[cx][cy].rot, "data": cells[cx][cy].data, "size": 1});
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

  bool isFullyEmpty(int i, bool isRow) {
    if (isRow) {
      for (var x = 0; x < width; x++) {
        if (cells[x][i].id != "empty") {
          return false;
        }
      }
    } else {
      for (var y = 0; y < height; y++) {
        if (cells[i][y].id != "empty") {
          return false;
        }
      }
    }

    return true;
  }

  void optimize() {
    var optimized = true;
    while (optimized) {
      print("Optimizing");
      optimized = false;

      if (isFullyEmpty(0, true)) {
        print("Optimization 1");
        for (var x = 0; x < width; x++) {
          cells[x].removeAt(0);
        }
        height--;
        optimized = true;
      }
      if (isFullyEmpty(0, false)) {
        print("Optimization 2");
        cells.removeAt(0);
        width--;
        optimized = true;
      }
      if (isFullyEmpty(height - 1, true)) {
        print("Optimization 3");
        for (var x = 0; x < width; x++) {
          cells[x].removeAt(height - 1);
        }
        height--;
        optimized = true;
      }
      if (isFullyEmpty(width - 1, false)) {
        print("Optimization 4");
        cells.removeAt(width - 1);
        width--;
        optimized = true;
      }
    }
  }
}
