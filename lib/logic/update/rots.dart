part of logic;

void rots(Set<String> cells) {
  if (cells.contains("rotator_cw")) {
    grid.updateCell(
      (cell, x, y) {
        if (!cell.tags.contains("anchored")) grid.rotate(x + 1, y, 1);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y + 1, 1);
        if (!cell.tags.contains("anchored")) grid.rotate(x - 1, y, 1);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y - 1, 1);
      },
      null,
      "rotator_cw",
    );
  }
  if (cells.contains("rotator_ccw")) {
    grid.updateCell(
      (cell, x, y) {
        if (!cell.tags.contains("anchored")) grid.rotate(x + 1, y, -1);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y + 1, -1);
        if (!cell.tags.contains("anchored")) grid.rotate(x - 1, y, -1);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y - 1, -1);
      },
      null,
      "rotator_ccw",
    );
  }
  if (cells.contains("opposite_rotator")) {
    grid.updateCell(
      (cell, x, y) {
        if (!cell.tags.contains("anchored")) grid.rotate(frontX(x, cell.rot), frontY(y, cell.rot), 1);
        if (!cell.tags.contains("anchored")) grid.rotate(frontX(x, cell.rot + 2), frontY(y, cell.rot + 2), -1);
      },
      null,
      "opposite_rotator",
    );
  }
  if (cells.contains("rotator_rand")) {
    final rng = Random();
    int randRot() => rng.nextBool() ? 1 : 3;
    grid.loopChunks(
      "rotator_rand",
      GridAlignment.bottomleft,
      (cell, x, y) {
        if (!cell.tags.contains("anchored")) grid.rotate(x + 1, y, randRot());
        if (!cell.tags.contains("anchored")) grid.rotate(x, y + 1, randRot());
        if (!cell.tags.contains("anchored")) grid.rotate(x - 1, y, randRot());
        if (!cell.tags.contains("anchored")) grid.rotate(x, y - 1, randRot());
      },
      filter: (cell, x, y) => cell.id == "rotator_rand" && !cell.updated,
    );
  }
  if (cells.contains("rotator_180")) {
    grid.updateCell(
      (cell, x, y) {
        if (!cell.tags.contains("anchored")) grid.rotate(x + 1, y, 2);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y + 1, 2);
        if (!cell.tags.contains("anchored")) grid.rotate(x - 1, y, 2);
        if (!cell.tags.contains("anchored")) grid.rotate(x, y - 1, 2);
      },
      null,
      "rotator_180",
    );
  }
  for (var rot in rotOrder) {
    if (cells.contains("redirector")) {
      grid.updateCell(
        (cell, x, y) {
          redirect(frontX(x, cell.rot), frontY(y, cell.rot), rot);
        },
        rot,
        "redirector",
      );
    }
    if (cells.contains("super_redirector")) {
      grid.updateCell(
        (cell, x, y) {
          redirect(x + 1, y, rot);
          redirect(x - 1, y, rot);
          redirect(x, y + 1, rot);
          redirect(x, y - 1, rot);
        },
        rot,
        "super_redirector",
      );
    }
  }
}

void redirect(int x, int y, int dir) {
  if (!grid.inside(x, y)) return;
  grid.rotate(x, y, (dir - grid.at(x, y).rot) % 4);
}
