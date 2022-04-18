part of logic;

void doAxis(int x, int y, int dir) {
  if (push(x, y, dir, 0)) {
    final bx = x + (dir % 2 == 0 ? dir - 1 : 0);
    final by = y + (dir % 2 == 1 ? dir - 2 : 0);
    pull(bx, by, dir, 1);
    grabSide(x, y, dir - 1, dir, 1);
    grabSide(x, y, dir + 1, dir, 1);
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
