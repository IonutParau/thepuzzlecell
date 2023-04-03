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
      "bulldozer",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        push(x, y, cell.rot, 0);
      },
      filter: (c, x, y) => c.id == "bulldozer" && c.rot == rot && !c.updated,
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
      "mover_trash",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        push(x, y, cell.rot, 0);
      },
      filter: (c, x, y) => c.id == "mover_trash" && c.rot == rot && !c.updated,
    );
    grid.loopChunks(
      "mover_enemy",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        push(x, y, cell.rot, 0);
      },
      filter: (c, x, y) => c.id == "mover_enemy" && c.rot == rot && !c.updated,
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
  }
}
