part of logic;

void doAnt(RotationalType rt, Cell cell, int x, int y) {
  if (rt == RotationalType.clockwise) {
    grid.rotate(x, y, 1);
    if (safeAt(x, y + 1)?.id != "empty" && push(x, y, 0, 1)) {
    } else if (safeAt(x, y - 1)?.id != "empty" && push(x, y, 2, 1)) {
    } else if (safeAt(x + 1, y)?.id != "empty" && push(x, y, 3, 1)) {
    } else if (safeAt(x - 1, y)?.id != "empty" && push(x, y, 1, 1)) {
    } else {
      push(x, y, 1, 1);
    }
  } else if (rt == RotationalType.counter_clockwise) {
    grid.rotate(x, y, -1);
    if (safeAt(x, y + 1)?.id != "empty" && push(x, y, 2, 1)) {
    } else if (safeAt(x, y - 1)?.id != "empty" && push(x, y, 0, 1)) {
    } else if (safeAt(x - 1, y)?.id != "empty" && push(x, y, 3, 1)) {
    } else if (safeAt(x + 1, y)?.id != "empty" && push(x, y, 1, 1)) {
    } else {
      push(x, y, 1, 1);
    }
  }
}

void ants() {
  grid.updateCell(
    (cell, x, y) {
      doAnt(RotationalType.clockwise, cell, x, y);
    },
    null,
    "ant_cw",
  );
  grid.updateCell(
    (cell, x, y) {
      doAnt(RotationalType.counter_clockwise, cell, x, y);
    },
    null,
    "ant_ccw",
  );
}
