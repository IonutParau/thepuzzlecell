part of scripts;

class ScriptingManager {
  final directory = Directory(path.join(assetsPath, 'mods'));

  List<LuaScript> luaScripts = [];

  void loadScripts([List<String> blocked = const []]) {
    final subdirs = directory.listSync().where((e) => e is Directory).cast<Directory>();

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
}

final scriptingManager = ScriptingManager();

class ScriptingError {
  String errorMsg;
  List<String> stackTrace;

  ScriptingError(this.errorMsg, this.stackTrace);
}
