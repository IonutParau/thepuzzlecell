part of logic;

void doSand(Cell cell, int x, int y) {
  if (safeAt(x, y + 1)?.id == "empty") {
    moveCell(x, y, x, y + 1);
  } else if (safeAt(x - 1, y)?.id == "empty" && safeAt(x - 1, y + 1)?.id == "empty") {
    moveCell(x, y, x - 1, y + 1);
  } else if (safeAt(x + 1, y)?.id == "empty" && safeAt(x + 1, y + 1)?.id == "empty") {
    moveCell(x, y, x + 1, y + 1);
  }
}

void doWater(Cell cell, int x, int y) {
  if (safeAt(x, y + 1)?.id == "empty") {
    moveCell(x, y, x, y + 1);
  } else if (safeAt(x - 1, y)?.id == "empty" && safeAt(x - 1, y + 1)?.id == "empty") {
    moveCell(x, y, x - 1, y + 1);
  } else if (safeAt(x + 1, y)?.id == "empty" && safeAt(x + 1, y + 1)?.id == "empty") {
    moveCell(x, y, x + 1, y + 1);
  } else if (safeAt(x - 1, y)?.id == "empty" && safeAt(x - 1, y + 1)?.id != "empty") {
    moveCell(x, y, x - 1, y);
  } else if (safeAt(x + 1, y)?.id == "empty" && safeAt(x + 1, y + 1)?.id != "empty") {
    moveCell(x, y, x + 1, y);
  }
}

void doGas(Cell cell, int x, int y) {
  if (safeAt(x, y - 1)?.id == "empty") {
    moveCell(x, y, x, y - 1);
  } else if (safeAt(x - 1, y)?.id == "empty" && safeAt(x - 1, y - 1)?.id == "empty") {
    moveCell(x, y, x - 1, y - 1);
  } else if (safeAt(x + 1, y)?.id == "empty" && safeAt(x + 1, y - 1)?.id == "empty") {
    moveCell(x, y, x + 1, y - 1);
  } else if (safeAt(x - 1, y)?.id == "empty" && safeAt(x - 1, y - 1)?.id != "empty") {
    moveCell(x, y, x - 1, y);
  } else if (safeAt(x + 1, y)?.id == "empty" && safeAt(x + 1, y - 1)?.id != "empty") {
    moveCell(x, y, x + 1, y);
  }
}

void automata() {
  grid.loopChunks("sand", fromRot(1), doSand, filter: ((cell, x, y) => cell.id == "sand" && !cell.updated));

  grid.loopChunks("water", fromRot(1), doWater, filter: ((cell, x, y) => cell.id == "water" && !cell.updated));

  grid.loopChunks("gas", fromRot(3), doGas, filter: ((cell, x, y) => cell.id == "gas" && !cell.updated));
}
