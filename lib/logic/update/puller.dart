part of logic;

void pullers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.loopChunks(
      "fast_puller",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        doSpeedPuller(x, y, rot, 2, 2);
      },
    );
    grid.loopChunks(
      "collector",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (pull(x, y, rot, 1)) {
          grid.at(x, y).updated = true;
        }
      },
    );
    grid.loopChunks(
      "puller",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        pull(x, y, rot, 1);
      },
    );
    grid.loopChunks(
      "slow_puller",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (cell.lifespan % 2 == 0) {
          pull(x, y, rot, 1);
        }
      },
    );
  }
}
