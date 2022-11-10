part of scripts;

// Container for all things with Lua modding
class LuaScript {
  LuaState ls;
  Directory dir;

  String get id => path.split(dir.path).last;

  int apiInvokes = 0;

  List<ScriptingError> errors = [];

  LuaScript(this.dir) : ls = LuaState.newState();

  // Handle memory safety
  void collected(LuaState ls, void Function() func, [int expectedReturns = 0]) {
    // Get size of stack
    final original = ls.getTop();

    // Run out epic code that MIGHT leak memory on the stack
    func();

    // Auto-remove waste
    while (ls.getTop() - expectedReturns > original) {
      ls.remove(ls.getTop() - expectedReturns);
    }
  }

  void defineFunc(String name, DartFunction func, int returns, [int minArgs = 0]) {
    ls.pushDartFunction((ls) {
      int result = 0;

      collected(ls, () {
        while (ls.getTop() < minArgs) {
          ls.pushNil();
        }

        try {
          result = func(ls);
        } catch (e) {
          // This can cause UB!!!
          result = returns;

          errors.add(ScriptingError(e.toString(), []));
        }
      }, returns);

      if (result != returns) {
        throw "INTERNAL API ERROR: API wants to return $returns but instead returned $result!!!";
      }

      return returns;
    });
    ls.setField(-1, name);
  }

  void defineGroup(String name, void Function() toRun, [bool global = false]) {
    collected(ls, () {
      ls.newTable();

      toRun();

      if (global) {
        ls.setGlobal(name);
      } else {
        ls.setField(-1, name);
      }
    });
  }

  void OnMsg(String msg) {
    ls.getGlobal("TPC");
    ls.getField(-1, "OnMsg");
    ls.pushString(msg);
    ls.call(1, 0);
  }

  Set<String> definedCells = {};

  bool hasDefinedCell(String cell) => definedCells.contains(cell);

  int defineCell(LuaState ls) {
    if (ls.isTable(-1)) {
      ls.getField(-1, "id");
      final cell = ls.toStr(-1)!;
      if (cells.contains(cell)) return 0;
      ls.getField(-2, "name");
      final name = ls.toStr(-1)!;
      ls.getField(-3, "desc");
      final desc = ls.toStr(-1)!;
      ls.pop(3);
      definedCells.add(cell);
      cells.add(cell);
      cellInfo[cell] = CellProfile(name, desc);
      ls.setGlobal("PROPS:$cell");
    }
    return 0;
  }

  void pushDefinedCellProperty(String cell, String key) {
    ls.getGlobal("PROPS:$cell");
    ls.getField(-1, key);
  }

  void loadAPI() {
    ls.openLibs();

    defineGroup("TPC", () {
      defineFunc("OnMsg", (ls) => 0, 0);

      defineFunc("DefineCell", defineCell, 1);
    }, true);
  }

  int importOther(LuaState ls) {
    final str = ls.checkString(1) ?? "";
    ls.loadFile(path.joinAll([dir.path, ...str.split('/')]));
    return 0;
  }

  void init() {
    loadAPI();
    ls.loadFile(path.joinAll([dir.path, 'main.lua']));
  }
}
