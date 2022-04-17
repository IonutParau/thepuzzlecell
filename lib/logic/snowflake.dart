part of logic;

class CellPosition {
  int x, y;
  CellPosition(this.x, this.y);

  bool operator ==(Object other) {
    if (other is CellPosition) {
      return ((other.x == x) && (other.y == y));
    } else {
      return false;
    }
  }
}

class SortedLinkedList<T> {
  SortedLinkedList<T>? child;
  T value;
  int score;
  bool discarded = false;

  SortedLinkedList(this.value, this.score);
}

class SnowflakeHelper {
  static void insert(SortedLinkedList<CellPosition> list,
      SortedLinkedList<CellPosition> newNode) {
    var current = list;

    while (true) {
      if (current.child == null) {
        current.child = newNode;
        return;
      }
      if (current.child!.score < newNode.score) {
        newNode.child = current.child;
        current.child = newNode;
        return;
      }
      current = current.child!;
    }
  }

  static void remove(SortedLinkedList<CellPosition> list, CellPosition value) {
    var current = list;

    while (true) {
      if (current.value == value) {
        current.discarded = true;
      }
      if (current.child == null) {
        return; // We've reached the end
      }
      current = current.child!;
    }
  }

  static void iterate(SortedLinkedList<CellPosition> list,
      Function(CellPosition node) callback) {
    var current = list;

    while (true) {
      if (!current.discarded) {
        callback(current.value);
      }
      if (current.child == null) {
        return;
      }
      current = current.child!;
    }
  }
}

enum UpdateMode {
  static,
  dual,
  quad,
}

Map<String, UpdateMode> snowflakeMap = {
  "conveyor": UpdateMode.quad,
};

class Snowflake {
  Map<String, SortedLinkedList<CellPosition>> _snowflake = {};

  void clear() => _snowflake = {};

  void add(String id, int rot, int x, int y) {
    if (id == "empty") return;
    snowflakeMap[id] ??= UpdateMode.quad;
    final mode = snowflakeMap[id];
    if (mode == UpdateMode.dual) {
      rot %= 2; // Such good
    }
    final pos = CellPosition(x, y);
    final l = SortedLinkedList(pos, score(rot, x, y));
    var lbl = "$id:$rot";
    if (mode == UpdateMode.static) {
      lbl = id;
    }
    if (_snowflake[lbl] == null) {
      _snowflake[lbl] = l;
    } else {
      SnowflakeHelper.insert(_snowflake[lbl]!, l);
    }
  }

  String getKey(Cell c) {
    final m = snowflakeMap[c.id];
    if (m != null) {
      if (m == UpdateMode.static) {
        return c.id;
      } else if (m == UpdateMode.dual) {
        return "${c.id}:${c.rot % 2}";
      } else if (m == UpdateMode.quad) {
        return "${c.id}:${c.rot}";
      }
    }
    return "";
  }

  void update(String key, Function(Cell cell, int x, int y) callback) {
    if (_snowflake[key] != null) {
      SnowflakeHelper.iterate(
        _snowflake[key]!,
        (pos) {
          final c = grid.at(pos.x, pos.y);
          if (getKey(c) == key && !c.updated) {
            c.updated = true;
            callback(c, pos.x, pos.y);
          }
        },
      );
    }
  }

  int flipx(int x) => grid.width - x - 1;
  int flipy(int y) => grid.height - y - 1;

  int score(int rot, int x, int y) {
    if (rot == 0) {
      return x + flipy(y) * grid.width;
    } else if (rot == 2) {
      return -x + flipy(y) * grid.width;
    } else if (rot == 1) {
      return flipx(x) + y * grid.width;
    } else if (rot == 3) {
      return x - y * grid.width;
    }
    return 0;
  }
}
