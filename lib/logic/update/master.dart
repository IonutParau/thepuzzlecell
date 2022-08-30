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

  void reset() {
    MasterState.current = MasterState.empty;
  }
}

void onMasterPowered(Cell cell, int x, int y) {}

num? customMasterNum() {
  return null;
}
