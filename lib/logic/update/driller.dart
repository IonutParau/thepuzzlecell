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
  if (nudge(x, y, dir, mt: MoveType.mirror)) return true;
  final fx = frontX(x, dir);
  final fy = frontY(y, dir);
  if (safeAt(fx, fy) == null) return false;
  if (!canMove(fx, fy, (dir + 2) % 4, 1, MoveType.mirror)) return false;
  swapCells(x, y, frontX(x, dir), frontY(y, dir));
  return true;
}
