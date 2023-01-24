part of logic;

class CodeCellInstruction {
  String name;
  List<String> params;

  CodeCellInstruction(this.name, this.params);
}

class CodeJump {
  int ip;
  CodeJump(this.ip);

  int get hashCode => ip;

  bool operator ==(Object other) {
    if (other is! CodeJump) return false;
    return other.ip == ip;
  }

  bool operator >(Object other) {
    if (other is! CodeJump) return false;
    return other.ip > ip;
  }

  bool operator >=(Object other) {
    if (other is! CodeJump) return false;
    return other.ip >= ip;
  }

  bool operator <=(Object other) {
    if (other is! CodeJump) return false;
    return other.ip <= ip;
  }

  bool operator <(Object other) {
    if (other is! CodeJump) return false;
    return other.ip < ip;
  }
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

  void pushJump(int ip) {
    push(CodeJump(ip));
  }

  void push(dynamic val) {
    stack.add(val);
  }

  void pushFrom(int i) {
    push(get(i));
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

  bool isNum(int i) => get(i) is num;
  bool isStr(int i) => get(i) is String;
  bool isBool(int i) => get(i) is bool;
  bool isJump(int i) => get(i) is CodeJump;
  bool isMap(int i) => get(i) is Map<String, dynamic>;
  bool isList(int i) => get(i) is List;

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

  void eq() {
    final a = pop();
    final b = pop();
    push(a == b);
  }

  void ne() {
    final a = pop();
    final b = pop();
    push(a != b);
  }

  void less() {
    final a = pop();
    final b = pop();
    push(a < b);
  }

  void lessEq() {
    final a = pop();
    final b = pop();
    push(a <= b);
  }

  void greater() {
    final a = pop();
    final b = pop();
    push(a > b);
  }

  void greaterEq() {
    final a = pop();
    final b = pop();
    push(a >= b);
  }

  void and() {
    final a = pop();
    final b = pop();
    push(a && b);
  }

  void or() {
    final a = pop();
    final b = pop();
    push(a || b);
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
    if (instruction == null) return i + 1;

    if (instruction.name == "pop") {
      context.stack.pop();
    }

    if (instruction.name == "link") {
      context.stack.link(
          int.parse(instruction.params[0]), int.parse(instruction.params[1]));
    }

    if (instruction.name == "pushNum") {
      context.stack.pushNum(double.parse(instruction.params[0]));
    }

    if (instruction.name == "pushMap") {
      context.stack.pushMap();
    }

    if (instruction.name == "pushEmptyList") {
      context.stack.pushList();
    }

    if (instruction.name == "pushList") {
      context.stack.pushList(int.parse(instruction.params[0]));
    }

    if (instruction.name == "pushFixedJump") {
      context.stack.pushJump(int.parse(instruction.params[0]));
    }

    if (instruction.name == "pushReturnJump") {
      context.stack.pushJump(i + 1);
    }

    if (instruction.name == "pushCurrentIP") {
      context.stack.pushJump(i);
    }

    if (instruction.name == "pushString") {
      context.stack.pushString(instruction.params.join(" "));
    }

    if (instruction.name == "add") {
      context.stack.sum();
    }

    if (instruction.name == "subtract") {
      context.stack.sub();
    }

    if (instruction.name == "multiply") {
      context.stack.mult();
    }

    if (instruction.name == "divide") {
      context.stack.div();
    }

    if (instruction.name == "exp") {
      context.stack.upArrow();
    }

    if (instruction.name == "index") {
      context.stack.index(
          int.parse(instruction.params[0]), int.parse(instruction.params[1]));
    }

    if (instruction.name == "setIndex") {
      context.stack.setIndex(int.parse(instruction.params[0]),
          int.parse(instruction.params[1]), int.parse(instruction.params[2]));
    }

    if (instruction.name == "pushFrom") {
      context.stack.pushFrom(int.parse(instruction.params[0]));
    }

    if (instruction.name == "branch") {
      final jump1 = context.stack.get(-2) as CodeJump;
      final jump2 = context.stack.get(-3) as CodeJump;
      if (context.stack.get(-1) == true) {
        return jump1.ip;
      } else {
        return jump2.ip;
      }
    }

    if (instruction.name == "goto") {
      return (context.stack.get(-1) as CodeJump).ip;
    }

    if (instruction.name == "stringify") {
      context.stack.stringify(int.parse(instruction.params[0]));
    }

    if (instruction.name == "pushStringified") {
      context.stack.pushStringified(int.parse(instruction.params[0]));
    }

    if (instruction.name == "pushSize") {
      if (context.stack.isJump(-1)) {
        context.stack.pushNum(8);
      }
      if (context.stack.isMap(-1)) {
        context.stack.pushNum(
          (context.stack.get(-1) as Map<String, dynamic>).length.toDouble(),
        );
      }
      if (context.stack.isList(-1)) {
        context.stack.pushNum(
          (context.stack.get(-1) as List).length.toDouble(),
        );
      }
      if (context.stack.isNum(-1)) {
        context.stack.pushNum(8);
      }
      if (context.stack.isBool(-1)) {
        context.stack.pushNum(1);
      }
      if (context.stack.isStr(-1)) {
        context.stack.pushNum(
          (context.stack.get(-1) as String).length.toDouble(),
        );
      }
    }

    if (instruction.name == "set") {
      context.stack.set(
        int.parse(instruction.params[0]),
        int.parse(instruction.params[1]),
      );
    }

    if (instruction.name == "eq") {
      context.stack.eq();
    }

    if (instruction.name == "ne") {
      context.stack.ne();
    }

    if (instruction.name == "less") {
      context.stack.less();
    }

    if (instruction.name == "lessEq") {
      context.stack.lessEq();
    }

    if (instruction.name == "greater") {
      context.stack.greater();
    }

    if (instruction.name == "greaterEq") {
      context.stack.greaterEq();
    }

    if (instruction.name == "and") {
      context.stack.and();
    }

    if (instruction.name == "or") {
      context.stack.or();
    }

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
