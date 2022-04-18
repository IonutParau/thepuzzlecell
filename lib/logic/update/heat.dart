part of logic;

void doMagma(Cell cell, int x, int y) {
  if (grid.inside(x + 1, y)) {
    if (grid.at(x + 1, y).id != "empty")
      grid.at(x + 1, y).data['heat'] =
          (grid.at(x + 1, y).data['heat'] ?? 0) + 1;
  }
  if (grid.inside(x - 1, y)) {
    if (grid.at(x - 1, y).id != "empty")
      grid.at(x - 1, y).data['heat'] =
          (grid.at(x - 1, y).data['heat'] ?? 0) + 1;
  }
  if (grid.inside(x, y + 1)) {
    if (grid.at(x, y + 1).id != "empty")
      grid.at(x, y + 1).data['heat'] =
          (grid.at(x, y + 1).data['heat'] ?? 0) + 1;
  }
  if (grid.inside(x, y - 1)) {
    if (grid.at(x, y - 1).id != "empty")
      grid.at(x, y - 1).data['heat'] =
          (grid.at(x, y - 1).data['heat'] ?? 0) + 1;
  }
}

void doSnow(Cell cell, int x, int y) {
  if (grid.inside(x + 1, y)) {
    if (grid.at(x + 1, y).id != "empty")
      grid.at(x + 1, y).data['heat'] =
          (grid.at(x + 1, y).data['heat'] ?? 0) - 1;
  }
  if (grid.inside(x - 1, y)) {
    if (grid.at(x - 1, y).id != "empty")
      grid.at(x - 1, y).data['heat'] =
          (grid.at(x - 1, y).data['heat'] ?? 0) - 1;
  }
  if (grid.inside(x, y + 1)) {
    if (grid.at(x, y + 1).id != "empty")
      grid.at(x, y + 1).data['heat'] =
          (grid.at(x, y + 1).data['heat'] ?? 0) - 1;
  }
  if (grid.inside(x, y - 1)) {
    if (grid.at(x, y - 1).id != "empty")
      grid.at(x, y - 1).data['heat'] =
          (grid.at(x, y - 1).data['heat'] ?? 0) - 1;
  }
}

void heat() {
  grid.loopChunks(
    "all",
    GridAlignment.BOTTOMRIGHT,
    (cell, x, y) {
      final temp = cell.data['heat'] ?? 0;
      if (temp >= 100) {
        cell.id = "magma";
      } else if (temp <= -100) {
        cell.id = "snow";
      } else {
        if (cell.id != "magma" && cell.id != "snow") {
          if (temp > 0) {
            cell.updated = (cell.lifespan % (max(temp ~/ 3, 3)) == 0);
          }
        }
      }
    },
  );

  grid.updateCell(doMagma, null, "magma");
  grid.updateCell(doSnow, null, "snow");
}
