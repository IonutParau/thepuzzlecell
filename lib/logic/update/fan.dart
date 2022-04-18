part of logic;

void doFan(Cell cell, int x, int y) {
  final fx = frontX(x, cell.rot);
  final fy = frontY(y, cell.rot);

  if (grid.inside(fx, fy)) {
    push(fx, fy, cell.rot, 1);
  }
}

void doVacuum(Cell cell, int x, int y) {
  final front = inFront(x, y, cell.rot);

  if (front != null) {
    if (front.id == "empty") {
      pull(frontX(frontX(x, cell.rot), cell.rot),
          frontY(frontY(y, cell.rot), cell.rot), (cell.rot + 2) % 4, 1);
    }
  }
}

void fans() {
  for (var rot in rotOrder) {
    grid.updateCell(
      doFan,
      rot,
      "fan",
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      doVacuum,
      rot,
      "vacuum",
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      (c, x, y) {
        grabSide(x, y, c.rot - 1, c.rot, 0);
        grabSide(x, y, c.rot + 1, c.rot, 0);
      },
      rot,
      "conveyor",
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      (c, x, y) {
        doDriller(frontX(x, c.rot), frontY(y, c.rot), c.rot);
      },
      rot,
      "swapper",
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      (c, x, y) {
        nudge(frontX(x, c.rot), frontY(y, c.rot), c.rot);
      },
      rot,
      "nudger",
    );
  }
}
