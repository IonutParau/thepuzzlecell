part of logic;

int floor(num n) => n.toInt();

final rotOrder = [0, 3, 2, 1];

var playerKeys = 0;
var puzzleWin = false;

void movers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "mover") {
          cell.updated = true;
          push(x, y, cell.rot, 0);
        }
      },
      rot,
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
    [int? offX, int? offY, int preaddedRot = 0]) {
  offX ??= 0;
  offY ??= 0;
  dir %= 4;
  gendir %= 4;
  final addedRot = (dir - gendir + preaddedRot) % 4;
  final genOff = fromDir(gendir + 2);
  final gx = x + genOff.dx ~/ 1;
  final gy = y + genOff.dy ~/ 1;
  if (!grid.inside(gx, gy)) return;

  final toGenerate = grid.at(gx, gy).copy;

  if (ungennable.contains(toGenerate.id)) {
    return;
  }

  final outputOff = fromDir(dir);
  final ox = x + outputOff.dx ~/ 1 + offX;
  final oy = y + outputOff.dy ~/ 1 + offY;

  if (push(ox, oy, dir, 1)) {
    final remaining = grid.at(ox, oy);
    if (moveInsideOf.contains(remaining.id) && remaining.id != "empty") {
      if (remaining.id == "wormhole") {
        moveCell(gx, gy, ox, oy, dir);
        grid.set(gx, gy, toGenerate);
      } else {
        moveCell(ox, oy, ox, oy);
      }
      return;
    }
    if (remaining.id == "empty") {
      final toGenLastrot = toGenerate.lastvars.lastRot;
      toGenerate.lastvars = grid.at(x, y).lastvars.copy;
      toGenerate.lastvars.lastRot = toGenLastrot;
      if (toGenerate.id.startsWith("generator") ||
          toGenerate.id.contains('gen') ||
          toGenerate.id.startsWith("replicator") ||
          toGenerate.id.contains("rep")) {
        toGenerate.updated = true;
      }
      grid.set(ox, oy, toGenerate);
      grid.rotate(ox, oy, addedRot);
    }
  }
}

void gens(Set cells) {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    if (cells.contains("generator")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "generator") {
            cell.updated = true;
            doGen(x, y, rot, rot);
          }
        },
        rot,
      );
    }
    if (cells.contains("generator_cw")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "generator_cw") {
            cell.updated = true;
            doGen(x, y, rot + 1, rot);
          }
        },
        rot,
      );
    }
    if (cells.contains("generator_ccw")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "generator_ccw") {
            cell.updated = true;
            doGen(x, y, rot - 1, rot);
          }
        },
        rot,
      );
    }
    if (cells.contains("crossgen")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "crossgen") {
            cell.updated = true;
            doGen(x, y, rot, rot);
            doGen(x, y, rot - 1, rot - 1);
          }
        },
        rot,
      );
    }
    if (cells.contains("triplegen")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "triplegen") {
            cell.updated = true;
            doGen(x, y, rot, rot);
            doGen(x, y, rot - 1, rot);
            doGen(x, y, rot + 1, rot);
          }
        },
        rot,
      );
    }
    if (cells.contains("constructorgen")) {
      grid.forEach(
        (cell, x, y) {
          if (!cell.updated && cell.id == "constructorgen") {
            cell.updated = true;
            doGen(x, y, rot, rot);
            doGen(x, y, rot - 1, rot);
            doGen(x, y, rot + 1, rot);
            final forward = fromDir(cell.rot) / 3 * 2;
            final up = fromDir(cell.rot + 3);
            final down = fromDir(cell.rot + 1);
            doGen(x, y, rot, rot, floor(forward.dx - down.dx),
                floor(forward.dy - down.dy));
            doGen(x, y, rot, rot, floor(forward.dx + down.dx),
                floor(forward.dy + down.dy));
          }
        },
        rot,
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
        if (!cell.updated && cell.id == "rotator_cw") {
          cell.updated = true;
          grid.rotate(x + 1, y, 1);
          grid.rotate(x - 1, y, 1);
          grid.rotate(x, y + 1, 1);
          grid.rotate(x, y - 1, 1);
        }
      },
    );
  }
  if (cells.contains("rotator_ccw")) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "rotator_ccw") {
          cell.updated = true;
          grid.rotate(x + 1, y, -1);
          grid.rotate(x - 1, y, -1);
          grid.rotate(x, y + 1, -1);
          grid.rotate(x, y - 1, -1);
        }
      },
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
        if (!cell.updated && cell.id == "gear_cw") {
          doGear(x, y, RotationalType.clockwise);
        }
      },
    );
  }
  if (cells.contains("gear_ccw")) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "gear_ccw") {
          cell.updated = true;
          doGear(x, y, RotationalType.counter_clockwise);
        }
      },
    );
  }
}

void doMirror(int x, int y, int dir) {
  if (dir == 0) {
    if (canMove(x + 1, y, 2, MoveType.mirror) &&
        canMove(x - 1, y, 0, MoveType.mirror)) {
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
  grid.forEach(
    (cell, x, y) {
      if (!cell.updated && cell.id == "mirror") {
        cell.updated = true;
        doMirror(x, y, cell.rot % 2);
      }
    },
  );
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
        if (!cell.updated && cell.id == "bird") {
          cell.updated = true;
          doBird(x, y, cell.rot);
        }
      },
      rot,
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
        if (!cell.updated && cell.id == "replicator") {
          cell.updated = true;
          doRep(x, y, cell.rot, cell.rot);
        }
      },
      rot,
    );
  }
}

void pullers() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "puller") {
          cell.updated = true;
          pull(x, y, rot, 1);
        }
      },
      rot,
    );
  }
}

void doPuzzleSide(int x, int y, int dir, Set<String> cells) {
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
  push(x, y, dir, 1, MoveType.puzzle);
}

void puzzles(Set<String> cells) {
  grid.forEach(
    (cell, x, y) {
      if (!cell.updated && cell.id == "puzzle") {
        cell.updated = true;
        if (keys[LogicalKeyboardKey.controlLeft] == true) return;
        if (keys[LogicalKeyboardKey.keyW] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells);
        } else if (keys[LogicalKeyboardKey.keyS] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells);
        } else if (keys[LogicalKeyboardKey.keyA] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells);
        } else if (keys[LogicalKeyboardKey.keyD] == true) {
          doPuzzleSide(x, y, cell.rot, cells);
        }
      }
    },
  );
}

void releasers() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if ((!cell.updated) && cell.id == "releaser") {
          cell.updated = true;
          final fx = x - ((rot % 2 == 0) ? (rot - 1) : 0);
          final fy = y - ((rot % 2 == 1) ? (rot - 2) : 0);
          if (!grid.inside(fx, fy)) return;
          final front = grid.at(fx, fy);
          front.updated = true;
          if (!push(x, y, rot, 0)) {
            front.updated = false;
          }
        }
      },
      rot,
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
        if (!cell.updated && cell.id == "liner") {
          cell.updated = true;
          if (push(x, y, cell.rot, 0)) {
            final bx = x + (cell.rot % 2 == 0 ? cell.rot - 1 : 0);
            final by = y + (cell.rot % 2 == 1 ? cell.rot - 2 : 0);
            pull(bx, by, cell.rot, 1);
          }
        }
      },
      rot,
    );
  }
}

void karls() {
  grid.forEach(
    (cell, x, y) {
      if (!cell.updated && cell.id == "karl") {
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
      }
    },
  );
}
