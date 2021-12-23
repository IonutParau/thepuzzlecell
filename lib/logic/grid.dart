part of logic;

class LastVars {
  Offset lastPos;
  int lastRot;

  LastVars(this.lastRot, int x, int y)
      : lastPos = Offset(
          x.toDouble(),
          y.toDouble(),
        );

  LastVars get copy =>
      LastVars(lastRot, lastPos.dx.toInt(), lastPos.dy.toInt());
}

class Cell {
  String id = "empty";
  int rot = 0;
  LastVars lastvars;
  bool updated = false;
  Map<String, dynamic> data = {};

  Cell(int x, int y) : lastvars = LastVars(0, x, y);

  Cell get copy {
    final c = Cell(lastvars.lastPos.dx.toInt(), lastvars.lastPos.dy.toInt());

    c.id = id;
    c.rot = rot;
    c.updated = updated;
    c.lastvars.lastRot = lastvars.lastRot;

    data.forEach((key, value) => c.data[key] = value);

    return c;
  }
}

Grid grid = Grid(100, 100);

class Grid {
  late List<List<Cell>> grid;
  late List<List<bool>> place;

  int width;
  int height;

  int tickCount = 0;

  bool wrap = false;

  Set<String> cells = {};

  void remake() {
    grid = [];
    place = [];
    for (var x = 0; x < width; x++) {
      grid.add([]);
      place.add([]);
      for (var y = 0; y < height; y++) {
        grid.last.add(Cell(x, y));
        place.last.add(false);
      }
    }
  }

  void forEach(void Function(Cell cell, int x, int y) callback,
      [int? wantedDirection]) {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final cell = at(x, y);
        if (cell.rot == (wantedDirection ?? cell.rot)) {
          callback(cell, x, y);
        }
      }
    }
  }

  Grid(this.width, this.height) {
    remake();
  }

  inside(int x, int y) {
    if (wrap) return true;
    return (x >= 0 && x < width && y >= 0 && y < height);
  }

  Cell at(int x, int y) {
    if (wrap) {
      return grid[(x + width) % width][(y + height) % height];
    }
    return grid[x][y];
  }

  void set(int x, int y, Cell cell) {
    if (wrap) {
      if (cell.id == "place") {
        place[(x + width) % width][(y + height) % height] =
            !place[(x + width) % width][(y + height) % height];
        return;
      }
      grid[(x + width) % width][(y + height) % height] = cell;
      return;
    }
    if (!inside(x, y)) return;
    if (cell.id == "place") {
      place[x][y] = !place[x][y];
      return;
    }
    grid[x][y] = cell;
  }

  bool placeable(int x, int y) {
    if (wrap) {
      return place[(x + width) % width][(y + height) % height];
    }
    if (!inside(x, y)) return false;
    return place[x][y];
  }

  Grid get copy {
    final grid = Grid(width, height);
    grid.wrap = wrap;
    forEach(
      (p0, p1, p2) {
        if (placeable(p1, p2)) grid.place[p1][p2] = true;
        grid.set(p1, p2, p0.copy);
      },
    );
    return grid;
  }

  bool get movable {
    for (var passThrough in moveInsideOf) {
      if (cells.contains(passThrough)) return true;
    }
    return false;
  }

  Set<String> getCells() {
    final cells = <String>{};
    forEach(
      (p0, p1, p2) {
        p0.updated = false;
        p0.lastvars = LastVars(p0.rot, p1, p2);
        cells.add(p0.id);
      },
    );

    return cells;
  }

  void rotate(int x, int y, int rot) {
    if (!inside(x, y)) return;
    if (at(x, y).id == "empty") return;
    at(x, y).rot += rot;
    at(x, y).rot %= 4;
  }

  void update() {
    tickCount++;
    cells = getCells();

    final subticks = [
      if (cells.contains("releaser")) releasers,
      if (cells.contains("mirror")) mirrors,
      if (cells.contains("generator") ||
          cells.contains("generator_cw") ||
          cells.contains("generator_ccw") ||
          cells.contains("crossgen") ||
          cells.contains("triplegen") ||
          cells.contains("constructorgen"))
        gens,
      if (cells.contains("replicator")) reps,
      if (cells.contains("rotator_cw") || cells.contains("rotator_ccw")) rots,
      if (cells.contains("gear_cw") || cells.contains("gear_ccw")) gears,
      if (cells.contains("mover")) movers,
      if (cells.contains("puller")) pullers,
      if (cells.contains("liner")) liners,
      if (cells.contains("bird")) birds,
      if (cells.contains("magnet")) magnets,
      //if (cells.contains("digger")) diggers,
      if (cells.contains("karl")) karls,
      if (cells.contains("puzzle")) puzzles,
    ];

    for (var subtick in subticks) {
      try {
        subtick();
      } catch (e) {
        subtick(cells);
      }
    }
  }
}
