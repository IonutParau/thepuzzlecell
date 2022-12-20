part of scripts;

class ModInfo {
  String title;
  String desc;
  String author;
  String icon;
  Set<String> cells;

  ModInfo(this.title, this.desc, this.author, this.icon, this.cells);
}

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

        if (luaFile.existsSync()) {
          luaScripts.add(LuaScript(subdir));
        }
      }
    }
  }

  String scriptType(String id) {
    bool isLua = luaScripts.where((e) => e.id == id).isNotEmpty;

    return isLua ? "Lua" : "unknown";
  }

  Set<String> getScripts() {
    final luas = luaScripts.map((e) => e.id);
    final arrows = [];

    return {...luas, ...arrows};
  }

  Future<void> initScripts() async {
    LuaState.loadLibLua(
      windows: 'dlls/lua54.dll',
      linux: 'dlls/liblua54.so',
      macos: 'dlls/liblua52.dylib',
    );
    for (var script in luaScripts) {
      await script.init();
    }

    return;
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
        return lua.addedForceModded(cell, dir, force, side, moveType.name) ?? 0;
      }
    }

    return 0;
  }

  bool moveInsideOf(Cell into, int x, int y, int dir, int force, MoveType mt) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(into.id)) {
        return lua.moveInsideOfModded(into, x, y, dir, force, mt.name) ?? false;
      }
    }

    return false;
  }

  void handleInside(
      int x, int y, int dir, int force, Cell moving, MoveType mt) {
    final destroyer = grid.at(x, y);
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(destroyer.id)) {
        return lua.handleInsideModded(x, y, dir, force, moving, mt.name);
      }
    }
  }

  bool acidic(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx,
      int my) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(cell.id)) {
        return lua.isAcidicModded(cell, dir, force, mt.name, melting, mx, my) ??
            false;
      }
    }

    return false;
  }

  void handleAcid(Cell cell, int dir, int force, MoveType mt, Cell melting,
      int mx, int my) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(cell.id)) {
        return lua.handleAcidModded(cell, dir, force, mt.name, melting, mx, my);
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
        final found = current.items
            .where((cat) => cat is CellCategory && cat.title == parts.first);
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

  bool canMove(
      Cell cell, int x, int y, int dir, int side, int force, MoveType mt) {
    for (var lua in luaScripts) {
      return lua.canMoveModded(cell, x, y, dir, side, force, mt.name) ?? true;
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

    return "Unnamed";
  }

  String modDesc(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        return lua.info['desc'] ?? "No Description available";
      }
    }

    return "No Description available";
  }

  String modAuthor(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        return lua.info['author'] ?? "Unknown Author";
      }
    }

    return "Unknown Author";
  }

  String modIcon(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        final p = path.join(lua.dir.path, 'icon.png');
        return File(p).existsSync()
            ? "mods/${id}/icon.png"
            : 'assets/images/modDefaultIcon.png';
      }
    }

    return "assets/images/modDefaultIcon.png";
  }

  Set<String> modCells(String id) {
    final l = <String>{};

    for (var lua in luaScripts) {
      if (lua.id == id) {
        l.addAll(lua.definedCells);
      }
    }

    return l;
  }
}

final scriptingManager = ScriptingManager();
