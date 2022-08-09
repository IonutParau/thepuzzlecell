part of logic;

void doFloppy(Cell cell, int x, int y) {
  if (cell.data['saved'] == null) {
    cell.data['saved'] = true;

    final bx = frontX(x, (cell.rot - 1) % 4);
    final by = frontY(y, (cell.rot - 1) % 4);

    final lx = frontX(x, (cell.rot - 2) % 4);
    final ly = frontY(y, (cell.rot - 2) % 4);

    final rx = frontX(x, cell.rot);
    final ry = frontY(y, cell.rot);

    cell.data['back'] = (grid.get(bx, by) ?? Cell(bx, by));
    cell.data['left'] = (grid.get(lx, ly) ?? Cell(lx, ly));
    cell.data['right'] = (grid.get(rx, ry) ?? Cell(rx, ry));
  } else {
    final fx = frontX(x, (cell.rot + 1) % 4);
    final fy = frontY(y, (cell.rot + 1) % 4);
    final f = grid.get(fx, fy);
    if (f == null) return;
    if ((f.id == cell.data['back']?.id) && f.id != "empty") cell.rotate(2);
    if ((f.id == cell.data['left']?.id) && f.id != "empty") cell.rotate(1);
    if ((f.id == cell.data['right']?.id) && f.id != "empty") cell.rotate(-1);

    push(x, y, (cell.rot + 1) % 4, 0);
  }
}

void floppys() {
  grid.updateCell(doFloppy, null, "floppy");
}
