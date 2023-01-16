part of logic;

void axis() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (push(x, y, cell.rot, 0)) {
          pull(frontX(x, cell.rot, -1), frontY(y, cell.rot, -1), cell.rot, 1);
          grabSide(x, y, cell.rot - 1, cell.rot);
          grabSide(x, y, cell.rot + 1, cell.rot);
        }
      },
      rot,
      "axis",
    );
  }
}
