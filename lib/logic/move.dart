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
}

int toSide(int dir, int rot) {
  return (dir - rot + 4) % 4;
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
      case "sticky":
        // Oh god
        if (mt == MoveType.push && (!cell.tags.contains("sticked"))) {
          cell.tags.add("sticked");
          final ix1 = frontX(x, cell.rot - 1);
          final iy1 = frontY(y, cell.rot - 1);
          final ix2 = frontX(x, cell.rot + 1);
          final iy2 = frontY(y, cell.rot + 1);
          bool successful = true;
          if (!canMoveAll(ix1, iy1, dir, force, mt)) {
            successful = false;
          }
          if (!canMoveAll(ix2, iy2, dir, force, mt)) {
            successful = false;
          }
          if (successful) {
            if (grid.inside(ix1, iy1) &&
                !grid.at(ix1, iy1).tags.contains("sticked")) {
              push(ix1, iy1, dir, force, mt);
            }
            if (grid.inside(ix2, iy2) &&
                !grid.at(ix2, iy2).tags.contains("sticked")) {
              push(ix2, iy2, dir, force, mt);
            }
            cell.tags.remove("sticked");
            return true;
          }
          cell.tags.remove("sticked");
          return false;
        }
        return true;
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
];

bool moveInsideOf(Cell into, int x, int y, int dir) {
  if (into.id == "enemy" && into.updated) return false;
  if (justMoveInsideOf.contains(into.id)) return true;

  return false;
}

bool canMoveAll(int x, int y, int dir, int force, MoveType mt) {
  var depth = 0;
  final depthLimit = dir % 2 == 0 ? grid.width : grid.height;
  while (grid.inside(x, y)) {
    if (depth > depthLimit) return false;
    depth++;
    if (canMove(x, y, dir, force, mt)) {
      if (moveInsideOf(grid.at(x, y), x, y, dir)) {
        return true;
      }

      force += addedForce(grid.at(x, y), dir, mt);
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

void moveCell(int ox, int oy, int nx, int ny, [int? dir, Cell? isMoving]) {
  final moving = isMoving ?? grid.at(ox, oy).copy;

  if (moving.id == "sync") {
    var dir = -1;
    if (ox < nx) dir = 0;
    if (oy < ny) dir = 1;
    if (ox > nx) dir = 2;
    if (oy > ny) dir = 3;

    doSync(ox, oy, dir, 0);
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

  if (movingTo.id != "trash" &&
      movingTo.id != "musical" &&
      movingTo.id != "wormhole" &&
      movingTo.id != "mech_trash" &&
      movingTo.id != "silent_trash") {
    if (movingTo.id == "enemy") {
      //grid.addBroken(moving, nx, ny);
      playSound(destroySound);
      grid.set(nx, ny, Cell(nx, ny));
      game.add(
        ParticleComponent(
          Particle.generate(
            count: 50,
            generator: (i) => AcceleratedParticle(
              position: Vector2(
                nx.toDouble() * cellSize.toDouble(),
                ny.toDouble() * cellSize.toDouble(),
              ),
              acceleration: randomVector2() * cellSize.toDouble() / 1.2,
              speed: randomVector2() * cellSize.toDouble() * 5,
              child: SpriteParticle(
                sprite: Sprite(Flame.images.fromCache("enemy_particles.png")),
                size: Vector2.all(cellSize / 10),
                lifespan: game.delay * 2,
              ),
            ),
          ),
        ),
      );
    } else {
      grid.set(nx, ny, moving);
    }
  } else {
    if (movingTo.id == "trash") {
      grid.addBroken(moving, nx, ny);
    } else if (movingTo.id == "silent_trash") {
      grid.addBroken(moving, nx, ny, "silent");
    } else if (movingTo.id == "mech_trash") {
      grid.addBroken(moving, nx, ny);
      MechanicalManager.spread(nx + 1, ny, 0);
      MechanicalManager.spread(nx - 1, ny, 2);
      MechanicalManager.spread(nx, ny + 1, 1);
      MechanicalManager.spread(nx, ny - 1, 3);
    } else if (movingTo.id == "wormhole") {
      if (grid.wrap) {
        final dx = grid.width - nx - 1;
        final dy = grid.height - ny - 1;

        if ((dx == nx && dy == ny) || (ox == nx && oy == ny)) return;

        final digging = grid.at(dx, dy);
        if (digging.id == "wormhole") return;
        if (dir != null) push(dx, dy, dir, 9999999999999);
        // If not empty attempt destruction
        if (grid.at(dx, dy).id != "empty") {
          moveCell(dx, dy, dx, dy);
          grid.addBroken(moving, nx, ny);
        }
        if (grid.at(dx, dy).id == "empty") {
          grid.set(dx, dy, moving);
        }
      } else if (!grid.wrap) {
        grid.addBroken(moving, nx, ny);
      }
    }
  }
  if (ox != nx || oy != ny) {
    grid.set(ox, oy, Cell(ox, oy));
  }
  //grid.grid[nx][ny].lastvars = grid.grid[ox][oy].lastvars.toVector2().toOffset();
}

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
];

final noForce = [];

int addedForce(Cell cell, int dir, MoveType mt) {
  final odir = (dir + 2) % 4; // Opposite direction
  if (["mech_mover", "mech_puller"].contains(cell.id)) {
    if (MechanicalManager.on(cell, true)) {
      if (cell.rot == dir) {
        cell.updated = true;
        //drawPower(cell);
        return 1;
      } else if (cell.rot == odir) {
        cell.updated = true;
        //drawPower(cell);
        return -1;
      }

      return 0;
    } else
      return 0;
  }
  if (withBias.contains(cell.id)) {
    if (cell.rot == dir) {
      cell.updated = true;
      return 1;
    } else if (cell.rot == odir) {
      cell.updated = true;
      return -1;
    }
    if (cell.id == "bird") {
      cell.updated = true;
    }
  }

  if (cell.id == "fast_mover" || cell.id == "fast_puller") {
    if (cell.rot == dir) {
      cell.updated = true;
      return 2;
    } else if (cell.rot == odir) {
      cell.updated = true;
      return -2;
    }
  }

  if (cell.id == "slow_mover" || cell.id == "slow_puller") {
    if (cell.lifespan % 2 == 0) {
      if (cell.rot == dir) {
        cell.updated = true;
        return 1;
      } else if (cell.rot == odir) {
        cell.updated = true;
        return -1;
      }
    }
  }

  if ((cell.id == "fan" ||
          (cell.id == "mech_fan" && MechanicalManager.on(cell, true))) &&
      cell.rot == odir &&
      mt == MoveType.push) {
    return -1;
  }

  return 0;
}

bool push(int x, int y, int dir, int force,
    [MoveType mt = MoveType.push, int depth = 0]) {
  if ((dir % 2 == 0 && depth > grid.width) ||
      (dir % 2 == 1 && depth > grid.height)) {
    return false;
  }
  dir %= 4;
  if (!grid.inside(x, y)) return false;
  var ox = x;
  var oy = y;

  if (dir == 0) {
    x++;
  } else if (dir == 2) {
    x--;
  } else if (dir == 1) {
    y++;
  } else if (dir == 3) {
    y--;
  }

  var c = grid.at(ox, oy);
  var addedRot = 0;
  if (moveInsideOf(c, ox, oy, dir)) return force > 0;
  if (!grid.inside(x, y)) return false;

  if (canMove(ox, oy, dir, force, mt)) {
    force += addedForce(c, dir, mt);
    if (force <= 0) return false;
    final mightMove = push(x, y, dir, force, mt, depth + 1);
    if (mightMove) {
      if (mt == MoveType.sync && c.id == "sync") {
        c.tags.add("sync move");
      }
      grid.at(ox, oy).rot = (grid.at(ox, oy).rot + addedRot) % 4;
      moveCell(ox, oy, x, y, dir);
    }
    return mightMove;
  } else {
    return false;
  }
}

bool pushDistance(int x, int y, int dir, int force, int distance,
    [MoveType mt = MoveType.push]) {
  final oforce = 0;
  final ox = x;
  final oy = y;
  while (distance > 0) {
    distance--;
    x -= (dir % 2 == 0 ? dir - 1 : 0);
    y -= (dir % 2 != 0 ? dir - 2 : 0);
    if (!grid.inside(x, y)) {
      return false;
    }

    if (mt != MoveType.grab) {
      final nc = walkBentPath(x, y, dir);
      if (nc.broken) return false;
      dir = nc.dir;
      x = nc.x;
      y = nc.y;
    }

    final c = grid.at(x, y);

    if (canMove(x, y, force, dir, mt)) {
      if (moveInsideOf(c, x, y, dir)) {
        break;
      }
      force += addedForce(c, dir, mt);
      if (force <= 0) return false;
    }
  }

  if ((!moveInsideOf(inFront(x, y, dir) ?? grid.at(x, y), x, y, dir)) &&
      !moveInsideOf(grid.at(x, y), x, y, dir)) {
    return false;
  }

  return push(ox, oy, dir, oforce + 1, mt);
}

bool pull(int x, int y, int dir, int force, [MoveType mt = MoveType.pull]) {
  if (!grid.inside(x, y)) return false;

  final ox = x;
  final oy = y;

  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (!moveInsideOf(grid.at(fx, fy), fx, fy, dir)) {
    return false;
  }

  // Check if movable
  var depth = 1;
  final depthLimit = 9999;
  var cx = x;
  var cy = y;
  while (true) {
    if (depth >= depthLimit) return false;
    cx += (dir % 2 == 0 ? (dir - 1) : 0);
    cy += (dir % 2 == 1 ? (dir - 2) : 0);
    if (!grid.inside(cx, cy)) break;
    final c = grid.at(cx, cy);
    if (moveInsideOf(c, cx, cy, dir)) break;
    force += addedForce(c, dir, mt);
    if (force <= 0) return false;
    if (!canMove(cx, cy, force, dir, mt)) {
      break;
    }
    depth++;
  }

  // Movement time
  cx = ox - (dir % 2 == 0 ? (dir - 1) : 0);
  cy = oy - (dir % 2 == 1 ? (dir - 2) : 0);
  var lastCX = cx;
  var lastCY = cy;
  while (depth > 0) {
    depth--; // I T E R A T I O N
    lastCX = cx;
    lastCY = cy;
    cx += (dir % 2 == 0 ? (dir - 1) : 0);
    cy += (dir % 2 == 1 ? (dir - 2) : 0);
    if (grid.inside(cx, cy)) {
      moveCell(cx, cy, lastCX, lastCY, dir);
    } else {
      break;
    }
  }

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
  for (var i = 0; i < speed; i++) {
    if (!pull(x, y, dir, force)) {
      return;
    }
    x = frontX(x, dir);
    y = frontY(y, dir);
  }
}

class BentPath {
  int x;
  int y;
  int dir;
  int addedRot;
  bool broken; // Broken means the path is useless

  BentPath(this.x, this.y, this.dir, this.addedRot, this.broken);
}

BentPath walkBentPath(int x, int y, int dir,
    [int addedRot = 0, int depth = 0]) {
  if (depth == 9999 || !grid.inside(x, y))
    return BentPath(x, y, dir, addedRot, true);

  final c = grid.at(x, y);
  final side = toSide(dir, c.rot);
  depth++;

  if (c.id == "curve") {
    if (side == 0) {
      addedRot += 3;
      dir = (dir + 1) % 4;
    } else if (side == 3) {
      addedRot++;
      dir = (dir + 3) % 4;
    }
    x = frontX(x, dir);
    y = frontY(y, dir);
    return walkBentPath(x, y, dir, addedRot, depth);
  } else {
    return BentPath(x, y, dir, addedRot, false);
  }
}
