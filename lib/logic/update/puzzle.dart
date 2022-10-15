part of logic;

bool isPuzzleKeyDown(int d) {
  d %= 4;
  if (d == 0) {
    return keys[LogicalKeyboardKey.arrowRight.keyLabel] == true;
  }
  if (d == 2) {
    return keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true;
  }
  if (d == 1) {
    return keys[LogicalKeyboardKey.arrowDown.keyLabel] == true;
  }
  if (d == 3) {
    return keys[LogicalKeyboardKey.arrowUp.keyLabel] == true;
  }
  return false;
}

void doPuzzleSide(int x, int y, int dir, Set<String> cells, [String type = "normal", int force = 1]) {
  AchievementManager.complete("incontrol");
  dir += 4;
  dir %= 4;
  var puzzle = grid.at(x, y);
  var ox = frontX(x, dir);
  var oy = frontY(y, dir);
  if (!grid.inside(ox, oy)) return;

  final o = grid.at(ox, oy);
  if (o.id.endsWith("puzzle") && o.id != "propuzzle" && o.id != "antipuzzle" && type != "robot") {
    var nextType = "normal";
    if (o.rot == puzzle.rot && isPuzzleKeyDown((dir - o.rot) % 4)) {
      print("Test");
      if (o.id == "trash_puzzle") nextType = "trash";
      if (o.id == "temporal_puzzle") nextType = "temporal";
      if (o.id == "unstable_puzzle") nextType = "unstable";
      if (o.id == "molten_puzzle") nextType = "molten";
      if (o.id == "frozen_puzzle") nextType = "frozen";
      force++;
      o.updated = true;
    } else if (o.rot == ((puzzle.rot + 2) % 4) && isPuzzleKeyDown((dir - puzzle.rot) % 4)) {
      force--;
    }
    if (force == 0) return;
    if ((o.rot == puzzle.rot) || (o.rot == (puzzle.rot + 2) % 4)) {
      doPuzzleSide(ox, oy, dir, cells, nextType, force);
    }
  }
  if (o.id == "key") {
    playerKeys++;
    grid.addBroken(o.copy, ox, oy, "silent");
    grid.set(ox, oy, Cell(ox, oy));
  } else if (o.id == "lock") {
    if (playerKeys > 0) {
      playerKeys--;
      o.id = "unlock";
    }
  } else if (o.id == "flag") {
    if (!cells.containsAny(enemies)) {
      puzzleWin = true;
      if (game.edType == EditorType.loaded) game.itime = game.delay;
    }
  } else if (o.id == "checkpoint") {
    enableCheckpoint(o, ox, oy);
  }

  if (type == "unstable") {
    unstableMove(x, y, dir);

    return;
  }

  if (push(x, y, dir, 1, mt: type == "robot" ? MoveType.push : MoveType.puzzle)) {
    // DO stuff
  } else {
    if (type == "trash") {
      grid.addBroken(grid.at(ox, oy), ox, oy);
      moveCell(x, y, ox, oy);
    } else if (type == "frozen") {
      addHeat(ox, oy, -1);
    } else if (type == "molten") {
      addHeat(ox, oy);
    }
  }
}

void doSandbox(Cell cell, int x, int y) {
  final rng = Random();

  final cx = rng.nextInt(grid.width);
  final cy = rng.nextInt(grid.height);
  final r = rng.nextInt(4);
  final t = cells[rng.nextInt(cells.length)];

  grid.set(
    cx,
    cy,
    Cell(cx, cy)
      ..rot = r
      ..lastvars.lastRot = r
      ..id = t,
  );
}

void doRobot(Cell cell, int x, int y) {
  var range = grid.width * grid.height ~/ 4;
  if (grid.cells.contains("key")) {
    final dirToKey = pathFindToCell(x, y, ["key"], range);
    if (dirToKey != null) {
      return doPuzzleSide(x, y, dirToKey, grid.cells, "robot", 1);
    }
  }

  if (grid.cells.contains("lock") && playerKeys > 0) {
    final dirToLock = pathFindToCell(x, y, ["lock"], range);
    if (dirToLock != null) {
      final fx = frontX(x, dirToLock);
      final fy = frontY(y, dirToLock);
      if (!grid.inside(fx, fy)) return;

      final f = grid.at(fx, fy);
      if (f.id == "lock") {
        if (playerKeys > 0) {
          playerKeys--;
          grid.set(
              fx,
              fy,
              Cell(fx, fy)
                ..id = "unlock"
                ..rot = f.rot);
        }
      } else {
        push(x, y, dirToLock, 1, mt: MoveType.push);
      }
    }
  }

  if (grid.cells.containsAny(enemies)) {
    final dirToEnemy = pathFindToCell(x, y, enemies, range);
    if (dirToEnemy != null) {
      push(x, y, dirToEnemy, 1);
      return;
    }
  }

  if (grid.cells.contains("flag")) {
    final dirToFlag = pathFindToCell(x, y, ["flag"], range);
    if (dirToFlag != null) {
      doPuzzleSide(x, y, dirToFlag, grid.cells, "robot", 1);
      return;
    }
  }
}

void doAssistant(Cell cell, int x, int y) {
  var range = grid.width * grid.height;
  if (grid.cells.contains("key")) {
    final dirToKey = pathFindToCell(x, y, ["key"], range);
    if (dirToKey != null) {
      return doPuzzleSide(x, y, dirToKey, grid.cells, "robot", 1);
    }
  }

  if (grid.cells.contains("lock") && playerKeys > 0) {
    final dirToLock = pathFindToCell(x, y, ["lock"], range);
    if (dirToLock != null) {
      final fx = frontX(x, dirToLock);
      final fy = frontY(y, dirToLock);
      if (!grid.inside(fx, fy)) return;

      final f = grid.at(fx, fy);
      if (f.id == "lock") {
        if (playerKeys > 0) {
          playerKeys--;
          grid.set(
              fx,
              fy,
              Cell(fx, fy)
                ..id = "unlock"
                ..rot = f.rot);
        }
      } else {
        push(x, y, dirToLock, 1, mt: MoveType.push);
      }
    }
  }

  if (grid.cells.containsAny(["push", "unlock"]) && grid.cells.containsAny(enemies)) {
    final pushPos = findCell(x, y, ["push", "unlock"], range);
    if (pushPos != null) {
      final pushX = pushPos.dx.toInt();
      final pushY = pushPos.dy.toInt();
      final dirToEnemy = getPathFindingDirection(x, y, pushX, pushY, true, {});
      if (dirToEnemy != null) {
        if (enemies.contains(grid.get(pushX + 1, pushY)?.id)) {
          final dir = getPathFindingDirection(x, y, pushX - 1, pushY, true, {});
          if (dir != null) {
            if (push(x, y, dir, 1, mt: MoveType.push)) return;
          }
        } else if (enemies.contains(grid.get(pushX - 1, pushY)?.id)) {
          final dir = getPathFindingDirection(x, y, pushX + 1, pushY, true, {});
          if (dir != null) {
            if (push(x, y, dir, 1, mt: MoveType.push)) return;
          }
        } else if (enemies.contains(grid.get(pushX, pushY + 1)?.id)) {
          final dir = getPathFindingDirection(x, y, pushX, pushY - 1, true, {});
          if (dir != null) {
            if (push(x, y, dir, 1, mt: MoveType.push)) return;
          }
        } else if (enemies.contains(grid.get(pushX, pushY - 1)?.id)) {
          final dir = getPathFindingDirection(x, y, pushX, pushY + 1, true, {});
          if (dir != null) {
            if (push(x, y, dir, 1, mt: MoveType.push)) return;
          }
        }

        if (push(x, y, dirToEnemy, 1, mt: MoveType.push)) return;
      }
    }
  }

  if (grid.cells.contains("flag")) {
    final dirToFlag = pathFindToCell(x, y, ["flag"], range);
    if (dirToFlag != null) {
      doPuzzleSide(x, y, dirToFlag, grid.cells, "robot", 1);
      return;
    }
  }
}

void puzzles(Set<String> cells) {
  grid.updateCell(
    doSandbox,
    null,
    "sandbox",
  );

  var removeTriggerKey = false;

  grid.updateCell(
    doRobot,
    null,
    "robot",
  );

  grid.updateCell(
    doAssistant,
    null,
    "assistant",
  );

  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells);
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells);
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells);
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells);
        }
      },
      rot,
      "puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "trash");
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "trash");
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "trash");
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "trash");
        }
      },
      rot,
      "trash_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          cell.rot = 3;
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          cell.rot = 1;
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          cell.rot = 2;
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          cell.rot = 0;
        }
        doPuzzleSide(x, y, cell.rot, cells);
      },
      rot,
      "mover_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "unstable");
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "unstable");
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "unstable");
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "unstable");
        }
      },
      rot,
      "unstable_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "frozen");
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "frozen");
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "frozen");
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "frozen");
        }
      },
      rot,
      "frozen_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "molten");
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "molten");
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "molten");
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "molten");
        }
      },
      rot,
      "molten_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot - 1, cells, "temporal");
        } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 1, cells, "temporal");
        } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot + 2, cells, "temporal");
        } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
          doPuzzleSide(x, y, cell.rot, cells, "temporal");
        } else if (keys[LogicalKeyboardKey.keyT.keyLabel] == true) {
          cell.tags.add("consistent");
          cells.add("consistency");
          removeTriggerKey = true;
          travelTime();
        }
      },
      rot,
      "temporal_puzzle",
    );
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        if (keys[LogicalKeyboardKey.keyT.keyLabel] == true) {
          if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
            doTransformer(x, y, (cell.rot - 1) % 4, (cell.rot - 1) % 4, 0, 0, cell.data['offset'] ?? 1);
          } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
            doTransformer(x, y, (cell.rot + 1) % 4, (cell.rot + 1) % 4, 0, 0, cell.data['offset'] ?? 1);
          } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
            doTransformer(x, y, (cell.rot + 2) % 4, (cell.rot + 2) % 4, 0, 0, cell.data['offset'] ?? 1);
          } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
            doTransformer(x, y, cell.rot, cell.rot, 0, 0, cell.data['offset'] ?? 1);
          }
        } else {
          if (keys[LogicalKeyboardKey.arrowUp.keyLabel] == true) {
            doPuzzleSide(x, y, cell.rot - 1, cells);
          } else if (keys[LogicalKeyboardKey.arrowDown.keyLabel] == true) {
            doPuzzleSide(x, y, cell.rot + 1, cells);
          } else if (keys[LogicalKeyboardKey.arrowLeft.keyLabel] == true) {
            doPuzzleSide(x, y, cell.rot + 2, cells);
          } else if (keys[LogicalKeyboardKey.arrowRight.keyLabel] == true) {
            doPuzzleSide(x, y, cell.rot, cells);
          }
        }
      },
      rot,
      "transform_puzzle",
    );
  }

  if (removeTriggerKey) keys.remove(LogicalKeyboardKey.keyT.keyLabel);
}
