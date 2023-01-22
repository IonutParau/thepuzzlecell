part of logic;

void doAntiGen(int x, int y, int dir, int gdir) {
  final addedRotation = (gdir - dir) % 4;

  final back = grid.get(frontX(x, dir, -1), frontY(y, dir, -1));
  if (back == null) return;

  final front = grid.get(frontX(x, gdir), frontY(y, gdir));
  if (front == null) return;

  if (front.id == back.id && (front.rot - addedRotation) % 4 == back.rot) {
    front.rot -= addedRotation;
    front.rot %= 4;
    grid.addBroken(front, x, y);
    grid.set(front.cx!, front.cy!, Cell(front.cx!, front.cy!));

    pull(frontX(x, gdir, 2), frontY(y, gdir, 2), (gdir + 2) % 4, 1);
  }
}

void antigens() {
  for (var rot in rotOrder) {
    grid.updateCell((cell, x, y) {
      doAntiGen(x, y, cell.rot, cell.rot);
    }, rot, "antigen");
  }
}
