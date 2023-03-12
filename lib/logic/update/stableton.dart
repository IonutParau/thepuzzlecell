part of logic;

class StabletonData {
  List<int> layerConstants;
  List<List<int>> offsets;
  int unitConstant;
  bool stationary;
  bool clonable;

  StabletonData({
    required this.unitConstant,
    required this.layerConstants,
    required this.offsets,
    required this.stationary,
    required this.clonable,
  });
}

final stabletonOrder = ["stable_a", "stable_b", "stable_i", "stable_j", "stable_k", "stable_n"];
final stabletonData = <String, StabletonData>{
  "stable_a": StabletonData(
    unitConstant: 1,
    layerConstants: [1, 1],
    offsets: [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ],
    stationary: true,
    clonable: false,
  ),
  "stable_b": StabletonData(
    unitConstant: -1,
    layerConstants: [-1, 1],
    offsets: [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ],
    stationary: true,
    clonable: true,
  ),
  "stable_i": StabletonData(
    unitConstant: 1,
    layerConstants: [1, -1, 2, -2, 3, -3],
    offsets: [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
      [-1, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
    ],
    stationary: true,
    clonable: false,
  ),
  "stable_j": StabletonData(
    unitConstant: -1,
    layerConstants: [1, -1, 2, -2, 3, -3],
    offsets: [
      [-1, 1],
      [1, -1],
      [1, 1],
      [-1, -1],
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
    ],
    stationary: true,
    clonable: false,
  ),
  "stable_k": StabletonData(
    unitConstant: 2,
    layerConstants: [1, -1, 1, -1, 1, -1, 1, -1],
    offsets: [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ],
    stationary: false,
    clonable: true,
  ),
  "stable_n": StabletonData(
    unitConstant: -5,
    layerConstants: [1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1, -1],
    offsets: [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ],
    stationary: false,
    clonable: true,
  ),
};

int calculateStability(int x, int y, List<int> layerConstants, int? ix, int? iy) {
  int stability = 0;

  for (var i = 0; i < layerConstants.length; i++) {
    var hasDoneAnything = false;
    final size = i + 1;

    if (grid.inside(0, y - i - 1)) {
      for (var ox = -size + 1; ox <= size - 1; ox++) {
        final cx = x + ox;
        final cy = y - i - 1;
        if (!grid.inside(cx, cy)) continue;
        if (ix == cx && iy == cy) continue;

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) continue;

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(0, y + i + 1)) {
      for (var ox = -size + 1; ox <= size - 1; ox++) {
        final cx = x + ox;
        final cy = y + i + 1;
        if (!grid.inside(cx, cy)) continue;
        if (ix == cx && iy == cy) continue;

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) continue;

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(x - i - 1, 0)) {
      for (var oy = -size; oy <= size; oy++) {
        final cx = x - i - 1;
        final cy = y + oy;
        if (!grid.inside(cx, cy)) continue;
        if (ix == cx && iy == cy) continue;

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) continue;

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(x + i + 1, 0)) {
      for (var oy = -size; oy <= size; oy++) {
        final cx = x + i + 1;
        final cy = y + oy;
        if (!grid.inside(cx, cy)) continue;
        if (ix == cx && iy == cy) continue;

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) continue;

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (!hasDoneAnything) {
      break;
    }
  }

  return stability;
}

void stabletons() {
  for (var stableton in stabletonOrder) {
    grid.updateCell((cell, x, y) {
      final data = stabletonData[stableton]!;
      final current = calculateStability(x, y, data.layerConstants, null, null);

      var bests = [
        [x, y]
      ];
      var bestScore = data.stationary ? current : (1 << 63);
      var hasMoved = false;

      for (var off in data.offsets) {
        final cx = x + off[0];
        final cy = y + off[1];

        if (!grid.inside(cx, cy)) continue;
        if (grid.at(cx, cy).id != "empty") continue;

        final score = calculateStability(cx, cy, data.layerConstants, x, y);

        if (score > bestScore) {
          bestScore = score;
          bests = [
            [cx, cy]
          ];
          hasMoved = true;
        } else if (score == bestScore) {
          bests.add([cx, cy]);
          hasMoved = true;
        }
      }

      if (hasMoved) {
        for (var best in bests) {
          final cx = best[0];
          final cy = best[1];
          if (grid.at(cx, cy).id != "empty") continue;

          grid.set(cx, cy, cell.copy);
          if (!data.clonable) break;
        }
        grid.set(x, y, Cell(x, y));
      }
    }, null, stableton);
  }
}
