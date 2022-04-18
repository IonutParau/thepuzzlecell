part of logic;

void Unstable(int x, int y, int dir) {
  var cx = x;
  var cy = y;

  final self = grid.at(x, y);
  self.updated = true;

  while (true) {
    cx = frontX(cx, dir);
    cy = frontY(cy, dir);
    if (!grid.inside(cx, cy)) return;

    final c = grid.at(cx, cy);

    if (c.id == "empty") {
      moveCell(x, y, cx, cy, dir);
      return;
    } else if (moveInsideOf(c, cx, cy, dir, MoveType.unkown_move)) {
      push(cx, cy, dir, 99999999999, replaceCell: self.copy);
    }
  }
}

void doField(Cell cell, int x, int y) {
  //print("Help ${cell.lifespan}");
  //final iteration = cell.lifespan;
  final rng = Random();
  final nx = rng.nextInt(grid.width);
  final ny = rng.nextInt(grid.height);

  final randomStuff = rng.nextInt(cells.length * 200);
  final randomRot = rng.nextInt(4);

  grid.set(x, y, Cell(x, y));

  if (randomStuff >= cells.length) {
    if (randomStuff < cells.length * 2) {
      grid.set(x, y, Cell(x, y)..id = "field");
      grid.setChunk(x, y, "field");
    }
  } else {
    grid.set(
      x,
      y,
      Cell(x, y)
        ..id = cells[randomStuff]
        ..rot = randomRot
        ..lastvars.lastRot = randomRot,
    );
    grid.setChunk(x, y, cells[randomStuff]);
  }

  if (grid.at(nx, ny).id != "empty") {
    grid.addBroken(grid.at(nx, ny), nx, ny, "silent");
  }

  grid.set(nx, ny, cell.copy);
  grid.setChunk(nx, ny, cell.id);
}

void quantums() {
  for (var rot in rotOrder) {
    grid.loopChunks(
      "unstable_mover",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot == rot) Unstable(x, y, cell.rot);
      },
      filter: (cell, x, y) =>
          cell.id == "unstable_mover" &&
          cell.rot == rot &&
          cell.updated == false,
    );
  }

  grid.loopChunks("field", GridAlignment.TOPLEFT, doField);
}
