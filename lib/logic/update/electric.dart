part of logic;

class ElectricPath {
  List<int> fullPath;
  Set<String> visited;
  int x;
  int y;
  Cell source;

  ElectricPath(this.fullPath, this.visited, this.x, this.y, this.source);

  ElectricPath get copy {
    return ElectricPath([...fullPath], visited, x, y, source);
  }

  List<ElectricPath> get next {
    if (fullPath.isNotEmpty) {
      if (isOffGrid) return [];
      if (isDone) return [this];
    }
    final l = <ElectricPath>[];

    for (var i = 0; i < 4; i++) {
      // This might look weird, it means "Don't immediately return to the last point"
      if (fullPath.isNotEmpty) if (endDir == (i + 2) % 4) continue;

      if (!electricManager.canTransfer(grid.at(x, y), x, y, i, source)) {
        continue;
      }

      // Some cells might block where they can transfer to.
      if (host != null && electricManager.blockedByHost(host!, x, y, i, source)) {
        continue;
      }

      final p = copy;

      p.fullPath.add(i);
      p.x = frontX(p.x, i);
      p.y = frontY(p.y, i);
      if (p.host != null &&
          electricManager.blockedByReceiver(p.host!, p.x, p.y, i, source)) {
        continue;
      }

      l.add(p);
      visited.add("${p.x} ${p.y}");
    }
    l.removeWhere((p) => p.isOffGrid || !p.valid);
    return l;
  }

  int get startDir => fullPath.first;
  int get endDir => fullPath.last;

  bool get isOffGrid => !grid.inside(x, y);
  bool get isDone => visited.contains("$x $y") && grid.inside(x, y)
      ? electricManager.isInput(grid.at(x, y), x, y, endDir)
      : false;

  Cell? get host => grid.get(x, y);

  bool get valid => host == null
      ? false
      : electricManager.canHost(
          host!,
          x,
          y,
          source,
        );

  @override
  int get hashCode => Object.hashAll([source.hashCode, x, y]);

  @override
  String toString() {
    return "$x $y $fullPath";
  }
}

class ElectricManager {
  bool isInput(Cell cell, int x, int y, int dir) {
    // final side = toSide(dir, cell.rot);
    if (cell.id == "electric_container") return true;
    if (cell.id == "electric_mover") return true;
    if (cell.id == "electric_puller") return true;
    if (cell.id == "electric_battery") return true;

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

  bool blockedByReceiver(Cell receiver, int x, int y, int dir, Cell source) {
    if (receiver.id == "electric_wire" && readPower(receiver, x, y) > 0) {
      return true;
    }

    return false;
  }

  bool canHost(Cell host, int x, int y, Cell source) {
    if (host.id == "electric_wire") return true;
    if (host.id == "electric_container") return true;
    if (host.id == "electric_mover") return true;
    if (host.id == "electric_puller") return true;
    if (host.id == "electric_battery") return true;

    return false;
  }

  bool canHavePower(Cell cell, int x, int y) {
    if (cell.id == "electric_wire") return true;
    if (cell.id == "electric_container") return true;
    if (cell.id == "electric_mover") return true;
    if (cell.id == "electric_puller") return true;
    if (cell.id == "electric_battery") return true;
    if (cell.id == "sentry") return true;

    return false;
  }

  List<ElectricPath> optimalDirections(Cell source, int x, int y) {
    if (!canHost(source, x, y, source)) return [];
    final visited = <String>{};
    var l = ElectricPath([], visited, x, y, source).next;
    final hashes = HashSet<int>();

    while (l.isNotEmpty) {
      var nl = <ElectricPath>[];

      for (var path in l) {
        if (path.isDone) {
          return l.where((p) => p.isDone).toList();
        } else {
          nl.addAll(path.next);
        }
      }

      final nh = Object.hashAll(nl);

      // In the case of a loop, return.
      if (hashes.contains(nh)) return [];

      l = nl;
      hashes.add(nh);
      print(nl);
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

  bool removePower(Cell cell, int x, int y, double amount) {
    final power = readPower(cell, x, y);

    if (power < amount) return false;

    setPower(cell, x, y, power - amount);
    return true;
  }

  void whenGiven(Cell cell, int x, int y, double amount) {
    if (cell.id == "electric_wire") {
      cell.updated = true;
    }
  }

  void whenSet(Cell cell, int x, int y, double amount) {
    if (cell.id == "electric_battery") {
      final bool useCapacity = (cell.data['use_capacity'] ?? false);
      final double capacity = ((cell.data['capacity'] ?? 0) as num).toDouble();

      if (useCapacity && amount > capacity) setPower(cell, x, y, capacity);
    }
  }

  void givePower(Cell cell, int x, int y, double amount) {
    cell.tags.add("received electricity");
    setPower(cell, x, y, directlyReadPower(cell) + amount);
    whenGiven(cell, x, y, amount);
  }

  void setPower(Cell cell, int x, int y, double power) {
    if (!canHavePower(cell, x, y)) return;
    power = max(power, 0);
    cell.data['electric_power'] = power;
    if (power == 0) cell.data.remove('electric_power');
    whenSet(cell, x, y, power);
  }

  double readPower(Cell cell, int x, int y) {
    return (cell.data['electric_power'] as num?)?.toDouble() ?? 0;
  }

  double directlyReadPower(Cell cell) {
    return (cell.data['electric_power'] as num?)?.toDouble() ?? 0;
  }
}

final electricManager = ElectricManager();

void electric() {
  grid.updateCell((cell, x, y) {
    electricManager.spreadPower(cell, x, y);
  }, null, "electric_wire");
  grid.updateCell((cell, x, y) {
    final num interval = (cell.data['interval'] ?? 1);
    if (interval <= 0) return;
    final power = ((cell.data['power_to_give'] ?? 1) as num).toDouble();

    cell.data['t'] ??= 0.0;
    cell.data['t']++;

    while (cell.data['t'] >= interval) {
      final f = grid.get(frontX(x, cell.rot), frontY(y, cell.rot));
      if (f != null) electricManager.givePower(f, f.cx!, f.cy!, power);
      cell.data['t'] -= interval;
    }
  }, null, "electric_generator");
  grid.updateCell((cell, x, y) {
    var power = electricManager.directlyReadPower(cell);
    final double capacity = ((cell.data['capacity'] ?? 0) as num).toDouble();
    final bool useCapacity = (cell.data['use_capacity'] ?? false);
    final cost = ((cell.data['cost'] ?? 1) as num).toDouble();

    if (power > capacity && useCapacity) {
      power = capacity;
      electricManager.setPower(cell, x, y, power);
    }

    if (power >= cost) {
      final f = grid.get(frontX(x, cell.rot), frontY(y, cell.rot));

      if (f == null) return;
      if (f.id == "empty") return;

      electricManager.removePower(cell, x, y, cost);
    } else {
      final f = grid.get(frontX(x, cell.rot), frontY(y, cell.rot));
      if (f == null) return;
      if (f.id == "empty") return;
      f.updated = true;
      f.tags.add("stopped");
    }
  }, null, "electric_battery");
  grid.updateCell((cell, x, y) {
    final power = electricManager.directlyReadPower(cell);
    final countFails = (cell.data['count_fails'] ?? false) as bool;
    final cost = ((cell.data['cost'] ?? 1) as num).toDouble();

    if (power >= cost) {
      if (push(x, y, cell.rot, 0)) {
        electricManager.removePower(cell, x, y, cost);
      } else if (countFails) {
        electricManager.removePower(cell, x, y, cost);
      }
    }
  }, null, "electric_mover");
  grid.updateCell((cell, x, y) {
    final power = electricManager.directlyReadPower(cell);
    final countFails = (cell.data['count_fails'] ?? false) as bool;
    final cost = ((cell.data['cost'] ?? 1) as num).toDouble();

    if (power >= cost) {
      if (pull(x, y, cell.rot, 0)) {
        electricManager.removePower(cell, x, y, cost);
      } else if (countFails) {
        electricManager.removePower(cell, x, y, cost);
      } else {
        print("uh oh");
      }
    }
  }, null, "electric_puller");
}
