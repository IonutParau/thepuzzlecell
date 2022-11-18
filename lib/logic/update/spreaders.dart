part of logic;

void doFire(Cell cell, int x, int y) {
  final fire = cell.copy;
  fire.updated = true;

  spread(x, y, fire);

  grid.addBroken(cell, x, y, "silent_shrinking");
  grid.set(x, y, Cell(x, y));
}

void doPlasma(Cell cell, int x, int y) {
  final plasma = cell.copy;
  plasma.updated = true;

  spread(x, y, plasma);

  doGas(cell, x, y);
}

void doLava(Cell cell, int x, int y) {
  final lava = cell.copy;
  lava.updated = true;

  spread(x, y, lava);

  doWater(cell, x, y);
}

bool spread(int x, int y, Cell spreader) {
  bool hasSpread = false;
  int id = spreader.data['id'] ?? 0;

  if (grid.inside(x + 1, y)) {
    final cell = grid.at(x + 1, y);
    if (cell.id != "empty" && (cell.id != spreader.id || (cell.data['id'] ?? 0) != id) && breakable(cell, x + 1, y, 0, BreakType.burn)) {
      grid.addBroken(cell, x + 1, y, "silent");
      grid.set(x + 1, y, spreader.copy);
      hasSpread = true;
    }
  }

  if (grid.inside(x - 1, y)) {
    final cell = grid.at(x - 1, y);
    if (cell.id != "empty" && (cell.id != spreader.id || (cell.data['id'] ?? 0) != id) && breakable(cell, x - 1, y, 2, BreakType.burn)) {
      grid.addBroken(cell, x - 1, y, "silent");
      grid.set(x - 1, y, spreader.copy);
      hasSpread = true;
    }
  }

  if (grid.inside(x, y + 1)) {
    final cell = grid.at(x, y + 1);
    if (cell.id != "empty" && (cell.id != spreader.id || (cell.data['id'] ?? 0) != id) && breakable(cell, x, y + 1, 1, BreakType.burn)) {
      grid.addBroken(cell, x, y + 1, "silent");
      grid.set(x, y + 1, spreader.copy);
      hasSpread = true;
    }
  }

  if (grid.inside(x, y - 1)) {
    final cell = grid.at(x, y - 1);
    if (cell.id != "empty" && (cell.id != spreader.id || (cell.data['id'] ?? 0) != id) && breakable(cell, x, y - 1, 3, BreakType.burn)) {
      grid.addBroken(cell, x, y - 1, "silent");
      grid.set(x, y - 1, spreader.copy);
      hasSpread = true;
    }
  }

  return hasSpread;
}

void doCancer(Cell cell, int x, int y) {
  final cancer = cell.copy;
  cancer.updated = true;

  spread(x, y, cancer);
}

void doFiller(Cell cell, int x, int y) {
  final filler = cell.copy;
  filler.updated = true;
  if (safeAt(x + 1, y)?.id == "empty") grid.set(x + 1, y, filler.copy);
  if (safeAt(x - 1, y)?.id == "empty") grid.set(x - 1, y, filler.copy);
  if (safeAt(x, y + 1)?.id == "empty") grid.set(x, y + 1, filler.copy);
  if (safeAt(x, y - 1)?.id == "empty") grid.set(x, y - 1, filler.copy);
}

void doConfigurableFiller(Cell cell, int x, int y) {
  final consistency = cell.data['consistency'] as num;
  if (rng.nextDouble() > consistency / 100) return;

  final filler = cell.copy;
  filler.updated = true;

  final rotate = cell.data['rotate'] as bool;
  final mutationChance = cell.data['mutationChance'] as num;
  final attackChance = cell.data['attackChance'] as num;
  final id = cell.data['id'] as int;

  Cell toSpread(int dir) {
    final c = filler.copy;

    if (rotate) {
      c.rot += dir;
      c.rot %= 4;
    }

    try {
      cell.data.forEach(
        (key, value) {
          c.data[key] = value;
          if (rng.nextDouble() <= mutationChance / 100) {
            if (value is bool) {
              c.data[key] = rng.nextBool();
            } else if (value is int) {
              c.data[key] = value;
            } else if (value is num) {
              c.data[key] = value + (rng.nextDouble() * 2 - 1);
            }
          }
        },
      );
    } catch (e, st) {
      print(e);
      print(st);
    }

    return c;
  }

  bool died = false;

  for (var dir in [0, 1, 2, 3]) {
    final fx = frontX(x, dir);
    final fy = frontY(y, dir);

    num odds = 100;

    if (dir == 0) {
      odds = cell.data['rightSpread'] as num;
    }
    if (dir == 2) {
      odds = cell.data['leftSpread'] as num;
    }
    if (dir == 1) {
      odds = cell.data['downSpread'] as num;
    }
    if (dir == 3) {
      odds = cell.data['upSpread'] as num;
    }
    if (rng.nextDouble() <= odds / 100) {
      if (safeAt(fx, fy)?.id == "empty") {
        grid.set(fx, fy, toSpread(dir));
      } else {
        if (safeAt(fx, fy)?.id == "configurable_filler" && safeAt(fx, fy)?.data['id'] != id) {
          if (rng.nextDouble() <= attackChance / 100) {
            grid.addBroken(grid.at(fx, fy), fx, fy, "silent");
            grid.set(fx, fy, toSpread(dir));
            if (rng.nextDouble() <= attackChance / 100) died = true;
          }
        }
      }
    }
  }

  if (died) {
    grid.addBroken(filler, x, y, "silent_shrinking");
    grid.set(x, y, Cell(x, y));
  }
}

void spreaders() {
  grid.updateCell(doCancer, null, "cancer");
  grid.updateCell(doFire, null, "fire");
  grid.loopChunks("lava", fromRot(1), doLava, filter: (c, x, y) => c.id == "lava" && !c.updated);
  grid.loopChunks("plasma", fromRot(3), doPlasma, filter: (c, x, y) => c.id == "plasma" && !c.updated);

  grid.updateCell(doFiller, null, "filler");

  grid.updateCell((cell, x, y) => ((rng.nextBool()) ? doFiller(cell, x, y) : null), null, "random_filler");

  grid.updateCell(doConfigurableFiller, null, "configurable_filler");
}
