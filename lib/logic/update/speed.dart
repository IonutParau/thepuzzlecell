part of logic;

void speeds() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (nudge(x, y, cell.rot)) {
          final fx = frontX(x, cell.rot);
          final fy = frontY(y, cell.rot);
          if (grid.inside(fx, fy)) {
            if (grid.at(fx, fy).id == "fast") {
              nudge(fx, fy, cell.rot);
            }
          }
        }
      },
      rot,
      "fast",
    );
    grid.updateCell(
      (cell, x, y) {
        nudge(x, y, cell.rot);
      },
      rot,
      "speed",
    );
    grid.updateCell(
      (cell, x, y) {
        cell.data['slow-toggled'] = !(cell.data['slow-toggled'] ?? false);
        if (cell.data['slow-toggled'] == true) {
          nudge(x, y, cell.rot);
        }
      },
      rot,
      "slow",
    );
  }
}
