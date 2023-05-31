part of logic;

void doGear(int x, int y, RotationalType rt) {
  if (rt == RotationalType.clockwise) {
    // If we are jammed, stop ourselves
    if (!canMove(x, y - 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y, 1, 1, MoveType.gear)) return;
    if (!canMove(x, y + 1, 2, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y, 3, 1, MoveType.gear)) return;

    grid.rotate(x, y, 1); // Cool stuff

    // Save cells
    final cells = [];
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x + 1, y).copy);
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x - 1, y).copy);

    // Move cells
    grid.set(x - 1, y, cells[0]);
    grid.rotate(x - 1, y, 1);
    grid.set(x, y + 1, cells[1]);
    grid.rotate(x, y + 1, 1);
    grid.set(x + 1, y, cells[2]);
    grid.rotate(x + 1, y, 1);
    grid.set(x, y - 1, cells[3]);
    grid.rotate(x, y - 1, 1);
  } else if (rt == RotationalType.counter_clockwise) {
    // If we are jammed, stop ourselves
    if (!canMove(x, y - 1, 2, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y, 3, 1, MoveType.gear)) return;
    if (!canMove(x, y + 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y, 1, 1, MoveType.gear)) return;

    grid.rotate(x, y, -1); // Cool stuff

    // Save cells
    final cells = [];
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x - 1, y).copy);
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x + 1, y).copy);

    // Move cells
    grid.set(x - 1, y, cells[0]);
    grid.rotate(x - 1, y, -1);
    grid.set(x, y + 1, cells[1]);
    grid.rotate(x, y + 1, -1);
    grid.set(x + 1, y, cells[2]);
    grid.rotate(x + 1, y, -1);
    grid.set(x, y - 1, cells[3]);
    grid.rotate(x, y - 1, -1);
  }
}

void doMegagear(int x, int y, RotationalType rt) {
  if (rt == RotationalType.clockwise) {
    // halt if can't move
    if (!canMove(x, y - 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y - 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y, 1, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y + 1, 1, 1, MoveType.gear)) return;
    if (!canMove(x, y + 1, 2, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y + 1, 2, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y, 3, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y - 1, 3, 1, MoveType.gear)) return;

    // save
    final cells = [];
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x + 1, y - 1).copy);
    cells.add(grid.at(x + 1, y).copy);
    cells.add(grid.at(x + 1, y + 1).copy);
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x - 1, y + 1).copy);
    cells.add(grid.at(x - 1, y).copy);
    cells.add(grid.at(x - 1, y - 1).copy);

    // move
    grid.set(x + 1, y - 1, cells[0]);
    grid.set(x + 1, y, cells[1]);
    grid.set(x + 1, y + 1, cells[2]);
    grid.set(x, y + 1, cells[3]);
    grid.set(x - 1, y + 1, cells[4]);
    grid.set(x - 1, y, cells[5]);
    grid.set(x - 1, y - 1, cells[6]);
    grid.set(x, y - 1, cells[7]);
    grid.rotate(x - 1, y, 1);
    grid.rotate(x, y - 1, 1);
    grid.rotate(x + 1, y, 1);
    grid.rotate(x, y + 1, 1);
  } else if (rt == RotationalType.counter_clockwise) {
    // halt if can't move
    if (!canMove(x, y - 1, 2, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y - 1, 3, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y, 3, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y + 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x, y + 1, 0, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y + 1, 1, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y, 1, 1, MoveType.gear)) return;
    if (!canMove(x - 1, y - 1, 2, 1, MoveType.gear)) return;

    // save
    final cells = [];
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x - 1, y - 1).copy);
    cells.add(grid.at(x - 1, y).copy);
    cells.add(grid.at(x - 1, y + 1).copy);
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x + 1, y + 1).copy);
    cells.add(grid.at(x + 1, y).copy);
    cells.add(grid.at(x + 1, y - 1).copy);

    // move
    grid.set(x - 1, y - 1, cells[0]);
    grid.set(x - 1, y, cells[1]);
    grid.set(x - 1, y + 1, cells[2]);
    grid.set(x, y + 1, cells[3]);
    grid.set(x + 1, y + 1, cells[4]);
    grid.set(x + 1, y, cells[5]);
    grid.set(x + 1, y - 1, cells[6]);
    grid.set(x, y - 1, cells[7]);
    grid.rotate(x - 1, y, -1);
    grid.rotate(x, y - 1, -1);
    grid.rotate(x + 1, y, -1);
    grid.rotate(x, y + 1, -1);
  }
}

void gears(cells) {
  if (!grid.movable) return;
  if (cells.contains("gear_cw")) {
    grid.updateCell(
      (cell, x, y) {
        doGear(x, y, RotationalType.clockwise);
      },
      null,
      "gear_cw",
    );
  }
  if (cells.contains("gear_ccw")) {
    grid.updateCell(
      (cell, x, y) {
        doGear(x, y, RotationalType.counter_clockwise);
      },
      null,
      "gear_ccw",
    );
  }
  if (cells.contains("megagear_cw")) {
    grid.updateCell(
      (cell, x, y) {
        doMegagear(x, y, RotationalType.clockwise);
      },
      null,
      "megagear_cw",
    );
  }
  if (cells.contains("megagear_ccw")) {
    grid.updateCell(
      (cell, x, y) {
        doMegagear(x, y, RotationalType.counter_clockwise);
      },
      null,
      "megagear_ccw",
    );
  }
}
