part of logic;

void transformers() {
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doTransformer(x, y, cell.rot, cell.rot, 0, 0);
      },
      rot,
      "transformer",
    );
    grid.updateCell(
      (cell, x, y) {
        doTransformer(x, y, cell.rot, (cell.rot + 1) % 4, 0, 0);
      },
      rot,
      "transformer_cw",
    );
    grid.updateCell(
      (cell, x, y) {
        doTransformer(x, y, cell.rot, (cell.rot + 3) % 4, 0, 0);
      },
      rot,
      "transformer_ccw",
    );
    grid.updateCell(
      (cell, x, y) {
        doTransformer(x, y, cell.rot, (cell.rot + 3) % 4, 0, 0);
        doTransformer(x, y, cell.rot, cell.rot, 0, 0);
        doTransformer(x, y, cell.rot, (cell.rot + 1) % 4, 0, 0);
      },
      rot,
      "triple_transformer",
    );
  }
}

void doTransformer(int x, int y, int dir, int outdir, int offX, int offY) {
  final idir = (dir + 2) % 4;

  final bx = frontX(x, idir);
  final by = frontY(y, idir);

  if (!grid.inside(bx, by)) return;

  final input = grid.at(bx, by).copy;

  final ox = frontX(x, outdir) + offX;
  final oy = frontY(y, outdir) + offY;

  if (!grid.inside(ox, oy)) return;

  final output = grid.at(ox, oy);
  input.rot = (input.rot + (outdir - dir + 4)) % 4;

  if (input.id != "empty" && output.id != "empty") {
    if (input.id == "untransformable" ||
        output.id == "untransformable" ||
        !breakable(input, bx, by, dir, BreakType.transform) ||
        !breakable(output, ox, oy, dir, BreakType.transform)) return;
    output.id = input.id;
    output.rot = input.rot;
    output.data = input.data;
    output.lifespan = input.lifespan;
    output.tags = input.tags;
    grid.setChunk(ox, oy, output.id);
  }
}

enum BreakType {
  rotate,
  transform,
}

bool breakable(Cell c, int x, int y, int dir, BreakType bt) {
  if (c.id == "wall" || c.id == "ghost") return false;

  if (c.id == "untransformable" && bt == BreakType.transform) return false;

  if (bt == BreakType.transform) {
    if (c.id == "pushable") {
      return false;
    } else if (c.id == "pullable") {
      return false;
    } else if (c.id == "grabbable") {
      return false;
    } else if (c.id == "swappable") {
      return false;
    } else if (c.id == "generatable") {
      return false;
    } else if (c.id == "propuzzle") {
      return false;
    } else if (c.id == "transform_trash") {
      return false;
    }
  }

  return true;
}
