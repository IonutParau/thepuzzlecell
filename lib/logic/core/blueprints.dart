part of logic;

var blueprints = <String>[];

Future<void> loadBlueprints() async {
  blueprints = (await loadFileData("assets/blueprints.txt")).split('\n');
  return;
}

Future<void> saveBlueprints() async {
  File(path.join(assetsPath, 'assets', 'blueprints.txt'))
      .writeAsStringSync(blueprints.join('\n'));
  return;
}

void loadBlueprint(int i) {
  final g = loadStr(blueprints[i], false);
  final gc = GridClip();
  gc.activate(g.width, g.height,
      g.tiles.map((row) => row.map((tile) => tile.cell).toList()).toList());
  gc.optimize();

  game.gridClip = gc;

  game.pasting = true;

  game.buttonManager.buttons['paste-btn']?.texture = 'interface/paste_on.png';

  game.buttonManager.buttons['select-btn']?.texture = "interface/select.png";
}

void addBlueprints() {
  final toolsCat = categories.first;
  final blueprintsCat = toolsCat.items.first as CellCategory;
  for (var i = 0; i < blueprints.length; i++) {
    blueprintsCat.items.add("blueprint $i");
    textureMap["blueprint $i.png"] = textureMap["blueprint.png"]!;
    cellInfo["blueprint $i"] = CellProfile(
      blueprints[i].split(';')[1],
      blueprints[i].split(';')[2],
    );
  }
  blueprintsCat.max = ceil(sqrt(blueprints.length) + 0.5);
  //game.loadAllButtons();
}

Future addBlueprint(String blueprint) async {
  blueprints.add(blueprint);
  final file = File(path.join(assetsPath, 'assets', 'blueprints.txt'));
  if (file.existsSync()) {
    await file.writeAsString(blueprints.join("\n"));
  }
  // Grab category, grab subcategory, clear contents
  categories.first.items.first.items.clear();
  addBlueprints();
  game.buttonManager.buttons.removeWhere((id, btn) {
    return id.startsWith('cat');
  });
  game.loadCellButtons();
}

Future removeBlueprint(String blueprint) async {
  blueprints.remove(blueprint);
  final file = File(path.join(assetsPath, 'assets', 'blueprints.txt'));
  if (file.existsSync()) {
    await file.writeAsString(blueprints.join("\n"));
  }
  // Grab category, grab subcategory, clear contents
  categories.first.items.first.items.clear();
  addBlueprints();
  game.buttonManager.buttons.removeWhere((id, btn) {
    return id.startsWith('cat');
  });
  game.loadCellButtons();
}
