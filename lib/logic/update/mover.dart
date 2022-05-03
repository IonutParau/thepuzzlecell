part of logic;

void movers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.loopChunks(
      "fast_mover",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        doSpeedMover(x, y, cell.rot, 0, 2);
      },
      filter: (c, x, y) => c.id == "fast_mover" && c.rot == rot && !c.updated,
    );
    grid.loopChunks(
      "mover",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        push(x, y, cell.rot, 0);
      },
      filter: (c, x, y) => c.id == "mover" && c.rot == rot && !c.updated,
    );
    grid.loopChunks(
      "slow_mover",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (cell.lifespan % 2 == 0) {
          push(x, y, cell.rot, 0);
        }
      },
      filter: (c, x, y) => c.id == "slow_mover" && c.rot == rot && !c.updated,
    );
    grid.loopChunks(
      "releaser",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        final fx = x - ((rot % 2 == 0) ? (rot - 1) : 0);
        final fy = y - ((rot % 2 == 1) ? (rot - 2) : 0);
        if (!grid.inside(fx, fy)) return;
        final front = grid.at(fx, fy);
        front.updated = true;
        if (!push(x, y, rot, 0)) {
          front.updated = false;
        }
      },
      filter: (c, x, y) => c.id == "releaser" && c.rot == rot && !c.updated,
    );
  }
}
