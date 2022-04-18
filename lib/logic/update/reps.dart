part of logic;

void doRep(int x, int y, int dir, int gendir,
    [int offX = 0, int offY = 0, bool physical = false]) {
  var lvxo = physical ? frontX(0, dir) * 2 : 0;
  var lvyo = physical ? frontY(0, dir) * 2 : 0;
  doGen(x, y, dir, gendir + 2, offX, offY, 2, physical, lvxo, lvyo);
}

void reps() {
  genOptimizer.clear();
  if (!grid.movable) return;
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, cell.rot, cell.rot);
      },
      rot,
      "replicator",
    );
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, cell.rot, cell.rot, 0, 0, true);
      },
      rot,
      "physical_replicator",
    );
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, cell.rot, cell.rot);
        doRep(x, y, (cell.rot + 2) % 4, (cell.rot + 2) % 4);
      },
      rot,
      "opposite_replicator",
    );
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, cell.rot, cell.rot);
        doRep(x, y, (cell.rot + 3) % 4, (cell.rot + 3) % 4);
      },
      rot,
      "cross_replicator",
    );
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, (cell.rot + 1) % 4, (cell.rot + 1) % 4);
        doRep(x, y, cell.rot, cell.rot);
        doRep(x, y, (cell.rot + 3) % 4, (cell.rot + 3) % 4);
      },
      rot,
      "triple_rep",
    );
    grid.updateCell(
      (cell, x, y) {
        doRep(x, y, 0, 0);
        doRep(x, y, 1, 1);
        doRep(x, y, 2, 2);
        doRep(x, y, 3, 3);
      },
      rot,
      "quad_rep",
    );
  }
}
