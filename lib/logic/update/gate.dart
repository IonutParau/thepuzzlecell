part of logic;

enum GateType { AND, OR, XOR, NOT, NAND, NOR, XNOR }

void doGate(int x, int y, int rot, GateType gateType) {
  if (gateType == GateType.NOT) {
    final back = inFront(x, y, (rot + 2) % 4);
    if (back != null) {
      if (!MechanicalManager.on(back)) {
        MechanicalManager.spread(frontX(x, rot), frontY(y, rot), 0, false, rot);
      }
    }
  } else {
    final ic1 = inFront(x, y, rot - 1);
    final ic2 = inFront(x, y, rot + 1);

    final i1 = ic1 == null ? false : MechanicalManager.on(ic1);
    final i2 = ic2 == null ? false : MechanicalManager.on(ic2);

    void activate() {
      MechanicalManager.spread(frontX(x, rot), frontY(y, rot), 0, false, rot);
    }

    switch (gateType) {
      case GateType.AND:
        if (i1 && i2) activate();
        break;
      case GateType.OR:
        if (i1 || i2) activate();
        break;
      case GateType.XOR:
        if (i1 != i2) activate();
        break;
      case GateType.NAND:
        if (!(i1 && i2)) activate();
        break;
      case GateType.NOR:
        if (!(i1 || i2)) activate();
        break;
      case GateType.XNOR:
        if (i1 == i2) activate();
        break;
      default:
        break;
    }
  }
}

void gates(Set<String> cells) {
  for (var rot in rotOrder) {
    if (cells.contains("and_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.AND);
        },
        rot,
        "and_gate",
      );
    }
    if (cells.contains("or_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.OR);
        },
        rot,
        "or_gate",
      );
    }
    if (cells.contains("xor_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.XOR);
        },
        rot,
        "xor_gate",
      );
    }
    if (cells.contains("not_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NOT);
        },
        rot,
        "not_gate",
      );
    }
    if (cells.contains("nand_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NAND);
        },
        rot,
        "nand_gate",
      );
    }
    if (cells.contains("nor_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.NOR);
        },
        rot,
        "nor_gate",
      );
    }
    if (cells.contains("xnor_gate")) {
      grid.updateCell(
        (cell, x, y) {
          doGate(x, y, cell.rot, GateType.XNOR);
        },
        rot,
        "xnor_gate",
      );
    }
  }
}
