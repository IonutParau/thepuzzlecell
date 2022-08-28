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
    } else if (o.id == "unstable_mover") {
      f.id = "unstable_puzzle";
      grid.setChunk(x, y, "unstable_puzzle");
      o.id = "empty";
    } else if (o.id == "snow") {
      f.id = "frozen_puzzle";
      grid.setChunk(x, y, "frozen_puzzle");
      o.id = "empty";
    } else if (o.id == "magma") {
      f.id = "molten_puzzle";
      grid.setChunk(x, y, "molten_puzzle");
      o.id = "empty";
    } else if (o.id == "time_trash") {
      f.id = "temporal_puzzle";
      grid.setChunk(x, y, "temporal_puzzle");
      o.id = "empty";
    } else if (o.id == "transformer") {
      f.id = "transform_puzzle";
      grid.setChunk(x, y, "transform_puzzle");
      o.id = "empty";
    }
  }
}

void pmerges() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        if (cell.rot != rot) return;
        mergePuzzle(x, y, cell.rot);
      },
      rot,
      "pmerge",
    );
  }
}
