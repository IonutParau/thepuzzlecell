part of logic;

class CodeCellInstruction {
  String name;
  List<String> params;

  CodeCellInstruction(this.name, this.params);
}

class CodeJump {
  int ip;
  CodeJump(this.ip);
}

class CodeStack {
  final List stack;
  CodeStack(this.stack);

  void pushNum(double n) {
    stack.add(n);
  }

  void pushString(String str) {
    stack.add(str);
  }

  void pushBool(bool b) {
    stack.add(b);
  }

  void pushMap() {
    stack.add(<String, dynamic>{});
  }

  void pushList([int size = 0]) {
    stack.add(List.filled(size, null, growable: true));
  }

  void sum() {
    final a = pop();
    final b = pop();

    push(a + b);
  }

  void sub() {
    final a = pop();
    final b = pop();

    push(a - b);
  }

  void mult() {
    final a = pop();
    final b = pop();

    push(a * b);
  }

  void div() {
    final a = pop();
    final b = pop();

    push(a / b);
  }

  void upArrow() {
    final a = pop();
    final b = pop();

    push(a ^ b);
  }

  void index(int i, int key) {
    final a = get(i);
    final b = get(key);

    push(a[b]);
  }

  void setIndex(int i, int key, int iv) {
    final a = get(i);
    final b = get(key);
    final c = get(iv);

    a[b] = c;
  }

  void stringify(int i) {
    set(i, get(i).toString());
  }

  void pushStringified(int i) {
    push(get(i).toString());
  }

  void push(dynamic val) {
    stack.add(val);
  }

  void swap(int i, int j) {
    final tmp = get(i);
    set(i, get(j));
    set(j, tmp);
  }

  void link(int i, int j) {
    set(i, get(j));
  }

  void clone(int i) {
    push(get(i));
  }

  void isNum(int i) => get(i) is num;
  void isStr(int i) => get(i) is String;
  void isBool(int i) => get(i) is bool;
  void isJump(int i) => get(i) is CodeJump;
  void isMap(int i) => get(i) is Map<String, dynamic>;
  void isList(int i) => get(i) is List;

  dynamic get(int n) {
    if (stack.isEmpty) return null;
    return stack[n % stack.length];
  }

  void set(int n, dynamic val) {
    if (stack.isEmpty) return;
    stack[n % stack.length] = val;
  }

  dynamic pop() {
    return stack.removeLast();
  }

  List popMultiple(int amount) {
    return List.generate(amount, (i) => pop());
  }
}

class CodeRuntimeContext {
  int ip;
  Map<int, CodeCellInstruction> instructions;
  CodeStack stack;

  CodeRuntimeContext(this.ip, this.instructions, this.stack);
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
          final i = c.data['line'] as int;
          final code = c.data['code'] as String;

          final segs = code.split(" ");

          m[i] = CodeCellInstruction(segs.isEmpty ? "" : segs[0],
              segs.length <= 1 ? [] : segs.sublist(1));
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
  int runInstruction(
      int i, CodeCellInstruction? instruction, CodeRuntimeContext context) {
    // TODO: Write new instruction set
    return i + 1;
  }

  void runProgram(Cell program, Map<int, CodeCellInstruction> instructions) {
    final id = program.data['id'] as String;
    if (!_runtimes.containsKey(id)) {
      _runtimes[id] = CodeRuntimeContext(0, {}, CodeStack([]));
    }

    final context = _runtimes[id]!;

    if (program.data['stack'] is List) {
      context.stack = CodeStack(program.data['stack']);
    }

    final ipt = program.data['ipt'];

    for (var i = 0; i < ipt; i++) {
      int idx = program.data['ip'];

      // Instruction 0 (default instruction) resets
      if (idx == 0) {
        context.stack.stack.clear();
        context.stack.pushMap(); // Map at 0 is the IO table
      }

      try {
        program.data['ip'] = runInstruction(idx, instructions[idx], context);
      } catch (e) {
        print("Program runtime error: $e");
        print("Code Pointer: $idx");
        print(
          "Faulty Instruction: ${instructions[idx]?.name} ${instructions[idx]?.params.join(" ")}",
        );
      }
    }
    program.data['stack'] = context.stack.stack;
    program.data['ip'] = context.ip;
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
