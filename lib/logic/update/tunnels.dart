part of logic;

void tunnels() {
  if (!grid.movable) return;
  genOptimizer.clear();
  // Tunnels
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doTunnel(x, y, cell.rot);
      },
      rot,
      "tunnel",
    );
    grid.updateCell(
      (cell, x, y) {
        doTunnel(x, y, cell.rot, (cell.rot + 1) % 4);
      },
      rot,
      "tunnel_cw",
    );
    grid.updateCell(
      (cell, x, y) {
        doTunnel(x, y, cell.rot, (cell.rot + 3) % 4);
      },
      rot,
      "tunnel_ccw",
    );
    grid.updateCell(
      (cell, x, y) {
        doMultiTunnel(x, y, cell.rot, [
          cell.rot + 1,
          cell.rot + 3,
        ]);
      },
      rot,
      "dual_tunnel",
    );
    grid.updateCell(
      (cell, x, y) {
        doMultiTunnel(x, y, cell.rot, [
          cell.rot,
          (cell.rot + 1) % 4,
          (cell.rot + 3) % 4,
        ]);
      },
      rot,
      "triple_tunnel",
    );
  }

  // Warpers
  for (var rot in rotOrder) {
    grid.updateCell(
      (cell, x, y) {
        doWarper(x, y, cell.rot, cell.rot);
      },
      rot,
      "warper",
    );
    grid.updateCell(
      (cell, x, y) {
        doWarper(x, y, cell.rot, (cell.rot + 1) % 4);
      },
      rot,
      "warper_cw",
    );
    grid.updateCell(
      (cell, x, y) {
        doWarper(x, y, cell.rot, (cell.rot + 3) % 4);
      },
      rot,
      "warper_ccw",
    );
  }
}

bool doTunnel(int x, int y, int dir, [int? odir]) {
  odir ??= dir;

  var addedRot = (odir - dir + 4) % 4;

  odir %= 4;

  final fx = frontX(x, odir);
  final fy = frontY(y, odir);

  if (genOptimizer.shouldSkip(fx, fy, odir)) return false;

  var bx = frontX(x, dir + 2);
  var by = frontY(y, dir + 2);

  var nc = nextCell(bx, by, (dir + 2) % 4);
  if (nc.broken) return false;
  bx = nc.x;
  by = nc.y;
  addedRot -= nc.addedrot;
  addedRot %= 4;

  if (grid.inside(fx, fy) && grid.inside(bx, by)) {
    if (!canMove(bx, by, dir, 1, MoveType.tunnel)) {
      return false;
    }

    final moving = grid.at(bx, by).copy;
    if (ungennable.contains(moving.id)) return false;
    if (moving.id == "empty") return false;
    if (moving.tags.contains('tunneled')) return false;

    moving.rot = (moving.rot + addedRot) % 4;
    moving.tags.add("tunneled");

    if (CellTypeManager.tunnels.contains(moving.id) && moving.rot == odir)
      moving.updated = true;
    if (push(fx, fy, odir, 1, mt: MoveType.tunnel, replaceCell: moving)) {
      grid.set(bx, by, Cell(bx, by));
      return true;
    } else {
      genOptimizer.skip(fx, fy, odir);
      return false;
    }
  }

  return false;
}

void doMultiTunnel(int x, int y, int dir, List<int> dirs) {
  bool successful = false;

  final bx = frontX(x, dir + 2);
  final by = frontY(y, dir + 2);

  if (!grid.inside(bx, by)) return;

  final c = grid.at(bx, by).copy;

  for (var odir in dirs) {
    if (doTunnel(x, y, dir, odir)) {
      grid.set(bx, by, c.copy);
      successful = true;
    }
  }

  if (successful) {
    grid.set(bx, by, Cell(bx, by));
  }
}

void doWarper(int x, int y, int dir, int odir) {
  final bx = frontX(x, (dir + 2) % 4);
  final by = frontY(y, (dir + 2) % 4);

  if (!grid.inside(bx, by)) return;
  if (ungennable.contains(grid.at(bx, by).id)) return;
  if (grid.at(bx, by).id.startsWith("warper")) return;

  var fx = x;
  var fy = y;

  var depth = 0;

  var addedRot = odir - dir + 4;

  while (true) {
    depth++;
    if (depth == 10000) return;
    fx = frontX(fx, odir);
    fy = frontY(fy, odir);

    if (!grid.inside(fx, fy)) return;

    final f = grid.at(fx, fy);

    if (f.id == "warper") {
    } else if (f.id == "warper_cw") {
      odir = (odir + 1) % 4;
      addedRot++;
    } else if (f.id == "warper_ccw") {
      odir = (odir + 3) % 4;
      addedRot = addedRot + 3;
    } else {
      break;
    }
  }

  addedRot %= 4;
  final moving = grid.at(bx, by).copy;
  moving.rot = (moving.rot + addedRot) % 4;
  if (push(fx, fy, odir, 1, mt: MoveType.tunnel, replaceCell: moving)) {
    grid.set(bx, by, Cell(bx, by));
  }
}
