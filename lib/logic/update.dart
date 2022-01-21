part of logic;

int floor(num n) => n.toInt();

final rotOrder = [0, 2, 3, 1];

var playerKeys = 0;
var puzzleWin = false;

void movers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        push(x, y, cell.rot, 0);
      },
      rot,
      "mover",
    );
  }
}

Offset fromDir(int dir) {
  dir += 4;
  dir %= 4;
  switch (dir) {
    case 0:
      return Offset(1, 0);
    case 2:
      return Offset(-1, 0);
    case 1:
      return Offset(0, 1);
    case 3:
      return Offset(0, -1);
    default:
      return Offset.zero;
  }
}

final ungennable = ["empty", "ghost"];

void doGen(int x, int y, int dir, int gendir,
    [int? offX, int? offY, int preaddedRot = 0, bool physical = false]) {
  offX ??= 0;
  offY ??= 0;
  dir %= 4;
  gendir %= 4;
  final addedRot = (dir - gendir + preaddedRot) % 4;
  final genOff = fromDir(gendir + 2);
  var gx = x + genOff.dx ~/ 1;
  var gy = y + genOff.dy ~/ 1;
  if (!grid.inside(gx, gy)) return;

  final toGenerate = grid.at(gx, gy).copy;

  if (toGenerate.tags.contains("gend $gendir")) return;

  toGenerate.tags.add("gend $gendir");

  if (ungennable.contains(toGenerate.id)) {
    return;
  }

  final outputOff = fromDir(dir);
  var ox = x + outputOff.dx ~/ 1 + offX;
  var oy = y + outputOff.dy ~/ 1 + offY;

  void gen() {
    if (!grid.inside(ox, oy)) return;
    if (!grid.inside(gx, gy)) return;
    if (!grid.inside(x, y)) return;
    final remaining = grid.at(ox, oy);
    if (moveInsideOf(remaining, ox, oy, dir) && remaining.id != "empty") {
      if (remaining.id == "wormhole") {
        moveCell(gx, gy, ox, oy, dir);
        grid.set(gx, gy, toGenerate);
      } else {
        if (remaining.id == "enemy") {
          moveCell(ox, oy, ox, oy);
        } else {
          grid.addBroken(toGenerate, ox, oy, x, y);
        }
      }
      return;
    }
    if (remaining.id == "empty") {
      final toGenLastrot = toGenerate.lastvars.lastRot;
      toGenerate.lastvars = grid.at(x, y).lastvars.copy;
      if (physical) {
        toGenerate.lastvars.lastPos -= fromDir(dir);
      }
      toGenerate.lastvars.lastRot = toGenLastrot;
      if (physical) {
        toGenerate.lastvars.lastPos += fromDir(gendir);
      }
      if (toGenerate.id.startsWith("generator") ||
          toGenerate.id.contains('gen') ||
          toGenerate.id.startsWith("replicator") ||
          toGenerate.id.contains("rep")) {
        if ((toGenerate.rot + addedRot) % 4 == dir) {
          toGenerate.updated = true;
        }
      }
      grid.set(ox, oy, toGenerate);
      grid.rotate(ox, oy, addedRot);
    }
  }

  if (push(ox, oy, dir, 1)) {
    gen();
  } else {
    if (physical) {
      if (push(x, y, (dir + 2) % 4, 1)) {
        final dx = frontX(0, dir);
        final dy = frontY(0, dir);

        ox -= dx;
        oy -= dy;

        // x += dx;
        // y += dy;

        gx -= dx;
        gy -= dy;

        gen();
      }
    }
  }
}

void gens(Set cells) {
  if (!grid.movable) return;
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
  }
}

enum RotationalType {
  clockwise,
  counter_clockwise,
}

void rots(Set<String> cells) {
  if (cells.contains("rotator_cw")) {
    grid.forEach(
      (cell, x, y) {
        grid.rotate(x + 1, y, 1);
        grid.rotate(x - 1, y, 1);
        grid.rotate(x, y + 1, 1);
        grid.rotate(x, y - 1, 1);
      },
      null,
      "rotator_cw",
    );
  }
  if (cells.contains("rotator_ccw")) {
    grid.forEach(
      (cell, x, y) {
        grid.rotate(x + 1, y, -1);
        grid.rotate(x - 1, y, -1);
        grid.rotate(x, y + 1, -1);
        grid.rotate(x, y - 1, -1);
      },
      null,
      "rotator_ccw",
    );
  }
  if (cells.contains("opposite_rotator")) {
    grid.forEach(
      (cell, x, y) {
        grid.rotate(frontX(x, cell.rot), frontY(y, cell.rot), 1);
        grid.rotate(frontX(x, cell.rot + 2), frontY(y, cell.rot + 2), -1);
      },
      null,
      "opposite_rotator",
    );
  }
}

void doGear(int x, int y, RotationalType rt) {
  if (rt == RotationalType.clockwise) {
    // If we are jammed, stop ourselves
    if (!canMoveAll(x + 1, y - 1, 0, MoveType.gear)) return;
    if (!canMove(x, y - 1, 0, MoveType.gear)) return;
    if (!canMoveAll(x + 1, y + 1, 1, MoveType.gear)) return;
    if (!canMove(x + 1, y, 1, MoveType.gear)) return;
    if (!canMoveAll(x - 1, y + 1, 2, MoveType.gear)) return;
    if (!canMove(x, y + 1, 2, MoveType.gear)) return;
    if (!canMoveAll(x - 1, y - 1, 3, MoveType.gear)) return;
    if (!canMove(x - 1, y, 3, MoveType.gear)) return;

    grid.rotate(x, y, 1); // Cool stuff

    // Moves corners
    push(x + 1, y - 1, 0, 1);
    push(x + 1, y + 1, 1, 1);
    push(x - 1, y + 1, 2, 1);
    push(x - 1, y - 1, 3, 1);

    // Save cells
    final cells = [];
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x + 1, y).copy);
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x - 1, y).copy);

    // Move cells
    grid.set(x - 1, y, cells[0]);
    grid.rotate(x - 1, y, 1);
    grid.set(x, y + 1, cells[1]);
    grid.rotate(x, y + 1, 1);
    grid.set(x + 1, y, cells[2]);
    grid.rotate(x + 1, y, 1);
    grid.set(x, y - 1, cells[3]);
    grid.rotate(x, y - 1, 1);
  } else if (rt == RotationalType.counter_clockwise) {
    // If we are jammed, stop ourselves
    if (!canMoveAll(x + 1, y - 1, 3, MoveType.gear)) return;
    if (!canMove(x, y - 1, 2, MoveType.gear)) return;
    if (!canMoveAll(x + 1, y + 1, 0, MoveType.gear)) return;
    if (!canMove(x + 1, y, 3, MoveType.gear)) return;
    if (!canMoveAll(x - 1, y + 1, 1, MoveType.gear)) return;
    if (!canMove(x, y + 1, 0, MoveType.gear)) return;
    if (!canMoveAll(x - 1, y - 1, 2, MoveType.gear)) return;
    if (!canMove(x - 1, y, 1, MoveType.gear)) return;

    grid.rotate(x, y, -1); // Cool stuff

    // Moves corners
    push(x + 1, y - 1, 3, 1);
    push(x + 1, y + 1, 0, 1);
    push(x - 1, y + 1, 1, 1);
    push(x - 1, y - 1, 2, 1);

    // Save cells
    final cells = [];
    cells.add(grid.at(x, y - 1).copy);
    cells.add(grid.at(x - 1, y).copy);
    cells.add(grid.at(x, y + 1).copy);
    cells.add(grid.at(x + 1, y).copy);

    // Move cells
    grid.set(x - 1, y, cells[0]);
    grid.rotate(x - 1, y, -1);
    grid.set(x, y + 1, cells[1]);
    grid.rotate(x, y + 1, -1);
    grid.set(x + 1, y, cells[2]);
    grid.rotate(x + 1, y, -1);
    grid.set(x, y - 1, cells[3]);
    grid.rotate(x, y - 1, -1);
  }
}

void gears(cells) {
  if (!grid.movable) return;
  if (cells.contains("gear_cw")) {
    grid.forEach(
      (cell, x, y) {
        doGear(x, y, RotationalType.clockwise);
      },
      null,
      "gear_cw",
    );
  }
  if (cells.contains("gear_ccw")) {
    grid.forEach(
      (cell, x, y) {
        doGear(x, y, RotationalType.counter_clockwise);
      },
      null,
      "gear_ccw",
    );
  }
}

void doMirror(int x, int y, int dir) {
  if (dir == 0) {
    if (canMove(x + 1, y, 2, MoveType.mirror) &&
        canMove(x - 1, y, 0, MoveType.mirror)) {
      // if (grid.at(x + 1, y).tags.contains("mirrored")) return;
      // if (grid.at(x - 1, y).tags.contains("mirrored")) return;
      if ((grid.at(x + 1, y).id == "mirror" &&
              grid.at(x + 1, y).rot % 2 == 0) ||
          (grid.at(x - 1, y).id == "mirror" &&
              grid.at(x - 1, y).rot % 2 == 0)) {
        return;
      }
      swapCells(x + 1, y, x - 1, y);
    }
  } else {
    if (canMove(x, y + 1, 3, MoveType.mirror) &&
        canMove(x, y - 1, 1, MoveType.mirror)) {
      // if (grid.at(x, y + 1).tags.contains("mirrored")) return;
      // if (grid.at(x, y - 1).tags.contains("mirrored")) return;
      if ((grid.at(x, y + 1).id == "mirror" &&
              grid.at(x, y + 1).rot % 2 == 1) ||
          (grid.at(x, y - 1).id == "mirror" &&
              grid.at(x, y - 1).rot % 2 == 1)) {
        return;
      }
      swapCells(x, y - 1, x, y + 1);
    }
  }
}

void mirrors() {
  for (var i in [0, 1]) {
    grid.forEach(
      (cell, x, y) {
        if ((cell.rot % 2) == i) {
          doMirror(x, y, i);
        } else if (i == 0) {
          cell.updated = false;
        }
      },
      null,
      "mirror",
    );
  }
}

void doBird(int x, int y, int dir) {
  final force = 0;
  if (dir % 2 == 1) {
    if (!push(x, y, dir, force + 1)) {
      grid.rotate(x, y, 1);
    }
  }

  final birdState = grid.tickCount % 4;

  switch (birdState) {
    case 0:
      if (!push(x, y, dir, force)) {
        grid.rotate(x, y, 1);
      }
      break;
    case 1:
      push(x, y, 1, force + 1);
      break;
    case 2:
      push(x, y, dir, force);
      if (!push(x, y, dir, force)) {
        grid.rotate(x, y, 1);
      }
      break;
    case 3:
      push(x, y, 3, force + 1);
      break;
    default:
      break;
  }
}

void birds() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doBird(x, y, cell.rot);
      },
      rot,
      "bird",
    );
  }
}

void doRep(int x, int y, int dir, int gendir, [int offX = 0, int offY = 0]) {
  doGen(x, y, dir, gendir + 2, offX, offY, 2);
}

void reps() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doRep(x, y, cell.rot, cell.rot);
      },
      rot,
      "replicator",
    );
  }
}

void pullers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        pull(x, y, rot, 1);
      },
      rot,
      "puller",
    );
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell, true)) {
          pull(x, y, cell.rot, 1);
        }
      },
      rot,
      "mech_mover",
    );
  }
}

void doPuzzleSide(int x, int y, int dir, Set<String> cells,
    [String type = "normal", int force = 1]) {
  dir %= 4;
  var ox = x;
  var oy = y;
  if (dir % 2 == 0) {
    ox -= dir - 1;
  } else {
    oy -= dir - 2;
  }
  if (!grid.inside(ox, oy)) return;

  final o = grid.at(ox, oy);
  if (o.id.endsWith("puzzle")) {
    if (o.rot == dir) {
      if (o.id == "trash_puzzle") type = "trash";
      force++;
      o.updated = true;
    } else if (o.rot == (dir + 2) % 4) {
      force--;
      o.updated = true;
    }
    if (force == 0) return;
    if (o.rot == dir || o.rot == (dir + 2) % 4) {
      doPuzzleSide(ox, oy, dir, cells, type, force);
    }
  }
  if (o.id == "key") {
    playerKeys++;
    grid.set(ox, oy, Cell(ox, oy));
  } else if (o.id == "lock") {
    if (playerKeys > 0) {
      playerKeys--;
      grid.set(ox, oy, Cell(ox, oy)..id = "unlock");
    }
  } else if (o.id == "flag") {
    if (!cells.contains("enemy")) {
      puzzleWin = true;
    }
  }

  if (push(x, y, dir, 1, MoveType.puzzle)) {
    // DO stuff
  } else {
    if (type == "trash") {
      moveCell(x, y, ox, oy);
    }
  }
}

void puzzles(Set<String> cells) {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (keys[PhysicalKeyboardKey.shiftLeft] == true) return;
        if (keys[PhysicalKeyboardKey.keyW] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells);
        } else if (keys[PhysicalKeyboardKey.keyS] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells);
        } else if (keys[PhysicalKeyboardKey.keyA] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells);
        } else if (keys[PhysicalKeyboardKey.keyD] == true) {
          doPuzzleSide(x, y, cell.rot, cells);
        }
      },
      rot,
      "puzzle",
    );
    grid.forEach(
      (cell, x, y) {
        if (keys[PhysicalKeyboardKey.shiftLeft] == true) return;
        if (keys[PhysicalKeyboardKey.keyW] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "trash");
        } else if (keys[PhysicalKeyboardKey.keyS] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "trash");
        } else if (keys[PhysicalKeyboardKey.keyA] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "trash");
        } else if (keys[PhysicalKeyboardKey.keyD] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "trash");
        }
      },
      rot,
      "trash_puzzle",
    );
    grid.forEach(
      (cell, x, y) {
        if (keys[PhysicalKeyboardKey.shiftLeft] != true) {
          if (keys[PhysicalKeyboardKey.keyW] == true) {
            cell.rot = 3;
          } else if (keys[PhysicalKeyboardKey.keyS] == true) {
            cell.rot = 1;
          } else if (keys[PhysicalKeyboardKey.keyA] == true) {
            cell.rot = 2;
          } else if (keys[PhysicalKeyboardKey.keyD] == true) {
            cell.rot = 0;
          }
        }
        doPuzzleSide(x, y, cell.rot, cells);
      },
      rot,
      "mover_puzzle",
    );
  }
}

void releasers() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        final fx = x - ((rot % 2 == 0) ? (rot - 1) : 0);
        final fy = y - ((rot % 2 == 1) ? (rot - 2) : 0);
        if (!grid.inside(fx, fy)) return;
        final front = grid.at(fx, fy);
        front.updated = true;
        if (!push(x, y, rot, 0)) {
          front.updated = false;
        }
      },
      rot,
      "releaser",
    );
  }
}

void doMagnet(int x, int y, int dir) {
  for (var i = 1; i < 3; i++) {
    final ox = x - (dir % 2 == 0 ? dir - 1 : 0) * i;
    final oy = y - (dir % 2 == 1 ? dir - 2 : 0) * i;
    if (!grid.inside(ox, oy)) return;
    final o = grid.at(ox, oy);
    if (o.id != "magnet" && o.id != "empty") return;
    if (o.id == "magnet" && (o.rot == dir || o.rot == (dir + 2) % 4)) {
      if (o.rot == dir) {
        if (i == 1) {
          o.updated = true;
          push(ox, oy, dir, 1);
          return;
        }
      } else {
        if (i == 2) {
          o.updated = true;
          push(ox, oy, dir + 2, 1);
          return;
        }
      }
    }
  }
}

void magnets() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "magnet") {
          cell.updated = true;
          doMagnet(x, y, cell.rot);
          doMagnet(x, y, cell.rot + 2);
        }
      },
      rot,
    );
  }
}

void diggers() {
  if (!grid.wrap) return;

  grid.forEach(
    (cell, x, y) {
      if (!cell.updated && cell.id == "digger") {
        cell.updated = true;

        final nX = grid.width - x - 1;
        final nY = grid.height - y - 1;

        moveCell(x, y, nX, nY);
      }
    },
  );
}

void liners() {
  if (!grid.movable) return;

  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (push(x, y, cell.rot, 0)) {
          final bx = x + (cell.rot % 2 == 0 ? cell.rot - 1 : 0);
          final by = y + (cell.rot % 2 == 1 ? cell.rot - 2 : 0);
          pull(bx, by, cell.rot, 1);
        }
      },
      rot,
      "liner",
    );
  }
}

void karls() {
  grid.forEach(
    (cell, x, y) {
      cell.updated = true;
      // print(cell.data['velX']);
      // print(cell.data['velY']);
      var velX = 0;
      var velY = 0;
      if (grid.inside(x - 1, y) && grid.inside(x + 1, y)) {
        if (grid.at(x - 1, y).id != "empty" && grid.at(x - 1, y).id != "wall")
          velX++;
        if (grid.at(x + 1, y).id == "wall") velX++; // Get to food dammit

        if (grid.at(x + 1, y).id != "empty" && grid.at(x + 1, y).id != "wall")
          velX--;
        if (grid.at(x - 1, y).id == "wall") velX--; // Get to food dammit
      }

      if (grid.inside(x, y - 1) && grid.inside(x, y + 1)) {
        if (grid.at(x, y - 1).id != "empty" && grid.at(x, y - 1).id != "wall")
          velY++;
        if (grid.at(x, y + 1).id == "wall") velY++; // Get to food dammit

        if (grid.at(x, y + 1).id != "empty" && grid.at(x, y + 1).id != "wall")
          velY--;
        if (grid.at(x, y - 1).id == "wall") velY--; // Get to food dammit
      }

      velX = clamp(velX, -1, 1).toInt();
      velY = clamp(velY, -1, 1).toInt();

      if (velX == 0 && velY == 0) {
        velX = cell.data['velX'] ?? 0;
        velY = cell.data['velY'] ?? 0;
      } else {
        cell.data['velX'] = velX;
        cell.data['velY'] = velY;
      }

      var fx = x + velX;
      var fy = y + velY;

      final vX = velX;
      final vY = velY;

      if (grid.inside(fx, fy)) {
        for (var i = 0; i < 3; i++) {
          fx = x + velX;
          fy = y + velY;
          if (grid.at(fx, fy).id == "wall") {
            grid.set(fx, fy, cell.copy);
            return;
          } else if (grid.at(fx, fy).id == "empty") {
            grid.set(fx, fy, cell.copy);
            grid.set(x, y, Cell(x, y));
            return;
          }
          if (i == 1) {
            velX = 0;
            velY = vY;
          }
          if (i == 2) {
            velX = vX;
            velY = 0;
          }
        }
      }
    },
    null,
    "karl",
  );
}

bool canMoveInDir(int x, int y, int dir, MoveType mt, [bool single = false]) {
  dir %= 4;
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (single) {
    return canMove(fx, fy, dir, mt);
  } else {
    return canMoveAll(fx, fy, dir, mt);
  }
}

Cell? inFront(int x, int y, int dir) {
  dir %= 4;
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return null;

  return grid.at(fx, fy);
}

void moveFront(int x, int y, int dir) {
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);
  if (!grid.inside(fx, fy)) return;

  moveCell(x, y, fx, fy, dir);
}

int frontX(int x, int dir) {
  dir %= 4;
  return x - (dir % 2 == 0 ? dir - 1 : 0);
}

int frontY(int y, int dir) {
  dir %= 4;
  return y - (dir % 2 == 1 ? dir - 2 : 0);
}

void doDartySide(int x, int y, int dir) {
  final cell = grid.at(x, y);
  final front = inFront(x, y, cell.rot);
  if (front != null) {
    if (moveInsideOf(front, frontX(x, dir), frontY(y, dir), dir)) {
      moveFront(x, y, cell.rot);
    } else if (front.id != "darty") {
      grid.set(frontX(x, cell.rot), frontY(y, cell.rot), cell.copy);
      grid.rotate(x, y, 2);
    } else {
      if (!push(x, y, dir, 0)) {
        doDarty(grid.at(x, y), x, y, true);
      }
    }
  }
}

void doDarty(Cell cell, int x, int y, [bool forced = false]) {
  final order = [cell.rot, cell.rot - 1, cell.rot + 1, cell.rot + 2];
  for (var dir in order) {
    var canSide = true;
    if (forced) canSide = inFront(x, y, dir)?.id != "darty";
    if (canMoveInDir(x, y, dir % 4, MoveType.push, true) && canSide) {
      cell.rot = dir % 4;
      doDartySide(x, y, dir);
      return;
    }
  }
}

void dartys() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doDarty(cell, x, y);
      },
      rot,
      "darty",
    );
  }
}

void grabSide(int x, int y, int mdir, int dir, int checkDepth) {
  mdir %= 4;
  final ox = x;
  final oy = y;
  var depth = 0;
  final depthLimit = dir % 2 == 0 ? grid.width : grid.height;
  while (grid.inside(x, y)) {
    if (depth > depthLimit) return;
    if (ox != x || oy != y) {
      if (canMove(x, y, dir, MoveType.grab)) {
        if (moveInsideOf(grid.at(x, y), x, y, dir)) {
          break;
        } else {
          if ((grid.at(x, y).id == "grabber" ||
                  (grid.at(x, y).id == "mech_grabber" &&
                      MechanicalManager.onAt(x, y, true))) &&
              grid.at(x, y).rot == dir) grid.at(x, y).updated = true;
          if (!pushDistance(x, y, dir, 1, checkDepth - 1, MoveType.grab)) {
            break;
          }
        }
      } else {
        break;
      }
    }
    depth++;

    x -= (mdir % 2 == 0 ? mdir - 1 : 0);
    y -= (mdir % 2 == 1 ? mdir - 2 : 0);
  }
}

bool doGrabber(int x, int y, int dir, [int rdepth = 0]) {
  grid.at(x, y).updated = true;
  if (rdepth > 9000) return false; // ITS OVER 9000!!!
  var fx = frontX(x, dir);
  var fy = frontY(y, dir);
  var depth = 0;
  if (grid.inside(fx, fy)) {
    final f = grid.at(fx, fy);
    if ((f.id == "grabber" ||
            (f.id == "mech_grabber" && MechanicalManager.on(f, true))) &&
        (f.rot == dir)) {
      if (doGrabber(fx, fy, dir, rdepth + 1)) {
        depth++;
      } else {
        return false;
      }
    } else {
      if (!moveInsideOf(f, fx, fy, dir)) return false;
    }
  }
  push(x, y, dir, 1, MoveType.grab);
  grabSide(x, y, dir - 1, dir, depth);
  grabSide(x, y, dir + 1, dir, depth);
  return true;
}

void grabbers() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doGrabber(x, y, cell.rot);
      },
      rot,
      "grabber",
    );
  }
}

void DoFan(Cell cell, int x, int y) {
  final fx = frontX(x, cell.rot);
  final fy = frontY(y, cell.rot);

  if (grid.inside(fx, fy)) {
    push(fx, fy, cell.rot, 1);
  }
}

void fans() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        DoFan(cell, x, y);
      },
      rot,
      "fan",
    );
  }
}

void doTunnel(int x, int y, int dir) {
  final fx = frontX(x, dir);
  final fy = frontY(y, dir);

  final bx = frontX(x, dir + 2);
  final by = frontY(y, dir + 2);

  if (grid.inside(fx, fy) && grid.inside(bx, by)) {
    if (!canMove(bx, by, dir, MoveType.tunnel)) {
      return;
    }

    final moving = grid.at(bx, by).copy;
    if (moving.id == "tunnel" && moving.rot == dir) {
      return;
    }
    if (ungennable.contains(moving.id)) return;
    if (moving.id == "empty") return;
    if (moving.tags.contains('tunneled')) return;

    if (push(fx, fy, dir, 1, MoveType.tunnel)) {
      moveCell(bx, by, fx, fy);
      grid.at(fx, fy).tags.add("tunneled");
    }
  }
}

void tunnels() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        doTunnel(x, y, cell.rot);
      },
      rot,
      "tunnel",
    );
  }
}

void mergePuzzle(int x, int y, int dir) {
  final fx = frontX(x, dir);
  final fy = frontY(y, dir);
  final bx = x - frontX(0, dir);
  final by = y - frontY(0, dir);

  if (!grid.inside(fx, fy)) return;
  if (!grid.inside(bx, by)) return;

  final o = grid.at(bx, by);
  final f = grid.at(fx, fy);

  if (f.id == "puzzle") {
    if (o.id == "trash") {
      f.id = "trash_puzzle";
      grid.setChunk(x, y, "trash_puzzle");
      o.id = "empty";
    } else if (o.id == "mover") {
      f.id = "mover_puzzle";
      grid.setChunk(x, y, "mover_puzzle");
      o.id = "empty";
    }
  }
}

void pmerges() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        mergePuzzle(x, y, cell.rot);
      },
      rot,
      "pmerge",
    );
  }
}

class MechanicalManager {
  static bool connectable(int? dir, Cell cell) {
    if (cell.id == "empty") return false;
    if (dir == null) return true;
    if (cell.id == "cross_mech_gear") return true;
    if (cell.id == "mech_grabber") return dir != (cell.rot + 2) % 4;
    if (cell.id.startsWith('mech_')) return true;
    return CellTypeManager.mechanical.contains(cell.id);
  }

  static void spread(int x, int y, [int depth = 0, int? sentDir]) {
    if (depth == 15) return;
    if (!grid.inside(x, y)) return;
    if (!connectable(sentDir, grid.at(x, y))) return;
    final cell = grid.at(x, y);
    if (onAt(x, y, true)) return;
    if (cell.id == "cross_mech_gear" && sentDir != null) {
      grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
      return spread(frontX(x, sentDir), frontY(y, sentDir), depth + 1, sentDir);
    }
    cell.data['power'] = 2;
    if (cell.id == "mech_gear" && depth < 14)
      grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
    if (cell.id == "mech_gear" && cell.updated) return;
    depth++;
    if (cell.id == "mech_gear") {
      if (sentDir != 2) {
        spread(x + 1, y, depth, 0);
      }
      if (sentDir != 0) {
        spread(x - 1, y, depth, 2);
      }
      if (sentDir != 3) {
        spread(x, y + 1, depth, 1);
      }
      if (sentDir != 1) {
        spread(x, y - 1, depth, 3);
      }
    }
  }

  static bool on(Cell cell, [bool freshly = false]) =>
      (cell.data['power'] ?? 0) > (freshly ? 1 : 0);

  static bool onAt(int x, int y, [bool freshly = false]) =>
      grid.inside(x, y) ? on(grid.at(x, y), freshly) : false;
}

void stoppers() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        final fx = frontX(x, cell.rot);
        final fy = frontY(y, cell.rot);

        if (grid.inside(fx, fy)) {
          final cell = grid.at(fx, fy);
          if (!cell.id.contains("puzzle")) {
            cell.updated = true;
          }
        }
      },
      rot,
      "stopper",
    );
  }
}

extension SetX on Set<String> {
  bool containsAny(List<String> strings) {
    for (var s in this) {
      if (strings.contains(s)) {
        return true;
      }
    }

    return false;
  }
}

class CellTypeManager {
  static List<String> movers = ["mover"];

  static List<String> puller = ["puller"];

  static List<String> grabbers = ["grabber"];

  static List<String> fans = ["fan"];

  static List<String> generators = [
    "generator",
    "generator_cw",
    "generator_ccw",
    "triple_gen",
    "crossgen",
    "constructorgen",
    "physical_gen",
  ];

  static List<String> replicators = ["replicator"];

  static List<String> tunnels = ["tunnel"];

  static List<String> rotators = [
    "rotator_cw",
    "rotator_ccw",
    "opposite_rotator"
  ];

  static List<String> gears = [
    "gear_cw",
    "gear_ccw",
  ];

  static List<String> puzzles = [
    "puzzle",
    "trash_puzzle",
    "mover_puzzle",
  ];

  static List<String> mechanical = [
    "mech_gen",
    "mech_mover",
    "pixel",
    "displayer",
    "mech_mover",
    "mech_puller",
    "mech_grabber",
    "mech_fan",
    "mech_generator",
    "mech_gear",
  ];

  static List<String> gates = [
    "and_gate",
    "or_gate",
    "xor_gate",
    "not_gate",
    "nand_gate",
    "nor_gate",
    "xnor_gate",
  ];
}

void doDisplayer(int x, int y, int dir) {
  var ox = x;
  var oy = y;
  var depth = 1;
  var depthing = true;
  while (true) {
    ox = frontX(ox, dir);
    oy = frontY(oy, dir);
    if (!grid.inside(ox, oy)) break;

    final o = grid.at(ox, oy);
    if (grid.placeable(ox, oy) && depthing) {
      depth++;
    } else {
      depthing = false;
    }
    if (o.id == "pixel") {
      depth--;
      if (depth == 0) {
        o.data['power'] = 2;
        break;
      }
    }
  }
}

void mechs(Set<String> cells) {
  // Power
  grid.forEach(
    (cell, x, y) {
      MechanicalManager.spread(
        frontX(
          x,
          cell.rot,
        ),
        frontY(
          y,
          cell.rot,
        ),
        0,
        cell.rot,
      );
    },
    null,
    "mech_gen",
  );

  // Powered
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell, true)) {
          push(x, y, cell.rot, 0);
        }
      },
      rot,
      "mech_mover",
    );
  }
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell, true)) {
          pull(x, y, cell.rot, 1);
        }
      },
      rot,
      "mech_puller",
    );
  }
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell, true)) {
          DoFan(cell, x, y);
        }
      },
      rot,
      "mech_fan",
    );
  }
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell, true)) {
          doGrabber(x, y, cell.rot);
        }
      },
      rot,
      "mech_grabber",
    );
  }

  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (MechanicalManager.on(cell)) {
          doDisplayer(x, y, cell.rot);
        }
      },
      rot,
      "displayer",
    );
  }

  // Power draw
  grid.forEach(
    (cell, x, y) {
      drawPower(cell);
    },
  );
}

void drawPower(Cell cell) {
  if (cell.data['power'] is int) {
    cell.data['power']--;
    if (cell.data['power'] == 0) {
      cell.data.remove('power');
    }
  }
}

void doSync(int x, int y, int movedir, int rot) {
  if (movedir != -1 && grid.at(x, y).tags.contains("sync move")) return;
  if (movedir != -1) {
    grid.at(x, y).tags.add("sync move");
  }
  if (rot != 0) {
    grid.at(x, y).tags.add("sync rot");
  }

  grid.forEach(
    (cell, x, y) {
      if ((!cell.tags.contains("sync move")) && movedir != -1) {
        push(x, y, movedir, 1, MoveType.sync);
      }
      if ((!cell.tags.contains("sync rot")) && rot != 0) {
        grid.rotate(x, y, rot);
      }
    },
    null,
    "sync",
  );
}

void speeds() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        final fx = frontX(x, cell.rot);
        final fy = frontY(y, cell.rot);
        if (moveInsideOf(grid.at(fx, fy), fx, fy, cell.rot)) {
          moveCell(x, y, fx, fy);
        }
      },
      rot,
      "speed",
    );
  }
}

enum GateType { AND, OR, XOR, NOT, NAND, NOR, XNOR }

void doGate(int x, int y, int rot, GateType gateType) {
  if (gateType == GateType.NOT) {
    final back = inFront(x, y, (rot + 2) % 4);
    if (back != null) {
      if (!MechanicalManager.on(back)) {
        MechanicalManager.spread(frontX(x, rot), frontY(y, rot), 0, rot);
      }
    }
  } else {
    final ic1 = inFront(x, y, rot - 1);
    final ic2 = inFront(x, y, rot + 1);

    final i1 = ic1 == null ? false : MechanicalManager.on(ic1);
    final i2 = ic2 == null ? false : MechanicalManager.on(ic2);

    void activate() {
      MechanicalManager.spread(frontX(x, rot), frontY(y, rot), 0, rot);
    }

    switch (gateType) {
      case GateType.AND:
        if (i1 && i2) activate();
        break;
      case GateType.OR:
        if (i1 || i2) activate();
        break;
      case GateType.XOR:
        if (i1 != i2) activate();
        break;
      case GateType.NAND:
        if (!(i1 && i2)) activate();
        break;
      case GateType.NOR:
        if (!(i1 || i2)) activate();
        break;
      case GateType.XNOR:
        if (i1 == i2) activate();
        break;
      default:
        break;
    }
  }
}

void gates(Set<String> cells) {
  for (var rot in rotOrder) {
    if (cells.contains("and_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.AND);
        },
        rot,
        "and_gate",
      );
    }
    if (cells.contains("or_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.OR);
        },
        rot,
        "or_gate",
      );
    }
    if (cells.contains("xor_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.XOR);
        },
        rot,
        "xor_gate",
      );
    }
    if (cells.contains("not_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NOT);
        },
        rot,
        "not_gate",
      );
    }
    if (cells.contains("nand_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NAND);
        },
        rot,
        "nand_gate",
      );
    }
    if (cells.contains("nor_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NOR);
        },
        rot,
        "nor_gate",
      );
    }
    if (cells.contains("xnor_gate")) {
      grid.forEach(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.XNOR);
        },
        rot,
        "xnor_gate",
      );
    }
  }
}
