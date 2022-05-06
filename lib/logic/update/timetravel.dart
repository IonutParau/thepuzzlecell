part of logic;

var mustTimeTravel = false;
var timeTravelCount = 0;

final timeTravellers = <String>[
  "time_trash",
];

void travelTime() => mustTimeTravel = true;

Cell cellFromData(Map<String, dynamic> data, int x, int y) {
  return Cell(x, y)
    ..id = cells[data['id']!]
    ..rot = data['rot']!
    ..lastvars.lastRot = data['rot']!
    ..data = data
    ..tags = (data['tags'] as String).split(' ').toSet();
}

Map<String, dynamic> copyData(Map<String, dynamic> data) {
  final d = <String, dynamic>{};

  data.forEach((key, value) {
    d[key] = value;
  });

  return d;
}

Map<String, dynamic> cellToData(Cell cell) {
  final data = copyData(cell.data);

  data['id'] = cells.indexOf(cell.id);
  data['rot'] = cell.rot;
  data['tags'] = cell.tags.join(" ");

  return data;
}

void doTimeHoleSide(int x, int y, int ox, int oy) {
  if (!grid.inside(x + ox, y + oy)) return;

  if (safeAt(x + ox, y + oy)?.id != "empty") {
    if (!(timeGrid!.inside(x - ox, y - oy))) return;
    timeGrid!.set(x - ox, y - oy, grid.at(x + ox, y + oy));
    grid.addBroken(grid.at(x + ox, y + oy), x, y);
    grid.set(x + ox, y + oy, Cell(x + ox, y + oy));
  }
}

Grid? timeGrid;

void timetravel() {
  //if (mustTimeTravel) print("Must time travel");
  grid.loopChunks(
    "consistency",
    GridAlignment.BOTTOMRIGHT,
    (cell, x, y) {
      cell.tags.add("consistent");
      safeAt(x - 1, y)?.tags.add("consistent");
      safeAt(x + 1, y)?.tags.add("consistent");
      safeAt(x, y - 1)?.tags.add("consistent");
      safeAt(x, y + 1)?.tags.add("consistent");
    },
  );

  if (timeGrid == null) {
    timeGrid = game.initial.copy;
  }

  grid.loopChunks(
    "time_hole",
    GridAlignment.BOTTOMRIGHT,
    (Cell cell, int x, int y) {
      doTimeHoleSide(x, y, -1, 0);
      doTimeHoleSide(x, y, 1, 0);
      doTimeHoleSide(x, y, 0, -1);
      doTimeHoleSide(x, y, 0, 1);
    },
    filter: (cell, x, y) => cell.id == "time_hole" && !cell.updated,
  );

  if (mustTimeTravel) {
    grid.loopChunks(
      "time_trash",
      GridAlignment.BOTTOMRIGHT,
      (Cell cell, int x, int y) {
        if (cell.data['time_travelled'] == true) {
          timeGrid!.set(x, y, debug<Cell>(cellFromData(cell.data, x, y)));
        }
      },
      filter: (cell, x, y) => cell.id == "time_trash" && !cell.updated,
    );

    grid.loopChunks(
      "consistent",
      GridAlignment.BOTTOMRIGHT,
      (Cell cell, int x, int y) {
        timeGrid!.set(x, y, cell.copy);
      },
    );

    grid.loopChunks(
      "time_machine",
      GridAlignment.BOTTOMLEFT,
      (Cell cell, int x, int y) {
        if (cell.data['time_travelled'] == true) {
          final s = CellStructure()..build(x, y);
          s.coords.forEach(
            (pos) => timeGrid!.set(
              pos.x.toInt(),
              pos.y.toInt(),
              grid.at(
                pos.x.toInt(),
                pos.y.toInt(),
              ),
            ),
          );
        }
      },
      filter: (c, x, y) => c.id == "time_machine",
    );

    if (grid.cells.contains("consistency")) {
      grid.loopChunks(
        "all",
        GridAlignment.BOTTOMRIGHT,
        (cell, x, y) {
          if (cell.tags.contains("consistent") && cell.id != "empty") {
            timeGrid!.set(x, y, cell);
          }
        },
      );
    }

    // At the end of it
    grid = timeGrid!.copy;
    playerKeys = 0;
    mustTimeTravel = false;
    game.itime = game.delay;
    puzzleWin = false;
  }
}
