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

void spreaders() {
  grid.updateCell(doCancer, null, "cancer");
  grid.updateCell(doFire, null, "fire");
  grid.loopChunks("lava", fromRot(1), doLava, filter: (c, x, y) => c.id == "lava" && !c.updated);
  grid.loopChunks("plasma", fromRot(3), doPlasma, filter: (c, x, y) => c.id == "plasma" && !c.updated);

  grid.updateCell(doFiller, null, "filler");
}
