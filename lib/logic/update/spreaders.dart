part of logic;

void doFire(Cell cell, int x, int y) {
  final fire = cell.copy;
  fire.updated = true;

  if (grid.inside(x + 1, y)) {
    final cell = grid.at(x + 1, y);
    if (cell.id != "empty" && cell.id != "fire" && breakable(cell, x + 1, y, 0, BreakType.burn)) {
      grid.addBroken(cell, x + 1, y, "silent");
      grid.set(x + 1, y, fire.copy);
    }
  }

  if (grid.inside(x - 1, y)) {
    final cell = grid.at(x - 1, y);
    if (cell.id != "empty" && cell.id != "fire" && breakable(cell, x - 1, y, 2, BreakType.burn)) {
      grid.addBroken(cell, x - 1, y, "silent");
      grid.set(x - 1, y, fire.copy);
    }
  }

  if (grid.inside(x, y + 1)) {
    final cell = grid.at(x, y + 1);
    if (cell.id != "empty" && cell.id != "fire" && breakable(cell, x, y + 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y + 1, "silent");
      grid.set(x, y + 1, fire.copy);
    }
  }

  if (grid.inside(x, y - 1)) {
    final cell = grid.at(x, y - 1);
    if (cell.id != "empty" && cell.id != "fire" && breakable(cell, x, y - 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y - 1, "silent");
      grid.set(x, y - 1, fire.copy);
    }
  }

  grid.addBroken(cell, x, y, "silent_shrinking");
  grid.set(x, y, Cell(x, y));
}

void doPlasma(Cell cell, int x, int y) {
  final plasma = cell.copy;
  plasma.updated = true;

  if (grid.inside(x + 1, y)) {
    final cell = grid.at(x + 1, y);
    if (cell.id != "empty" && cell.id != "plasma" && breakable(cell, x + 1, y, 0, BreakType.burn)) {
      grid.addBroken(cell, x + 1, y, "silent");
      grid.set(x + 1, y, plasma.copy);
    }
  }

  if (grid.inside(x - 1, y)) {
    final cell = grid.at(x - 1, y);
    if (cell.id != "empty" && cell.id != "plasma" && breakable(cell, x - 1, y, 2, BreakType.burn)) {
      grid.addBroken(cell, x - 1, y, "silent");
      grid.set(x - 1, y, plasma.copy);
    }
  }

  if (grid.inside(x, y + 1)) {
    final cell = grid.at(x, y + 1);
    if (cell.id != "empty" && cell.id != "plasma" && breakable(cell, x, y + 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y + 1, "silent");
      grid.set(x, y + 1, plasma.copy);
    }
  }

  if (grid.inside(x, y - 1)) {
    final cell = grid.at(x, y - 1);
    if (cell.id != "empty" && cell.id != "plasma" && breakable(cell, x, y - 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y - 1, "silent");
      grid.set(x, y - 1, plasma.copy);
    }
  }

  doWater(cell, x, y);
}

void doCancer(Cell cell, int x, int y) {
  final cancer = cell.copy;
  cancer.updated = true;

  if (grid.inside(x + 1, y)) {
    final cell = grid.at(x + 1, y);
    if (cell.id != "empty" && cell.id != "cancer" && breakable(cell, x + 1, y, 0, BreakType.burn)) {
      grid.addBroken(cell, x + 1, y, "silent");
      grid.set(x + 1, y, cancer.copy);
    }
  }

  if (grid.inside(x - 1, y)) {
    final cell = grid.at(x - 1, y);
    if (cell.id != "empty" && cell.id != "cancer" && breakable(cell, x - 1, y, 2, BreakType.burn)) {
      grid.addBroken(cell, x - 1, y, "silent");
      grid.set(x - 1, y, cancer.copy);
    }
  }

  if (grid.inside(x, y + 1)) {
    final cell = grid.at(x, y + 1);
    if (cell.id != "empty" && cell.id != "cancer" && breakable(cell, x, y + 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y + 1, "silent");
      grid.set(x, y + 1, cancer.copy);
    }
  }

  if (grid.inside(x, y - 1)) {
    final cell = grid.at(x, y - 1);
    if (cell.id != "empty" && cell.id != "cancer" && breakable(cell, x, y - 1, 0, BreakType.burn)) {
      grid.addBroken(cell, x, y - 1, "silent");
      grid.set(x, y - 1, cancer.copy);
    }
  }
}

void spreaders() {
  grid.loopChunks("plasma", GridAlignment.topleft, doPlasma, filter: (c, x, y) => c.id == "plasma" && !c.updated);
  grid.updateCell(doFire, null, "fire");
  grid.updateCell(doCancer, null, "cancer");
}
