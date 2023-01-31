part of logic;

void grabbers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doGrabber(x, y, cell.rot);
      },
      rot,
      "grabber",
    );
    grid.updateCell(
      (cell, x, y) {
        doThief(x, y, cell.rot);
      },
      rot,
      "thief",
    );
  }
}

void doThief(int x, int y, int dir) {
  if (nudge(x, y, dir, mt: MoveType.grab)) {
    if (grabSide(x, y, dir - 1, dir)) {
      safeAt(
        frontX(x, dir) + frontX(0, (dir + 3) % 4),
        frontY(y, dir) + frontY(0, (dir + 3) % 4),
      )?.updated = true;
    }
    if (grabSide(x, y, dir + 1, dir)) {
      safeAt(
        frontX(x, dir) + frontX(0, (dir + 1) % 4),
        frontY(y, dir) + frontY(0, (dir + 1) % 4),
      )?.updated = true;
    }
  }
}

bool doGrabber(int x, int y, int dir) {
  if (nudge(x, y, dir, mt: MoveType.grab)) {
    grabSide(x, y, dir - 1, dir);
    grabSide(x, y, dir + 1, dir);
    return true;
  }
  return false;
}

bool hasGrabberBias(Cell cell, int x, int y, int dir, int mdir) {
  final odir = (dir + 2) % 4;

  if (cell.id == "mech_grabber" && (cell.rot == odir || cell.rot == dir))
    return MechanicalManager.on(cell, true);

  if (modded.contains(cell.id)) {
    return scriptingManager.hasGrabberBias(cell, x, y, dir, mdir);
  }

  return ["grabber", "axis", "bringer", "lofter", "conveyor"]
          .contains(cell.id) &&
      (cell.rot == odir || cell.rot == dir);
}

bool grabSide(int x, int y, int mdir, int dir) {
  mdir %= 4;
  final ox = x;
  final oy = y;
  var depth = 0;
  final depthLimit = dir % 2 == 0 ? grid.width : grid.height;
  while (grid.inside(x, y)) {
    if (depth > depthLimit) return depth > 0;
    if (ox != x || oy != y) {
      if (canMove(x, y, dir, 1, MoveType.grab)) {
        if (moveInsideOf(grid.at(x, y), x, y, dir, 1, MoveType.grab)) {
          break;
        } else {
          if (hasGrabberBias(grid.at(x, y), x, y, dir, mdir))
            grid.at(x, y).updated = true;
          if (!canMove(x, y, dir, 1, MoveType.grab)) break;
          final fx = frontX(x, dir);
          final fy = frontY(y, dir);
          if (!grid.inside(fx, fy)) break;
          if (moveInsideOf(grid.at(fx, fy), fx, fy, dir, 1, MoveType.grab)) {
            moveCell(x, y, fx, fy, dir, null, MoveType.grab);
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

  return depth > 0;
}
