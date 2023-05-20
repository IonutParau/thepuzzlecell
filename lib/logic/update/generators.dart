part of logic;

bool shouldHaveGenBias(String id, int side) {
  if (CellTypeManager.generators.contains(id) || CellTypeManager.replicators.contains(id) || CellTypeManager.superGens.contains(id) || CellTypeManager.memgens.contains(id)) {
    if (id == "quad_rep") return true;

    if (id.contains("opposite")) return (side == 0 || side == 2);

    if (id.contains("cross")) return (side == 0 || side == 3);

    if (id == "triple_rep") return (side == 2 || side == 1 || side == 3);

    return side == 0;
  }

  if (modded.contains(id)) {
    return scriptingManager.shouldHaveGenBias(id, side);
  }

  return false;
}

class GenOptimizer {
  bool shouldSkip(int x, int y, int dir) {
    if (!grid.inside(x, y)) return false;
    return grid.tiles[grid.x(x)][grid.y(y)].genOp[dir % 4];
  }

  void skip(int x, int y, int dir) {
    if (!grid.inside(x, y)) return;
    grid.tiles[grid.x(x)][grid.y(y)].opGen(dir);
  }

  void remove(int x, int y) {
    if (!grid.inside(x, y)) return;
    grid.tiles[grid.x(x)][grid.y(y)].deopGenAll();
  }

  void removeDir(int x, int y, int dir) {
    if (!grid.inside(x, y)) return;
    grid.tiles[grid.x(x)][grid.y(y)].deopGen(dir);
  }
}

final GenOptimizer genOptimizer = GenOptimizer();

void doGen(int x, int y, int dir, int gendir, [int? offX, int? offY, int preaddedRot = 0, bool physical = false, int lvxo = 0, int lvyo = 0, bool ignoreOptimization = false]) {
  offX ??= 0;
  offY ??= 0;
  dir %= 4;
  gendir %= 4;

  var ox = frontX(x, dir) + offX;
  var oy = frontY(y, dir) + offY;

  if (genOptimizer.shouldSkip(ox, oy, dir) && !physical && !ignoreOptimization) {
    genOptimizer.skip(x, y, dir);
    //print("skip");
    return;
  }

  var addedRot = (dir - gendir + preaddedRot) % 4;
  var gx = frontX(x, gendir, -1);
  var gy = frontY(y, gendir, -1);
  if (!grid.inside(gx, gy)) return;

  final toGenerate = grid.at(gx, gy).copy;

  if (toGenerate.tags.contains("gend $gendir")) return;

  toGenerate.tags.add("gend $gendir");

  if (isUngennable(toGenerate, gx, gy, gendir)) {
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
    genOptimizer.removeDir(x, y, dir);
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

void gens(Set<String> cells) {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    if (cells.contains("generator")) {
      grid.loopChunks(
        "generator",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot, rot);
        },
        filter: (cell, x, y) => cell.id == "generator" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("generator_cw")) {
      grid.loopChunks(
        "generator_cw",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot + 1, rot);
        },
        filter: (cell, x, y) => cell.id == "generator_cw" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("generator_ccw")) {
      grid.loopChunks(
        "generator_ccw",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot - 1, rot);
        },
        filter: (cell, x, y) => cell.id == "generator_ccw" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("crossgen")) {
      grid.loopChunks(
        "crossgen",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot - 1);
        },
        filter: (cell, x, y) => cell.id == "crossgen" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("doublegen")) {
      grid.loopChunks(
        "doublegen",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
        },
        filter: (cell, x, y) => cell.id == "doublegen" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("triplegen")) {
      grid.loopChunks(
        "triplegen",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
        },
        filter: (cell, x, y) => cell.id == "triplegen" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("constructorgen")) {
      grid.loopChunks(
        "constructorgen",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot, rot);
          doGen(x, y, rot - 1, rot);
          doGen(x, y, rot + 1, rot);
          final forward = fromDir(cell.rot) / 3 * 2;
          final down = fromDir(cell.rot + 1);
          doGen(x, y, rot, rot, floor(forward.dx - down.dx), floor(forward.dy - down.dy));
          doGen(x, y, rot, rot, floor(forward.dx + down.dx), floor(forward.dy + down.dy));
        },
        filter: (cell, x, y) => cell.id == "constructorgen" && cell.rot == rot && !cell.updated,
      );
    }
    if (cells.contains("physical_gen")) {
      grid.loopChunks(
        "physical_gen",
        fromRot(rot),
        (cell, x, y) {
          doGen(x, y, rot, rot, null, null, 0, true);
        },
        filter: (cell, x, y) => cell.id == "physical_gen" && cell.rot == rot && !cell.updated,
      );
    }
    grid.loopChunks(
      "physical_gen_cw",
      fromRot(rot),
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
      filter: (cell, x, y) => cell.id == "physical_gen_cw" && cell.rot == rot && !cell.updated,
    );
    grid.loopChunks(
      "physical_gen_ccw",
      fromRot(rot),
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
      filter: (cell, x, y) => cell.id == "physical_gen_ccw" && cell.rot == rot && !cell.updated,
    );
  }
}
