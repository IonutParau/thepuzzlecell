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

bool nudge(int x, int y, int rot, {MoveType mt = MoveType.unkown_move}) {
  if (!canMove(x, y, rot, 0, mt)) return false;
  final fx = frontX(x, rot);
  final fy = frontY(y, rot);
  if (grid.inside(fx, fy)) {
    if (moveInsideOf(grid.at(fx, fy), fx, fy, rot, mt)) {
      moveCell(x, y, fx, fy, rot, null, mt);
      return true;
    }
  }
  return false;
}
