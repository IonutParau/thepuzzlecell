part of logic;

final biomes = [
  "biome_cw",
  "biome_ccw",
  "desert",
  "snowy",
  "forest",
  "freezing",
  "trash_biome",
  "quantum_biome",
  "no_burn_biome",
  "consistency_biome",
  "mechanical_halting",
];

// Biomes
void biome() {
  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    grid.rotate(x, y, 1);
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "biome_cw");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    grid.rotate(x, y, 3);
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "biome_ccw");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    cell.data['heat'] = (cell.data['heat'] ?? 0) + 1;
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "desert");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    cell.data['heat'] = (cell.data['heat'] ?? 0) - 1;
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "snowy");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    cell.data.remove("heat");
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "forest");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    cell.updated = true;
    cell.tags.add("stopped");
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "freezing");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    grid.addBroken(cell, x, y, "shrinking");
    grid.set(x, y, Cell(x, y));
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "trash_biome");

  final rng = Random();

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    if (cell.id != "empty") {
      final c = <String>[...cells];
      c.removeWhere((id) => id == "empty" || backgrounds.contains(id));
      cell.id = c[rng.nextInt(c.length)];
      grid.setChunk(x, y, cell.id);
      cell.updated = false;
    }
  }, filter: (cell, x, y) => grid.placeable(x, y) == "quantum_biome");

  grid.loopChunks("all", GridAlignment.topleft, (cell, x, y) {
    cell.tags.add("consistent");
  }, filter: (cell, x, y) => cell.id != "empty" && grid.placeable(x, y) == "consistency_biome");
}
