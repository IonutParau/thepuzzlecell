part of logic;

void doQuantumTomato(Cell cell, int x, int y) {
    final double range = cell.data['range']?.toDouble() ?? 5.0;
    final double strength = cell.data['strength']?.toDouble() ?? 2.0;

    final int r = range.ceil();
    final double r2 = range * range;

    for(int ox = -r; ox < r; ox++) {
        for(int oy = -r; oy < r; oy++) {
            final ex = x + ox,
                ey = y + oy;

            if(!grid.inside(ex, ey)) continue;

            final e = grid.at(ex, ey);

            if(e.id != "electron") continue;

            final d = ox * ox + oy * oy;
            if(d > r2) continue;

            final a = atan2(oy, ox);
            var offa = 90.0;
            final dr = sqrt(d);
            offa /= dr;
            offa = 90.0 - offa;
            final fd = a + offa / 180.0 * pi;

            final fx = cos(fd) * strength;
            final fy = cos(fd) * strength;

            e.data['vel_x'] ??= 0.0;
            e.data['vel_y'] ??= 0.0;

            e.data['vel_x'] += fx;
            e.data['vel_y'] += fy;
        }
    }
}

void references() {
  if (grid.movable) {
    for (var rot in rotOrder) {
      grid.updateCell(
        (cell, x, y) {
          grid.rotate(frontX(cell.cx ?? x, cell.rot),
              frontY(cell.cy ?? y, cell.rot), 1);
          grid.rotate(frontX(cell.cx ?? x, cell.rot + 1),
              frontY(cell.cy ?? y, cell.rot + 1), 1);
          grid.rotate(frontX(cell.cx ?? x, cell.rot + 2),
              frontY(cell.cy ?? y, cell.rot + 2), 1);
          grid.rotate(frontX(cell.cx ?? x, cell.rot + 3),
              frontY(cell.cy ?? y, cell.rot + 3), 1);

          final a = grid.get(x - 1, y);
          final b = grid.get(x + 1, y);
          final c = grid.get(x, y - 1);
          final d = grid.get(x, y + 1);

          if (a != null && a.id != "empty" && !isUngennable(a, x, y, 0)) {
            Cell ac = a.copy;
            ac.updated =
                ac.updated || shouldHaveGenBias(ac.id, toSide(0, ac.rot));
            push(
              x + 1,
              y,
              0,
              1,
              replaceCell: ac,
            );
          }
          if (b != null && b.id != "empty" && !isUngennable(b, x, y, 2)) {
            Cell bc = b.copy;
            bc.updated =
                bc.updated || shouldHaveGenBias(bc.id, toSide(2, bc.rot));
            push(
              x - 1,
              y,
              2,
              1,
              replaceCell: bc,
            );
          }
          if (c != null && c.id != "empty" && !isUngennable(c, x, y, 1)) {
            Cell cc = c.copy;
            cc.updated =
                cc.updated || shouldHaveGenBias(cc.id, toSide(2, cc.rot));
            push(
              x,
              y + 1,
              1,
              1,
              replaceCell: cc,
            );
          }
          if (d != null && d.id != "empty" && !isUngennable(d, x, y, 3)) {
            Cell dc = d.copy;
            dc.updated =
                dc.updated || shouldHaveGenBias(dc.id, toSide(2, dc.rot));
            push(
              x,
              y - 1,
              3,
              1,
              replaceCell: dc,
            );
          }
        },
        rot,
        "nuke",
      );
    }
    for (var rot in rotOrder) {
      grid.updateCell((cell, x, y) {
        pull(x, y, cell.rot, 0);
      }, rot, "cellua");
    }
    for (var rot in rotOrder) {
      grid.updateCell((cell, x, y) {
        push(x, y, cell.rot, 0);
      }, rot, "mystic_x");
    }
    grid.updateCell(doQuantumTomato, null, "quantum_tomato");
  }
}
