part of logic;

void mechs(Set<String> cells) {
  // Power
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (mathManager.input(x, y, cell.rot + 2) > (cell.data['offset'] ?? 0)) {
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
        }
      },
      rot,
      "math_to_mech",
    );
    grid.updateCell(
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
      rot,
      "mech_gen",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        final front = grid.get(frontX(x, cell.rot), frontY(y, cell.rot));
        if (front == null) return;
        if (front.id != "empty") {
          MechanicalManager.spread(
            frontX(
              x,
              cell.rot,
              -1,
            ),
            frontY(
              y,
              cell.rot,
              -1,
            ),
            0,
            false,
            (cell.rot + 2) % 4,
          );
        }
      },
      rot,
      "mech_sensor",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        final front = grid.get(frontX(x, cell.rot), frontY(y, cell.rot));
        final back = grid.get(frontX(x, cell.rot, -1), frontY(y, cell.rot, -1));
        if (front == null || back == null) return;
        if (front.id != "empty" && (front.id == back.id && front.rot == back.rot)) {
          MechanicalManager.spread(
            frontX(
              x,
              (cell.rot + 1) % 4,
            ),
            frontY(
              y,
              (cell.rot + 1) % 4,
            ),
            0,
            false,
            (cell.rot + 1) % 4,
          );
          MechanicalManager.spread(
            frontX(
              x,
              (cell.rot - 1) % 4,
            ),
            frontY(
              y,
              (cell.rot - 1) % 4,
            ),
            0,
            false,
            (cell.rot - 1) % 4,
          );
        }
      },
      rot,
      "mech_comparator",
    );
  }

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.tags.contains("piston-update")) return;
        cell.tags.add("piston-update");
        if (MechanicalManager.on(cell) && !MechanicalManager.on(cell, true)) {
          final fx = frontX(x, cell.rot, 2);
          final fy = frontY(y, cell.rot, 2);

          pull(fx, fy, (cell.rot + 2) % 4, 1);
        }
        cell.updated = false;
      },
      rot,
      "piston",
    );
  }

  if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
    grid.updateCell(
      (cell, x, y) {
        MechanicalManager.spread(x, y, -1, true);
      },
      null,
      "mech_keyup",
    );
  }

  if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
    grid.updateCell(
      (cell, x, y) {
        MechanicalManager.spread(x, y, -1, true);
      },
      null,
      "mech_keyleft",
    );
  }
  if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
    grid.updateCell(
      (cell, x, y) {
        MechanicalManager.spread(x, y, -1, true);
      },
      null,
      "mech_keyright",
    );
  }
  if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
    grid.updateCell(
      (cell, x, y) {
        MechanicalManager.spread(x, y, -1, true);
      },
      null,
      "mech_keydown",
    );
  }

  // Power draw
  grid.loopChunks(
    "all",
    GridAlignment.bottomleft,
    (cell, x, y) {
      drawPower(cell);
    },
  );

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.tags.contains("toggle_normalUpdate")) return;
        if (cell.data['toggled'] == true) {
          final fx = frontX(x, cell.rot);
          final fy = frontY(y, cell.rot);

          if (grid.inside(fx, fy)) {
            MechanicalManager.spread(fx, fy, 0, false, cell.rot);
          }
        }
        cell.updated = false;
        cell.tags.add("toggle_normalUpdate");
      },
      rot,
      "mech_toggle",
    );
  }
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
    print(grid.placeable(ox, oy));
    if ((grid.placeable(ox, oy) != "empty") && depthing) {
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
  if (cell.data['power'] is num) {
    cell.data['power']--;
    if (cell.data['power'] == 0) {
      cell.data.remove('power');
    }
  }
}

class MechanicalManager {
  static bool connectable(int? dir, Cell cell) {
    if (cell.id == "empty") return false;
    if (cell.id == "piston") return true;
    if (dir == null) return true;
    if (cell.id == "time_machine") return true;
    if (cell.id == "cross_mech_gear") return true;
    if (cell.id == "mech_grabber") return dir != (cell.rot + 2) % 4;
    if (cell.id == "mech_to_math") return dir == cell.rot;
    if (cell.id.startsWith('mech_') && !["mech_gen", "mech_keyleft", "mech_keyright", "mech_keyup", "mech_keydown"].contains(cell.id)) return true;
    if (cell.id == "keylimit") return true;
    if (cell.id == "keyforce") return true;
    if (cell.id == "keyfake") return true;
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
      grid.rotate(frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 1), frontY(cell.cy ?? y, cell.rot + 1), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 2), frontY(cell.cy ?? y, cell.rot + 2), 1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 3), frontY(cell.cy ?? y, cell.rot + 3), 1);
    } else if (cell.id == "mech_rotator_ccw") {
      cell.updated = true;
      grid.rotate(frontX(cell.cx ?? x, cell.rot), frontY(cell.cy ?? y, cell.rot), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 1), frontY(cell.cy ?? y, cell.rot + 1), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 2), frontY(cell.cy ?? y, cell.rot + 2), -1);
      grid.rotate(frontX(cell.cx ?? x, cell.rot + 3), frontY(cell.cy ?? y, cell.rot + 3), -1);
    } else if (cell.id == "mech_p_gen") {
      cell.updated = true;
      doGen(x, y, cell.rot, cell.rot);
    } else if (cell.id == "mech_toggle") {
      cell.data['toggled'] = ((cell.data['toggled'] ?? false) == false);

      if (cell.data['toggled'] == true) {
        final fx = frontX(x, cell.rot);
        final fy = frontY(y, cell.rot);

        if (grid.inside(fx, fy)) {
          MechanicalManager.spread(fx, fy, 0, false, cell.rot);
        }
      }
    } else if (cell.id == "piston") {
      final fx = frontX(x, cell.rot);
      final fy = frontY(y, cell.rot);

      push(fx, fy, cell.rot, 1);
    } else if (cell.id == "keylimit") {
      final keysToCheck = [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft];

      if (keys[keysToCheck[cell.rot].keyLabel] == true) {
        puzzleLost = true;
      }
    } else if (cell.id == "keyforce") {
      final keysToCheck = [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft];

      if (keys[keysToCheck[cell.rot].keyLabel] != true) {
        puzzleLost = true;
      }
    } else if (cell.id == "keyfake") {
      final keysToCheck = [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft];

      final key = keysToCheck[cell.rot];

      keys[key.keyLabel] = true;

      QueueManager.add("newtick", () {
        keys[key.keyLabel] = false;
      });
    } else if (cell.id == "mech_stopper") {
      final fx = frontX(x, cell.rot);
      final fy = frontY(y, cell.rot);

      if (grid.inside(fx, fy)) {
        final cell = grid.at(fx, fy);
        if (!cell.id.contains("puzzle")) {
          cell.updated = true;
          cell.tags.add("stopped");
        }
      }
    } else if (cell.id == "mech_to_math") {
      mathManager.output(x, y, cell.rot, mathManager.customCount(cell, x, y, cell.rot) ?? 0);
    } else if (cell.id == "mech_checkpoint") {
      enableCheckpoint(cell, x, y);
    }
  }

  static void spread(int x, int y, [int depth = 0, bool continueFirst = false, int? sentDir]) {
    AchievementManager.complete("circuitry");
    if (depth == 99) return;
    if (!grid.inside(x, y)) return;
    if (!connectable(sentDir, grid.at(x, y))) return;
    final cell = grid.at(x, y);
    if (onAt(x, y, true) && cell.id != "cross_mech_gear") return;
    if (cell.id == "cross_mech_gear" && sentDir != null) {
      if (sentDir % 2 == 0) {
        if (cell.tags.contains("cross_sent 1")) return;
      } else {
        if (cell.tags.contains("cross_sent 2")) return;
      }
    }
    if (grid.placeable(x, y) == "mechanical_halting") {
      return;
    }
    if (cell.id == "cross_mech_gear" && sentDir != null) {
      cell.data['power'] = 2;
      grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
      if (sentDir % 2 == 0) {
        cell.tags.add("cross_sent 1");
      } else {
        cell.tags.add("cross_sent 2");
      }
      return spread(
        frontX(cell.cx!, sentDir),
        frontY(cell.cy!, sentDir),
        depth + 1,
        continueFirst,
        sentDir,
      );
    }
    cell.data['power'] = 2;
    if (!cell.updated) {
      whenPowered(cell, cell.cx!, cell.cy!);
    }
    if (cell.id == "mech_gear" && depth < 14) grid.rotate(x, y, (depth % 2 == 0) ? 1 : -1);
    if (cell.id == "mech_gear" && cell.updated) return;
    depth++;
    if (cell.id == "mech_gear" || (depth <= 0 && continueFirst)) {
      if (sentDir != 2) {
        spread(cell.cx! + 1, cell.cy!, depth, continueFirst, 0);
      }
      if (sentDir != 0) {
        spread(cell.cx! - 1, cell.cy!, depth, continueFirst, 2);
      }
      if (sentDir != 3) {
        spread(cell.cx!, cell.cy! + 1, depth, continueFirst, 1);
      }
      if (sentDir != 1) {
        spread(cell.cx!, cell.cy! - 1, depth, continueFirst, 3);
      }
    }
  }

  static bool on(Cell cell, [bool freshly = false]) => (cell.data['power'] ?? 0) > (freshly ? 1 : 0);

  static bool onAt(int x, int y, [bool freshly = false]) => grid.inside(x, y) ? on(grid.at(x, y), freshly) : false;
}
