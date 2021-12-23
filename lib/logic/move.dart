part of logic;

enum MoveType {
  push,
  gear,
  mirror,
  pull,
  puzzle,
}

bool canMove(int x, int y, int dir, MoveType mt) {
  if (grid.inside(x, y)) {
    final cell = grid.at(x, y);
    final id = cell.id;
    final rot = cell.rot;

    switch (id) {
      case "slide":
        return (dir - rot) % 2 == 0;
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

final moveInsideOf = [
  "empty",
  "trash",
  "enemy",
  "musical",
  "wormhole",
];

bool canMoveAll(int x, int y, int dir, MoveType mt) {
  while (grid.inside(x, y)) {
    if (canMove(x, y, dir, mt)) {
      if (moveInsideOf.contains(grid.at(x, y).id)) {
        return true;
      }

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

void moveCell(int ox, int oy, int nx, int ny, [int? dir]) {
  final moving = grid.at(ox, oy);

  final movingTo = grid.at(nx, ny).copy;
  if (movingTo.id != "trash" &&
      movingTo.id != "musical" &&
      movingTo.id != "wormhole") {
    if (movingTo.id == "enemy") {
      destroySound.stop();
      destroySound.play();
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
      destroySound.stop();
      destroySound.play();
    } else if (movingTo.id == "wormhole") {
      if (grid.wrap) {
        final dx = grid.width - nx - 1;
        final dy = grid.height - ny - 1;

        if ((dx == nx && dy == ny) || (ox == nx && oy == ny)) return;

        final digging = grid.at(dx, dy);
        if (digging.id == "wormhole") return;
        if (dir != null) push(dx, dy, dir, 9999999999999);
        // if (digging.id != "empty") {
        //   destroySound.stop();
        //   destroySound.play();
        // }
        grid.set(dx, dy, moving);
      } else if (!grid.wrap) {
        destroySound.stop();
        destroySound.play();
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

bool push(int x, int y, int dir, int force,
    [MoveType mt = MoveType.push, int depth = 0]) {
  if ((dir % 2 == 0 && depth > grid.width) ||
      (dir % 2 == 1 && depth > grid.height)) {
    return false;
  }
  dir %= 4;
  if (!grid.inside(x, y)) return false;
  final ox = x;
  final oy = y;

  if (dir == 0) {
    x++;
  } else if (dir == 2) {
    x--;
  } else if (dir == 1) {
    y++;
  } else if (dir == 3) {
    y--;
  }

  final c = grid.at(ox, oy);
  if (moveInsideOf.contains(c.id)) return force > 0;
  if (!grid.inside(x, y)) return false;

  if (canMove(ox, oy, dir, mt)) {
    if (c.id == "mover" ||
        c.id == "puller" ||
        c.id == "bird" ||
        c.id == "releaser" ||
        c.id == "liner") {
      if (c.rot == dir) {
        c.updated = true;
        force++;
      } else if (c.rot == (dir + 2) % 4) {
        c.updated = true;
        force--;
      }
    }
    if (c.id == "bird") {
      c.updated = true;
    }
    if (force <= 0) return false;
    final mightMove = push(x, y, dir, force, mt, depth + 1);
    if (mightMove) moveCell(ox, oy, x, y, dir);
    return mightMove;
  } else {
    return false;
  }
}

bool pull(int x, int y, int dir, int force, [MoveType mt = MoveType.pull]) {
  if (!grid.inside(x, y)) return false;

  final ox = x;
  final oy = y;

  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (!moveInsideOf.contains(grid.at(fx, fy).id)) {
    return false;
  }

  // Check if movable
  var depth = 1;
  final depthLimit = (dir % 2 == 0 ? grid.width : grid.height);
  var cx = x;
  var cy = y;
  while (true) {
    if (depth >= depthLimit) return false;
    cx += (dir % 2 == 0 ? (dir - 1) : 0);
    cy += (dir % 2 == 1 ? (dir - 2) : 0);
    if (!grid.inside(cx, cy)) break;
    final c = grid.at(cx, cy);
    if (moveInsideOf.contains(c.id)) break;
    if (c.id == "mover" ||
        c.id == "puller" ||
        c.id == "bird" ||
        c.id == "releaser" ||
        c.id == "liner") {
      if (c.rot == dir) {
        c.updated = true;
        force++;
      } else if (c.rot == (dir + 2) % 4) {
        force--;
      }
    }
    if (force <= 0) return false;
    if (!canMove(cx, cy, dir, mt)) {
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
