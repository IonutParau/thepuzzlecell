part of logic;

void doDartySide(int x, int y, int dir) {
  final cell = grid.at(x, y);
  final front = inFront(x, y, cell.rot);
  if (front != null) {
    if (moveInsideOf(
        front, frontX(x, dir), frontY(y, dir), dir, MoveType.push)) {
      moveFront(x, y, cell.rot);
    } else if (front.id != "darty") {
      grid.set(frontX(x, cell.rot), frontY(y, cell.rot), cell.copy);
      grid.rotate(x, y, 2);
    } else {
      if (!push(x, y, dir, 0)) {
        doDarty(grid.at(x, y), x, y, true);
      }
    }
  }
}

void doDarty(Cell cell, int x, int y, [bool forced = false]) {
  final order = [cell.rot, cell.rot - 1, cell.rot + 1, cell.rot + 2];
  for (var dir in order) {
    var canSide = true;
    if (forced) canSide = inFront(x, y, dir)?.id != "darty";
    if (canMoveInDir(x, y, dir % 4, MoveType.push, true) && canSide) {
      cell.rot = dir % 4;
      doDartySide(x, y, dir);
      return;
    }
  }
}

void dartys() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doDarty(cell, x, y);
      },
      rot,
      "darty",
    );
  }
}
