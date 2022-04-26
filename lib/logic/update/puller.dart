part of logic;

void pullers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        doSpeedPuller(x, y, rot, 2, 2);
      },
      rot,
      "fast_puller",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (pull(x, y, rot, 1)) {
          grid.at(x, y).updated = true;
        }
      },
      rot,
      "collector",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        pull(x, y, rot, 1);
      },
      rot,
      "puller",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (cell.lifespan % 2 == 0) {
          pull(x, y, rot, 1);
        }
      },
      rot,
      "slow_puller",
    );
  }
}
