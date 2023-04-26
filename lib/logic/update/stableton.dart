part of logic;

class StabletonData {
  List<int> layerConstants;
  List<List<int>> offsets;
  int unitConstant;
  bool stationary;
  bool clonable;
  List<String> decaysInto;
  int decayRecursion;

  StabletonData({
    required this.unitConstant,
    required this.layerConstants,
    required this.offsets,
    required this.stationary,
    required this.clonable,
    required this.decaysInto,
    required this.decayRecursion,
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
    clonable: true,
    decaysInto: [],
    decayRecursion: 0,
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
    decaysInto: [],
    decayRecursion: 0,
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
    decaysInto: [],
    decayRecursion: 0,
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
    decaysInto: [],
    decayRecursion: 0,
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
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
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
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
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

class StabletonMove {
  String newID;
  int newX;
  int newY;
  int score;

  StabletonMove(this.newID, this.newX, this.newY, this.score);
}

List<StabletonMove> calculateMostStableMoves(String id, int x, int y, StabletonData data, bool isDecay, int current, int depth, int maxDepth) {
  var bestMoves = <StabletonMove>[];
  var bestScore = data.stationary ? current : (1 << 63);

  if (isDecay) {
    final inactiveScore = calculateStability(x, y, data.layerConstants, null, null);
    bestMoves.add(StabletonMove(id, x, y, inactiveScore));
    bestScore = inactiveScore;
  }

  if (depth < maxDepth) {
    var bestDecayMoves = data.decaysInto.map((did) => calculateMostStableMoves(id, x, y, stabletonData[did]!, true, current, depth + 1, maxDepth)).toList();
    bestDecayMoves.removeWhere((moves) => moves.isEmpty);

    for (var bestDecay in bestDecayMoves) {
      if (bestDecay.first.score > bestScore) {
        bestScore = bestDecay.first.score;
        bestMoves = [StabletonMove(id, x, y, bestScore)];
      }
    }
  }

  for (var off in data.offsets) {
    final cx = x + off[0];
    final cy = y + off[1];

    if (!grid.inside(cx, cy)) continue;
    if (grid.at(cx, cy).id != "empty") continue;
    final score = calculateStability(cx, cy, data.layerConstants, x, y);

    if (score > bestScore) {
      bestMoves = [StabletonMove(id, cx, cy, score)];
      bestScore = score;
    } else if (score == bestScore) {
      bestMoves.add(StabletonMove(id, cx, cy, score));
    }
  }

  return bestMoves;
}

void stabletons() {
  for (var stableton in stabletonOrder) {
    grid.updateCell((cell, x, y) {
      final data = stabletonData[stableton]!;
      final current = calculateStability(x, y, data.layerConstants, null, null);

      final bestMoves = calculateMostStableMoves(cell.id, x, y, data, false, current, 0, data.decayRecursion);

      if (!data.clonable && bestMoves.length > 1 && data.stationary) {
        return; // If there is a tie in the stableton possible moves, do nothing.
      }

      if (bestMoves.isNotEmpty) {
        for (var best in bestMoves) {
          final cid = best.newID;
          final cx = best.newX;
          final cy = best.newY;

          final c = cell.copy;
          c.id = cid;
          grid.set(cx, cy, c);
          if (!data.clonable) break;
        }
        if (grid.at(x, y) == cell) grid.set(x, y, Cell(x, y));
      }
    }, null, stableton);
  }
}
