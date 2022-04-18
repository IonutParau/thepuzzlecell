part of logic;

void bringers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doBringer(x, y, cell.rot);
      },
      rot,
      "bringer",
    );
  }
}
