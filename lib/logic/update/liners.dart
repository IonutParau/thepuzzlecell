part of logic;

void liners() {
  if (!grid.movable) return;

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (push(x, y, cell.rot, 0)) {
          pull(frontX(x, cell.rot, -1), frontY(y, cell.rot, -1), cell.rot, 1);
        }
      },
      rot,
      "liner",
    );
  }
}
