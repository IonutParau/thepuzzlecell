part of logic;

void autoflag() {
  if (grid.cells.contains("auto_flag")) {
    if ((!grid.cells.containsAny(enemies)) &&
        !grid.cells.contains("key") &&
        !grid.cells.contains("lock")) {
      puzzleWin = true;
      game.itime = game.delay;
    }
  }
}
