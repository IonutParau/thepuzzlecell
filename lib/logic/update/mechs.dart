part of logic;

void mechs(Set<String> cells) {
  // Power
  for (var rot in rotOrder) {
    grid.loopChunks(
      "mech_gen",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
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
          false,
          cell.rot,
        );
      },
      filter: (c, x, y) => c.id == "mech_gen" && c.rot == rot && !c.updated,
    );
  }

  if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
    grid.loopChunks(
      "mech_keyup",
      GridAlignment.BOTTOMLEFT,
      (cell, x, y) {
        MechanicalManager.spread(x - 1, y);
        MechanicalManager.spread(x + 1, y);
        MechanicalManager.spread(x, y - 1);
        MechanicalManager.spread(x, y + 1);
      },
      filter: (cell, x, y) => cell.id == "mech_keyup" && !cell.updated,
    );
  }

  if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
    grid.loopChunks(
      "mech_keyleft",
      GridAlignment.BOTTOMLEFT,
      (cell, x, y) {
        MechanicalManager.spread(x - 1, y);
        MechanicalManager.spread(x + 1, y);
        MechanicalManager.spread(x, y - 1);
        MechanicalManager.spread(x, y + 1);
      },
      filter: (cell, x, y) => cell.id == "mech_keyleft" && !cell.updated,
    );
  }
  if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
    grid.loopChunks(
      "mech_keyright",
      GridAlignment.BOTTOMLEFT,
      (cell, x, y) {
        MechanicalManager.spread(x - 1, y);
        MechanicalManager.spread(x + 1, y);
        MechanicalManager.spread(x, y - 1);
        MechanicalManager.spread(x, y + 1);
      },
      filter: (cell, x, y) => cell.id == "mech_keyright" && !cell.updated,
    );
  }
  if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
    grid.loopChunks(
      "mech_keydown",
      GridAlignment.BOTTOMLEFT,
      (cell, x, y) {
        MechanicalManager.spread(x - 1, y);
        MechanicalManager.spread(x + 1, y);
        MechanicalManager.spread(x, y - 1);
        MechanicalManager.spread(x, y + 1);
      },
      filter: (cell, x, y) => cell.id == "mech_keydown" && !cell.updated,
    );
  }

  // Power draw
  grid.loopChunks(
    "all",
    GridAlignment.BOTTOMLEFT,
    (cell, x, y) {
      drawPower(cell);
    },
  );
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
    if (grid.placeable(ox, oy) != "empty" && depthing) {
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

void drawPower(Cell cell) {
  if (cell.data['power'] is int) {
    cell.data['power']--;
    if (cell.data['power'] == 0) {
      cell.data.remove('power');
    }
  }
}

class MechanicalManager {
  static bool connectable(int? dir, Cell cell) {
    if (cell.id == "empty") return false;
    if (dir == null) return true;
    if (cell.id == "time_machine") return true;
    if (cell.id == "cross_mech_gear") return true;
    if (cell.id == "mech_grabber") return dir != (cell.rot + 2) % 4;
    if (cell.id.startsWith('mech_')) return true;
    return CellTypeManager.mechanical.contains(cell.id);
  }

  static void whenPowered(Cell cell, int x, int y) {
    if (cell.id == "mech_mover") {
      cell.updated = true;
      push(x, y, cell.rot, 0);
    } else if (cell.id == "mech_puller") {
      cell.updated = true;
      pull(x, y, cell.rot, 0);
    } else if (cell.id == "mech_fan") {
      cell.updated = true;
      doFan(cell, x, y);
    } else if (cell.id == "mech_grabber") {
      cell.updated = true;
      doGrabber(x, y, cell.rot);
    } else if (cell.id == "displayer") {
      cell.updated = true;
      doDisplayer(x, y, cell.rot);
    } else if (cell.id == "time_machine") {
      cell.data['time_travelled'] = true;
      travelTime();
    } else if (cell.id == "mech_rotator_cw") {
      cell.updated = true;
      grid.rotate(
          frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
          frontY(cell.cy ?? y, cell.rot + 1), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
          frontY(cell.cy ?? y, cell.rot + 2), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
          frontY(cell.cy ?? y, cell.rot + 3), 1);
    } else if (cell.id == "mech_rotator_ccw") {
      cell.updated = true;
      grid.rotate(
          frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
          frontY(cell.cy ?? y, cell.rot + 1), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
          frontY(cell.cy ?? y, cell.rot + 2), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
          frontY(cell.cy ?? y, cell.rot + 3), -1);
    } else if (cell.id == "mech_p_gen") {
      cell.updated = true;
      doGen(x, y, cell.rot, cell.rot);
    }
  }

  static void spread(int x, int y,
      [int depth = 0, bool continueFirst = false, int? sentDir]) {
    //print("e");
    AchievementManager.complete("circuitry");
    if (depth == 15) return;
    if (!grid.inside(x, y)) return;
    if (!connectable(sentDir, grid.at(x, y))) return;
    final cell = grid.at(x, y);
    if (onAt(x, y, true)) return;
    if (cell.id == "cross_mech_gear" && sentDir != null) {
      grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
      return spread(
        frontX(x, sentDir),
        frontY(y, sentDir),
        depth + 1,
        continueFirst,
        sentDir,
      );
    }
    cell.data['power'] = 2;
    if (!cell.updated) {
      whenPowered(cell, x, y);
    }
    if (cell.id == "mech_gear" && depth < 14)
      grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
    if (cell.id == "mech_gear" && cell.updated) return;
    depth++;
    if (cell.id == "mech_gear" || (depth == 0 && continueFirst)) {
      if (sentDir != 2) {
        spread(x + 1, y, depth, continueFirst, 0);
      }
      if (sentDir != 0) {
        spread(x - 1, y, depth, continueFirst, 2);
      }
      if (sentDir != 3) {
        spread(x, y + 1, depth, continueFirst, 1);
      }
      if (sentDir != 1) {
        spread(x, y - 1, depth, continueFirst, 3);
      }
    }
  }

  static bool on(Cell cell, [bool freshly = false]) =>
      (cell.data['power'] ?? 0) > (freshly ? 1 : 0);

  static bool onAt(int x, int y, [bool freshly = false]) =>
      grid.inside(x, y) ? on(grid.at(x, y), freshly) : false;
}
