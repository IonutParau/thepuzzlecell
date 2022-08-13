part of logic;

void hungryTrashes() {
  grid.updateCell(
    (cell, x, y) {
      var ox = 0;
      var oy = 0;

      if (safeAt(x + 1, y) != null && safeAt(x + 1, y)?.id != "empty") {
        ox++;
      }
      if (safeAt(x - 1, y) != null && safeAt(x - 1, y)?.id != "empty") {
        ox--;
      }
      if (safeAt(x, y + 1) != null && safeAt(x, y + 1)?.id != "empty") {
        oy++;
      }
      if (safeAt(x, y - 1) != null && safeAt(x, y - 1)?.id != "empty") {
        oy--;
      }

      if (ox != 0) {
        grid.addBroken(grid.at(x + ox, y), x + ox, y);
        grid.set(x + ox, y, cell.copy);
      }
      if (oy != 0) {
        grid.addBroken(grid.at(x, y + oy), x, y + oy);
        grid.set(x, y + oy, cell.copy);
      }
      if (ox != 0 || oy != 0) {
        grid.set(x, y, Cell(x, y));
      }
    },
    null,
    "hungry_trash",
  );
}
