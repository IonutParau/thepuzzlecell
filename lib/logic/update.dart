part of logic;

int floor(num n) => n.toInt();

final rotOrder = [0, 2, 3, 1];

var playerKeys = 0;
var puzzleWin = false;

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

enum RotationalType {
  clockwise,
  counter_clockwise,
}

void doMagnet(int x, int y, int dir) {
  for (var i = 1; i < 3; i++) {
    final ox = x - (dir % 2 == 0 ? dir - 1 : 0) * i;
    final oy = y - (dir % 2 == 1 ? dir - 2 : 0) * i;
    if (!grid.inside(ox, oy)) return;
    final o = grid.at(ox, oy);
    if (o.id != "magnet" && o.id != "empty") return;
    if (o.id == "magnet" && (o.rot == dir || o.rot == (dir + 2) % 4)) {
      if (o.rot == dir) {
        if (i == 1) {
          o.updated = true;
          push(ox, oy, dir, 1);
          return;
        }
      } else {
        if (i == 2) {
          o.updated = true;
          push(ox, oy, dir + 2, 1);
          return;
        }
      }
    }
  }
}

void magnets() {
  for (var rot in rotOrder) {
    grid.forEach(
      (cell, x, y) {
        if (!cell.updated && cell.id == "magnet") {
          cell.updated = true;
          doMagnet(x, y, cell.rot);
          doMagnet(x, y, cell.rot + 2);
        }
      },
      rot,
    );
  }
}

void diggers() {
  if (!grid.wrap) return;

  grid.forEach(
    (cell, x, y) {
      if (!cell.updated && cell.id == "digger") {
        cell.updated = true;

        final nX = grid.width - x - 1;
        final nY = grid.height - y - 1;

        moveCell(x, y, nX, nY);
      }
    },
  );
}

bool canMoveInDir(int x, int y, int dir, MoveType mt, [bool single = false]) {
  dir %= 4;
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return false;

  if (single) {
    return canMove(fx, fy, dir, 1, mt);
  } else {
    return canMoveAll(fx, fy, dir, 1, mt);
  }
}

Cell? inFront(int x, int y, int dir) {
  dir %= 4;
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);

  if (!grid.inside(fx, fy)) return null;

  return grid.at(fx, fy);
}

void moveFront(int x, int y, int dir) {
  final fx = x - (dir % 2 == 0 ? dir - 1 : 0);
  final fy = y - (dir % 2 == 1 ? dir - 2 : 0);
  if (!grid.inside(fx, fy)) return;

  moveCell(x, y, fx, fy, dir);
}

int frontX(int x, int dir) {
  dir %= 4;
  return x - (dir % 2 == 0 ? dir - 1 : 0);
}

int frontY(int y, int dir) {
  dir %= 4;
  return y - (dir % 2 == 1 ? dir - 2 : 0);
}

extension SetX on Set<String> {
  bool containsAny(List<String> strings) {
    for (var s in this) {
      if (strings.contains(s)) {
        return true;
      }
    }

    return false;
  }
}

class CellTypeManager {
  static List<String> rockets = [
    "rocket",
    "rocket_cw",
    "rocket_ccw",
  ];

  static List<String> movers = [
    "mover",
    "slow_mover",
    "fast_mover",
    "releaser"
  ];

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

  static List<String> fans = ["fan", "vacuum", "conveyor", "swapper", "nudger"];

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
  ];

  static List<String> puzzles = [
    "puzzle",
    "trash_puzzle",
    "mover_puzzle",
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
  ];

  static List<String> gates = [
    "and_gate",
    "or_gate",
    "xor_gate",
    "not_gate",
    "nand_gate",
    "nor_gate",
    "xnor_gate",
  ];

  static List<String> mirrors = [
    "mirror",
    "super_mirror",
  ];

  static List<String> speeds = [
    "speed",
    "slow",
    "fast",
  ];

  static List<String> curves = [
    "curve",
    "straight_curve",
    "cross_curve",
    "cross_straight_curve",
  ];

  static List<String> quantum = ["unstable_mover", "field"];
}

void doSync(int x, int y, int movedir, int rot) {
  if (movedir != -1 && grid.at(x, y).tags.contains("sync move")) return;
  if (movedir != -1) {
    grid.at(x, y).tags.add("sync move");
  }
  if (rot != 0) {
    grid.at(x, y).tags.add("sync rot");
  }

  grid.forEach(
    (cell, x, y) {
      if ((!cell.tags.contains("sync move")) && movedir != -1) {
        push(x, y, movedir, 1, mt: MoveType.sync);
      }
      if ((!cell.tags.contains("sync rot")) && rot != 0) {
        grid.rotate(x, y, rot);
      }
    },
    null,
    "sync",
  );
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
  if (ox > 0) return 0;
  if (ox < 0) return 2;
  if (oy > 0) return 1;
  if (oy < 0) return 3;

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
    // if (!canMove(nv.x.toInt(), nv.y.toInt(), (dirFromOff(dx, dy) + amount) % 4,
    //     1, MoveType.unkown_move)) {
    //   return;
    // }
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
  }

  for (var i = 0; i < structure.coords.length; i++) {
    final v = structure.coords[i];
    if (v != center)
      grid.set(v.x.toInt(), v.y.toInt(), Cell(v.x.toInt(), v.y.toInt()));
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

int round(num n) => (n + 0.5).toInt();
