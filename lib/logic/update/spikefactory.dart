part of logic;

void doSpikeFactory(Cell cell, int x, int y) {
  final interval = (cell.data['interval'] ?? 1) as num;
  final radius = (cell.data['radius'] ?? 1).toInt();

  if (radius <= 0) return;
  if (interval <= 0) return;

  cell.data['int_t'] ??= 0;
  cell.data['int_t']++;
  while (cell.data['int_t'] >= interval) {
    cell.data['int_t'] -= interval;

    final offx = ((rng.nextDouble() * 2 - 1) * radius).toInt();
    final offy = ((rng.nextDouble() * 2 - 1) * radius).toInt();

    if (offx != 0 || offy != 0) {
      var bx = x + offx;
      var by = y + offy;

      var attempts = 0;

      // Tries to make sure it actually DOES spawn something lmao
      while (!grid.inside(bx, by) || (grid.placeable(bx, by) != "spiketrap_biome" && grid.placeable(bx, by) != "empty") || (bx == x && by == y)) {
        if (attempts == grid.width * grid.height) return;
        bx = x + ((rng.nextDouble() * 2 - 1) * radius).toInt();
        by = y + ((rng.nextDouble() * 2 - 1) * radius).toInt();
        attempts++;
      }
      grid.setPlace(bx, by, "spiketrap_biome");
    }
  }
}

void spikefactories() {
  grid.updateCell(doSpikeFactory, null, "spikefactory");
}
