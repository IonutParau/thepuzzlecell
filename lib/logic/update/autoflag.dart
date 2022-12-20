part of logic;

void autoflag() {
  if (grid.cells.contains("auto_flag")) {
    if (!grid.cells.containsAny(moddedEnemy) && (!grid.cells.containsAny([...enemies]..removeWhere((e) => e == "friend"))) && !grid.cells.contains("key") && !grid.cells.contains("lock")) {
      puzzleWin = true;
      if (game.edType == EditorType.loaded) game.itime = game.delay;
    }
  }
}
