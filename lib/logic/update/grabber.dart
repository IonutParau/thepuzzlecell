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
    if (grabSide(x, y, dir - 1, dir, 2)) {
      safeAt(
        frontX(x, dir) + frontX(0, (dir + 3) % 4),
        frontY(y, dir) + frontY(0, (dir + 3) % 4),
      )?.updated = true;
    }
    if (grabSide(x, y, dir + 1, dir, 2)) {
      safeAt(
        frontX(x, dir) + frontX(0, (dir + 1) % 4),
        frontY(y, dir) + frontY(0, (dir + 1) % 4),
      )?.updated = true;
    }
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
            (f.id == "mech_grabber" && MechanicalManager.on(f, true)) ||
            f.id == "thief") &&
        (f.rot == dir)) {
      if (doGrabber(fx, fy, dir, rdepth + 1)) {
        depth++;
      } else {
        return false;
      }
    } else {
      if (!moveInsideOf(f, fx, fy, dir, MoveType.grab)) return false;
    }
  }
  push(x, y, dir, 1, mt: MoveType.grab);
  grabSide(x, y, dir - 1, dir, depth);
  grabSide(x, y, dir + 1, dir, depth);
  return true;
}

bool grabSide(int x, int y, int mdir, int dir, int checkDepth) {
  mdir %= 4;
  final ox = x;
  final oy = y;
  var depth = 0;
  final depthLimit = dir % 2 == 0 ? grid.width : grid.height;
  while (grid.inside(x, y)) {
    if (depth > depthLimit) return depth > 0;
    if (ox != x || oy != y) {
      if (canMove(x, y, dir, 1, MoveType.grab)) {
        if (moveInsideOf(grid.at(x, y), x, y, dir, MoveType.grab)) {
          break;
        } else {
          if ((grid.at(x, y).id == "grabber" ||
                  (grid.at(x, y).id == "mech_grabber" &&
                      MechanicalManager.onAt(x, y, true)) ||
                  grid.at(x, y).id == "axis" ||
                  grid.at(x, y).id == "bringer" ||
                  grid.at(x, y).id == "conveyor") &&
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

  return depth > 0;
}
