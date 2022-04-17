part of logic;

void bringers() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doBringer(x, y, cell.rot);
      },
      rot,
      "bringer",
    );
  }
}
