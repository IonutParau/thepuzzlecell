part of logic;

void drillers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        cell.updated = true;
        doDriller(x, y, cell.rot);
      },
      rot,
      "driller",
    );
  }
}

bool doDriller(int x, int y, int dir) {
  if (!canMove(x, y, dir, 0, MoveType.mirror)) return false;
  if (!nudge(x, y, dir, mt: MoveType.mirror)) {
    final fx = frontX(x, dir);
    final fy = frontY(y, dir);
    final f = safeAt(fx, fy);
    if (f != null) {
      if (canMove(fx, fy, (dir + 2) % 4, 1, MoveType.mirror)) {
        swapCells(x, y, frontX(x, dir), frontY(y, dir));
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return true;
  }
}
