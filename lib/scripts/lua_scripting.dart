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

  void pushCell(Cell cell, LuaState ls) {
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

    // updated
    ls.pushDartFunction((ls) {
      if (ls.getTop() == 0) {
        ls.pushBoolean(cell.updated);
        return 1;
      }
      cell.updated = ls.toBoolean(-1);
      return 0;
    });
    ls.setField(-2, "updated");

    // copy
    ls.pushDartFunction((ls) {
      pushCell(cell.copy, ls);
      return 1;
    });
    ls.setField(-2, "copy");

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
      if (ls.getTop() == 0) {
        ls.newTable();
        cell.data.forEach(
          (key, value) {
            if (value is String) {
              ls.pushString(value);
            } else if (value is int) {
              ls.pushInteger(value);
            } else if (value is double) {
              ls.pushNumber(value.toDouble());
            } else if (value is bool) {
              ls.pushBoolean(value);
            } else {
              ls.pushNil();
            }
            ls.setField(-2, key);
          },
        );
        return 1;
      }
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

    ls.newTable();
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
    ls.setField(-2, "last");
  }

  Cell popCell(LuaState ls, [bool pop = true]) {
    Cell cell = Cell(0, 0);

    collected(ls, () {
      ls.getField(-1, "id");
      ls.call(0, 1);
      cell.id = ls.toStr(-1)!;
      ls.pop(1);

      ls.getField(-1, "rot");
      ls.call(0, 1);
      cell.rot = ls.toInteger(-1);
      ls.pop(1);

      ls.getField(-1, "data");
      ls.call(0, 1);

      String? lastKey;

      // Why Lua
      while (true) {
        ls.pushString(lastKey);
        if (ls.next(-2)) {
          if (ls.isString(-2)) {
            final key = ls.toStr(-2)!;
            lastKey = key;
            final prop = props[cell.id]?.where((e) => e.key == key);
            if (prop == null || prop.isEmpty) {
              // Auto inferrence
              if (ls.isBoolean(-1)) {
                cell.data[key] = ls.toBoolean(-1);
              }
              if (ls.isInteger(-1)) {
                cell.data[key] = ls.toInteger(-1);
              }
              if (ls.isNumber(-1)) {
                cell.data[key] = ls.toNumber(-1);
              }
              if (ls.isString(-1)) {
                cell.data[key] = ls.toStr(-1);
              }
            } else {
              final p = prop.first;

              if (p.type == CellPropertyType.number) {
                cell.data[key] = ls.toNumber(-1);
              } else if (p.type == CellPropertyType.integer) {
                cell.data[key] = ls.toInteger(-1);
              } else if (p.type == CellPropertyType.boolean) {
                cell.data[key] = ls.toBoolean(-1);
              } else {
                cell.data[key] = ls.toStr(-1);
              }
            }
          }
          ls.pop(2);
        } else {
          break;
        }
      }
      ls.pop(1);

      ls.getField(-1, "lifespan");
      ls.call(0, 1);
      cell.lifespan = ls.toInteger(-1);
      ls.pop(1);

      ls.getField(-1, "updated");
      ls.call(0, 1);
      cell.updated = ls.toBoolean(-1);
      ls.pop(1);

      ls.getField(-1, "cx");
      ls.call(0, 1);
      cell.cx = ls.toInteger(-1);
      ls.pop(1);

      ls.getField(-1, "cy");
      ls.call(0, 1);
      cell.cy = ls.toInteger(-1);
      ls.pop(1);

      ls.getField(-1, "tags");
      ls.call(0, 1);
      var i = 0;
      while (true) {
        i++;
        ls.pushInteger(i);
        ls.getTable(-2);
        if (ls.isString(-1)) {
          cell.tags.add(ls.toStr(-1)!);
        } else if (ls.isNil(-1)) {
          ls.pop(1);
          break;
        }
        ls.pop(1);
      }
      ls.pop(1);

      ls.getField(-1, "invisible");
      ls.call(0, 1);
      cell.invisible = ls.toBoolean(-1);
      ls.pop(1);

      ls.getField(-1, "last");

      double lastX = 0;
      double lastY = 0;
      int lastRot = 0;

      ls.getField(-1, "x");
      ls.call(0, 1);
      lastX = ls.toNumber(-1);
      ls.pop(1);

      ls.getField(-1, "y");
      ls.call(0, 1);
      lastY = ls.toNumber(-1);
      ls.pop(1);

      ls.getField(-1, "rot");
      ls.call(0, 1);
      lastRot = ls.toInteger(-1);
      ls.pop(1);

      ls.pop(1);

      cell.lastvars = LastVars(lastRot, lastX, lastY);
    });

    if (pop) ls.pop(1);

    return cell;
  }

  int? addedForce(Cell cell, int dir, int force, int side, String moveType) {
    if (definedCells.contains(cell.id)) {
      // We getting into low level Lua VM stuff, we need garbage collection
      final id = cell.id;
      int? result;
      collected(ls, () {
        ls.getGlobal("ADDED_FORCE:$id");
        if (ls.isFunction(-1)) {
          pushCell(cell, ls);
          ls.pushInteger(dir);
          ls.pushInteger(side);
          ls.pushInteger(force);
          ls.pushString(moveType);
          ls.call(5, 1);
          result = ls.toIntegerX(-1);
        }
      });
      return result;
    }
    return null;
  }

  bool? moveInsideOf(Cell into, int x, int y, int dir, int force, String mt) {
    if (definedCells.contains(into.id)) {
      final id = into.id;
      bool? result;

      collected(ls, () {
        ls.getGlobal("MOVE_INSIDE_OF:$id");
        if (ls.isFunction(-1)) {
          pushCell(into, ls);
          ls.pushInteger(x);
          ls.pushInteger(y);
          ls.pushInteger(dir);
          ls.pushInteger(toSide(dir, into.rot));
          ls.pushInteger(force);
          ls.pushString(mt);
          ls.call(7, 1);
          result = ls.toBoolean(-1);
        }
      });

      return result;
    }
    return null;
  }

  void handleInside(int x, int y, int dir, int force, Cell moving, String mt) {
    final destroyer = grid.at(x, y);
    if (definedCells.contains(destroyer.id)) {
      final id = destroyer.id;
      collected(ls, () {
        ls.getGlobal("HANDLE_INSIDE:$id");
        if (ls.isFunction(-1)) {
          pushCell(destroyer, ls);
          ls.pushInteger(x);
          ls.pushInteger(y);
          pushCell(moving, ls);
          ls.pushInteger(dir);
          ls.pushInteger(toSide(dir, moving.rot));
          ls.pushInteger(force);
          ls.pushString(mt);
          ls.call(8, 0);
        }
      });
    }
  }

  bool? isAcidic(Cell cell, int dir, int force, String mt, Cell melting, int mx, int my) {
    if (definedCells.contains(cell.id)) {
      final id = cell.id;
      bool? result;
      collected(ls, () {
        ls.getGlobal("IS_ACIDIC:$id");
        if (ls.isFunction(-1)) {
          pushCell(cell, ls);
          ls.pushInteger(dir);
          ls.pushInteger(toSide(dir, cell.rot));
          ls.pushInteger(force);
          ls.pushString(mt);
          pushCell(melting, ls);
          ls.pushInteger(mx);
          ls.pushInteger(my);
          ls.call(8, 1);
          result = ls.toBoolean(-1);
        }
      });
      return result;
    }

    return null;
  }

  void handleAcid(Cell cell, int dir, int force, String mt, Cell melting, int mx, int my) {
    if (definedCells.contains(cell.id)) {
      final id = cell.id;
      collected(ls, () {
        ls.getGlobal("HANDLE_ACID:$id");
        if (ls.isFunction(-1)) {
          pushCell(cell, ls);
          ls.pushInteger(dir);
          ls.pushInteger(toSide(dir, cell.rot));
          ls.pushInteger(force);
          ls.pushString(mt);
          pushCell(melting, ls);
          ls.pushInteger(mx);
          ls.pushInteger(my);
          ls.call(8, 0);
        }
      });
    }
  }

  int defineCell(LuaState ls) {
    try {
      collected(ls, () {
        if (ls.isTable(-1)) {
          ls.getField(-1, "id");
          final cell = ls.toStr(-1)!;
          if (cells.contains(cell)) return;
          ls.pop(1);

          ls.getField(-1, "name");
          final name = ls.toStr(-1) ?? defaultProfile.title;
          ls.pop(1);

          ls.getField(-1, "desc");
          final desc = ls.toStr(-1) ?? defaultProfile.description;
          ls.pop(1);

          ls.getField(-1, "category");
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
          ls.pop(1);

          ls.getField(-1, "texture");
          final texture = ls.toStr(-1) ?? "default.png";
          ls.pop(1);

          ls.getField(-1, "update");
          if (ls.isTable(-1)) {
            ls.getField(-1, "mode");
            final mode = ls.toStr(-1) ?? "4-way";
            ls.pop(1);

            ls.getField(-1, "index");
            final index = ls.toNumberX(-1) ?? -1;
            ls.pop(1);

            ls.getField(-1, "fn");
            if (ls.isFunction(-1)) {
              ls.setGlobal("CELL_UPDATE_FUNCS:$cell");
              ls.pushNil();
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
                    cell.updated = true;
                    collected(ls, () {
                      ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                      if (ls.isFunction(-1)) {
                        pushCell(cell, ls);
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
                      cell.updated = true;
                      collected(ls, () {
                        ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                        if (ls.isFunction(-1)) {
                          pushCell(cell, ls);
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
                        cell.updated = true;
                        collected(ls, () {
                          ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                          if (ls.isFunction(-1)) {
                            pushCell(cell, ls);
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
          ls.pop(1);

          ls.getField(-1, "addedForce");
          if (ls.isFunction(-1)) {
            ls.setGlobal("ADDED_FORCE:$cell");
            ls.pushNil();
          }
          ls.pop(1);

          ls.getField(-1, "handleInside");
          if (ls.isFunction(-1)) {
            ls.setGlobal("HANDLE_INSIDE:$cell");
            ls.pushNil();
          }
          ls.pop(1);

          ls.getField(-1, "moveInsideOf");
          if (ls.isFunction(-1)) {
            ls.setGlobal("MOVE_INSIDE_OF:$cell");
            ls.pushNil();
          }
          ls.pop(1);

          ls.getField(-1, "acidic");
          if (ls.isFunction(-1)) {
            ls.setGlobal("IS_ACIDIC:$cell");
            ls.pushNil();
          }
          ls.pop(1);

          ls.getField(-1, "handleAcid");
          if (ls.isFunction(-1)) {
            ls.setGlobal("HANDLE_ACID:$cell");
            ls.pushNil();
          }
          ls.pop(1);

          // YO!!!
          definedCells.add(cell);
          cells.add(cell);
          modded.add(cell);
          print("Defining Cell: " + cell);
          cellInfo[cell] = CellProfile(name, desc);
          textureMap['$cell.png'] = "../../mods/$id/${texture.split("/").join(path.separator)}";
          textureMapBackup['$cell.png'] = textureMap['$cell.png']!;
          ls.setGlobal("PROPS:$cell");
        }
      });
    } catch (e, st) {
      print(e);
      print(st);
    }
    return 0;
  }

  void pushDefinedCellProperty(String cell, String key) {
    ls.getGlobal("PROPS:$cell");
    ls.getField(-1, key);
  }

  void pushGrid(Grid grid) {
    ls.newTable();

    defineFunc("width", (ls) {
      ls.pushInteger(grid.width);
      return 1;
    }, 1, 0);

    defineFunc("height", (ls) {
      ls.pushInteger(grid.height);
      return 1;
    }, 1, 0);

    defineFunc("get", (ls) {
      final x = ls.toNumber(-2).toInt();
      final y = ls.toNumber(-1).toInt();

      final c = grid.get(x, y);

      if (c == null) {
        ls.pushNil();
      } else {
        pushCell(c, ls);
      }
      return 1;
    }, 1, 2);

    defineFunc("set", (ls) {
      try {
        final x = ls.toNumber(-3).toInt();
        final y = ls.toNumber(-2).toInt();
        final cell = popCell(ls, false);

        grid.set(x, y, cell);
        return 0;
      } catch (e, st) {
        print(e);
        print(st);
        return 0;
      }
    }, 0, 3);

    defineFunc("inside", (ls) {
      final x = ls.toNumber(-2).toInt();
      final y = ls.toNumber(-1).toInt();

      ls.pushBoolean(grid.inside(x, y));
      return 1;
    }, 1, 2);

    defineFunc("copyCell", (ls) {
      final cx = ls.toNumber(-5).toInt();
      final cy = ls.toNumber(-4).toInt();
      final nx = ls.toNumber(-3).toInt();
      final ny = ls.toNumber(-2).toInt();
      final update = ls.toBoolean(-1);

      final c = grid.get(cx, cy)?.copy;
      if (c != null) {
        c.updated = c.updated || update;

        grid.set(nx, ny, c);
      }

      return 0;
    }, 0, 5);

    defineFunc("copyCell", (ls) {
      final cx = ls.toNumber(-5).toInt();
      final cy = ls.toNumber(-4).toInt();
      final nx = ls.toNumber(-3).toInt();
      final ny = ls.toNumber(-2).toInt();
      final update = ls.toBoolean(-1);

      final c = grid.get(cx, cy)?.copy;
      if (c != null) {
        c.updated = c.updated || update;

        grid.set(nx, ny, c);
      }

      return 0;
    }, 0, 5);

    defineFunc("spawn", (ls) {
      final cx = ls.toNumber(-3).toInt();
      final cy = ls.toNumber(-2).toInt();
      final cell = popCell(ls, false);

      final c = grid.get(cx, cy);
      if (c != null && c.id == "empty") {
        grid.set(cx, cy, cell);
      }

      return 0;
    }, 0, 3);

    defineFunc("chunkSize", (ls) {
      ls.pushInteger(grid.chunkSize);
      return 1;
    }, 1, 0);

    defineFunc("tickCount", (ls) {
      ls.pushInteger(grid.tickCount);
      return 1;
    }, 1, 0);

    defineFunc("title", (ls) {
      if (ls.getTop() == 1) {
        grid.title = ls.toStr(-1)!;
        ls.pushNil();
        return 1;
      }

      ls.pushString(grid.title);
      return 1;
    }, 1, 0);

    defineFunc("desc", (ls) {
      if (ls.getTop() == 1) {
        grid.title = ls.toStr(-1)!;
        ls.pushNil();
        return 1;
      }

      ls.pushString(grid.title);
      return 1;
    }, 1, 0);

    defineFunc("wrap", (ls) {
      if (ls.getTop() == 1) {
        grid.wrap = ls.toBoolean(-1);
        ls.pushNil();
        return 1;
      }

      ls.pushBoolean(grid.wrap);
      return 1;
    }, 1, 0);

    defineFunc("clearChunks", (ls) {
      grid.clearChunks();
      return 0;
    }, 0, 0);

    defineFunc("rotate", (ls) {
      final x = ls.toNumber(-3).toInt();
      final y = ls.toNumber(-2).toInt();
      final rot = ls.toNumber(-1).toInt();
      grid.rotate(x, y, rot);
      return 0;
    }, 0, 3);

    defineFunc("addBroken", (ls) {
      final x = ls.toNumber(-3).toInt();
      final y = ls.toNumber(-2).toInt();
      final rot = ls.toNumber(-1).toInt();
      grid.rotate(x, y, rot);
      return 0;
    }, 0, 3);

    defineFunc("placeable", (ls) {
      final x = ls.toNumber(-2).toInt();
      final y = ls.toNumber(-1).toInt();
      ls.pushString(grid.placeable(x, y));
      return 1;
    }, 1, 2);

    defineFunc("setPlace", (ls) {
      final x = ls.toNumber(-3).toInt();
      final y = ls.toNumber(-2).toInt();
      final place = ls.toStr(-1)!;

      grid.setPlace(x, y, place);
      return 0;
    }, 0, 3);

    defineFunc("setChunk", (ls) {
      final x = ls.toNumber(-3).toInt();
      final y = ls.toNumber(-2).toInt();
      final chunk = ls.toStr(-1)!;

      grid.setChunk(x, y, chunk);
      return 0;
    }, 0, 3);

    defineFunc("addBroken", (ls) {
      // Grab cell from -6
      ls.pushNil();
      ls.copy(-7, -1);
      final cell = popCell(ls);

      // Grab rest of args
      final dx = ls.toNumber(-5).toInt();
      final dy = ls.toNumber(-4).toInt();
      final type = ls.toStr(-3)!;
      final rlvx = ls.toNumberX(-2)?.toInt();
      final rlvy = ls.toNumberX(-1)?.toInt();

      grid.addBroken(cell, dx, dy, type, rlvx, rlvy);
      return 0;
    }, 0, 6);

    defineFunc("memory", (ls) {
      final channel = ls.toNumber(-2).toInt();
      final idx = ls.toNumber(-1).toInt();
      ls.pushNumber(grid.memory[channel]?[idx]?.toDouble() ?? 0);
      return 1;
    }, 1, 2);
  }

  void loadAPI() {
    ls.openLibs();

    defineGroup("TPC", () {
      defineFunc("OnMsg", (ls) => 0, 0);

      defineFunc("DefineCell", defineCell, 0, 1);

      defineFunc("Import", importOther, 0, 1);

      defineFunc("Grid", (ls) {
        pushGrid(grid);
        return 1;
      }, 1, 0);

      defineFunc("enemyParticleCount", (ls) {
        ls.pushNumber(enemyParticleCounts.toDouble());
        return 1;
      }, 1);
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
