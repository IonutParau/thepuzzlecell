part of logic;

int floor(num n) => n.toInt();

final rotOrder = [0, 2, 3, 1];

var playerKeys = 0;
var puzzleWin = false;
var puzzleLost = false;

Offset fromDir(int dir) {
  dir += 4;
  dir %= 4;
  switch (dir) {
    case 0:
      return Offset(1, 0);
    case 2:
      return Offset(-1, 0);
    case 1:
      return Offset(0, 1);
    case 3:
      return Offset(0, -1);
    default:
      return Offset.zero;
  }
}

final ungennable = [
  "empty",
  "ghost",
  "ungeneratable",
  "pushable",
  "pullable",
  "transformable",
  "grabbable",
  "swappable",
  "propuzzle",
  "gen_trash",
];

bool isUngennable(Cell cell, int x, int y, int dir) {
  /* Special code here */

  return ungennable.contains(cell.id);
}

enum RotationalType {
  clockwise,
  counter_clockwise,
}

class CellTypeManager {
  static List<String> memgens = [
    "mem_gen",
    "mem_gen_cw",
    "mem_gen_ccw",
    "mem_gen_double",
    "mem_gen_triple",
  ];

  static List<String> movers = ["mover", "slow_mover", "fast_mover", "releaser"];

  static List<String> puller = [
    "puller",
    "slow_puller",
    "fast_puller",
    "collector",
  ];

  static List<String> grabbers = [
    "grabber",
    "thief",
  ];

  static List<String> fans = [
    "fan",
    "vacuum",
    "conveyor",
    "swapper",
    "nudger",
    "superfan",
    "airflow",
    "supervacuum",
    "inverse_airflow",
  ];

  static List<String> ants = ["ant_cw", "ant_ccw"];

  static List<String> generators = [
    "generator",
    "generator_cw",
    "generator_ccw",
    "triplegen",
    "crossgen",
    "constructorgen",
    "doublegen",
    "physical_gen",
    "physical_gen_cw",
    "physical_gen_ccw",
  ];

  static List<String> superGens = [
    "supgen",
    "supgen_cw",
    "supgen_ccw",
    "double_supgen",
    "triple_supgen",
    "cross_supgen",
    "constructor_supgen",
  ];

  static List<String> replicators = [
    "replicator",
    "cross_replicator",
    "opposite_replicator",
    "triple_rep",
    "quad_rep",
    "physical_replicator",
  ];

  static List<String> tunnels = [
    "tunnel",
    "tunnel_cw",
    "tunnel_ccw",
    "triple_tunnel",
    "dual_tunnel",
    "warper",
    "warper_cw",
    "warper_ccw",
  ];

  static List<String> transformers = [
    "transformer",
    "transformer_cw",
    "transformer_ccw",
    "triple_transformer",
  ];

  static List<String> rotators = [
    "rotator_cw",
    "rotator_ccw",
    "rotator_180",
    "redirector",
    "opposite_rotator",
    "rotator_rand",
    "super_redirector",
  ];

  static List<String> gears = [
    "gear_cw",
    "gear_ccw",
    "megagear_cw",
    "megagear_ccw",
  ];

  static List<String> puzzles = [
    "puzzle",
    "trash_puzzle",
    "mover_puzzle",
    "molten_puzzle",
    "frozen_puzzle",
    "unstable_puzzle",
    "transform_puzzle",
  ];

  static List<String> mechanical = [
    "mech_gen",
    "mech_mover",
    "pixel",
    "displayer",
    "mech_mover",
    "mech_puller",
    "mech_grabber",
    "mech_fan",
    "mech_generator",
    "mech_gear",
    "mech_keyup",
    "mech_keyleft",
    "mech_keyright",
    "mech_keydown",
    "mech_rotator_cw",
    "mech_rotator_ccw",
    "keylimit",
    "keyforce",
    "keyfake",
  ];

  static List<String> gates = ["and_gate", "or_gate", "xor_gate", "not_gate", "nand_gate", "nor_gate", "xnor_gate", "imply_gate", "nimply_gate"];

  static List<String> mirrors = [
    "mirror",
    "super_mirror",
  ];

  static List<String> speeds = [
    "speed",
    "slow",
    "fast",
  ];

  static List<String> quantum = ["unstable_mover", "field"];
}

Cell? safeAt(int x, int y) {
  if (!grid.inside(x, y)) return null;
  return grid.at(x, y);
}

class CellStructure {
  List<Vector2> coords = [];
  List<Cell> cells = [];

  bool inStructure(int x, int y) {
    for (var coord in coords) {
      if (coord.x == x && coord.y == y) return true;
    }
    return false;
  }

  void build(int x, int y) {
    if (!grid.inside(x, y)) return;
    if (grid.at(x, y).id == "empty") return;
    if (!inStructure(x, y)) {
      coords.add(Vector2(x.toDouble(), y.toDouble()));
      cells.add(grid.at(x, y));
      this.build(x + 1, y);
      this.build(x - 1, y);
      this.build(x, y + 1);
      this.build(x, y - 1);
    }
  }
}

int dirFromOff(int ox, int oy) {
  var dir = (atan2(oy, ox) / halfPi);

  while (dir < 0) dir += 4;

  bool within(double a, double b) => (dir >= a && dir <= b);

  // Why am I trying to be accurate here
  if (within(3.5, 4) || within(0, 0.5)) {
    return 0;
  }
  if (within(0.5, 1.5)) {
    return 1;
  }
  if (within(1.5, 2.5)) {
    return 2;
  }
  if (within(2.5, 3.5)) {
    return 3;
  }

  return -1;
}

void doAnchor(int x, int y, int amount) {
  amount %= 4;
  final structure = CellStructure()..build(x, y);

  //print(rot);

  final center = Vector2(x.toDouble(), y.toDouble());

  for (var i = 0; i < structure.coords.length; i++) {
    final v = structure.coords[i];
    final nv = Vector2.all(0);
    final dx = v.x.toInt() - x;
    final dy = v.y.toInt() - y;
    if (!canMove(v.x.toInt(), v.y.toInt(), (dirFromOff(dx, dy) + amount) % 4, 1, MoveType.unknown_move)) {
      return;
    }
    if (amount == 1) {
      nv.x = x - dy.toDouble();
      nv.y = y + dx.toDouble();
    } else if (amount == 3 || amount == -1) {
      nv.x = x + dy.toDouble();
      nv.y = y - dx.toDouble();
    } else if (amount == 2) {
      nv.x = x - dx.toDouble();
      nv.y = y - dy.toDouble();
    }
    if (!grid.inside(nv.x.toInt(), nv.y.toInt())) return;
    if (nv != v) {
      if (!structure.inStructure(nv.x.toInt(), nv.y.toInt())) {
        if (grid.at(nv.x.toInt(), nv.y.toInt()).id != "empty") {
          return;
        }
      }
    }
  }

  for (var i = 0; i < structure.coords.length; i++) {
    final v = structure.coords[i];
    if (v != center) grid.set(v.x.toInt(), v.y.toInt(), Cell(v.x.toInt(), v.y.toInt()));
  }

  for (var i = 0; i < structure.coords.length; i++) {
    final v = structure.coords[i];
    if (v != center) {
      final dx = v.x.toInt() - x;
      final dy = v.y.toInt() - y;
      if (amount == 1) {
        v.x = x - dy.toDouble();
        v.y = y + dx.toDouble();
      } else if (amount == 3 || amount == -1) {
        v.x = x + dy.toDouble();
        v.y = y - dx.toDouble();
      } else if (amount == 2) {
        v.x = x - dx.toDouble();
        v.y = y - dy.toDouble();
      }
    }
  }

  for (var i = 0; i < structure.coords.length; i++) {
    final v = structure.coords[i];
    if (v != center) {
      grid.set(v.x.toInt(), v.y.toInt(), structure.cells[i]);
      grid.at(v.x.toInt(), v.y.toInt()).cx = v.x.toInt();
      grid.at(v.x.toInt(), v.y.toInt()).cy = v.y.toInt();
      if (grid.at(v.x.toInt(), v.y.toInt()).id != "anchor") {
        if (!structure.cells[i].tags.contains("anchored $amount")) {
          structure.cells[i].tags.add("anchored $amount");
          structure.cells[i].tags.add("anchored");
          grid.rotate(v.x.toInt(), v.y.toInt(), amount);
        }
      }
    }
  }
}

Offset? findCell(int x, int y, List<String> targets, int maxDepth) {
  Map<String, bool> visited = {};
  List<List<int>> toVisit = [
    [x, y],
  ];
  bool first = true;
  var d = maxDepth;

  while (toVisit.isNotEmpty) {
    final cur = toVisit.removeAt(0);
    final cx = cur[0];
    final cy = cur[1];
    if (grid.inside(cx, cy)) {
      final cell = grid.at(cx, cy);
      if (targets.contains(cell.id)) {
        return Offset(cx.toDouble(), cy.toDouble());
      }
      if (cell.id == "empty" || first) {
        if (!visited.containsKey("$cx $cy")) {
          visited["$cx $cy"] = true;
          toVisit.add([cx + 1, cy]);
          toVisit.add([cx - 1, cy]);
          toVisit.add([cx, cy + 1]);
          toVisit.add([cx, cy - 1]);
          d += 4;
        }
      }
    }
    first = false;
    d = d - 1;
    if (d == 0) return null;
  }

  return null;
}

int? getPathFindingDirection(int x, int y, int dx, int dy, bool first, Map<String, bool> visited) {
  if (x == dx && y == dy) return null;
  if (!grid.inside(x, y)) return null;
  final Map<String, bool> visited = {};
  visited["$x $y"] = true;
  final List<List> toVisit = [
    [
      x + 1,
      y,
      [0]
    ],
    [
      x,
      y + 1,
      [1]
    ],
    [
      x - 1,
      y,
      [2]
    ],
    [
      x,
      y - 1,
      [3]
    ],
  ];

  var maxDepth = grid.width * grid.height;
  var d = maxDepth;

  while (toVisit.isNotEmpty) {
    final cur = toVisit.removeAt(0);
    final cx = cur[0];
    final cy = cur[1];
    final path = cur[2];
    if (grid.inside(cx, cy)) {
      final cell = grid.at(cx, cy);
      if (cx == dx && cy == dy) {
        return path[0];
      }
      if (cell.id == "empty") {
        if (!visited.containsKey("$cx $cy")) {
          visited["$cx $cy"] = true;
          toVisit.add([
            cx + 1,
            cy,
            [...path, 0]
          ]);
          toVisit.add([
            cx,
            cy + 1,
            [...path, 1]
          ]);
          toVisit.add([
            cx - 1,
            cy,
            [...path, 2]
          ]);
          toVisit.add([
            cx,
            cy - 1,
            [...path, 3]
          ]);
          d += 4;
        }
      }
    }
    d--;
    if (d == 0) return null;
  }

  return null;
}

int? pathFindToCell(int x, int y, List<String> targets, int maxDepth) {
  final cell = findCell(x, y, targets, maxDepth);
  if (cell == null) return null;

  final cx = cell.dx.toInt();
  final cy = cell.dy.toInt();

  return getPathFindingDirection(x, y, cx, cy, true, {});
}
