part of scripts;

class ScriptingManager {
  final directory = Directory(path.join(assetsPath, 'mods'));

  List<LuaScript> luaScripts = [];

  void loadScripts([List<String> blocked = const []]) {
    final subitems = directory.listSync();
    final subdirs = subitems.where((e) => e is Directory).cast<Directory>();

    for (var subdir in subdirs) {
      final id = path.split(subdir.path).last;

      if (!blocked.contains(id)) {
        final luaFile = File(path.join(subdir.path, 'main.lua'));
        final arrowFile = File(path.join(subdir.path, 'main.arrow'));

        if (luaFile.existsSync()) {
          luaScripts.add(LuaScript(subdir));
        }
        if (arrowFile.existsSync()) {
          throw "Arrow is not supported yet.";
        }
      }
    }
  }

  String scriptType(String id) {
    bool isArrow = false;
    bool isLua = luaScripts.where((e) => e.id == id).isNotEmpty;

    if (isLua && !isArrow) return "lua";
    if (isArrow && !isLua) return "arrow";
    if (isArrow && isLua) return "hybrid";

    return "unknown";
  }

  Set<String> getScripts() {
    final luas = luaScripts.map((e) => e.id);
    final arrows = [];

    return {...luas, ...arrows};
  }

  void initScripts() {
    for (var script in luaScripts) {
      script.init();
    }
  }

  void OnMsg(String id, String msg) {
    for (var script in luaScripts) {
      if (script.id == id) {
        script.OnMsg(msg);
      }
    }
  }

  int addedForce(Cell cell, int dir, int force, MoveType moveType) {
    final id = cell.id;
    final side = toSide(dir, cell.rot);
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(id)) {
        return lua.addedForce(cell, dir, force, side, moveType.name) ?? 0;
      }
    }

    return 0;
  }

  bool moveInsideOf(Cell into, int x, int y, int dir, int force, MoveType mt) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(into.id)) {
        return lua.moveInsideOf(into, x, y, dir, force, mt.name) ?? false;
      }
    }

    return false;
  }

  void handleInside(int x, int y, int dir, int force, Cell moving, MoveType mt) {
    final destroyer = grid.at(x, y);
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(destroyer.id)) {
        return lua.handleInside(x, y, dir, force, moving, mt.name);
      }
    }
  }

  bool acidic(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int my) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(cell.id)) {
        return lua.isAcidic(cell, dir, force, mt.name, melting, mx, my) ?? false;
      }
    }

    return false;
  }

  void handleAcid(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int my) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(cell.id)) {
        return lua.handleAcid(cell, dir, force, mt.name, melting, mx, my);
      }
    }
  }

  void addToCat(String cat, String cell) {
    final parts = cat.split('/');

    CellCategory? current;

    while (parts.isNotEmpty) {
      if (current == null) {
        final found = categories.where((cat) => cat.title == parts.first);
        if (found.isEmpty) {
          return;
        }
        current = found.first;
      } else {
        final found = current.items.where((cat) => cat is CellCategory && cat.title == parts.first);
        if (found.isEmpty) {
          return;
        }
        current = found.first;
      }
      parts.removeAt(0);
    }

    current?.items.add(cell);
  }

  void addToCats(List<String> cats, String cell) {
    cats.forEach((cat) => addToCat(cat, cell));
  }

  bool canMove(Cell cell, int x, int y, int dir, int side, int force, MoveType mt) {
    for (var lua in luaScripts) {
      return lua.canMove(cell, x, y, dir, side, force, mt.name) ?? true;
    }

    return true;
  }

  String modOrigin(String id) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(id)) return lua.id;
    }

    return "";
  }

  String modName(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        return lua.info['name'] ?? "Unnamed";
      }
    }

    return "";
  }
}

final scriptingManager = ScriptingManager();

class ScriptingError {
  String errorMsg;
  List<String> stackTrace;

  ScriptingError(this.errorMsg, this.stackTrace);
}
