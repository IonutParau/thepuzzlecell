import '../logic/logic.dart';

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

  int addedForce(Cell cell, int dir, int force, MoveType moveType) {
    return 0;
  }

  bool moveInsideOf(Cell into, int x, int y, int dir, int force, MoveType mt) {
    return false;
  }

  void handleInside(int x, int y, int dir, int force, Cell moving, MoveType mt) {
    return;
  }
}

final scriptingManager = ScriptingManager();
