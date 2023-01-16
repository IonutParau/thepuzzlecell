part of logic;

void doMirror(int x, int y, int dir) {
  if (dir == 0) {
    if (canMove(x + 1, y, 2, 1, MoveType.mirror) && canMove(x - 1, y, 0, 1, MoveType.mirror)) {
      swapCells(x + 1, y, x - 1, y);
    }
  } else {
    if (canMove(x, y + 1, 3, 1, MoveType.mirror) && canMove(x, y - 1, 1, 1, MoveType.mirror)) {
      swapCells(x, y - 1, x, y + 1);
    }
  }
}

void doSuperMirror(int x, int y, int dir) {
  final odir = dir + 2;

  var depth = 0;
  while (true) {
    depth++;
    if (depth == 9999) return;

    final x1 = x + frontX(0, dir) * depth;
    final y1 = y + frontY(0, dir) * depth;
    final x2 = x + frontX(0, odir) * depth;
    final y2 = y + frontY(0, odir) * depth;

    if (!grid.inside(x1, y1) || !grid.inside(x2, y2)) return;

    final c1 = grid.at(x1, y1);
    final c2 = grid.at(x2, y2);

    if (c1.id == "empty" && c2.id == "empty") return;

    if (!canMove(x1, y1, odir, 1, MoveType.mirror) || !canMove(x2, y2, dir, 1, MoveType.mirror)) return;
    swapCells(x1, y1, x2, y2);
  }
}

void mirrors() {
  for (var i in [0, 1]) {
    grid.loopChunks(
      "mirror",
      i == 0 ? GridAlignment.bottomleft : GridAlignment.bottomright,
      (cell, x, y) {
        doMirror(x, y, i);
      },
      filter: (c, x, y) => c.id == "mirror" && c.rot % 2 == i && !c.updated,
    );
    grid.loopChunks(
      "super_mirror",
      i == 0 ? GridAlignment.bottomleft : GridAlignment.bottomright,
      (cell, x, y) {
        if (cell.rot % 2 == i) doSuperMirror(x, y, i);
      },
      filter: (c, x, y) => c.id == "super_mirror" && c.rot % 2 == i && !c.updated,
    );
  }
}
