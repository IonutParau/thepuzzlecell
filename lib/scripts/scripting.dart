part of scripts;

class ModInfo {
  String title;
  String desc;
  String author;
  String icon;
  Directory dir;
  Set<String> cells;
  String? readme;

  ModInfo(this.title, this.desc, this.author, this.icon, this.dir, this.cells, this.readme);
}

class ScriptingManager {
  final directory = Directory(path.join(assetsPath, 'mods'));

  List<LuaScript> luaScripts = [];

  Map<String, List<void Function(String)>> channels = {};

  void createChannel(String id) {
    channels[id] ??= [];
  }

  void sendToChannel(String id, String data) {
    channels[id]?.forEach((fn) => fn(data));
  }

  bool hasChannel(String id) => channels.containsKey(id);

  void listenToChannel(String id, void Function(String) callback) {
    if (!hasChannel(id)) {
      createChannel(id);
    }

    channels[id]!.add(callback);
  }

  void loadScripts([List<String> blocked = const []]) {
    if (!Directory('dlls').existsSync()) {
      return;
    }
    final subitems = directory.listSync();
    final subdirs = subitems.whereType<Directory>().cast<Directory>();

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

  Set<String> getScripts() {
    return luaScripts.map((e) => e.id).toSet();
  }

  final loaded = <String>{};

  List<void Function()> postInit = [];

  Future<void> initScripts() async {
    if (!Directory('dlls').existsSync()) {
      return;
    }

    LuaState.loadLibLua(
      windows: 'dlls/lua54.dll',
      linux: 'dlls/liblua54.so',
      macos: 'dlls/liblua52.dylib',
    );
    for (var script in luaScripts) {
      loaded.add(script.id);
      await script.init();
    }

    while (postInit.isNotEmpty) {
      postInit.removeAt(0)();
    }

    return;
  }

  void onMsg(String id, String msg) {
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

  void handleInside(int x, int y, int dir, int force, Cell moving, MoveType mt) {
    final destroyer = grid.at(x, y);
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(destroyer.id)) {
        return lua.handleInsideModded(x, y, dir, force, moving, mt.name);
      }
    }
  }

  bool acidic(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int my) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(cell.id)) {
        return lua.isAcidicModded(cell, dir, force, mt.name, melting, mx, my) ?? false;
      }
    }

    return false;
  }

  void handleAcid(Cell cell, int dir, int force, MoveType mt, Cell melting, int mx, int my) {
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

  CellCategory? catByName(String cat) {
    final parts = cat.split('/');

    CellCategory? current;

    while (parts.isNotEmpty) {
      if (current == null) {
        final found = categories.where((cat) => cat.title == parts.first);
        if (found.isEmpty) {
          return null;
        }
        current = found.first;
      } else {
        final found = current.items.where((cat) => cat is CellCategory && cat.title == parts.first);
        if (found.isEmpty) {
          return null;
        }
        current = found.first;
      }
      parts.removeAt(0);
    }

    return current;
  }

  void addToCats(List<String> cats, String cell) {
    for (var cat in cats) {
      addToCat(cat, cell);
    }
  }

  bool canMove(Cell cell, int x, int y, int dir, int side, int force, MoveType mt) {
    for (var lua in luaScripts) {
      return lua.canMoveModded(cell, x, y, dir, side, force, mt.name) ?? true;
    }

    return true;
  }

  String modOrigin(String id) {
    for (var lua in luaScripts) {
      if (lua.definedCells.contains(id)) {
        return lua.id;
      }
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
        return File(p).existsSync() ? "mods/$id/icon.png" : 'assets/images/modDefaultIcon.png';
      }
    }

    return "assets/images/modDefaultIcon.png";
  }

  Directory modDir(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        return lua.dir;
      }
    }

    return Directory.current;
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

  String? modReadme(String id) {
    for (var lua in luaScripts) {
      if (lua.id == id) {
        final f = File(path.join(lua.dir.path, 'README.md'));
        return f.existsSync() ? f.readAsStringSync() : null;
      }
    }

    return null;
  }

  bool isSticky(Cell cell, int x, int y, int dir, bool base, bool checkedAsBack, int originX, int originY) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.isSticky(cell, x, y, dir, base, checkedAsBack, originX, originY) ?? false;
      }
    }

    return false;
  }

  bool sticksTo(Cell cell, Cell to, int dir, bool base, bool checkedAsBack, int originX, int originY) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.sticksTo(cell, to, dir, base, checkedAsBack, originX, originY) ?? false;
      }
    }

    return false;
  }

  bool blocksUnstable(Cell cell, int x, int y, int dir, Cell moving) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.blocksUnstable(cell, x, y, dir, moving);
      }
    }

    return false;
  }

  bool shouldHaveGenBias(String id, int side) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(id)) {
        return lua.shouldHaveGenBias(id, side);
      }
    }

    return false;
  }

  bool isUngeneratable(Cell cell, int x, int y, int dir) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.isUngeneratable(cell, x, y, dir);
      }
    }

    return false;
  }

  String? customText(Cell cell, num x, num y) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.customText(cell, x, y);
      }
    }

    return null;
  }

  bool hasGrabberBias(Cell cell, int x, int y, int dir, int mdir) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.hasGrabberBias(cell, x, y, dir, mdir);
      }
    }

    return false;
  }

  bool moddedBreakable(Cell cell, int x, int y, int dir, BreakType bt) {
    for (var lua in luaScripts) {
      if (lua.hasDefinedCell(cell.id)) {
        return lua.moddedBreakable(cell, x, y, dir, bt);
      }
    }

    return false;
  }

  void createCategory(String host, String name, String desc, String look, int max) {
    if (host.isEmpty) {
      categories.add(CellCategory(name, desc, [], look, max: max));
      return;
    }

    final parts = host.split('/');
    List<dynamic> cats = categories;

    while (parts.isNotEmpty) {
      final curr = parts.removeAt(0);

      var found = false;

      for (var cat in cats) {
        if (cat is! CellCategory) {
          continue;
        }
        if (cat.title == curr) {
          cats = cat.items;
          found = true;
          break;
        }
      }
      if (!found) {
        return;
      }
    }
    cats.add(CellCategory(name, desc, [], look, max: max));
  }

  void mathWhenWritten(Cell cell, int x, int y, int dir, num amount) {
    for(var lua in luaScripts) {
      if(lua.hasDefinedCell(cell.id)) {
        lua.mathWhenWritten(cell, x, y, dir, amount);
        return;
      }
    }
  }


  num? mathCustomCount(Cell cell, int x, int y, int dir) {
    for(var lua in luaScripts) {
      if(lua.hasDefinedCell(cell.id)) {
        return lua.mathCustomCount(cell, x, y, dir);
      }
    }
    
    return null;
  }

  bool mathAutoApplyCount(Cell cell, int cx, int cy, int dir, num count, int ox, int oy) {
    for(var lua in luaScripts) {
      if(lua.hasDefinedCell(cell.id)) {
        return lua.mathAutoApplyCount(cell, cx, cy, dir, count, ox, oy);
      }
    }
    return true;
  }

  bool mathIsWritable(Cell cell, int x, int y, int dir) {
    for(var lua in luaScripts) {
      if(lua.hasDefinedCell(cell.id)) {
        return lua.mathIsWritable(cell, x, y, dir);
      }
    }
    return false;
  }

  bool mathIsOutput(Cell cell, int x, int y, int dir) {
    for(var lua in luaScripts) {
      if(lua.hasDefinedCell(cell.id)) {
        return lua.mathIsOutput(cell, x, y, dir);
      }
    }
    return false;
  }
}

final scriptingManager = ScriptingManager();
