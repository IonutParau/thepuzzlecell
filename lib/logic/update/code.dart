part of logic;

class CodeCellInstruction {
  String name;
  List<String> params;

  CodeCellInstruction(this.name, this.params);
}

class CodeJump {
  int ip;
  CodeJump(this.ip);

  @override
  int get hashCode => ip;

  @override
  bool operator ==(Object other) {
    if (other is! CodeJump) {
      return false;
    }
    return other.ip == ip;
  }

  bool operator >(Object other) {
    if (other is! CodeJump) {
      return false;
    }
    return other.ip > ip;
  }

  bool operator >=(Object other) {
    if (other is! CodeJump) {
      return false;
    }
    return other.ip >= ip;
  }

  bool operator <=(Object other) {
    if (other is! CodeJump) {
      return false;
    }
    return other.ip <= ip;
  }

  bool operator <(Object other) {
    if (other is! CodeJump) {
      return false;
    }
    return other.ip < ip;
  }
}

class CodeStack {
  final List<dynamic> stack;
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

    if (a is List && b is num) {
      push(a[b.toInt()]);
    }

    if (a is Map<String, dynamic>) {
      push(a[b.toString()]);
    }
  }

  void setIndex(int i, int key, int iv) {
    final a = get(i);
    final b = get(key);
    final c = get(iv);

    if (a is List && b is num) {
      a[b.toInt()] = c;
    }
    if (a is Map<String, dynamic>) {
      a[b.toString()] = c;
    }
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

  void remove(int i) {
    if (stack.isEmpty) {
      return;
    }
    stack.removeAt(i % stack.length);
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

  bool isNull(int i) => get(i) == null;
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

  List<dynamic> popMultiple(int amount) {
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
  Map<String, dynamic> buffers;

  CodeRuntimeContext(this.ip, this.instructions, this.stack, this.buffers);
}

class CodeCellManager {
  final Map<String, CodeRuntimeContext> _runtimes = {};

  dynamic getBuffer(String program, String buffer) {
    return _runtimes[program]?.buffers[buffer];
  }

  void setBuffer(String program, String buffer, dynamic value) {
    _runtimes[program]?.buffers[buffer] = value;
  }

  void clearContexts() {
    _runtimes.clear();
  }

  Map<int, CodeCellInstruction> getInstructions(int x, int y, int dir) {
    var cx = x;
    var cy = y;
    var m = <int, CodeCellInstruction>{};

    while (true) {
      cx = frontX(cx, dir);
      cy = frontY(cy, dir);

      if (grid.inside(cx, cy)) {
        final c = grid.at(cx, cy);

        if (c.id == "code_instruction") {
          final i = (c.data['line'] as num).toInt();
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

    if (instruction.name == "pop") {
      context.stack.pop();
    }

    if (instruction.name == "link") {
      context.stack.link(int.parse(instruction.params[0]), int.parse(instruction.params[1]));
    }

    if (instruction.name == "pushNum") {
      if (instruction.params[0] == "infinity") {
        context.stack.pushNum(double.infinity);
      } else if (instruction.params[0] == "-infinity") {
        context.stack.pushNum(double.negativeInfinity);
      } else if (instruction.params[0] == "nan") {
        context.stack.pushNum(double.nan);
      } else {
        context.stack.pushNum(double.parse(instruction.params[0]));
      }
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

    if (instruction.name == "pushBool") {
      context.stack.pushBool(instruction.params[0] == "true");
    }

    if (instruction.name == "pushNull") {
      context.stack.push(null);
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
      context.stack.index(int.parse(instruction.params[0]), int.parse(instruction.params[1]));
    }

    if (instruction.name == "setIndex") {
      context.stack.setIndex(int.parse(instruction.params[0]), int.parse(instruction.params[1]), int.parse(instruction.params[2]));
    }

    if (instruction.name == "pushFrom") {
      context.stack.pushFrom(int.parse(instruction.params[0]));
    }

    if (instruction.name == "branch") {
      final jump1 = context.stack.get(-2) as CodeJump;
      final jump2 = context.stack.get(-3) as CodeJump?;
      final cond = context.stack.get(-1);
      context.stack.pop();
      context.stack.pop();
      context.stack.pop();
      if (cond == true) {
        return jump1.ip;
      } else if (jump2 != null) {
        return jump2.ip;
      }
    }

    if (instruction.name == "goto") {
      return (context.stack.pop() as CodeJump).ip;
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

    if (instruction.name == "list-add") {
      final l = context.stack.get(int.parse(instruction.params[0]));
      final v = context.stack.get(int.parse(instruction.params[1]));

      if (l is List) {
        l.add(v);
      }
    }

    if (instruction.name == "list-removeAt") {
      final l = context.stack.get(int.parse(instruction.params[0]));
      final i = context.stack.get(int.parse(instruction.params[1]));

      if (l is List && i is num) {
        l.removeAt(i.toInt());
      }
    }

    if (instruction.name == "list-insertAt") {
      final l = context.stack.get(int.parse(instruction.params[0]));
      final i = context.stack.get(int.parse(instruction.params[1]));
      final v = context.stack.get(int.parse(instruction.params[2]));

      if (l is List && i is num) {
        l.insert(i.toInt(), v);
      }
    }

    if (instruction.name == "list-contains") {
      final l = context.stack.get(int.parse(instruction.params[0]));
      final v = context.stack.get(int.parse(instruction.params[1]));

      if (l is List) {
        context.stack.pushBool(l.contains(v));
      }
    }

    if (instruction.name == "list-join") {
      final l = context.stack.get(int.parse(instruction.params[0]));
      final sep = context.stack
          .get(
            int.parse(instruction.params[1]),
          )
          .toString();

      if (l is List) {
        context.stack.pushString(l.join(sep));
      }
    }

    if (instruction.name == "pop-n") {
      for (var i = 0; i < int.parse(instruction.params[0]); i++) {
        context.stack.pop();
      }
    }

    if (instruction.name == "mapListPairs") {
      final m = context.stack.get(int.parse(instruction.params[0]));
      final map = context.stack.get(m);

      if (map is Map<String, dynamic>) {
        context.stack.push(map.entries.map((entry) => <String, dynamic>{"key": entry.key, "value": entry.value}).toList());
      }
    }

    if (instruction.name == "isNull") {
      context.stack.push(context.stack.isNull(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isNumber") {
      context.stack.push(context.stack.isNum(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isString") {
      context.stack.push(context.stack.isStr(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isJump") {
      context.stack.push(context.stack.isJump(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isList") {
      context.stack.push(context.stack.isList(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isMap") {
      context.stack.push(context.stack.isMap(int.parse(instruction.params[0])));
    }

    if (instruction.name == "isBool") {
      context.stack.push(context.stack.isBool(int.parse(instruction.params[0])));
    }

    if (instruction.name == "ioCreate") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();

      if (!context.buffers.containsKey(buffName)) {
        context.buffers[buffName] = null;
      }
    }

    if (instruction.name == "ioErase") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();

      context.buffers.remove(buffName);
    }

    if (instruction.name == "ioGet") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();

      context.stack.push(context.buffers[buffName]);
    }

    if (instruction.name == "ioSet") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();
      final val = context.stack.get(int.parse(instruction.params[1]));

      context.buffers[buffName] = val;
    }

    if (instruction.name == "ioGetExternal") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();
      final programName = context.stack.get(int.parse(instruction.params[1])).toString();

      context.stack.push(getBuffer(programName, buffName));
    }

    if (instruction.name == "ioSetExternal") {
      final buffName = context.stack.get(int.parse(instruction.params[0])).toString();
      final programName = context.stack.get(int.parse(instruction.params[1])).toString();
      final val = context.stack.get(int.parse(instruction.params[2]));

      setBuffer(programName, buffName, val);
    }

    return i + 1;
  }

  void runProgram(Cell program, Map<int, CodeCellInstruction> instructions) {
    final id = program.data['id'] as String;
    if (!_runtimes.containsKey(id)) {
      _runtimes[id] = CodeRuntimeContext(0, {}, CodeStack([]), {});
    }

    final context = _runtimes[id]!;

    if (program.data['stack'] is List) {
      context.stack = CodeStack(program.data['stack']);
    }

    if (program.data['buffers'] is List) {
      context.buffers = program.data['buffers'];
    }

    final ipt = program.data['ipt'];

    for (var i = 0; i < ipt; i++) {
      int idx = program.data['ip'];

      // Instruction 0 (default instruction) resets
      if (idx == 0) {
        context.stack.stack.clear();
      }

      try {
        program.data['ip'] = runInstruction(idx, instructions[idx], context);
      } catch (e) {
        print("Program: $id");
        print("Program runtime error: $e");
        print("Code Pointer: $idx");
        print("[ Code ]");
        instructions.entries.toList().forEach((entry) {
          print("${entry.key}. ${entry.value.name} ${entry.value.params.join(" ")}");
        });
        print(
          "Faulty Instruction: ${instructions[idx]?.name} ${instructions[idx]?.params.join(" ")}",
        );
      }
    }
    program.data['stack'] = context.stack.stack;
    program.data['buffers'] = context.buffers;
    program.data['ip'] = context.ip;
  }
}

void codeCellsSubtick() {
  grid.codeManager.clearContexts();
  grid.updateCell(
    (cell, x, y) {
      final code = grid.codeManager.getInstructions(x, y, cell.rot);

      grid.codeManager.runProgram(cell, code);
    },
    null,
    "code_program",
    useQuadChunks: true,
  );
}
