part of logic;

class WorldManager {
  List<String> _worlds = [];

  void LoadWorldsFromSettings() {
    if (storage.getStringList("worlds") != null) {
      _worlds = storage.getStringList("worlds")!;
    }
  }

  String worldAt(int i) => _worlds[i];

  int get worldLength => _worlds.length;

  void SaveWorldsToSettings() {
    storage.setStringList("worlds", _worlds);
  }

  void AddWorld(String title, String description, int x, int y) {
    final g = Grid(x, y);
    _worlds.add(P3.encodeGrid(g, title: title, description: description));
    SaveWorldsToSettings();
  }

  void SaveWorld(int i) {
    final str = _worlds[i].split(';');
    var g = game.isinitial ? grid : game.initial;
    _worlds[i] = P3.encodeGrid(g, title: str[1], description: str[2]);
    SaveWorldsToSettings();
  }

  void DeleteWorld(int i) {
    _worlds.removeAt(i);
    SaveWorldsToSettings();
  }
}

int? worldIndex = null;

final worldManager = WorldManager();
