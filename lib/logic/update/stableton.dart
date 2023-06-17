part of logic;

class StabletonData {
  List<int> layerConstants;
  List<(int, int)> offsets;
  List<(int, int)> swapOffsets;
  int unitConstant;
  bool stationary;
  bool clonable;
  List<String> decaysInto;
  int decayRecursion;

  StabletonData({
    required this.unitConstant,
    required this.layerConstants,
    required this.offsets,
    required this.swapOffsets,
    required this.stationary,
    required this.clonable,
    required this.decaysInto,
    required this.decayRecursion,
  });
}

final stabletonOrder = ["stable_a", "stable_b", "stable_c", "stable_d", "stable_i", "stable_j", "stable_k", "stable_n", "stable_p", "stable_s", "stable_o"];
final stabletonData = <String, StabletonData>{
  "stable_a": StabletonData(
    unitConstant: 1,
    layerConstants: [1, 1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: true,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_b": StabletonData(
    unitConstant: -1,
    layerConstants: [-1, 1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: true,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_i": StabletonData(
    unitConstant: 1,
    layerConstants: [1, -1, 2, -2, 3, -3],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
      (-1, -1),
      (1, 1),
      (1, -1),
      (-1, 1),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_j": StabletonData(
    unitConstant: -1,
    layerConstants: [1, -1, 2, -2, 3, -3],
    offsets: [
      (-1, 1),
      (1, -1),
      (1, 1),
      (-1, -1),
      (0, 1),
      (0, -1),
      (1, 0),
      (-1, 0),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_k": StabletonData(
    unitConstant: 2,
    layerConstants: [1, -1, 1, -1, 1, -1, 1, -1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: false,
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_n": StabletonData(
    unitConstant: -5,
    layerConstants: [1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1, -1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: false,
    clonable: false,
    decaysInto: [],
    decayRecursion: 0,
  ),
  "stable_c": StabletonData(
    unitConstant: 1,
    layerConstants: [1, 1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: true,
    decaysInto: ["stable_d"],
    decayRecursion: 1,
  ),
  "stable_d": StabletonData(
    unitConstant: -1,
    layerConstants: [-1, 1],
    offsets: [
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ],
    swapOffsets: [],
    stationary: true,
    clonable: true,
    decaysInto: ["stable_c"],
    decayRecursion: 1,
  ),
  "stable_p": StabletonData(
    unitConstant: 1,
    layerConstants: [-1, 1, 2, -2],
    offsets: [], // only moves diagonally
    swapOffsets: [
      (-2, 2),
      (2, -2),
      (-2, -2),
      (2, 2),
    ],
    stationary: true,
    clonable: true,
    decaysInto: ["stable_s", "stable_o"],
    decayRecursion: 1,
  ),
  "stable_s": StabletonData(
    unitConstant: -1,
    layerConstants: [-1, 1, 2, -2],
    offsets: [], // only moves diagonally
    swapOffsets: [
      (0, 2),
      (2, 0),
      (0, -2),
      (-2, 0),
    ],
    stationary: true,
    clonable: true,
    decaysInto: ["stable_p"],
    decayRecursion: 1,
  ),
  "stable_o": StabletonData(
    unitConstant: 1,
    layerConstants: [1, -1, -2, 2],
    offsets: [], // only moves diagonally
    swapOffsets: [
      (-2, 2),
      (2, -2),
      (-2, -2),
      (2, 2),
      (0, 2),
      (2, 0),
      (0, -2),
      (-2, 0),
    ],
    stationary: true,
    clonable: true,
    decaysInto: ["stable_s", "stable_p"],
    decayRecursion: 1,
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
        if (!grid.inside(cx, cy)) {
          continue;
        }
        if (ix == cx && iy == cy) {
          continue;
        }

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) {
          continue;
        }

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(0, y + i + 1)) {
      for (var ox = -size + 1; ox <= size - 1; ox++) {
        final cx = x + ox;
        final cy = y + i + 1;
        if (!grid.inside(cx, cy)) {
          continue;
        }
        if (ix == cx && iy == cy) {
          continue;
        }

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) {
          continue;
        }

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(x - i - 1, 0)) {
      for (var oy = -size; oy <= size; oy++) {
        final cx = x - i - 1;
        final cy = y + oy;
        if (!grid.inside(cx, cy)) {
          continue;
        }
        if (ix == cx && iy == cy) {
          continue;
        }

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) {
          continue;
        }

        stability += data.unitConstant * layerConstants[i];
      }
      hasDoneAnything = true;
    }

    if (grid.inside(x + i + 1, 0)) {
      for (var oy = -size; oy <= size; oy++) {
        final cx = x + i + 1;
        final cy = y + oy;
        if (!grid.inside(cx, cy)) {
          continue;
        }
        if (ix == cx && iy == cy) {
          continue;
        }

        final c = grid.at(cx, cy);

        final data = stabletonData[c.id];
        if (data == null) {
          continue;
        }

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

enum StabletonMoveType {
  movement,
  swap,
}

class StabletonMove {
  String newID;
  int newX;
  int newY;
  int score;
  StabletonMoveType type;

  StabletonMove(this.newID, this.newX, this.newY, this.score, this.type);
}

List<StabletonMove> calculateMostStableMoves(String id, int x, int y, StabletonData data, bool isDecay, int current, int depth, int maxDepth) {
  var bestMoves = <StabletonMove>[];
  var bestScore = data.stationary ? current : (1 << 63);

  if (isDecay) {
    final inactiveScore = calculateStability(x, y, data.layerConstants, null, null);
    bestMoves.add(StabletonMove(id, x, y, inactiveScore, StabletonMoveType.movement));
    bestScore = inactiveScore;
  }

  if (depth < maxDepth) {
    var bestDecayMoves = data.decaysInto.map((did) => calculateMostStableMoves(did, x, y, stabletonData[did]!, true, current, depth + 1, maxDepth)).toList();

    for (var bestDecay in bestDecayMoves) {
      if (bestDecay.isEmpty) {
        continue;
      }
      if (bestDecay.first.score > bestScore) {
        bestScore = bestDecay.first.score;
        bestMoves = [StabletonMove(bestDecay.first.newID, x, y, bestScore, StabletonMoveType.movement)];
      }
    }
  }

  for (var (ox, oy) in data.swapOffsets) {
    final cx = x + ox;
    final cy = y + oy;

    if (!grid.inside(cx, cy)) {
      continue;
    }
    if (!stabletonOrder.contains(grid.at(cx, cy).id)) {
      continue;
    }

    final score = calculateStability(cx, cy, data.layerConstants, x, y);

    if (score > bestScore) {
      bestMoves = [StabletonMove(id, cx, cy, score, StabletonMoveType.swap)];
      bestScore = score;
    } else if (score == bestScore) {
      bestMoves.add(StabletonMove(id, cx, cy, score, StabletonMoveType.swap));
    }
  }

  for (var (ox, oy) in data.offsets) {
    final cx = x + ox;
    final cy = y + oy;

    if (!grid.inside(cx, cy)) {
      continue;
    }
    if (grid.at(cx, cy).id != "empty") {
      continue;
    }
    final score = calculateStability(cx, cy, data.layerConstants, x, y);

    if (score > bestScore) {
      bestMoves = [StabletonMove(id, cx, cy, score, StabletonMoveType.movement)];
      bestScore = score;
    } else if (score == bestScore) {
      bestMoves.add(StabletonMove(id, cx, cy, score, StabletonMoveType.movement));
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
        var onlySwaps = true;
        for (var bestMove in bestMoves) {
          if (bestMove.type != StabletonMoveType.swap) {
            onlySwaps = false;
            break;
          }
        }
        if (onlySwaps) {
          for (var bestMove in bestMoves) {
            final cid = bestMove.newID;
            final cx = bestMove.newX;
            final cy = bestMove.newY;

            final o = grid.at(cx, cy);

            if (stabletonOrder.contains(o.id)) {
              final c = cell.copy;
              c.id = cid;
              grid.set(cx, cy, c);
              grid.set(x, y, o);
            }
          }
          bestMoves.clear(); // fixes bugs!!!!
        }
      }

      if (bestMoves.isNotEmpty) {
        for (var best in bestMoves) {
          if (best.type == StabletonMoveType.swap) {
            continue;
          }

          final cid = best.newID;
          final cx = best.newX;
          final cy = best.newY;

          final c = cell.copy;
          c.id = cid;
          grid.set(cx, cy, c);
          if (!data.clonable) {
            break;
          }
        }
        if (grid.at(x, y).id == cell.id) {
          grid.set(x, y, Cell(x, y));
        }
      }
    }, null, stableton);
  }
}
