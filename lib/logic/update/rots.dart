part of logic;

void rots(Set<String> cells) {
  if (cells.contains("rotator_cw")) {
    grid.updateCell(
      (cell, x, y) {
        grid.rotate(
            frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), 1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
            frontY(cell.cy ?? y, cell.rot + 1), 1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
            frontY(cell.cy ?? y, cell.rot + 2), 1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
            frontY(cell.cy ?? y, cell.rot + 3), 1);
      },
      null,
      "rotator_cw",
    );
  }
  if (cells.contains("rotator_ccw")) {
    grid.updateCell(
      (cell, x, y) {
        grid.rotate(
            frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), -1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
            frontY(cell.cy ?? y, cell.rot + 1), -1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
            frontY(cell.cy ?? y, cell.rot + 2), -1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
            frontY(cell.cy ?? y, cell.rot + 3), -1);
      },
      null,
      "rotator_ccw",
    );
  }
  if (cells.contains("opposite_rotator")) {
    grid.updateCell(
      (cell, x, y) {
        grid.rotate(
            frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), 1);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
            frontY(cell.cy ?? y, cell.rot + 2), -1);
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
        grid.rotate(frontX(cell.cx ?? x, cell.rot),
            frontY(cell.cy ?? y, cell.rot), randRot());
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
            frontY(cell.cy ?? y, cell.rot + 1), randRot());
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
            frontY(cell.cy ?? y, cell.rot + 2), randRot());
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
            frontY(cell.cy ?? y, cell.rot + 3), randRot());
      },
      filter: (cell, x, y) => cell.id == "rotator_rand" && !cell.updated,
    );
  }
  if (cells.contains("rotator_180")) {
    grid.updateCell(
      (cell, x, y) {
        grid.rotate(
            frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), 2);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
            frontY(cell.cy ?? y, cell.rot + 1), 2);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
            frontY(cell.cy ?? y, cell.rot + 2), 2);
        grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
            frontY(cell.cy ?? y, cell.rot + 3), 2);
      },
      null,
      "rotator_180",
    );
  }
  for (var rot in rotOrder) {
    if (cells.contains("redirector")) {
      grid.updateCell(
        (cell, x, y) {
          final fx = frontX(x, cell.rot);
          final fy = frontY(y, cell.rot);
          if (grid.inside(fx, fy)) {
            redirect(grid.at(fx, fy), fx, fy, rot);
          }
        },
        rot,
        "redirector",
      );
    }
    if (cells.contains("super_redirector")) {
      grid.updateCell(
        (cell, x, y) {
          redirect(grid.get(x + 1, y) ?? Cell(x + 1, y), x + 1, y, rot);
          redirect(grid.get(x - 1, y) ?? Cell(x - 1, y), x - 1, y, rot);
          redirect(grid.get(x, y + 1) ?? Cell(x, y + 1), x, y + 1, rot);
          redirect(grid.get(x, y - 1) ?? Cell(x, y - 1), x, y - 1, rot);
        },
        rot,
        "super_redirector",
      );
    }
    if (cells.contains("configurable_redirector")) {
      grid.updateCell(
        (cell, x, y) {
          final confOrder = ["forward", "right", "backward", "left"];

          for (var r in rotOrder) {
            final fx = frontX(x, (rot + r) % 4);
            final fy = frontY(y, (rot + r) % 4);

            final off = (cell.data[confOrder[r]] as num).toInt();

            redirect(grid.get(fx, fy) ?? Cell(fx, fy), fx, fy, (rot + off) % 4);
          }
        },
        rot,
        "configurable_redirector",
      );
    }
  }
}

void redirect(Cell cell, int x, int y, int dir) {
  if (!grid.inside(x, y)) return;
  grid.rotate(x, y, (dir - cell.rot) % 4);
}
