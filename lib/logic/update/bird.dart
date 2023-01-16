part of logic;

void birds() {
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doBird(x, y, cell.rot);
      },
      rot,
      "bird",
    );

    grid.updateCell(
      (cell, x, y) {
        doHawk(x, y, cell.rot);
      },
      rot,
      "hawk",
    );

    grid.updateCell(
      (cell, x, y) {
        doPelican(x, y, cell.rot);
      },
      rot,
      "pelican",
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

void doHawk(int x, int y, int dir) {
  final force = 0;
  final c = grid.at(x, y); // Fix to a weird bug
  if (dir % 2 == 1) {
    if (!pull(x, y, dir, force + 1)) {
      c.rotate(1);
    }
  }

  final birdState = grid.tickCount % 4;

  switch (birdState) {
    case 0:
      if (!pull(x, y, dir, force)) {
        c.rotate(1);
      }
      break;
    case 1:
      pull(x, y, 1, force + 1);
      break;
    case 2:
      if (!pull(x, y, dir, force)) {
        c.rotate(1);
      }
      break;
    case 3:
      pull(x, y, 3, force + 1);
      break;
    default:
      break;
  }
}

void doPelican(int x, int y, int dir) {
  final c = grid.at(x, y); // Fix to a weird bug
  if (dir % 2 == 1) {
    if (!doGrabber(x, y, dir)) {
      c.rotate(1);
    }
  }

  final birdState = grid.tickCount % 4;

  switch (birdState) {
    case 0:
      if (!doGrabber(x, y, dir)) {
        c.rotate(1);
      }
      break;
    case 1:
      doGrabber(x, y, 1);
      break;
    case 2:
      if (!doGrabber(x, y, dir)) {
        c.rotate(1);
      }
      break;
    case 3:
      doGrabber(x, y, 3);
      break;
    default:
      break;
  }
}
