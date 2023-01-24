part of logic;

void shield() {
  grid.updateCell((cell, x, y) {
    grid.get(x - 1, y)?.tags.add("shielded");
    grid.get(x + 1, y)?.tags.add("shielded");
    grid.get(x, y - 1)?.tags.add("shielded");
    grid.get(x, y + 1)?.tags.add("shielded");
  }, null, "shield", useQuadChunks: true);
}
