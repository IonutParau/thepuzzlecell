part of logic;

// Biomes
void biomes(Set<String> cells) {
  grid.loopChunks("all", GridAlignment.TOPLEFT, (cell, x, y) {
    grid.rotate(x, y, 1);
  }, filter: (cell, x, y) => grid.placeable(x, y) == "biome_cw");

  grid.loopChunks("all", GridAlignment.TOPLEFT, (cell, x, y) {
    grid.rotate(x, y, 3);
  }, filter: (cell, x, y) => grid.placeable(x, y) == "biome_ccw");
}
