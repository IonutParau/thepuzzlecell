part of scripts;

// Container for all things with Lua modding
class LuaScript {
  LuaState ls;
  Directory dir;

  String get id => path.split(dir.path).last;

  int apiInvokes = 0;

  List<ScriptingError> errors = [];

  LuaScript(this.dir) : ls = LuaState.newState();

  // Handle memory safety
  void collected(LuaState ls, void Function() func, [int expectedReturns = 0]) {
    // Get size of stack
    final original = ls.getTop();

    // Run out epic code that MIGHT leak memory on the stack
    func();

    // Auto-remove waste
    while (ls.getTop() - expectedReturns > original) {
      ls.remove(ls.getTop() - expectedReturns);
    }
  }

  void defineFunc(String name, DartFunction func, int returns, [int minArgs = 0]) {
    ls.pushDartFunction((ls) {
      int result = 0;

      collected(ls, () {
        while (ls.getTop() < minArgs) {
          ls.pushNil();
        }

        try {
          result = func(ls);
        } catch (e) {
          // This can cause UB!!!
          result = returns;

          errors.add(ScriptingError(e.toString(), []));
        }
      }, returns);

      if (result != returns) {
        throw "INTERNAL API ERROR: API wants to return $returns but instead returned $result!!!";
      }

      return returns;
    });
    ls.setField(-2, name);
  }

  void defineGroup(String name, void Function() toRun, [bool global = false]) {
    collected(ls, () {
      ls.newTable();

      toRun();

      if (global) {
        ls.setGlobal(name);
      } else {
        ls.setField(-1, name);
      }
    });
  }

  void OnMsg(String msg) {
    ls.getGlobal("TPC");
    ls.getField(-1, "OnMsg");
    ls.pushString(msg);
    ls.call(1, 0);
  }

  Set<String> definedCells = {};

  bool hasDefinedCell(String cell) => definedCells.contains(cell);

  void pushCell(Cell cell) {
    ls.newTable();

    // id
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.pushString(cell.id);
        return 1;
      }
      final id = ls.toStr(-1)!;
      cell.id = id;
      return 0;
    });
    ls.setField(-2, "id");

    // lifespan
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.pushInteger(cell.lifespan);
        return 1;
      }
      final lifespan = ls.toNumber(-1);
      cell.lifespan = lifespan.toInt();
      return 0;
    });
    ls.setField(-2, "lifespan");

    // rot
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.pushInteger(cell.rot);
        return 1;
      }
      final rot = ls.toNumber(-1);
      cell.rot = rot.toInt();
      return 0;
    });
    ls.setField(-2, "rot");

    // invisible
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.pushBoolean(cell.invisible);
        return 1;
      }
      final invisible = ls.toBoolean(-1);
      cell.invisible = invisible;
      return 0;
    });
    ls.setField(-2, "invisible");

    // tags
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.newTable();
        var i = 0;
        for (var tag in cell.tags) {
          i++;
          ls.pushInteger(i);
          ls.pushString(tag);
          ls.setTable(-3);
        }
        return 1;
      }
      return 0;
    });
    ls.setField(-2, "tags");

    // tag
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 1) {
        cell.tags.add(ls.toStr(-1)!);
      }
      return 0;
    });
    ls.setField(-2, "tag");

    // tagged
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 1) {
        ls.pushBoolean(cell.tags.contains(ls.toStr(-1)!));
        return 1;
      }
      return 0;
    });
    ls.setField(-2, "tagged");

    // cx
    ls.pushDartFunction((ls) {
      ls.pushInteger(cell.cx);
      return 1;
    });
    ls.setField(-2, "cx");

    // cy
    ls.pushDartFunction((ls) {
      ls.pushInteger(cell.cy);
      return 1;
    });
    ls.setField(-2, "cy");

    // data
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 3) {
        final field = ls.toStr(-3)!;
        final type = ls.toStr(-1) ?? "auto";
        if (ls.isString(-2) && (type == "auto" || type == "string")) {
          cell.data[field] = ls.toStr(-2);
        }
        if (ls.isBoolean(-2) && (type == "auto" || type == "bool")) {
          cell.data[field] = ls.toBoolean(-2);
        }
        if (ls.isNumber(-2) && (type == "auto" || type == "number")) {
          cell.data[field] = ls.toNumber(-2);
        }
        if (ls.isNil(-2) && type == "auto") {
          cell.data.remove(field);
        }
      }
      if (ls.getTop() == 2) {
        final field = ls.toStr(-2)!;
        final type = ls.toStr(-1) ?? "auto";
        final val = cell.data[field];

        if (val == null) {
          ls.pushNil();
          return 1;
        }
        if (val is String && (type == "string" || type == "auto")) {
          ls.pushNil();
          return 1;
        }
        if (val is num && (type == "number" || type == "auto")) {
          ls.pushNumber(val.toDouble());
          return 1;
        }
        if (val is bool && (type == "bool" || type == "auto")) {
          ls.pushBoolean(val);
          return 1;
        }
      }
      return 0;
    });
    ls.setField(-2, "data");

    defineGroup("last", () {
      // x
      ls.pushDartFunction((ls) {
        if (ls.getTop() == 1) {
          cell.lastvars.lastPos = Offset(ls.toNumber(-1), cell.lastvars.lastPos.dy);
          return 0;
        }
        ls.pushNumber(cell.lastvars.lastPos.dx);
        return 1;
      });
      ls.setField(-2, "x");

      // y
      ls.pushDartFunction((ls) {
        if (ls.getTop() == 1) {
          cell.lastvars.lastPos = Offset(cell.lastvars.lastPos.dx, ls.toNumber(-1));
          return 0;
        }
        ls.pushNumber(cell.lastvars.lastPos.dy);
        return 1;
      });
      ls.setField(-2, "y");

      // rot
      ls.pushDartFunction((ls) {
        if (ls.getTop() == 1) {
          cell.lastvars.lastRot = ls.toInteger(-1);
          return 0;
        }
        ls.pushInteger(cell.lastvars.lastRot);
        return 1;
      });
      ls.setField(-2, "rot");
    });
  }

  int defineCell(LuaState ls) {
    if (ls.isTable(-1)) {
      ls.getField(-1, "id");
      final cell = ls.toStr(-1)!;
      if (cells.contains(cell)) return 0;
      ls.getField(-2, "name");
      final name = ls.toStr(-1)!;
      ls.getField(-3, "desc");
      final desc = ls.toStr(-1)!;
      ls.getField(-4, "category");
      if (ls.isTable(-1)) {
        final cats = <String>[];

        var i = 0;
        var run = true;
        while (run) {
          i++;
          ls.pushInteger(i);
          ls.getTable(-2);
          if (ls.isNil(-1)) {
            ls.pop(1);
            run = false;
          } else {
            cats.add(ls.toStr(-1)!);
            ls.pop(1);
          }
        }

        scriptingManager.addToCats(cats, cell);
      } else if (ls.isString(-1)) {
        scriptingManager.addToCat(ls.toStr(-1)!, cell);
      }
      ls.getField(-5, "texture");
      final texture = ls.toStr(-1)!;

      ls.getField(-6, "update");
      if (ls.isTable(-1)) {
        ls.getField(-1, "mode");
        final mode = ls.toStr(-1) ?? "4-way";
        ls.pop(1);

        ls.getField(-1, "index");
        final index = ls.toNumberX(-1) ?? -1;
        ls.pop(1);

        ls.getField(-1, "fn");
        print(ls.typeName2(-1));
        if (ls.isFunction(-1)) {
          ls.setGlobal("CELL_UPDATE_FUNCS:$cell");
        }
        ls.pop(1);

        int i = subticks.length;

        if (index >= 0) {
          i = index.toInt();
        }

        subticks.insert(i, () {
          // Optimization!!!
          if (grid.cells.contains(cell)) {
            if (mode == "static") {
              grid.updateCell((cell, x, y) {
                collected(ls, () {
                  ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                  if (ls.isFunction(-1)) {
                    pushCell(cell);
                    ls.pushNumber(x.toDouble());
                    ls.pushNumber(y.toDouble());
                    ls.call(3, 0);
                  }
                });
              }, null, cell);
            }
            if (mode == "4-way") {
              for (var rot in rotOrder) {
                grid.updateCell((cell, x, y) {
                  collected(ls, () {
                    ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                    if (ls.isFunction(-1)) {
                      pushCell(cell);
                      ls.pushNumber(x.toDouble());
                      ls.pushNumber(y.toDouble());
                      ls.call(3, 0);
                    }
                  });
                }, rot, cell);
              }
            }
            if (mode == "2-way") {
              for (var rot in [0, 1]) {
                grid.loopChunks(
                  cell,
                  i == 0 ? GridAlignment.bottomleft : GridAlignment.bottomright,
                  (cell, x, y) {
                    collected(ls, () {
                      ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                      if (ls.isFunction(-1)) {
                        pushCell(cell);
                        ls.pushNumber(x.toDouble());
                        ls.pushNumber(y.toDouble());
                        ls.call(3, 0);
                      }
                    });
                  },
                  filter: (cell, x, y) => cell.id == cell && (cell.rot % 2 == rot) && !cell.updated,
                );
              }
            }
          }
        });
      }

      // YO!!!
      definedCells.add(cell);
      cells.add(cell);
      print("Defining Cell: " + cell);
      cellInfo[cell] = CellProfile(name, desc);
      textureMap['$cell.png'] = "../../mods/$id/${texture.split("/").join(path.separator)}";
      textureMapBackup['$cell.png'] = textureMap['$cell.png']!;
      ls.setGlobal("PROPS:$cell");
    }
    return 0;
  }

  void pushDefinedCellProperty(String cell, String key) {
    ls.getGlobal("PROPS:$cell");
    ls.getField(-1, key);
  }

  void loadAPI() {
    ls.openLibs();

    defineGroup("TPC", () {
      defineFunc("OnMsg", (ls) => 0, 0);

      defineFunc("DefineCell", defineCell, 0, 1);
    }, true);
  }

  int importOther(LuaState ls) {
    final str = ls.checkString(1) ?? "";
    ls.doFile(path.joinAll([dir.path, ...str.split('/')]));
    return 0;
  }

  void init() {
    loadAPI();
    print(path.joinAll([dir.path, 'main.lua']));
    ls.doFile(path.joinAll([dir.path, 'main.lua']));
  }
}
