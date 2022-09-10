part of logic;

void doLofter(int x, int y, int dir) {
  if (pull(x, y, dir, 0)) {
    grabSide(x, y, dir - 1, dir);
    grabSide(x, y, dir + 1, dir);
  }
}

void lofters() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doLofter(x, y, cell.rot);
      },
      rot,
      "lofter",
    );
  }
}
