part of logic;

void doFactory(Cell cell, int x, int y) {
  cell.data['t'] ??= 0;
  cell.data['t']++;

  cell.data['interval'] ??= 1;

  if (cell.data['interval'] <= 0) return;

  while (cell.data['t'] >= cell.data['interval']) {
    cell.data['t'] -= cell.data['interval'];
    final physical = cell.data['physical'] ?? false;
    final quantized = cell.data['quantized'] ?? false;

    final ox = frontX(x, cell.rot);
    final oy = frontY(y, cell.rot);

    if (genOptimizer.shouldSkip(ox, oy, cell.rot) && !physical) {
      genOptimizer.skip(x, y, cell.rot);
      return;
    }

    final c = cell.data['cell'] ?? "push!0";
    final addRot = cell.data['addrot'] ?? false;

    final id = parseJointCellStr(c)[0] as String;
    final r = parseJointCellStr(c)[1];
    var rot = r;
    if (addRot) rot += cell.rot;
    rot %= 4;

    final output = Cell(x, y);
    output.cx = frontX(x, cell.rot + 2);
    output.cy = frontY(y, cell.rot + 2);
    output.id = id;
    output.rot = rot;
    output.lastvars.lastRot = r;
    output.tags.add("gend ${cell.rot}");
    final p = props[output.id];
    if (p != null) {
      for (var prop in p) {
        output.data[prop.key] = prop.def;
      }
    }

    if (shouldHaveGenBias(output.id, toSide(cell.rot, output.rot))) {
      output.updated = true;
    }

    if (quantized) {
      unstableGen(x, y, cell.rot, output.copy);
    } else if (!push(ox, oy, cell.rot, 1, replaceCell: output)) {
      if (!physical) return;
      if (!push(x, y, (cell.rot + 2) % 4, 1)) return;
      output.lastvars.lastPos = cell.lastvars.lastPos.scale(1, 1);
      if (!push(x, y, cell.rot, 1, replaceCell: output)) return;
    }
    x = cell.cx ?? x;
    y = cell.cy ?? y;
  }
}

void factories() {
  for (var rot in rotOrder) {
    grid.updateCell(doFactory, rot, "factory");
  }
}
