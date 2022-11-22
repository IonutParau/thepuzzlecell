part of logic;

class CodeCellInstruction {
  String name;
  List<String> params;

  CodeCellInstruction(this.name, this.params);
}

class CodeTable {
  late List _l;

  CodeTable(int capacity) {
    _l = List.generate(capacity, (i) => null);
  }

  CodeTable.generate(int capacity, dynamic Function(int i) generator) {
    _l = List.generate(capacity, generator);
  }

  int get capacity => _l.length;

  dynamic get(dynamic idx) {
    if (_l.isEmpty) return null;

    return _l[idx.hashCode % _l.length];
  }

  void set(dynamic idx, dynamic value) {
    if (_l.isEmpty) return;

    _l[idx.hashCode % _l.length] = value;
  }

  @override
  int get hashCode => Object.hashAll(_l);
}

class CodeRuntimeContext {
  List stack = [];
  List allocated = [];
  List io = [];

  dynamic getStack(dynamic idx) {
    if (stack.isEmpty) return null;
    return stack[idx.hashCode % stack.length];
  }

  void setStack(dynamic idx, dynamic val) {
    if (stack.isEmpty) return;
    stack[idx.hashCode % stack.length] = val;
  }

  dynamic createStack(int amount) {
    for (var i = 0; i < amount; i++) {
      stack.add(null);
    }
  }

  dynamic popStack(int amount, [int offset = 0]) {
    if (offset == 0) {
      for (var i = 0; i < amount; i++) {
        stack.removeLast();
      }
    } else {
      for (var i = 0; i < amount; i++) {
        stack.removeAt(stack.length - 1 - offset);
      }
    }
  }

  int allocate(dynamic thing) {
    allocated.add(thing);
    return allocated.length - 1;
  }

  void free(dynamic idx) {
    final i = idx.hashCode % allocated.length;

    allocated[i] = null;

    while (allocated.last == null) {
      allocated.removeLast();
    }
  }

  void setAllocated(dynamic idx, dynamic val) {
    if (allocated.isEmpty) {
      allocate(val);
      return;
    }

    allocated[idx.hashCode % allocated.length] = val;
  }

  dynamic getAllocated(dynamic idx) {
    if (allocated.isEmpty) {
      return null;
    }

    return allocated[idx.hashCode % allocated.length];
  }

  int exposeAsIO(dynamic thing) {
    io.add(thing);
    return io.length - 1;
  }

  dynamic readIO(dynamic thing) {
    if (io.isEmpty) return null;

    return io[thing.hashCode % io.length];
  }

  void setIO(dynamic idx, dynamic thing) {
    if (io.isEmpty) return;

    io[idx.hashCode % io.length] = thing;
  }

  dynamic copy(dynamic other) {
    if (other is int) return other;
    if (other is double) return other;

    if (other is CodeTable) {
      final newTable = CodeTable(other.capacity);

      for (var i = 0; i < other.capacity; i++) {
        newTable.set(i, copy(other.get(i)));
      }

      return newTable;
    }

    return null;
  }
}

class CodeCellManager {
  Map<String, CodeRuntimeContext> _runtimes = {};

  void clearContexts() {
    _runtimes.clear();
  }

  Map<int, CodeCellInstruction> getInstructions(int x, int y, int dir) {
    var cx = x;
    var cy = y;
    var m = <int, CodeCellInstruction>{};

    while (true) {
      cx = frontX(x, dir);
      cy = frontY(y, dir);

      if (grid.inside(cx, cy)) {
        final c = grid.at(cx, cy);

        if (c.id == "code_instruction") {
          final i = c.data['idx'] as int;
          final code = c.data['code'] as String;

          final segs = code.split(" ");

          m[i] = CodeCellInstruction(segs.isEmpty ? "" : segs[0], segs.length <= 1 ? [] : segs.sublist(1));
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return m;
  }

  // Returns which instruction to go to.
  int runInstruction(int i, CodeCellInstruction? instruction, CodeRuntimeContext context) {
    if (instruction == null) return i + 1;

    if (instruction.name == "create") {
      final amount = int.parse(instruction.params[0]);

      context.createStack(amount);
    }

    if (instruction.name == "delete") {
      final amount = int.parse(instruction.params[0]);

      context.popStack(amount);
    }

    if (instruction.name == "deleteShifted") {
      final amount = int.parse(instruction.params[0]);
      final shift = int.parse(instruction.params[1]);

      context.popStack(amount, shift);
    }

    if (instruction.name == "top") {
      // top is the largest non-wrapping index
      final top = context.stack.length - 1;
      context.createStack(1);
      context.setStack(-1, top);
    }

    if (instruction.name == "push") {
      final ptr = int.parse(instruction.params[0]);

      final amount = context.getStack(ptr) as int;

      context.createStack(amount);
    }

    if (instruction.name == "pop") {
      final ptr = int.parse(instruction.params[0]);

      final amount = context.getStack(ptr) as int;

      context.popStack(amount);
    }

    if (instruction.name == "popShifted") {
      int amount = context.getStack(int.parse(instruction.params[0]));
      int shift = context.getStack(int.parse(instruction.params[1]));

      context.popStack(amount, shift);
    }

    // table takes a constant size!!!
    if (instruction.name == "table") {
      final ptr = int.parse(instruction.params[0]);

      final size = context.getStack(ptr) as int;

      context.createStack(1);
      context.setStack(-1, CodeTable(size));
    }

    // tableD has a pointer for size lmao
    if (instruction.name == "tableD") {
      final size = int.parse(instruction.params[0]);

      context.createStack(1);
      context.setStack(-1, CodeTable(size));
    }

    if (instruction.name == "deref") {
      final ptr = int.parse(instruction.params[0]);

      context.setStack(ptr, context.copy(context.getStack(ptr)));
    }

    if (instruction.name == "clone") {
      final ptr = int.parse(instruction.params[0]);

      final v = context.copy(context.getStack(ptr));

      context.createStack(1);
      context.setStack(-1, v);
    }

    if (instruction.name == "copy") {
      final src = int.parse(instruction.params[0]);
      final dest = int.parse(instruction.params[1]);

      final v = context.copy(context.getStack(src));

      context.setStack(dest, v);
    }

    if (instruction.name == "integer") {
      final ptr = int.parse(instruction.params[0]);
      final val = int.parse(instruction.params[1]);

      context.setStack(ptr, val);
    }

    if (instruction.name == "double") {
      final ptr = int.parse(instruction.params[0]);
      final val = double.parse(instruction.params[1]);

      context.setStack(ptr, val);
    }

    if (instruction.name == "null") {
      final ptr = int.parse(instruction.params[0]);

      context.setStack(ptr, null);
    }

    if (instruction.name == "malloc") {
      final ptr = int.parse(instruction.params[0]);

      context.setStack(ptr, context.allocate(null));
    }

    if (instruction.name == "mallocTable") {
      final ptr = int.parse(instruction.params[0]);
      final size = int.parse(instruction.params[1]);

      context.setStack(ptr, context.allocate(CodeTable(size)));
    }

    if (instruction.name == "mallocInt") {
      final ptr = int.parse(instruction.params[0]);
      final val = int.parse(instruction.params[1]);

      context.setStack(ptr, context.allocate(val));
    }

    if (instruction.name == "mallocDouble") {
      final ptr = int.parse(instruction.params[0]);
      final val = double.parse(instruction.params[1]);

      context.setStack(ptr, context.allocate(val));
    }

    if (instruction.name == "free") {
      final ptr = context.getStack(int.parse(instruction.params[0]));

      context.free(ptr);
    }

    if (instruction.name == "goto") {
      final code = int.parse(instruction.params[0]);

      return code;
    }

    if (instruction.name == "gotoD") {
      final code = context.getStack(int.parse(instruction.params[0]));

      return code;
    }

    if (instruction.name == "ifgoto") {
      final code = int.parse(instruction.params[0]);
      final val = context.getStack(int.parse(instruction.params[1]));

      if (val is int && val > 0) {
        return code;
      }

      if (val is double && val > 0) {
        return code;
      }

      if (val is CodeTable && val.capacity > 0) {
        return code;
      }
    }

    if (instruction.name == "ifgotoD") {
      final code = int.parse(instruction.params[0]);
      final val = context.getStack(int.parse(instruction.params[1]));

      if (val is int && val > 0) {
        return code;
      }

      if (val is double && val > 0) {
        return code;
      }

      if (val is CodeTable && val.capacity > 0) {
        return code;
      }
    }

    if (instruction.name == "add") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) + context.getStack(b));
    }

    if (instruction.name == "sub") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) - context.getStack(b));
    }

    if (instruction.name == "mult") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) * context.getStack(b));
    }

    if (instruction.name == "div") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) / context.getStack(b));
    }

    if (instruction.name == "divInt") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) ~/ context.getStack(b));
    }

    if (instruction.name == "mod") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) % context.getStack(b));
    }

    if (instruction.name == "equal") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) == context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "less") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) < context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "greater") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) > context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "lessEqual") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) <= context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "greaterEqual") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) >= context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "notEqual") {
      final a = int.parse(instruction.params[0]);
      final b = int.parse(instruction.params[1]);
      final c = int.parse(instruction.params[2]);

      context.setStack(c, context.getStack(a) != context.getStack(b) ? 1 : 0);
    }

    if (instruction.name == "merge") {
      final a = context.getStack(int.parse(instruction.params[0])) as CodeTable;
      final b = context.getStack(int.parse(instruction.params[1])) as CodeTable;
      final c = int.parse(instruction.params[2]);

      context.setStack(
        c,
        CodeTable.generate(
          a.capacity + b.capacity,
          (i) {
            var v = null;

            if (i >= a.capacity) {
              v = b.get(i);
            } else {
              v = a.get(i);
            }

            return v;
          },
        ),
      );
    }

    if (instruction.name == "mcopy") {
      final src = int.parse(instruction.params[0]);
      final dest = context.getStack(int.parse(instruction.params[1]));

      final v = context.copy(context.getStack(src));

      context.setAllocated(dest, v);
    }

    if (instruction.name == "mderef") {
      final ptr = int.parse(instruction.params[0]);

      context.setStack(ptr, context.copy(context.getAllocated(ptr)));
    }

    if (instruction.name == "mset") {
      final ptr = int.parse(instruction.params[0]);
      final key = int.parse(instruction.params[1]);
      final val = int.parse(instruction.params[2]);

      (context.getAllocated(ptr) as CodeTable).set(key, context.copy(val));
    }

    if (instruction.name == "mget") {
      final ptr = int.parse(instruction.params[0]);
      final key = int.parse(instruction.params[1]);
      final out = int.parse(instruction.params[2]);

      context.setStack(out, (context.getAllocated(ptr) as CodeTable).get(key));
    }

    if (instruction.name == "set") {
      final ptr = int.parse(instruction.params[0]);
      final key = int.parse(instruction.params[1]);
      final val = int.parse(instruction.params[2]);

      (context.getStack(ptr) as CodeTable).set(key, context.copy(val));
    }

    if (instruction.name == "get") {
      final ptr = int.parse(instruction.params[0]);
      final key = int.parse(instruction.params[1]);
      final out = int.parse(instruction.params[2]);

      context.setStack(out, (context.getStack(ptr) as CodeTable).get(key));
    }

    if (instruction.name == "createIO") {
      final src = int.parse(instruction.params[0]);
      final dest = context.getStack(int.parse(instruction.params[1]));

      final v = context.copy(context.getStack(src));

      context.setAllocated(dest, v);
    }

    if (instruction.name == "ioDeref") {
      final ptr = int.parse(instruction.params[0]);

      context.setStack(ptr, context.copy(context.readIO(ptr)));
    }

    if (instruction.name == "ioCopy") {
      final src = int.parse(instruction.params[0]);
      final dest = int.parse(instruction.params[1]);

      context.setIO(context.getStack(dest), context.copy(context.getStack(src)));
    }

    return i + 1;
  }

  void runProgram(Cell program, Map<int, CodeCellInstruction> instructions) {
    final id = program.data['id'] as String;
    if (!_runtimes.containsKey(id)) {
      _runtimes[id] = CodeRuntimeContext();
    }

    final context = _runtimes[id]!;

    // Bind runtime stuff with the cell's data (so the program cell stores all the program info)
    context.stack = (program.data['stack'] ?? []) as List;
    context.allocated = (program.data['allocated'] ?? []) as List;
    context.io = (program.data['io'] ?? []) as List;

    final ipt = program.data['ipt'];

    for (var i = 0; i < ipt; i++) {
      int idx = program.data['codeptr'];

      // Instruction 0 (default instruction) resets
      if (idx == 0) {
        context.stack.clear();
        context.allocated.clear();
        context.io.clear();
      }

      try {
        program.data['codeptr'] = runInstruction(idx, instructions[idx], context);
      } catch (e) {
        print("Program runtime error: $e");
        print("Code Pointer: $idx");
        print("Faulty Instruction: ${instructions[idx]?.name} ${instructions[idx]?.params.join(" ")}");
      }
    }
  }
}

void codeCellsSubtick() {
  grid.updateCell(
    (cell, x, y) {
      final code = grid.codeManager.getInstructions(x, y, cell.rot);

      grid.codeManager.runProgram(cell, code);
    },
    null,
    "code_program",
  );
}
