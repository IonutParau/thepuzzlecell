part of logic;

void releasers() {
  for (var rot in rotOrder) {
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
        } else {
          front.tags.add('stopped');
        }
      },
      filter: (c, x, y) => c.id == "releaser" && c.rot == rot && !c.updated,
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (pull(x, y, rot, 0)) {
          grid.at(x, y).updated = true;
          grid.at(x, y).tags.add('stopped');
        }
      },
      rot,
      "collector",
    );
  }
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doThief(x, y, cell.rot);
      },
      rot,
      "thief",
    );
  }
}
