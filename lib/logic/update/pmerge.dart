part of logic;

void mergePuzzle(int x, int y, int dir) {
  final fx = frontX(x, dir);
  final fy = frontY(y, dir);
  final bx = x - frontX(0, dir);
  final by = y - frontY(0, dir);

  if (!grid.inside(fx, fy)) return;
  if (!grid.inside(bx, by)) return;

  final o = grid.at(bx, by);
  final f = grid.at(fx, fy);

  if (f.id == "puzzle") {
    if (o.id == "trash") {
      f.id = "trash_puzzle";
      grid.setChunk(x, y, "trash_puzzle");
      o.id = "empty";
    } else if (o.id == "mover") {
      f.id = "mover_puzzle";
      grid.setChunk(x, y, "mover_puzzle");
      o.id = "empty";
    }
  }
}

void pmerges() {
  for (var rot in rotOrder) {
    grid.loopChunks(
      "pmerge",
      fromRot(rot),
      (cell, x, y) {
        if (cell.rot != rot) return;
        mergePuzzle(x, y, cell.rot);
      },
    );
  }
}
