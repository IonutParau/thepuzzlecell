part of logic;

void doPuzzleSide(int x, int y, int dir, Set<String> cells,
    [String type = "normal", int force = 1]) {
  AchievementManager.complete("incontrol");
  dir += 4;
  dir %= 4;
  var puzzle = grid.at(x, y);
  var ox = frontX(x, dir);
  var oy = frontY(y, dir);
  if (!grid.inside(ox, oy)) return;

  final o = grid.at(ox, oy);
  if (o.id.endsWith("puzzle") && o.id != "antipuzzle") {
    if (o.rot == puzzle.rot) {
      if (o.id == "trash_puzzle") type = "trash";
      force++;
      o.updated = true;
    } else if (o.rot == ((puzzle.rot + 2) % 4)) {
      force--;
      o.updated = true;
    }
    if (force == 0) return;
    if ((o.rot == puzzle.rot) || (o.rot == (puzzle.rot + 2) % 4)) {
      doPuzzleSide(ox, oy, dir, cells, type, force);
    }
  }
  if (o.id == "key") {
    playerKeys++;
    grid.set(ox, oy, Cell(ox, oy));
  } else if (o.id == "lock") {
    if (playerKeys > 0) {
      playerKeys--;
      grid.set(
          ox,
          oy,
          Cell(ox, oy)
            ..id = "unlock"
            ..rot = o.rot);
    }
  } else if (o.id == "flag") {
    if (!cells.containsAny(enemies)) {
      puzzleWin = true;
      if (game.edType == EditorType.loaded) game.itime = game.delay;
    }
  }

  if (push(x, y, dir, 1, mt: MoveType.puzzle)) {
    // DO stuff
  } else {
    if (type == "trash") {
      moveCell(x, y, ox, oy);
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

void puzzles(Set<String> cells) {
  grid.updateCell(
    doSandbox,
    null,
    "sandbox",
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
  }
}
