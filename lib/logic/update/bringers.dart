part of logic;

void bringers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doDriller(x, y, dir);
        grabSide(x, y, dir - 1, dir);
        grabSide(x, y, dir + 1, dir);
      },
      rot,
      "bringer",
    );
  }
}
