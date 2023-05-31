part of logic;

void enableCheckpoint(Cell cell, int x, int y) {
  if (cell.data['checkpoint_enabled'] == true) return;

  if (cell.data['checkpoint_reset'] == true) {
    grid.loopChunks("checkpoint", GridAlignment.bottomright, (cell, x, y) {
      cell.data.remove('checkpoint_enabled');
    }, shouldUpdate: false, filter: (c, x, y) => c.id == "checkpoint");
    grid.loopChunks("mech_checkpoint", GridAlignment.bottomright, (cell, x, y) {
      cell.data.remove('checkpoint_enabled');
    }, shouldUpdate: false, filter: (c, x, y) => c.id == "mech_checkpoint");
  }

  cell.data['checkpoint_enabled'] = true;
}

void doCheckpoint(Cell cell, int x, int y) {
  if (cell.tags.contains("checkpoint_update")) return;
  cell.updated = false;
  cell.tags.add("checkpoint_update");
  if (cell.data['checkpoint_enabled'] != true) return;

  if (!grid.cells.containsAny(CellTypeManager.puzzles)) {
    final o = (cell.copy..id = "puzzle");
    if (cell.data['reset_rot'] == true) {
      o.rot = 0;
      o.lastvars.lastRot = 0;
    }
    push(frontX(x, cell.rot), frontY(y, cell.rot), cell.rot, 1,
        mt: MoveType.puzzle, replaceCell: o);
  }
}

void checkpoints() {
  grid.updateCell(doCheckpoint, null, "checkpoint");
  grid.updateCell(doCheckpoint, null, "mech_checkpoint");
}
