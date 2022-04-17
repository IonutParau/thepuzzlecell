part of logic;

bool shouldHaveGenBias(String id, int side) {
  if (CellTypeManager.generators.contains(id) ||
      CellTypeManager.replicators.contains(id) ||
      CellTypeManager.superGens.contains(id)) {
    if (id.contains("triple")) return (side == 0 || side == 3 || side == 1);
    if (id.contains("ccw")) return (side == 3);
    if (id.contains("cw")) return (side == 1);
    if (id == "constructorgen" ||
        id == "constructor_supgen" ||
        id == "quad_rep") return true;

    if (id.contains("double")) return (side == 1 || side == 3);

    if (id.contains("opposite")) return (side == 0 || side == 2);

    if (id.contains("cross")) return (side == 0 || side == 3);
  }

  return false;
}

class GenOptimizer {
  Map<String, bool> hasWorked = {};

  bool shouldSkip(int x, int y, int dir) {
    if (hasWorked["$x $y $dir"] == false) {
      return true;
    }

    return false;
  }

  void skip(int x, int y, int dir) {
    hasWorked["$x $y $dir"] = false;
  }

  void clear() {
    hasWorked.clear();
  }
}

final GenOptimizer genOptimizer = GenOptimizer();

void doGen(int x, int y, int dir, int gendir,
    [int? offX,
    int? offY,
    int preaddedRot = 0,
    bool physical = false,
    int lvxo = 0,
    int lvyo = 0]) {
  offX ??= 0;
  offY ??= 0;
  dir %= 4;
  gendir %= 4;

  final outputOff = fromDir(dir);
  var ox = x + outputOff.dx ~/ 1 + offX;
  var oy = y + outputOff.dy ~/ 1 + offY;

  if (genOptimizer.shouldSkip(ox, oy, dir) && !physical) {
    genOptimizer.skip(x, y, dir);
    //print("skip");
    return;
  }

  var addedRot = (dir - gendir + preaddedRot) % 4;
  final genOff = fromDir(gendir + 2);
  var gx = x + genOff.dx ~/ 1;
  var gy = y + genOff.dy ~/ 1;
  if (!grid.inside(gx, gy)) return;

  final gnc = nextCell(gx, gy, (gendir + 2) % 4);
  if (gnc.broken) return;
  gx = gnc.x;
  gy = gnc.y;
  //gendir = gnc.dir;
  addedRot -= gnc.addedrot;
  addedRot %= 4;

  final toGenerate = grid.at(gx, gy).copy;

  if (toGenerate.tags.contains("gend $gendir")) return;

  toGenerate.tags.add("gend $gendir");

  if (ungennable.contains(toGenerate.id)) {
    return;
  }

  final toGenLastrot = toGenerate.lastvars.lastRot;
  toGenerate.lastvars = grid.at(x, y).lastvars.copy;
  if (physical) {
    toGenerate.lastvars.lastPos -= fromDir(dir);
  }
  toGenerate.lastvars.lastRot = toGenLastrot;
  if (physical) {
    toGenerate.lastvars.lastPos += fromDir(gendir);
  }
  toGenerate.lastvars.lastPos = Offset(
    toGenerate.lastvars.lastPos.dx + lvxo,
    toGenerate.lastvars.lastPos.dy + lvyo,
  );
  toGenerate.rot += addedRot;
  toGenerate.rot %= 4;
  toGenerate.updated = toGenerate.updated ||
      shouldHaveGenBias(
        toGenerate.id,
        toSide(dir, toGenerate.rot),
      );

  if (push(ox, oy, dir, 1, replaceCell: toGenerate)) {
  } else {
    genOptimizer.skip(x, y, dir);
    if (physical) {
      final dx = frontX(0, dir);
      final dy = frontY(0, dir);

      ox -= dx;
      oy -= dy;

      // x += dx;
      // y += dy;

      gx -= dx;
      gy -= dy;
      if (push(x, y, (dir + 2) % 4, 1, replaceCell: toGenerate)) {}
    }
  }
}

void gens(Set cells) {
  if (!grid.movable) return;
  genOptimizer.clear();
  for (var rot in rotOrder) {
    if (cells.contains("generator")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot, rot);
        },
        rot,
        "generator",
      );
    }
    if (cells.contains("generator_cw")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot + 1, rot);
        },
        rot,
        "generator_cw",
      );
    }
    if (cells.contains("generator_ccw")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot - 1, rot);
        },
        rot,
        "generator_ccw",
      );
    }
    if (cells.contains("crossgen")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot - 1);
        },
        rot,
        "crossgen",
      );
    }
    if (cells.contains("doublegen")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
        },
        rot,
        "doublegen",
      );
    }
    if (cells.contains("triplegen")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
        },
        rot,
        "triplegen",
      );
    }
    if (cells.contains("constructorgen")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
          final forward = fromDir(cell.rot) / 3 * 2;
          final down = fromDir(cell.rot + 1);
          doGen(x, y, rot, rot, floor(forward.dx - down.dx),
              floor(forward.dy - down.dy));
          doGen(x, y, rot, rot, floor(forward.dx + down.dx),
              floor(forward.dy + down.dy));
        },
        rot,
        "constructorgen",
      );
    }
    if (cells.contains("physical_gen")) {
      grid.forEach(
        (cell, x, y) {
          doGen(x, y, rot, rot, null, null, 0, true);
        },
        rot,
        "physical_gen",
      );
    }
    grid.forEach(
      (cell, x, y) {
        doGen(
          x,
          y,
          rot + 1,
          rot,
          null,
          null,
          0,
          true,
          frontX(0, rot + 1) - frontX(0, rot),
          frontY(0, rot + 1) - frontY(0, rot),
        );
      },
      rot,
      "physical_gen_cw",
    );
    grid.forEach(
      (cell, x, y) {
        doGen(
          x,
          y,
          rot + 3,
          rot,
          null,
          null,
          0,
          true,
          frontX(0, rot + 3) - frontX(0, rot),
          frontY(0, rot + 3) - frontY(0, rot),
        );
      },
      rot,
      "physical_gen_ccw",
    );
  }
}
