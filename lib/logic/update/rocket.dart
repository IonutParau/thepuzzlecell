part of logic;

void DoRocket(int x, int y, int dir, [int rot = 0]) {
  var bx = frontX(x, -dir);
  var by = frontY(y, -dir);

  if (!grid.inside(bx, by)) {
    push(x, y, dir, 0);
    return;
  }

  final back = grid.at(bx, by).copy;

  if (push(x, y, dir, 0)) {
    back.rot = (back.rot + rot) % 4;
    grid.set(bx, by, back);
  }
}

void rockets() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        DoRocket(x, y, cell.rot);
      },
      rot,
      "rocket",
    );
    grid.forEach(
      (cell, x, y) {
        DoRocket(x, y, cell.rot, 1);
      },
      rot,
      "rocket_cw",
    );
    grid.forEach(
      (cell, x, y) {
        DoRocket(x, y, cell.rot, 3);
      },
      rot,
      "rocket_ccw",
    );
  }
}
