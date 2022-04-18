part of logic;

void doSupGen(int x, int y, int dir, int gendir,
    [int offX = 0, int offY = 0, int preaddedRot = 0]) {
  dir %= 4;
  gendir %= 4;
  final toGen = <Cell>[];

  var addedRot = (dir - gendir + preaddedRot) % 4;
  while (addedRot < 0) addedRot += 4;

  gendir += 2;
  gendir %= 4;

  var sx = x;
  var sy = y;

  var d = 0;

  while (true) {
    d++;
    if (d == 10000) return;
    sx = frontX(sx, gendir);
    sy = frontY(sy, gendir);

    if (!grid.inside(sx, sy)) break;
    if (sx == x && sy == y) break;

    final snc = nextCell(sx, sy, gendir);
    if (snc.broken) break;
    sx = snc.x;
    sy = snc.y;
    gendir = snc.dir;
    addedRot -= snc.addedrot;
    addedRot %= 4;

    final s = grid.at(sx, sy);

    if (ungennable.contains(s.id)) break;
    if (s.tags.contains("gend $gendir")) break;
    final c = s.copy;
    c.tags.add("gend $gendir");
    c.lastvars = grid.at(x, y).lastvars.copy;
    c.lastvars.lastRot = s.lastvars.lastRot;
    toGen.add(c);
  }

  final fx = frontX(x, dir) + offX;
  final fy = frontY(y, dir) + offY;

  if (genOptimizer.shouldSkip(fx, fy, dir)) return;

  if (toGen.isNotEmpty) {
    for (var cell in toGen) {
      cell.updated = cell.updated ||
          shouldHaveGenBias(
            cell.id,
            toSide(dir, cell.rot),
          );
      cell.rot += addedRot;
      cell.rot %= 4;
      if (!push(fx, fy, dir, 1, replaceCell: cell)) {
        genOptimizer.skip(fx, fy, dir);
        return;
      }
    }
  }
}

void supgens() {
  genOptimizer.clear();
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, cell.rot, cell.rot);
      },
      rot,
      "supgen",
    );
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, (cell.rot + 1) % 4, cell.rot);
      },
      rot,
      "supgen_cw",
    );
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, (cell.rot + 3) % 4, cell.rot);
      },
      rot,
      "supgen_ccw",
    );
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, cell.rot, cell.rot);
        doSupGen(x, y, (cell.rot + 3) % 4, (cell.rot + 3) % 4);
      },
      rot,
      "cross_supgen",
    );
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, cell.rot + 3, cell.rot);
        doSupGen(x, y, cell.rot + 1, cell.rot);
      },
      rot,
      "double_supgen",
    );
    grid.updateCell(
      (cell, x, y) {
        doSupGen(x, y, cell.rot + 3, cell.rot);
        doSupGen(x, y, cell.rot, cell.rot);
        doSupGen(x, y, cell.rot + 1, cell.rot);
      },
      rot,
      "triple_supgen",
    );
    grid.updateCell(
      (cell, x, y) {
        final lx = frontX(0, cell.rot + 1);
        final ly = frontY(0, cell.rot + 1);

        final rx = frontX(0, cell.rot + 3);
        final ry = frontY(0, cell.rot + 3);
        doSupGen(x, y, cell.rot + 3, cell.rot);
        doSupGen(x, y, cell.rot, cell.rot, lx, ly);
        doSupGen(x, y, cell.rot, cell.rot);
        doSupGen(x, y, cell.rot, cell.rot, rx, ry);
        doSupGen(x, y, cell.rot + 1, cell.rot);
      },
      rot,
      "constructor_supgen",
    );
  }
}
