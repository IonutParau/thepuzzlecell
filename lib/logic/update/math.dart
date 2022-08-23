part of logic;

final mathManager = MathManager();

class MathManager {
  Map<int, Map<int, num>> memory = {};

  void setGlobal(num channel, num index, num value) {
    if (memory[channel.toInt()] == null) memory[channel.toInt()] = {};

    memory[channel.toInt()]![index.toInt()] = value;
  }

  num getGlobal(num channel, num index) {
    if (memory[channel.toInt()] == null) return 0;
    if (memory[channel.toInt()]![index.toInt()] == null) return 0;

    return memory[channel.toInt()]![index.toInt()]!;
  }

  // This technically does a little rounding. Eh, whatever, we also do a little trolling
  double logn(int x, int n) {
    return log(x) / log(n);
  }

  List<int> tunneled(int x, int y, int dir) {
    while (true) {
      final c = grid.at(x, y);
      final side = toSide(dir, c.rot);
      x = frontX(x, dir);
      y = frontY(y, dir);

      switch (c.id) {
        case "math_tunnel":
          if (side % 2 == 1) return [x, y];
          break;
        case "math_tunnel_cw":
          if (side == 0) {
            dir++;
            dir %= 4;
          } else if (side == 3) {
            dir--;
            dir %= 4;
          } else {
            return [x, y];
          }
          break;
        case "math_cross_tunnel":
          break;
        default:
          return [x, y];
      }
    }
  }

  void whenWritten(Cell cell, int x, int y, int dir, num amount) {}

  // Returns if we should override count
  bool isWritable(int x, int y, int dir) {
    final cell = grid.at(x, y);
    final side = toSide(dir, cell.rot);

    if (cell.id == "counter" || cell.id == "math_number") return true;
    if (["math_memset", "math_memwriter"].contains(cell.id) && dir == cell.rot) return true;

    return false;
  }

  // Returns if we should read count
  bool isOutput(int x, int y, int dir) {
    final cell = grid.at(x, y);
    final side = toSide(dir, cell.rot);

    if (cell.id == "counter" || cell.id == "math_number") return true;
    if (["math_memget", "math_memreader", "math_memset", "math_memwriter"].contains(cell.id) && dir == cell.rot) return true;

    return false;
  }

  void output(int x, int y, int dir, num count) {
    final t = tunneled(x, y, dir);
    final tx = t[0];
    final ty = t[1];

    if (isWritable(tx, ty, dir)) {
      grid.at(tx, ty).data['count'] = count;
      whenWritten(grid.at(tx, ty), tx, ty, dir, count);
    }
  }

  num input(int x, int y, int dir, num count) {
    final t = tunneled(x, y, dir);
    final tx = t[0];
    final ty = t[1];

    if (isOutput(tx, ty, (dir + 2) % 4)) {
      final c = grid.at(tx, ty);
      final id = c.id;
      final rot = c.rot;
      final side = toSide((dir + 2) % 4, rot);
      return c.data['count'] as num;
    }

    return 0;
  }
}

void math() {}
