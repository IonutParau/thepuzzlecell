class ScriptingManager {
  void loadScripts([List<String> blocked = const []]) {
    return;
  }

  String scriptType(String id) {
    return "unknown";
  }

  Set<String> getScripts() {
    return {};
  }

  void initScripts() {
    return;
  }

  void OnMsg(String id, String msg) {
    return;
  }
}

final scriptingManager = ScriptingManager();
