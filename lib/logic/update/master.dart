part of logic;

class MasterState {
  Map<String, dynamic> cell;
  LastVars lastVars;
  double x;
  double y;
  int fakelifespan;
  int fakecellScaleX;
  int fakecellScaleY;
  bool active = false;

  MasterState(this.cell, this.x, this.y, this.lastVars, this.fakelifespan, this.fakecellScaleX, this.fakecellScaleY);

  static List<MasterState> _states = [MasterState(Cell(0, 0).toMap, 0, 0, LastVars(0, 0, 0), 0, 1, 1)];

  static bool get isCurrentActive => _states.last.active;
  static MasterState get current => _states.last;
  static void set current(MasterState state) => _states.last = state;
  static void push(MasterState state) => _states.add(state);
  static MasterState pop() {
    final s = _states.removeLast();
    if (_states.isEmpty) {
      _states.add(MasterState.empty);
    }
    return s;
  }

  static MasterState get empty => MasterState(Cell(0, 0).toMap, 0, 0, LastVars(0, 0, 0), 0, 1, 1);

  static bool get usable => current.active;

  // Copies it to an atomic replica
  MasterState get copy => MasterState({...cell}, x, y, lastVars.copy, fakelifespan, fakecellScaleX, fakecellScaleY)..active = active;
}

final masterController = MasterController();

class MasterController {
  void place() {
    final state = MasterState.current;
    if (!state.active) return;
    final c = Cell.fromMap(state.cell, state.x.toInt(), state.y.toInt());
    c.lastvars = state.lastVars.copy;
    grid.set(state.x.toInt(), state.y.toInt(), c);
  }

  void fill(int lx, int ly) {
    final state = MasterState.current;
    if (!state.active) return;
    final sx = state.x.toInt();
    final sy = state.y.toInt();

    for (var cx = sx; (lx > sx) ? cx <= lx : cx >= lx; (lx > sx) ? cx++ : cx--) {
      for (var cy = sy; (ly > sy) ? cy <= ly : cy >= ly; (ly > sy) ? cy++ : cy--) {
        final c = Cell.fromMap(state.cell, cx, cy);
        c.lastvars = state.lastVars.copy;
        grid.set(cx, cy, c);
      }
    }
  }

  void select(int x, int y) {
    if (!grid.inside(x, y)) return;

    final c = grid.at(x, y);

    MasterState.current.cell = c.toMap;
    MasterState.current.x = x.toDouble();
    MasterState.current.y = y.toDouble();
    MasterState.current.lastVars = c.lastvars.copy;
    MasterState.current.fakelifespan = 0;
    MasterState.current.fakecellScaleX = 1;
    MasterState.current.fakecellScaleY = 1;
  }

  void reset() {
    MasterState.current = MasterState.empty;
  }
}

void onMasterPowered(Cell cell, int x, int y) {
  if (cell.id == "master_new_cell") {
    MasterState.current.cell = Cell(0, 0).toMap;
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_place") {
    masterController.place();
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_push_state") {
    MasterState.push(MasterState.empty);
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_pop_state") {
    MasterState.pop();
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_id") {
    MasterState.current.cell['id'] = (cell.data['id'] ?? "empty");
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_idx") {
    try {
      final idx = mathManager.input(x, y, cell.rot - 1).toInt();
      final id = cells[idx % cells.length];
      MasterState.current.cell['id'] = id;
      MasterState.current.active = true;
    } catch (e) {
      MasterState.current.cell['id'] = 'id_setter_error';
      MasterState.current.active = true;
    }
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_select_xy") {
    final cx = mathManager.input(x, y, cell.rot - 1).toInt();
    final cy = mathManager.input(x, y, cell.rot + 1).toInt();
    MasterState.current.active = true;
    masterController.select(cx, cy);
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_xy") {
    final cx = mathManager.input(x, y, cell.rot - 1).toDouble();
    final cy = mathManager.input(x, y, cell.rot + 1).toDouble();
    MasterState.current.active = true;
    MasterState.current.x = cx;
    MasterState.current.y = cy;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_last_xy") {
    final cx = mathManager.input(x, y, cell.rot - 1).toDouble();
    final cy = mathManager.input(x, y, cell.rot + 1).toDouble();
    final lv = Offset(cx, cy);

    MasterState.current.lastVars.lastPos = lv;
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_rot") {
    final rot = mathManager.input(x, y, cell.rot - 1).toInt();

    MasterState.current.cell['rot'] = rot;
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_set_lastrot") {
    final rot = mathManager.input(x, y, cell.rot - 1).toInt();

    MasterState.current.lastVars.lastRot = rot;
    MasterState.current.active = true;
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_fill_xy") {
    final cx = mathManager.input(x, y, cell.rot - 1).toInt();
    final cy = mathManager.input(x, y, cell.rot + 1).toInt();

    masterController.fill(cx, cy);

    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_push") {
    final cx = MasterState.current.x.toInt();
    final cy = MasterState.current.y.toInt();

    final r = mathManager.input(x, y, cell.rot - 1).toInt();

    push(cx, cy, r, cell.data['force'] ?? 1);

    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
  if (cell.id == "master_add_fake") {
    MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
  }
}

num? customMasterNum(Cell cell, int x, int y, int dir) {
  if (cell.id == "master_get_camx") return game.pixelToCellX(game.canvasSize.x ~/ 2);
  if (cell.id == "master_get_camy") return game.pixelToCellY(game.canvasSize.y ~/ 2);
  if (cell.id == "master_get_mousex") return game.cellMouseX;
  if (cell.id == "master_get_mousey") return game.cellMouseY;
  if (cell.id == "master_get_rot") return MasterState.usable ? (MasterState.current.cell['rot'] ?? 0) : 0;
  if (cell.id == "master_get_lastrot") return MasterState.usable ? (MasterState.current.lastVars.lastRot) : 0;
  if (cell.id == "master_get_x") return (cell.cx ?? x);
  if (cell.id == "master_get_y") return (cell.cy ?? y);
  if (cell.id == "master_get_width") return grid.width;
  if (cell.id == "master_get_height") return grid.height;

  return null;
}

void master() {
  if (MasterState.usable) {
    grid.updateCell((cell, x, y) {
      if (MasterState.current.cell['id'] == (cell.data['id'] ?? "empty")) {
        MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
      }
    }, null, "master_has_id");
    grid.updateCell((cell, x, y) {
      final idx = mathManager.input(x, y, cell.rot - 1).toInt();
      final id = cells[idx % cells.length];
      if (MasterState.current.cell['id'] == id) {
        MechanicalManager.spread(frontX(x, cell.rot), frontY(y, cell.rot), 0, false, cell.rot);
      }
    }, null, "master_has_idx");
  }
}
