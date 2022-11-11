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
}

final scriptingManager = ScriptingManager();

class ScriptingError {
  String errorMsg;
  List<String> stackTrace;

  ScriptingError(this.errorMsg, this.stackTrace);
}
