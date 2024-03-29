part of logic;

// QuadChunk is an optimization that turns the chunk system into a quad-tree
class QuadChunk {
  static int get minSize => storage.getInt("min_node_size") ?? 5;
  static set minSize(int val) {
    storage.setInt("min_node_size", val);
  }

  // Tree stuff
  List<QuadChunk> subs = [];
  bool get subd => subs.isNotEmpty;
  int sx, sy, ex, ey;
  int get width =>
      ex -
      sx +
      1; // If sx and ex are equal, the width is 1 (useful for subdivision)
  int get height =>
      ey -
      sy +
      1; // If sy and ey are equal, the height is 1 (useful for subdivision)

  // OOP stuff
  QuadChunk(this.sx, this.sy, this.ex, this.ey);

  // Data
  HashSet<String> types = HashSet();
  int reads = 0;

  bool get isUnit => width == 1 && height == 1;

  // Logic / Helper functions
  bool get isNodeOnly => width >= minSize && height >= minSize && !isUnit;

  void divide() {
    if (isUnit) return;
    if (subd) return;
    final w2 = width ~/ 2;
    final h2 = height ~/ 2;

    // Subdivide to 4 sub-nodes
    subs.addAll([
      QuadChunk(sx, sy, sx + w2, sy + h2),
      QuadChunk(sx + w2 + 1, sy, ex, sy + h2),
      QuadChunk(sx, sy + h2 + 1, sx + w2, ey),
      QuadChunk(sx + w2 + 1, sy + h2 + 1, ex, ey),
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
      for (var sub in subs) {
        sub.insert(x, y, id);
      }
    }
  }

  bool containsType(String id) {
    if (id == "*") return true;
    if (id == "all") return types.isNotEmpty;

    return types.contains(id);
  }

  List<List<int>> fetch(String id,
      [int? minx, int? miny, int? maxx, int? maxy]) {
    // Stop if the type is not within the node
    if (!containsType(id)) return [];

    // Outside of size
    if (minx != null && ex < minx) return [];
    if (miny != null && ey < miny) return [];
    if (maxx != null && sx > maxx) return [];
    if (maxy != null && sy > maxy) return [];

    // If we're only supposed to be a node, return what the nodes agree on
    if (isNodeOnly) {
      final l = <List<int>>[];

      for (var sub in subs) {
        l.addAll(sub.fetch(id, minx, miny, maxx, maxy));
      }

      return l;
    } else {
      final l = <List<int>>[];

      // Add all x,y pairs within
      for (var x = sx; x <= ex; x++) {
        for (var y = sy; y <= ey; y++) {
          if (!grid.inside(x, y)) continue;
          l.add([x, y]);
        }
      }

      return l;
    }
  }

  void iterateX(int y, String chunkType, bool reversed,
      void Function(Cell cell, int x, int y) callback) {
    if (y != -1 && !(y >= sy && y <= ey)) return;
    if (!containsType(chunkType)) return;

    if (isNodeOnly) {
      // Iterating the list in order gives us 0 -> w-1 order
      // Iterating the list backwards gives us w-1 -> 0 order
      if (reversed) {
        for (var i = subs.length - 1; i >= 0; i--) {
          subs[i].iterateX(y, chunkType, reversed, callback);
        }
      } else {
        for (var sub in subs) {
          sub.iterateX(y, chunkType, reversed, callback);
        }
      }
    } else {
      if (reversed) {
        for (var x = ex; x >= sx; x--) {
          if (!grid.inside(x, y)) continue;
          callback(grid.at(x, y), x, y);
        }
      } else {
        for (var x = sx; x <= ex; x++) {
          if (!grid.inside(x, y)) continue;
          callback(grid.at(x, y), x, y);
        }
      }
    }
  }

  void iterateY(int x, String chunkType, bool reversed,
      void Function(Cell cell, int x, int y) callback) {
    if (x != -1 && !(x >= sx && x <= ex)) return;
    if (!containsType(chunkType)) return;

    if (isNodeOnly) {
      // Iterating the list in order gives us 0 -> w-1 order
      // Iterating the list backwards gives us w-1 -> 0 order
      if (reversed) {
        for (var i = subs.length - 1; i >= 0; i--) {
          subs[i].iterateY(x, chunkType, reversed, callback);
        }
      } else {
        for (var sub in subs) {
          sub.iterateY(x, chunkType, reversed, callback);
        }
      }
    } else {
      if (reversed) {
        for (var y = ey; y >= sy; y--) {
          if (!grid.inside(x, y)) continue;
          callback(grid.at(x, y), x, y);
        }
      } else {
        for (var y = sy; y <= ey; y++) {
          if (!grid.inside(x, y)) continue;
          callback(grid.at(x, y), x, y);
        }
      }
    }
  }

  void iterate(Grid grid, GridAlignment alignment, String chunkType,
      void Function(Cell cell, int x, int y) callback) {
    if (alignment == GridAlignment.bottomright) {
      for (var y = 0; y < grid.height; y++) {
        iterateX(y, chunkType, false, callback);
      }
    }
    if (alignment == GridAlignment.topleft) {
      for (var y = grid.height - 1; y >= 0; y--) {
        iterateX(y, chunkType, true, callback);
      }
    }
    if (alignment == GridAlignment.topright) {
      for (var x = 0; x < grid.width; x++) {
        iterateY(x, chunkType, true, callback);
      }
    }
    if (alignment == GridAlignment.bottomleft) {
      for (var x = grid.width - 1; x >= 0; x--) {
        iterateY(x, chunkType, false, callback);
      }
    }
  }
}
