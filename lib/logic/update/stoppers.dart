part of logic;

void stoppers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        final fx = frontX(x, cell.rot);
        final fy = frontY(y, cell.rot);

        if (grid.inside(fx, fy)) {
          final cell = grid.at(fx, fy);
          if (!cell.id.contains("puzzle")) {
            cell.updated = true;
          }
        }
      },
      rot,
      "stopper",
    );
  }
}
