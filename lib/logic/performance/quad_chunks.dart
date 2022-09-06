part of logic;

// QuadChunk is an optimization that turns the chunk system into a quad-tree
class QuadChunk {
  // Arbitrarily chosen value of 5
  static int minSize = 5;

  // Tree stuff
  List<QuadChunk> subs = [];
  bool get subd => subs.isNotEmpty;
  int sx, sy, ex, ey;
  int get width => ex - sx + 1; // If sx and ex are equal, the width is 1 (useful for subdivision)
  int get height => ey - sy + 1; // If sy and ey are equal, the height is 1 (useful for subdivision)

  // OOP stuff
  QuadChunk(this.sx, this.sy, this.ex, this.ey);

  // Data
  Set<String> types = {};
  int reads = 0;

  // Logic / Helper functions
  bool get isNodeOnly => width >= minSize && height >= minSize;

  void divide() {
    if (subd) return;
    final w2 = width ~/ 2;
    final h2 = height ~/ 2;

    // Subdivide to 4 sub-nodes
    subs.addAll([
      QuadChunk(sx, sy, sx + w2, sy + h2),
      QuadChunk(sx + w2, sy, ex, sy + h2),
      QuadChunk(sx, sy + h2, sx + w2, ey),
      QuadChunk(sx + w2, sy + h2, ex, ey),
    ]);
  }

  bool inside(int x, int y) {
    return (x >= sx && x <= ex && y >= sy && y <= ey);
  }

  void insert(int x, int y, String id) {
    if (!inside(x, y)) return;

    types.add(id);
    if (isNodeOnly) {
      divide();
      for (var sub in subs) sub.insert(x, y, id);
    }
  }

  bool containsType(String id) {
    if (id == "*") return true;
    if (id == "all") return types.isNotEmpty;

    return types.contains(id);
  }

  List<List<int>> fetch(String id, [int? minx, int? miny, int? maxx, int? maxy]) {
    // Stop if the type is not within the node
    if (!containsType(id)) return [];

    // Outside of size
    if (minx != null && ex < minx) return [];
    if (miny != null && ey < miny) return [];
    if (maxx != null && sx > maxx) return [];
    if (maxy != null && sy > maxy) return [];
    reads++;
    bool recount = (reads == 200);
    if (recount) reads = 0;

    // If we're only supposed to be a node, return what the nodes agree on
    if (isNodeOnly) {
      final l = <List<int>>[];

      if (recount) types = {};

      for (var sub in subs) {
        l.addAll(sub.fetch(id));
        if (recount) types.addAll(sub.types);
      }

      return l;
    } else {
      final l = <List<int>>[];

      // Add all x,y pairs within
      for (var x = sx; x <= ex; x++) {
        for (var y = sy; y <= ey; y++) {
          l.add([x, y]);
          if (recount) types.add(grid.get(x, y)?.id ?? "empty");
        }
      }

      return l;
    }
  }
}
