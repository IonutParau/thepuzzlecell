part of logic;

void carriers() {
  if (!grid.movable) return;

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (doDriller(x, y, cell.rot)) {
          pull(frontX(x, cell.rot, -1), frontY(y, cell.rot, -1), cell.rot, 1);
        }
      },
      rot,
      "carrier",
    );
  }
}
