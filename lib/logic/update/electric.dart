part of logic;

class ElectricPath {
  List<int> fullPath;
  int x;
  int y;
  Cell source;

  ElectricPath(this.fullPath, this.x, this.y, this.source);

  ElectricPath get copy {
    return ElectricPath([...fullPath], x, y, source);
  }

  List<ElectricPath> get next {
    if (isOffGrid) return [];
    if (isDone) return [this];
    final l = <ElectricPath>[];

    for (var i = 0; i < 4; i++) {
      // This might look weird, it means "Don't immediately return to the last point"
      if (fullPath.isNotEmpty && endDir == (i + 2) % 4) continue;

      if (!electricManager.canTransfer(grid.at(x, y), x, y, i, source))
        continue;

      // Some cells might block where they can transfer to.
      if (host != null &&
          !electricManager.blockedByHost(host!, x, y, i, source)) continue;

      final p = copy;

      p.fullPath.add(i);
      p.x = frontX(p.x, i);
      p.y = frontY(p.y, i);

      l.add(p);
    }
    l.removeWhere((p) => p.isOffGrid);
    return l;
  }

  int get startDir => fullPath.first;
  int get endDir => fullPath.last;

  bool get isOffGrid => !grid.inside(x, y);
  bool get isDone => grid.inside(x, y)
      ? electricManager.isInput(grid.at(x, y), x, y, endDir)
      : false;

  Cell? get host => grid.get(x, y);
}

class ElectricManager {
  bool isInput(Cell cell, int x, int y, int dir) {
    // final side = toSide(dir, cell.rot);

    return false;
  }

  bool canTransfer(Cell cell, int x, int y, int dir, Cell source) {
    // final side = toSide(dir, cell.rot);

    if (cell.id == "electric_wire") return true;

    return false;
  }

  bool blockedByHost(Cell host, int x, int y, int dir, Cell source) {
    return false;
  }

  List<ElectricPath> optimalDirections(Cell source, int x, int y) {
    var l = ElectricPath([], x, y, source).next;

    while (l.isNotEmpty) {
      var nl = <ElectricPath>[];

      for (var path in l) {
        if (path.isDone) {
          return l.where((p) => p.isDone).toList();
        } else {
          nl.addAll(path.next);
        }
      }

      l = nl;
    }

    return [];
  }

  // Spread power through a wire.
  void spreadPower(Cell cell, int x, int y) {
    final directions = optimalDirections(cell, x, y);

    // If we can't spread, we don't spread.
    if (directions.isEmpty) return;

    var power = readPower(cell, x, y) / directions.length;
    if (power == 0) return;

    setPower(cell, x, y, 0);

    for (var dir in directions) {
      final sd = dir.startDir;
      final cx = frontX(x, sd);
      final cy = frontY(y, sd);
      if (!grid.inside(cx, cy)) continue;
      givePower(grid.at(cx, cy), cx, cy, power);
    }
  }

  double takePower(Cell cell, int x, int y, double amount) {
    final power = readPower(cell, x, y);

    setPower(cell, x, y, max(power - amount, 0));

    return min(power, amount);
  }

  void givePower(Cell cell, int x, int y, double amount) {
    setPower(cell, x, y, readPower(cell, x, y) + amount);
  }

  void setPower(Cell cell, int x, int y, double power) {
    power = max(power, 0);
    cell.data['electric_power'] = power;
    if (power == 0) cell.data.remove('electric_power');
  }

  double readPower(Cell cell, int x, int y) {
    return (cell.data['electric_power'] as num?)?.toDouble() ?? 0;
  }
}

final electricManager = ElectricManager();
