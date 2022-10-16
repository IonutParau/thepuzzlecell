part of logic;

enum MoveType {
  push,
  gear,
  mirror,
  pull,
  puzzle,
  grab,
  tunnel,
  sync,
  sticky_push,
  sticky_pull,
  unkown_move,
  transform,
  burn,
}

int toSide(int dir, int rot) {
  return (dir - rot + 4) % 4;
}

bool canMoveInDir(int x, int y, int dir, MoveType mt, [bool single = false]) {
  dir %= 4;
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (single) {
    return canMove(fx, fy, dir, 1, mt);
  } else {
    return canMoveAll(fx, fy, dir, 1, mt);
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

int frontX(int x, int dir, [int amount = 1]) {
  dir %= 4;
  return x - (dir % 2 == 0 ? dir - 1 : 0) * amount;
}

int frontY(int y, int dir, [int amount = 1]) {
  dir %= 4;
  return y - (dir % 2 == 1 ? dir - 2 : 0) * amount;
}

enum DestinationType { DIRECTIONAL, FIXED }

class DestinationInfo {
  DestinationType dt;
  int dir = 0;
  int x = 0;
  int y = 0;

  DestinationInfo.directional(this.dir) : dt = DestinationType.DIRECTIONAL;

  DestinationInfo.fixed(this.x, this.y) : dt = DestinationType.FIXED;
}

bool canMove(int x, int y, int dir, int force, MoveType mt) {
  if (grid.inside(x, y)) {
    final cell = grid.at(x, y);
    final id = cell.id;
    final rot = cell.rot;
    final side = toSide(dir, rot);

    switch (id) {
      case "pushable":
        return mt == MoveType.push;
      case "pullable":
        return mt == MoveType.pull;
      case "grabbable":
        return mt == MoveType.grab;
      case "swappable":
        return mt == MoveType.mirror;
      case "transformable":
        return mt == MoveType.transform;
      case "generatable":
        return false;
      case "propuzzle":
        return mt == MoveType.puzzle;
      case "untransformable":
        return mt != MoveType.transform;
      case "unpushable":
        return mt != MoveType.push;
      case "unpullable":
        return mt != MoveType.pull;
      case "ungrabbable":
        return mt != MoveType.grab;
      case "unswappable":
        return mt != MoveType.mirror;
      case "anchor":
        return mt != MoveType.gear;
      case "onedir":
        return side == 2;
      case "twodir":
        return side == 2 || side == 1;
      case "threedir":
        return side == 0 || side == 1 || side == 2;
      case "slide":
        return side == 0 || side == 2;
      case "mirror":
        return ((dir - rot) % 2 == 1 || mt != MoveType.puzzle);
      case "wall":
        return false;
      case "lock":
        return false;
      case "gear_cw":
        return mt != MoveType.gear;
      case "gear_ccw":
        return mt != MoveType.gear;
      case "ghost":
        return false;
      case "antipuzzle":
        return mt != MoveType.puzzle;
      default:
        return true;
    }
  }

  return false;
}

final justMoveInsideOf = [
  "empty",
  "trash",
  "enemy",
  "musical",
  "wormhole",
  "mech_trash",
  "silent_trash",
  "physical_enemy",
  "physical_trash",
  "hungry_trash",
  "time_trash",
  "time_reset",
  "portal_a",
  "portal_b",
].toSet().toList();

bool moveInsideOf(Cell into, int x, int y, int dir, int force, MoveType mt) {
  dir %= 4;
  if (enemies.contains(into.id) && into.tags.contains("stopped")) return false;
  if (into.id == "explosive") {
    return !(into.data['mobile'] ?? false);
  }
  if (into.id == "mech_p_trash" || into.id == "mech_enemy") {
    return MechanicalManager.on(into);
  }
  if (justMoveInsideOf.contains(into.id)) return true;

  final side = toSide(dir, into.rot);

  if (into.id == "semi_enemy" && !into.tags.contains("stopped")) {
    return side % 2 == 1;
  }

  if (into.id == "semi_trash") {
    return side % 2 == 1;
  }

  if (into.id == "push_trash") {
    return mt == MoveType.push;
  }
  if (into.id == "pull_trash") {
    return mt == MoveType.pull;
  }
  if (into.id == "grab_trash") {
    return mt == MoveType.grab;
  }
  if (into.id == "swap_trash") {
    return mt == MoveType.mirror;
  }
  if (into.id == "puzzle_trash") {
    return mt == MoveType.puzzle;
  }

  if (into.id == "trash_can") return (into.data['remaining'] ?? 10) > 0;

  if (trashes.contains(into.id) && !into.tags.contains("stopped")) return true;

  if (["forker", "forker_cw", "forker_ccw", "triple_forker", "double_forker"].contains(into.id)) {
    return (dir == into.rot);
  }

  return false;
}

bool canMoveAll(int x, int y, int dir, int force, MoveType mt) {
  var depth = 0;
  final depthLimit = dir % 2 == 0 ? grid.width : grid.height;
  while (grid.inside(x, y)) {
    if (depth > depthLimit) return false;
    depth++;
    if (canMove(x, y, dir, force, mt)) {
      if (moveInsideOf(grid.at(x, y), x, y, dir, force, mt)) {
        return true;
      }

      force += addedForce(grid.at(x, y), dir, force, mt);
      if (force <= 0) return false;

      if (dir == 0) {
        x++;
      } else if (dir == 2) {
        x--;
      } else if (dir == 1) {
        y++;
      } else if (dir == 3) {
        y--;
      }
    } else {
      return false;
    }
  }
  return false;
}

Vector2 randomVector2() {
  return (Vector2.random() - Vector2.all(0.5)) * 2;
}

final trashes = [
  "trash",
  "semi_trash",
  "trashcan",
  "silent_trash",
  "physical_trash",
  "hungry_trash",
  "mech_trash",
  "time_trash",
  "time_reset",
  "push_trash",
  "pull_trash",
  "grab_trash",
  "swap_trash",
  "gen_trash",
  "transform_trash",
  "puzzle_trash",
  "counter",
  "trash_can",
  "mech_p_trash",
];

final enemies = [
  "enemy",
  "semi_enemy",
  "silent_enemy",
  "physical_enemy",
  "explosive",
  "mech_enemy",
];

T debug<T>(T value) {
  print(value);
  return value;
}

final int enemyParticleCounts = 50;

void handleInside(int x, int y, int dir, int force, Cell moving, MoveType mt) {
  if (moving.id == "empty") return;
  final destroyer = grid.at(x, y);

  if (!moveInsideOf(destroyer, x, y, dir, force, mt)) return;

  if (destroyer.id == "wormhole") {
    if (grid.wrap) {
      final dx = grid.width - x - 1;
      final dy = grid.height - y - 1;

      if (dx == x && dy == y) return;

      final digging = grid.at(dx, dy);
      if (digging.id == "wormhole") return;
      QueueManager.add("post-move", () => push(dx, dy, dir, 9999999999999, replaceCell: moving));
      // If not empty attempt destruction
    } else {
      grid.addBroken(moving, x, y);
    }
  }

  if (destroyer.id == "portal_a") {
    var foundOutput = false;
    var outputX = 0;
    var outputY = 0;
    var closestDist = double.infinity;
    var extraRot = 0;

    grid.loopChunks("portal_b", GridAlignment.bottomright, (cell, cx, cy) {
      var dx = cx - x;
      var dy = cy - y;
      var d = dx * dx + dy * dy;

      if (closestDist > d) {
        closestDist = d.toDouble();
        outputX = cx;
        outputY = cy;
        foundOutput = true;

        extraRot = (cell.rot - destroyer.rot + 2) % 4;
      }
    }, shouldUpdate: false, filter: (cell, x, y) => cell.id == "portal_b");

    if (foundOutput) {
      final odir = (dir + extraRot) % 4;
      final fx = frontX(outputX, odir);
      final fy = frontY(outputY, odir);
      final sending = moving.copy;
      sending.rot += extraRot;
      sending.rot %= 4;

      if (grid.inside(fx, fy)) {
        QueueManager.add("post-move", () => push(fx, fy, odir, 1, replaceCell: sending));
      }
    }
    return;
  }

  if (destroyer.id == "portal_b") {
    var foundOutput = false;
    var outputX = 0;
    var outputY = 0;
    var closestDist = double.infinity;
    var extraRot = 0;

    grid.loopChunks("portal_a", GridAlignment.bottomright, (cell, cx, cy) {
      var dx = cx - x;
      var dy = cy - y;
      var d = dx * dx + dy * dy;

      if (closestDist > d) {
        closestDist = d.toDouble();
        outputX = cx;
        outputY = cy;
        foundOutput = true;

        extraRot = (cell.rot - destroyer.rot + 2) % 4;
      }
    }, shouldUpdate: false, filter: (cell, x, y) => cell.id == "portal_a");

    if (foundOutput) {
      final odir = (dir + extraRot) % 4;
      final fx = frontX(outputX, odir);
      final fy = frontY(outputY, odir);
      final sending = moving.copy;
      sending.rot += extraRot;
      sending.rot %= 4;

      if (grid.inside(fx, fy)) {
        QueueManager.add("post-move", () => push(fx, fy, odir, 1, replaceCell: sending));
      }
    }
    return;
  }

  if (destroyer.id == "forker") {
    grid.addBroken(moving, x, y);
    final r = destroyer.rot;
    QueueManager.add(
      "post-move",
      () => push(
        frontX(x, r),
        frontY(y, r),
        r,
        1,
        replaceCell: moving.copy,
      ),
    );
    return;
  }
  if (destroyer.id == "forker_cw") {
    grid.addBroken(moving, x, y);
    final r = destroyer.rot + 1;
    QueueManager.add(
      "post-move",
      () => push(
        frontX(x, r),
        frontY(y, r),
        r,
        1,
        replaceCell: moving.copy..rotate(1),
      ),
    );
    return;
  }
  if (destroyer.id == "forker_ccw") {
    grid.addBroken(moving, x, y);
    final r = destroyer.rot + 3;
    QueueManager.add(
      "post-move",
      () => push(
        frontX(x, r),
        frontY(y, r),
        r,
        1,
        replaceCell: moving.copy..rotate(3),
      ),
    );
    return;
  }
  if (destroyer.id == "double_forker") {
    grid.addBroken(moving, x, y);
    final r = destroyer.rot;
    push(
      frontX(x, r + 1),
      frontY(y, r + 1),
      r + 1,
      1,
      replaceCell: moving.copy..rotate(1),
    );
    push(
      frontX(x, r + 3),
      frontY(y, r + 3),
      r + 3,
      1,
      replaceCell: moving.copy..rotate(3),
    );
    QueueManager.add(
      "post-move",
      () {
        push(
          frontX(x, r + 1),
          frontY(y, r + 1),
          r + 1,
          1,
          replaceCell: moving.copy..rotate(1),
        );
        push(
          frontX(x, r + 3),
          frontY(y, r + 3),
          r + 3,
          1,
          replaceCell: moving.copy..rotate(3),
        );
      },
    );
    return;
  }
  if (destroyer.id == "triple_forker") {
    grid.addBroken(moving, x, y);
    final r = destroyer.rot;
    QueueManager.add("post-move", () {
      push(
        frontX(x, r),
        frontY(y, r),
        r,
        1,
        replaceCell: moving.copy,
      );
      push(
        frontX(x, r + 1),
        frontY(y, r + 1),
        r + 1,
        1,
        replaceCell: moving.copy..rotate(1),
      );
      push(
        frontX(x, r + 3),
        frontY(y, r + 3),
        r + 3,
        1,
        replaceCell: moving.copy..rotate(3),
      );
    });
    return;
  }

  if (trashes.contains(destroyer.id)) {
    // Trashes
    if (destroyer.id == "silent_trash") {
      grid.addBroken(moving, x, y, "silent");
    } else if (destroyer.id == "time_trash") {
      mustTimeTravel = true;
      destroyer.data = cellToData(moving);
      destroyer.data['time_travelled'] = true;
    } else if (destroyer.id == "time_reset") {
      mustTimeTravel = true;
    } else if (destroyer.id == "mech_trash") {
      grid.addBroken(moving, x, y, (destroyer.data['silent'] ?? false) ? "silent" : "normal");
      if ((destroyer.data['countdown'] ?? 0) > 0) {
        destroyer.data['countdown']--;
      } else {
        QueueManager.add("post-move", () {
          MechanicalManager.spread(x + 1, y, 0, false, 0);
          MechanicalManager.spread(x - 1, y, 0, false, 2);
          MechanicalManager.spread(x, y + 1, 0, false, 1);
          MechanicalManager.spread(x, y - 1, 0, false, 3);
        });
      }
    } else if (destroyer.id == "physical_trash") {
      grid.addBroken(moving, x, y);
      if (mt == MoveType.push) {
        push(frontX(x, dir), frontY(y, dir), dir, 1);
      }
    } else if (destroyer.id == "counter") {
      grid.addBroken(moving, x, y, (destroyer.data['silent'] ?? false) ? "silent" : "normal");
      var amount = 1;
      if (moving.id == "counter" || moving.id == "math_number") amount = (moving.data['count'] ?? 0);
      destroyer.data['count'] = (destroyer.data['count'] ?? 0) + amount;
    } else if (destroyer.id == "trash_can") {
      destroyer.data['remaining'] ??= 10;
      if (moving.id == "number" || moving.id == "counter") {
        destroyer.data['remaining'] -= (moving.data['count'] ?? 0);
      } else {
        destroyer.data['remaining']--;
      }
      grid.addBroken(moving, x, y, (destroyer.data['silent'] ?? false) ? "silent" : "normal");
    } else {
      final silent = destroyer.data['silent'] ?? false;
      grid.addBroken(moving, x, y, silent == true ? "silent" : "normal");
    }
  } else if (enemies.contains(destroyer.id)) {
    // Enemies
    if (destroyer.id == "physical_enemy") {
      grid.addBroken(destroyer, x, y, "shrinking");
      grid.addBroken(moving, x, y, "shrinking");
      grid.set(x, y, Cell(x, y));
      if (mt == MoveType.push) push(frontX(x, dir), frontY(y, dir), dir, 1);
      game.blueparticles.emit(enemyParticleCounts, x, y);
    } else if (destroyer.id == "explosive") {
      QueueManager.add("post-move", () => doExplosive(destroyer, x, y));
      grid.set(x, y, Cell(x, y));
      grid.addBroken(moving, x, y, "shrinking");
      game.yellowparticles.emit(enemyParticleCounts, x, y);
    } else {
      final silent = destroyer.data['silent'] ?? false;
      grid.addBroken(destroyer, x, y, silent == true ? "silent_shrinking" : "shrinking");
      grid.addBroken(moving, x, y, silent == true ? "silent_shrinking" : "shrinking");
      grid.set(x, y, Cell(x, y));
      game.redparticles.emit(enemyParticleCounts, x, y);
    }
  }
}

bool moveCell(int ox, int oy, int nx, int ny, [int? dir, Cell? isMoving, MoveType mt = MoveType.unkown_move, int force = 1]) {
  final moving = isMoving ?? grid.at(ox, oy).copy;

  if (dir == null) {
    dir = dirFromOff(nx - ox, ny - oy);
  }
  final movingTo = grid.at(nx, ny).copy;

  final cx = (nx + grid.width) % grid.width;
  final cy = (ny + grid.height) % grid.height;

  var nlx = moving.lastvars.lastPos.dx.toInt();
  var nly = moving.lastvars.lastPos.dy.toInt();

  if (ox == 0 && cx == grid.width - 1) {
    nlx = grid.width;
  } else if (ox == grid.width - 1 && cx == 0) {
    nlx = -1;
  }

  if (oy == 0 && cy == grid.height - 1) {
    nly = grid.height;
  } else if (oy == grid.height - 1 && cy == 0) {
    nly = -1;
  }

  moving.lastvars.lastPos = Offset(nlx.toDouble(), nly.toDouble());

  if (moveInsideOf(movingTo, nx, ny, dir, force, mt) && movingTo.id != "empty") {
    handleInside(nx, ny, dir, force, moving, mt);
    grid.set(ox, oy, Cell(ox, oy));
    QueueManager.runQueue("post-move");
    return true;
  } else {
    grid.set(nx, ny, moving);
  }

  if (acidic(moving, dir, force, mt, movingTo, nx, ny)) {
    if (movingTo.id != "empty") {
      handleAcid(moving, dir, force, mt, movingTo, nx, ny);
    }
  }

  if (ox != nx || oy != ny) {
    grid.set(ox, oy, Cell(ox, oy));
  }
  QueueManager.runQueue("post-move");
  return true;
}

bool wouldWrap(int x, int y) {
  return (((x + grid.width) % grid.width) != x || ((y + grid.height) % grid.height) != y);
}

int wrapX(int x) => (x + grid.width) % grid.width;
int wrapY(int y) => (y + grid.height) % grid.height;

void swapCells(int ox, int oy, int nx, int ny) {
  if (!grid.inside(ox, oy) || !grid.inside(nx, ny)) return;
  final cell1 = grid.at(ox, oy).copy;

  grid.set(ox, oy, grid.at(nx, ny));
  grid.set(nx, ny, cell1);
}

final withBias = [
  "mover",
  "puller",
  "liner",
  "releaser",
  "bird",
  "darty",
  "axis",
  "bringer",
  "collector",
  "thief",
  "hawk",
  "pelican",
  "mover_trash",
  "mover_enemy",
  "lofter",
];

int addedForce(Cell cell, int dir, int force, MoveType mt) {
  dir %= 4;
  if (cell.id == "weight") {
    return -1;
  }
  final odir = (dir + 2) % 4; // Opposite direction

  if (cell.id == "floppy") {
    if (dir == (cell.rot + 1) % 4) {
      return 1;
    } else if (odir == (cell.rot + 1) % 4) {
      return -1;
    } else {
      return 0;
    }
  }

  if (["mech_mover", "mech_puller"].contains(cell.id)) {
    if (MechanicalManager.on(cell, true)) {
      if (cell.rot == dir) {
        cell.updated = true;
        //drawPower(cell);
        return 1;
      } else if (cell.rot == odir) {
        //cell.updated = true;
        //drawPower(cell);
        return -1;
      }

      return 0;
    } else
      return 0;
  }

  if (cell.id == "bulldozer") {
    final bias = cell.data['bias'] ?? 1;

    if (cell.rot == dir) {
      return bias;
    } else if (cell.rot == odir) {
      return -bias;
    }
    return 0;
  }

  if (withBias.contains(cell.id)) {
    if (cell.rot == dir) {
      cell.updated = true;
      return 1;
    } else if (cell.rot == odir) {
      //cell.updated = true;
      return -1;
    }
    if (cell.id == "bird") {
      cell.updated = true;
    }
    if (cell.id == "hawk") {
      cell.updated = true;
    }
    if (cell.id == "pelican") {
      cell.updated = true;
    }
  }

  if (cell.id == "fast_mover" || cell.id == "fast_puller") {
    if (cell.rot == dir) {
      cell.updated = true;
      return 2;
    } else if (cell.rot == odir) {
      //cell.updated = true;
      return -2;
    }
  }

  if (cell.id == "slow_mover" || cell.id == "slow_puller") {
    if (cell.lifespan % 2 == 0) {
      if (cell.rot == dir) {
        cell.updated = true;
        return 1;
      } else if (cell.rot == odir) {
        //cell.updated = true;
        return -1;
      }
    }
  }

  if ((cell.id == "fan" || cell.id == "superfan" || cell.id == "airflow" || (cell.id == "mech_fan" && MechanicalManager.on(cell, true))) && cell.rot == odir && mt == MoveType.push) {
    return -1;
  }

  return 0;
}

// The term "acidic" comes from CelLua's "Acid" cell.
bool acidic(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int iy) {
  if (["mobile_trash", "mobile_enemy"].contains(cell.id)) {
    return true;
  }

  if (["mover_trash", "mover_enemy"].contains(cell.id) && cell.rot == dir) {
    return true;
  }

  if (cell.id == "explosive") {
    return cell.data['mobile'] ?? false;
  }

  return false;
}

void handleAcid(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int my) {
  if (cell.id == "mobile_trash" || cell.id == "mover_trash") {
    grid.addBroken(melting, mx, my);
    grid.set(mx, my, cell);
  }

  if (cell.id == "mobile_enemy" || cell.id == "mover_enemy" || cell.id == "explosive") {
    grid.addBroken(melting, mx, my, "shrinking");
    grid.addBroken(cell, mx, my, "shrinking");
    if (cell.id == "explosive") {
      QueueManager.add("post-move", () => doExplosive(cell, mx, my));
    }
    grid.set(mx, my, Cell(mx, my));
    game.yellowparticles.emit(enemyParticleCounts, mx, my);
  }
}

bool push(int x, int y, int dir, int force, {MoveType mt = MoveType.push, int depth = 0, Cell? replaceCell, bool shifted = false}) {
  replaceCell ??= Cell(x, y);
  if (!grid.inside(x, y)) return false;
  if (((dir % 2 == 0) && (depth > grid.width)) || ((dir % 2 == 1) && (depth > grid.height))) {
    return false;
  }
  dir %= 4;
  var ox = x;
  var oy = y;

  // final nc = nextCell(x, y, dir, true);
  // if (nc.broken) return false;
  // x = nc.x;
  // y = nc.y;
  // dir = nc.dir;
  var addedRot = 0; //nc.addedrot;
  x = frontX(x, dir);
  y = frontY(y, dir);

  var c = grid.at(ox, oy);

  if (c.id == "empty") {
    grid.set(ox, oy, replaceCell);
    return true;
  }
  if (moveInsideOf(c, ox, oy, dir, force, mt)) {
    handleInside(ox, oy, dir, force, replaceCell, mt);
    if (depth == 0) QueueManager.runQueue("post-move");
    return force > 0;
  }
  if (!grid.inside(x, y)) return false;
  if (canMove(ox, oy, dir, force, mt)) {
    if (acidic(replaceCell, dir, force, mt, c, ox, oy)) {
      if (c.id != "empty") {
        handleAcid(replaceCell, dir, force, mt, c, ox, oy);
      } else {
        grid.set(ox, oy, replaceCell);
      }
      return true;
    }
    force += addedForce(c, dir, force, mt);
    if (force <= 0) return false;
    final mightMove = push(x, y, dir, force, mt: mt, depth: depth + 1, replaceCell: c.copy);
    // If we have been modified, only allow the past one to move if we have been fully deleted
    final now = grid.at(ox, oy);
    if (c != now) {
      return now.id == "empty";
    }
    if (mightMove) {
      genOptimizer.remove(x, y);
      if (mt == MoveType.sync && c.id == "sync") {
        c.tags.add("sync move");
      }

      grid.at(ox, oy).rot = (grid.at(ox, oy).rot + addedRot) % 4;
      grid.set(ox, oy, replaceCell.copy);
      postmove(c, ox, oy, dir, force, mt);
    }
    if (depth == 0) QueueManager.runQueue("post-move");
    return mightMove;
  } else {
    if (depth == 0) QueueManager.runQueue("post-move");
    return false;
  }
}

bool pull(int x, int y, int dir, int force, [MoveType mt = MoveType.pull, bool shifted = false]) {
  if (!grid.inside(x, y)) return false;
  if (moveInsideOf(grid.at(x, y), x, y, dir, force, mt)) return true;
  if (!canMove(x, y, dir, force, mt)) return false;

  if (CellTypeManager.curves.contains(grid.at(x, y).id) && !shifted) {
    final nc = nextCell(x, y, (dir + 2) % 4);
    if (nc.broken) {
      return false;
    } else {
      return pull(nc.x, nc.y, (nc.dir + 2) % 4, force, mt, true);
    }
  }

  final ox = x;
  final oy = y;

  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (!moveInsideOf(grid.at(fx, fy), fx, fy, dir, force, mt)) {
    return false;
  }

  var cx = ox + frontX(0, dir);
  var cy = oy + frontY(0, dir);
  var odir = dir;
  var depth = 0;

  while (true) {
    depth++;
    if (depth == 9999) return false;
    cx -= frontX(0, dir);
    cy -= frontY(0, dir);
    if (!grid.inside(cx, cy)) break;
    final nc = nextCell(cx, cy, (dir + 2) % 4);
    if (nc.broken) break;
    cx = nc.x;
    cy = nc.y;
    dir = (nc.dir + 2) % 4;
    if (moveInsideOf(grid.at(cx, cy), cx, cy, dir, force, mt)) break;
    force += addedForce(grid.at(cx, cy), dir, force, mt);
    if (force <= 0) return false;
    final lastrot = grid.at(cx, cy).rot;
    grid.at(cx, cy).rot -= nc.addedrot;
    grid.at(cx, cy).rot %= 4;
    if (canMove(cx, cy, dir, force, mt)) {
      //moveCell(cx, cy, frontX(cx, dir), frontY(cy, dir), dir);
    } else {
      grid.at(cx, cy).rot = lastrot;
      break;
    }
  }

  cx = ox + frontX(0, dir);
  cy = oy + frontY(0, dir);
  depth = 0;
  dir = odir;

  while (true) {
    depth++;
    if (depth == 9999) break;
    cx -= frontX(0, dir);
    cy -= frontY(0, dir);
    final nc = nextCell(cx, cy, (dir + 2) % 4);
    if (nc.broken) break;
    cx = nc.x;
    cy = nc.y;
    dir = (nc.dir + 2) % 4;
    final addedrot = nc.addedrot;
    if (!grid.inside(cx, cy)) break;
    if (moveInsideOf(grid.at(cx, cy), cx, cy, dir, force, mt)) break;
    force += addedForce(grid.at(cx, cy), dir, force, mt);
    if (force <= 0) return false;
    if (canMove(cx, cy, dir, force, mt)) {
      grid.at(cx, cy).rot = (grid.at(cx, cy).rot - addedrot) % 4;
      moveCell(cx, cy, frontX(cx, dir), frontY(cy, dir), dir, null, mt);
    } else {
      break;
    }
  }

  return true;
}

bool nudge(int x, int y, int rot, {MoveType mt = MoveType.unkown_move}) {
  if (!canMove(x, y, rot, 0, mt)) return false;
  if (moveInsideOf(grid.at(x, y), x, y, rot, 1, mt)) return false;
  final fx = frontX(x, rot);
  final fy = frontY(y, rot);
  if (grid.inside(fx, fy)) {
    if (moveInsideOf(grid.at(fx, fy), fx, fy, rot, 1, mt)) {
      moveCell(x, y, fx, fy, rot, null, mt);
      return true;
    }
  }
  QueueManager.runQueue("post-move");
  return false;
}

void doSpeedMover(int x, int y, int dir, int force, int speed) {
  final o = grid.at(x, y).copy;
  for (var i = 0; i < speed; i++) {
    if (!grid.inside(x, y)) return;
    if (grid.at(x, y).id != o.id) {
      return;
    }
    if (!push(x, y, dir, force)) {
      return;
    }
    x = frontX(x, dir);
    y = frontY(y, dir);
  }
}

void doSpeedPuller(int x, int y, int dir, int force, int speed) {
  var cx = x;
  var cy = y;
  for (var i = 0; i < speed; i++) {
    if (!pull(cx, cy, dir, force)) {
      return;
    }
    cx = frontX(cx, dir);
    cy = frontY(cy, dir);
  }
}

class NextCell {
  int x;
  int y;
  bool broken;
  int dir;
  int addedrot;

  NextCell(this.x, this.y, this.dir, this.addedrot, this.broken);
}

NextCell nextCell(int x, int y, int dir, [bool skipFirst = false]) {
  var addedrot = 0;
  var depth = 0;

  if (skipFirst) {
    x = frontX(x, dir);
    y = frontY(y, dir);
  }

  while (true) {
    depth++;
    bool completed = true;
    if (depth > 9000 || !grid.inside(x, y)) {
      return NextCell(0, 0, 0, 0, true);
    }
    final c = grid.at(x, y);

    final side = toSide(dir, c.rot);
    if (CellTypeManager.curves.contains(c.id)) {
      if (c.id == "curve") {
        if (side == 0) {
          dir = (dir + 1) % 4;
          addedrot++;
          completed = false;
        } else if (side == 3) {
          dir = (dir + 3) % 4;
          addedrot += 3;
          completed = false;
        }
      }
    }
    if (completed) return NextCell(x, y, dir, addedrot, false);
    x = frontX(x, dir);
    y = frontY(y, dir);
  }
}

void premove(Cell cell, int x, int y, int dir, MoveType mt) {}

void postmove(Cell cell, int x, int y, int dir, int force, MoveType mt) {
  if (cell.id == "push_glue") {
    final lx = frontX(x, dir - 1);
    final ly = frontY(y, dir - 1);
    final rx = frontX(x, dir + 1);
    final ry = frontY(y, dir + 1);

    cell.tags.add("push_glued");

    if (safeAt(lx, ly)?.tags.contains("push_glued") == false) push(lx, ly, dir, force);
    if (safeAt(rx, ry)?.tags.contains("push_glued") == false) push(rx, ry, dir, force);
  }
}

void doExplosive(Cell destroyer, int x, int y, [bool silent = false]) {
  final radius = destroyer.data['radius'] ?? 1;
  final effectiveness = (destroyer.data['effectiveness'] ?? 100) / 100;
  final byproduct = destroyer.data['byproduct'] ?? "empty!0";
  final circular = destroyer.data['circular'] ?? false;
  final pseudoRandom = destroyer.data['pseudorandom'] ?? false;

  grid.addBroken(destroyer, x, y, silent ? "silent_shrinking" : "shrinking");

  // Grid index modulo height XOR'd with the tick count. Seems like a pretty good pseudo-random seed
  final prng = Random(((x + y * grid.width) % grid.height) ^ grid.tickCount);

  for (var cx = x - radius; cx <= x + radius; cx++) {
    for (var cy = y - radius; cy <= y + radius; cy++) {
      if (!grid.inside(cx.toInt(), cy.toInt())) return;

      final d = pow(cx - x, 2) + pow(cy - y, 2);
      final ox = cx - x;
      final oy = cy - y;

      final c = grid.at(cx.toInt(), cy.toInt());

      if (!breakable(c, cx.toInt(), cy.toInt(), dirFromOff(ox.toInt(), oy.toInt()), BreakType.explode)) {
        return;
      }
      if ((circular && d <= radius) || !circular || (cx == x && cy == y)) {
        grid.addBroken(c, x, y, "shrinking");
        var r = 0.0;

        if (pseudoRandom) {
          r = prng.nextDouble();
        } else {
          // Random
          r = rng.nextDouble();
        }

        if (r <= effectiveness || d == 0) {
          final id = parseJointCellStr(byproduct)[0];
          final rot = parseJointCellStr(byproduct)[1];
          // Confusing cascade operator stuffs
          final c = Cell(cx.toInt(), cy.toInt(), rot)
            ..id = id
            ..rot = rot;

          grid.set(cx.toInt(), cy.toInt(), c);
        }
      }
    }
  }
}
