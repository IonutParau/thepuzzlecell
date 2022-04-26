part of logic;

void liners() {
  if (!grid.movable) return;

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (push(x, y, cell.rot, 0)) {
          final bx = x + (cell.rot % 2 == 0 ? cell.rot - 1 : 0);
          final by = y + (cell.rot % 2 == 1 ? cell.rot - 2 : 0);
          pull(bx, by, cell.rot, 1);
        }
      },
      rot,
      "liner",
    );
  }
}

void doBringer(int x, int y, int dir) {
  doDriller(x, y, dir);
  grabSide(x, y, dir - 1, dir, 1);
  grabSide(x, y, dir + 1, dir, 1);
}
