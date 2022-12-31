part of logic;

void bringers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doDriller(x, y, cell.rot);
        grabSide(x, y, cell.rot - 1, cell.rot);
        grabSide(x, y, cell.rot + 1, cell.rot);
      },
      rot,
      "bringer",
    );
  }
}
