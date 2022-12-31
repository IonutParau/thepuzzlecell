part of logic;

void doAxis(int x, int y, int dir) {
  if (push(x, y, dir, 0)) {
    pull(frontX(x, cell.rot + 2), frontY(y, cell.rot + 2), dir, 1);
    grabSide(x, y, dir - 1, dir);
    grabSide(x, y, dir + 1, dir);
  }
}

void axis() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doAxis(x, y, cell.rot);
      },
      rot,
      "axis",
    );
  }
}
