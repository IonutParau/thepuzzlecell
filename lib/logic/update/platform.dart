part of logic;

void platforms() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (push(x, y, cell.rot, 0)) {
          grabSide(x, y, cell.rot - 1, cell.rot);
          grabSide(x, y, cell.rot + 1, cell.rot);
        }
      },
      rot,
      "platform",
    );
  }
}
