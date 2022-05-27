part of logic;

class WorldManager {
  List<String> _worlds = [];

  void loadWorldsFromSettings() {
    if (storage.getStringList("worlds") != null) {
      _worlds = storage.getStringList("worlds")!;
    }
  }

  String worldAt(int i) => _worlds[i];

  int get worldLength => _worlds.length;

  void saveWorldsToSettings() {
    storage.setStringList("worlds", _worlds);
  }

  void addWorld(String title, String description, int x, int y) {
    final g = Grid(x, y);
    _worlds.add(P3.encodeGrid(g, title: title, description: description));
    saveWorldsToSettings();
  }

  void saveWorld(int i) {
    final str = _worlds[i].split(';');
    var g = game.isinitial ? grid : game.initial;
    _worlds[i] = P3.encodeGrid(g, title: str[1], description: str[2]);
    saveWorldsToSettings();
  }

  void deleteWorld(int i) {
    _worlds.removeAt(i);
    saveWorldsToSettings();
  }
}

int? worldIndex;

final worldManager = WorldManager();
