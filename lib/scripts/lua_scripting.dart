part of scripts;

// Container for all things with Lua modding
class LuaScript {
  late LuaState ls;
  Directory dir;

  String get id => path.split(dir.path).last;

  Map<String, dynamic> get info {
    final f = File(path.join(dir.path, 'info.json'));

    if (f.existsSync()) {
      return jsonDecode(f.readAsStringSync());
    }

    return {};
  }

  LuaScript(this.dir) {
    ls = LuaState(dll: LuaState.toLibLua(windows: 'dlls/lua54.dll', linux: 'dlls/liblua54.so', macos: 'dlls/liblua52.dylib'));
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
    final releaser = LuaDartFunctionReleaser();

    final cellLib = <String, dynamic>{
      "id": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushString(cell.id);
          return 1;
        }
        final id = ls.toStr(-1);
        cell.id = id!;
        return 0;
      },
      "lifespan": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushInteger(cell.lifespan);
          return 1;
        }
        final lifespan = ls.toInteger(-1);
        cell.lifespan = lifespan;
        return 0;
      },
      "rot": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushInteger(cell.rot);
          return 1;
        }
        final rot = ls.toInteger(-1);
        cell.rot = rot % 4;
        return 0;
      },
      "updated": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushBoolean(cell.updated);
          return 1;
        }
        cell.updated = ls.toBoolean(-1);
        return 0;
      },
      "copy": (LuaState ls) {
        pushCell(cell.copy, ls);
        return 1;
      },
      "invisible": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushBoolean(cell.invisible);
          return 1;
        }
        final invisible = ls.toBoolean(-1);
        cell.invisible = invisible;
        return 0;
      },
      "tags": (LuaState ls) {
        ls.createTable(cell.tags.length, cell.tags.length);
        var i = 0;
        for (var tag in cell.tags) {
          i++;
          ls.pushInteger(i);
          ls.pushString(tag);
          ls.setTable(-3);
        }
        return 1;
      },
      "tag": (LuaState ls) {
        if (ls.top == 1) {
          cell.tags.add(ls.toStr(-1)!);
        }
        return 0;
      },
      "tagged": (LuaState ls) {
        if (ls.top == 1) {
          ls.pushBoolean(cell.tags.contains(ls.toStr(-1)!));
          return 1;
        }
        return 0;
      },
      "cx": (LuaState ls) {
        ls.pushInteger(cell.cx ?? 0);
        return 1;
      },
      "cy": (LuaState ls) {
        ls.pushInteger(cell.cy ?? 0);
        return 1;
      },
      "field": (LuaState ls) {
        if (ls.top == 1) {
          final field = ls.toStr(-1);

          final val = cell.data[field];

          if (val is String) {
            ls.pushString(val);
          } else if (val is int) {
            ls.pushInteger(val);
          } else if (val is double) {
            ls.pushNumber(val);
          } else if (val is bool) {
            ls.pushBoolean(val);
          } else {
            ls.pushNil();
          }

          return 1;
        } else if (ls.top == 2) {
          final field = ls.toStr(-2)!;

          if (ls.type(-1) == LuaType.nil) {
            cell.data.remove(field);
            return 0;
          }

          if (field == "heat") {
            cell.data["heat"] = ls.toInteger(-1);
            return 0;
          }

          final properties = props[cell.id] ?? <CellProperty>[];

          for (var prop in properties) {
            if (prop.key == field) {
              if (prop.type == CellPropertyType.boolean) {
                cell.data[field] = ls.toBoolean(-1);
                return 0;
              } else if (prop.type == CellPropertyType.integer) {
                cell.data[field] = ls.toInteger(-1);
                return 0;
              } else if (prop.type == CellPropertyType.number) {
                cell.data[field] = ls.toNumber(-1);
                return 0;
              } else if (prop.type == CellPropertyType.cellRot) {
                cell.data[field] = ls.toInteger(-1) % 4;
                return 0;
              } else {
                cell.data[field] = ls.toStr(-1);
                return 0;
              }
            }
          }

          final type = ls.type(-1);

          if (type == LuaType.boolean) {
            cell.data[field] = ls.toBoolean(-1);
          }
          if (type == LuaType.number) {
            cell.data[field] = ls.toNumber(-1);
          }
          if (type == LuaType.string) {
            cell.data[field] = ls.toStr(-1);
          }
        }
        return 0;
      },
      "data": (LuaState ls) {
        if (ls.top == 0) {
          ls.pushString(jsonEncode(cell.data));
          return 1;
        }
        final data = jsonDecode(ls.toStr(-1)!);
        cell.data = data;

        return 0;
      },
      "last": <String, dynamic>{
        "x": (LuaState ls) {
          if (ls.top == 1) {
            cell.lastvars.lastPos = Offset(ls.toNumber(-1), cell.lastvars.lastPos.dy);
            return 0;
          }
          ls.pushNumber(cell.lastvars.lastPos.dy);
          return 1;
        },
        "y": (LuaState ls) {
          if (ls.top == 1) {
            cell.lastvars.lastPos = Offset(ls.toNumber(-1), cell.lastvars.lastPos.dy);
            return 0;
          }
          ls.pushNumber(cell.lastvars.lastPos.dy);
          return 1;
        },
        "rot": (LuaState ls) {
          if (ls.top == 1) {
            cell.lastvars.lastRot = ls.toInteger(-1) % 4;
            return 0;
          }
          ls.pushInteger(cell.lastvars.lastRot);
          return 1;
        },
        "id": (LuaState ls) {
          if (ls.top == 1) {
            cell.lastvars.id = ls.toStr(-1)!;
            return 0;
          }
          ls.pushString(cell.lastvars.id);
          return 1;
        },
      },
      "release": (LuaState ls) {
        releaser.release();
        return 0;
      }
    };

    ls.pushLib(cellLib, releaser);
  }

  Cell popCell(LuaState ls, [bool pop = true]) {
    Cell cell = Cell(0, 0);

    // Get ID
    {
      ls.pushString("id");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.id = ls.toStr(-1)!;
      ls.pop(1);
    }

    // Get Rotation
    {
      ls.pushString("rot");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.rot = ls.toInteger(-1) % 4;
      ls.pop(1);
    }

    // Get Lifespan
    {
      ls.pushString("lifespan");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.lifespan = ls.toInteger(-1);
      ls.pop(1);
    }

    // Get Updated
    {
      ls.pushString("updated");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.updated = ls.toBoolean(-1);
      ls.pop(1);
    }

    // Get Invsibile
    {
      ls.pushString("invisible");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.invisible = ls.toBoolean(-1);
      ls.pop(1);
    }

    // Get Tags
    {
      ls.pushString("tags");
      ls.getTable(-2);
      ls.call(0, 1);

      var i = 0;
      while (true) {
        i++;
        ls.pushInteger(i);
        ls.getTable(-2);
        if (ls.type(-1) == LuaType.nil || ls.type(-1) == LuaType.none) {
          ls.pop();
          break;
        } else if (ls.type(-1) == LuaType.string) {
          cell.tags.add(ls.toStr(-1)!);
        }
        ls.pop();
      }

      ls.pop();
    }

    // CX
    {
      ls.pushString("cx");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.cx = ls.toInteger(-1);
      ls.pop();
    }

    // CY
    {
      ls.pushString("cy");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.cy = ls.toInteger(-1);
      ls.pop();
    }

    // Data
    {
      ls.pushString("data");
      ls.getTable(-2);
      ls.call(0, 1);
      cell.data = jsonDecode(ls.toStr(-1)!);
      ls.pop();
    }

    // Lastvars
    {
      ls.pushString("last");
      ls.getTable(-2);

      late int cx;
      late int cy;
      late int rot;
      late String id;

      // X
      {
        ls.pushString("x");
        ls.getTable(-2);
        ls.call(0, 1);
        cx = ls.toInteger(-1);
        ls.pop();
      }

      // Y
      {
        ls.pushString("y");
        ls.getTable(-2);
        ls.call(0, 1);
        cy = ls.toInteger(-1);
        ls.pop();
      }

      // Rot
      {
        ls.pushString("rot");
        ls.getTable(-2);
        ls.call(0, 1);
        rot = ls.toInteger(-1) % 4;
        ls.pop();
      }

      // ID
      {
        ls.pushString("id");
        ls.getTable(-2);
        ls.call(0, 1);
        id = ls.toStr(-1)!;
        ls.pop();
      }

      cell.lastvars = LastVars(rot, cx, cy, id);

      ls.pop();
    }

    if (pop) ls.pop();

    return cell;
  }

  int? addedForceModded(Cell cell, int dir, int force, int side, String moveType) {
    if (definedCells.contains(cell.id)) {
      // We getting into low level Lua VM stuff, we need garbage collection
      final id = cell.id;
      int? result;
      ls.getGlobal("ADDED_FORCE:$id");
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(dir);
        ls.pushInteger(side);
        ls.pushInteger(force);
        ls.pushString(moveType);
        ls.call(5, 1);
        result = ls.toInteger(-1);
        ls.pop();
      }
      ls.pop();
      return result;
    }
    return null;
  }

  bool? moveInsideOfModded(Cell into, int x, int y, int dir, int force, String mt) {
    if (definedCells.contains(into.id)) {
      final id = into.id;
      bool? result;

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
        ls.pop();
      }
      ls.pop();

      return result;
    }
    return null;
  }

  void handleInsideModded(int x, int y, int dir, int force, Cell moving, String mt) {
    final destroyer = grid.at(x, y);
    if (definedCells.contains(destroyer.id)) {
      final id = destroyer.id;
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
      ls.pop();
    }
  }

  bool? isAcidicModded(Cell cell, int dir, int force, String mt, Cell melting, int mx, int my) {
    if (definedCells.contains(cell.id)) {
      final id = cell.id;
      bool? result;
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
        ls.pop();
      }
      ls.pop();
      return result;
    }

    return null;
  }

  void handleAcidModded(Cell cell, int dir, int force, String mt, Cell melting, int mx, int my) {
    if (definedCells.contains(cell.id)) {
      final id = cell.id;
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
      ls.pop();
    }
  }

  int defineCell(LuaState ls) {
    try {
      if (ls.isTable(-1)) {
        ls.pushString("id");
        ls.getTable(-2);
        final cell = ls.toStr(-1)!;
        ls.pop(1);
        if (cells.contains(cell)) return 0;

        ls.pushString("name");
        ls.getTable(-2);
        final name = ls.toStr(-1) ?? defaultProfile.title;
        ls.pop(1);

        ls.pushString("desc");
        ls.getTable(-2);
        final desc = ls.toStr(-1) ?? defaultProfile.description;
        ls.pop(1);

        ls.pushString("category");
        ls.getTable(-2);
        if (ls.isTable(-1)) {
          final cats = <String>[];

          var i = 0;
          var run = true;
          while (run) {
            i++;
            ls.pushInteger(i);
            ls.getTable(-2);
            if (ls.isNilOrNone(-1)) {
              ls.pop(1);
              run = false;
            } else {
              cats.add(ls.toStr(-1)!);
              ls.pop(1);
            }
          }

          scriptingManager.addToCats(cats, cell);
        } else if (ls.isStr(-1)) {
          scriptingManager.addToCat(ls.toStr(-1)!, cell);
        }
        ls.pop(1);

        ls.pushString("texture");
        ls.getTable(-2);
        final texture = ls.toStr(-1) ?? "default.png";
        ls.pop(1);

        ls.pushString("update");
        ls.getTable(-2);
        if (ls.isTable(-1)) {
          ls.pushString("mode");
          ls.getTable(-2);
          final mode = ls.isStr(-1) ? ls.toStr(-1)! : "4-way";
          ls.pop(1);

          ls.pushString("index");
          ls.getTable(-2);
          final index = ls.isNumber(-1) ? ls.toNumber(-1) : -1;
          ls.pop(1);

          ls.pushString("fn");
          ls.getTable(-2);
          if (ls.isFunction(-1)) {
            ls.setGlobal("CELL_UPDATE_FUNCS:$cell");
          } else {
            ls.pop();
          }

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
                  ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                  if (ls.isFunction(-1)) {
                    pushCell(cell, ls);
                    ls.pushNumber(x.toDouble());
                    ls.pushNumber(y.toDouble());
                    ls.call(3, 0);
                  } else {
                    ls.pop();
                  }
                }, null, cell);
              }
              if (mode == "4-way") {
                for (var rot in rotOrder) {
                  grid.updateCell((cell, x, y) {
                    cell.updated = true;
                    ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                    if (ls.isFunction(-1)) {
                      pushCell(cell, ls);
                      ls.pushInteger(x);
                      ls.pushInteger(y);
                      ls.call(3, 0);
                    } else {
                      ls.pop();
                    }
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
                      ls.getGlobal("CELL_UPDATE_FUNCS:${cell.id}");
                      if (ls.isFunction(-1)) {
                        pushCell(cell, ls);
                        ls.pushNumber(x.toDouble());
                        ls.pushNumber(y.toDouble());
                        ls.call(3, 0);
                      } else {
                        ls.pop();
                      }
                    },
                    filter: (cell, x, y) => cell.id == cell && (cell.rot % 2 == rot) && !cell.updated,
                  );
                }
              }
            }
          });
        }
        ls.pop();

        ls.pushString("addedForce");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("ADDED_FORCE:$cell");
        } else {
          ls.pop(1);
        }

        ls.pushString("handleInside");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("HANDLE_INSIDE:$cell");
          ls.pushNil();
        }
        ls.pop(1);

        ls.pushString("moveInsideOf");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("MOVE_INSIDE_OF:$cell");
          ls.pushNil();
        }
        ls.pop(1);

        ls.pushString("acidic");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("IS_ACIDIC:$cell");
          ls.pushNil();
        }
        ls.pop(1);

        ls.pushString("handleAcid");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("HANDLE_ACID:$cell");
          ls.pushNil();
        }
        ls.pop(1);

        ls.pushString("isSticky");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("IS_STICKY:$id");
        } else {
          ls.pop();
        }

        ls.pushString("sticksTo");
        ls.getTable(-2);
        if (ls.isFunction(-1)) {
          ls.setGlobal("STICKS_TO:$id");
        } else {
          ls.pop();
        }

        ls.pushString("isReference");
        ls.getTable(-2);
        if (ls.isBoolean(-1)) {
          if (ls.toBoolean(-1)) {
            referenceCells.add(id);
          }
        }
        ls.pop();

        ls.pushString("properties");
        ls.getTable(-2);
        if (ls.isTable(-1)) {
          final cellProps = <CellProperty>[];

          var i = 0;
          var stopped = false;
          while (!stopped) {
            i++;
            ls.pushInteger(i);
            ls.getTable(-2);
            if (ls.isNilOrNone(-1)) {
              stopped = true;
            } else if (ls.isTable(-1)) {
              ls.pushString("name");
              ls.getTable(-2);
              final name = ls.toStr(-1)!;
              ls.pop(1);

              ls.pushString("desc");
              ls.getTable(-2);
              final desc = ls.toStr(-1)!;
              ls.pop(1);

              ls.pushString("field");
              ls.getTable(-2);
              final field = ls.toStr(-1)!;
              ls.pop(1);

              ls.pushString("type");
              ls.getTable(-2);
              final type = ls.toStr(-1)!;
              ls.pop(1);

              ls.pushString("default");
              ls.getTable(-2);
              for (var propType in CellPropertyType.values) {
                if (propType.name == type) {
                  dynamic val;

                  if (propType == CellPropertyType.number) {
                    val = ls.toNumber(-1);
                  } else if (propType == CellPropertyType.integer) {
                    val = ls.toNumber(-1).toInt();
                  } else if (propType == CellPropertyType.boolean) {
                    val = ls.toBoolean(-1);
                  } else {
                    val = ls.toStr(-1);
                  }
                  cellProps.add(CellProperty(name, desc, field, propType, val));
                }
              }
              ls.pop(1);
            }
            ls.pop(1);
          }

          props[cell] = cellProps;
        }
        ls.pop(1);

        // YO!!!
        definedCells.add(cell);
        cells.add(cell);
        modded.add(cell);
        print("Defined Cell: " + cell);
        cellInfo[cell] = CellProfile(name, desc);
        textureMap['$cell.png'] = "../../mods/$id/${texture.split("/").join(path.separator)}";
        textureMapBackup['$cell.png'] = textureMap['$cell.png']!;
        ls.setGlobal("PROPS:$cell");
      }
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

  T withDefinedCellProperty<T>(String cell, String key, T Function() fn) {
    pushDefinedCellProperty(cell, key);
    final r = fn();
    ls.pop(2);
    return r;
  }

  bool? canMoveModded(Cell cell, int x, int y, int dir, int side, int force, String mt) {
    if (definedCells.contains(cell.id)) {
      return withDefinedCellProperty<bool>(cell.id, "movable", () {
        if (ls.isFunction(-1)) {
          pushCell(cell, ls);
          ls.pushInteger(x);
          ls.pushInteger(y);
          ls.pushInteger(dir);
          ls.pushInteger(side);
          ls.pushInteger(force);
          ls.pushString(mt);
          ls.call(7, 1);
          final b = ls.toBoolean(-1);
          return b;
        }
        return true;
      });
    }

    return null;
  }

  bool? isSticky(Cell cell, int x, int y, int dir, bool base, bool checkedAsBack, int originX, int originY) {
    if (definedCells.contains(cell.id)) {
      final id = cell.id;
      ls.getGlobal("IS_STICKY:$id");
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(x);
        ls.pushInteger(y);
        ls.pushInteger(dir);
        ls.pushBoolean(base);
        ls.pushBoolean(checkedAsBack);
        ls.pushInteger(originX);
        ls.pushInteger(originY);
        ls.call(8, 1);
        final res = ls.toBoolean(-1);
        ls.pop();
        return res;
      }
      ls.pop();
    }

    return null;
  }

  bool? sticksTo(Cell sticker, Cell to, int dir, bool base, bool checkedAsBack, int originX, int originY) {
    final id = sticker.id;
    if (definedCells.contains(id)) {
      ls.getGlobal("STICKS_TO:$id");
      if (ls.isFunction(-1)) {
        pushCell(sticker, ls);
        pushCell(to, ls);
        ls.pushInteger(dir);
        ls.pushBoolean(base);
        ls.pushBoolean(checkedAsBack);
        ls.pushInteger(originX);
        ls.pushInteger(originY);
        ls.call(7, 1);
        final res = ls.toBoolean(-1);
        ls.pop();
        return res;
      }
      ls.pop();
    }

    return null;
  }

  void pushGrid(Grid grid, [LuaState? ls]) {
    final releaser = LuaDartFunctionReleaser();

    final gridAPI = <String, dynamic>{
      "width": (LuaState ls) {
        ls.pushInteger(grid.width);
        return 1;
      },
      "height": (LuaState ls) {
        ls.pushInteger(grid.height);
        return 1;
      },
      "get": (LuaState ls) {
        final x = ls.toInteger(-2);
        final y = ls.toInteger(-1);

        final c = grid.get(x, y);

        if (c == null) {
          ls.pushNil();
        } else {
          pushCell(c, ls);
        }
        return 1;
      },
      "set": (LuaState ls) {
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
      },
      "inside": (LuaState ls) {
        final x = ls.toNumber(-2).toInt();
        final y = ls.toNumber(-1).toInt();

        ls.pushBoolean(grid.inside(x, y));
        return 1;
      },
      "copyCell": (LuaState ls) {
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
      },
      "spawn": (LuaState ls) {
        final cx = ls.toNumber(-3).toInt();
        final cy = ls.toNumber(-2).toInt();
        final cell = popCell(ls, false);

        final c = grid.get(cx, cy);
        if (c != null && c.id == "empty") {
          grid.set(cx, cy, cell);
        }

        return 0;
      },
      "chunkSize": (LuaState ls) {
        ls.pushInteger(grid.chunkSize);
        return 1;
      },
      "tickCount": (LuaState ls) {
        ls.pushInteger(grid.tickCount);
        return 1;
      },
      "title": (LuaState ls) {
        if (ls.top == 1) {
          grid.title = ls.toStr(-1)!;
          return 0;
        }
        ls.pushString(grid.title);
        return 1;
      },
      "desc": (LuaState ls) {
        if (ls.top == 1) {
          grid.desc = ls.toStr(-1)!;
          return 0;
        }
        ls.pushString(grid.desc);
        return 1;
      },
      "wrap": (LuaState ls) {
        if (ls.top == 1) {
          grid.wrap = ls.toBoolean(-1);
          ls.pushNil();
          return 1;
        }

        ls.pushBoolean(grid.wrap);
        return 1;
      },
      "clearChunks": (LuaState ls) {
        grid.clearChunks();
        return 0;
      },
      "rotate": (LuaState ls) {
        final x = ls.toNumber(-3).toInt();
        final y = ls.toNumber(-2).toInt();
        final rot = ls.toNumber(-1).toInt();
        grid.rotate(x, y, rot);
        return 0;
      },
      "placeable": (LuaState ls) {
        final x = ls.toNumber(-2).toInt();
        final y = ls.toNumber(-1).toInt();
        ls.pushString(grid.placeable(x, y));
        return 1;
      },
      "setPlace": (LuaState ls) {
        final x = ls.toNumber(-3).toInt();
        final y = ls.toNumber(-2).toInt();
        final place = ls.toStr(-1)!;

        grid.setPlace(x, y, place);
        return 0;
      },
      "setChunk": (LuaState ls) {
        final x = ls.toNumber(-3).toInt();
        final y = ls.toNumber(-2).toInt();
        final chunk = ls.toStr(-1)!;

        grid.setChunk(x, y, chunk);
        return 0;
      },
      "addBroken": (LuaState ls) {
        while (ls.top < 6) {
          ls.pushNil();
        }

        // Grab cell from -6
        ls.pushNil();
        ls.copy(-7, -1);
        final cell = popCell(ls);

        // Grab rest of args
        final dx = ls.toNumber(-5).toInt();
        final dy = ls.toNumber(-4).toInt();
        final type = ls.toStr(-3)!;
        final rlvx = ls.isNumber(-2) ? ls.toNumber(-2).toInt() : null;
        final rlvy = ls.isNumber(-1) ? ls.toNumber(-1).toInt() : null;

        grid.addBroken(cell, dx, dy, type, rlvx, rlvy);
        return 0;
      },
      "memory": (LuaState ls) {
        if (ls.top == 3) {
          final channel = ls.toInteger(-3);
          final idx = ls.toInteger(-2);
          final val = ls.toNumber(-1);
          grid.memory[channel]?[idx] = val;
          return 0;
        }
        final channel = ls.toNumber(-2).toInt();
        final idx = ls.toNumber(-1).toInt();
        ls.pushNumber(grid.memory[channel]?[idx]?.toDouble() ?? 0);
        return 1;
      },
      "release": (LuaState ls) {
        releaser.release();
        return 0;
      },
      "types": (LuaState ls) {
        final types = grid.cells;
        var i = 0;
        ls.createTable(types.length, types.length);
        for (var type in types) {
          i++;
          ls.pushString(type);
          ls.pushInteger(i);
          ls.setTable(-3);
        }
        return 1;
      },
    };

    (ls ?? this.ls).pushLib(gridAPI, releaser);
  }

  Map<String, dynamic> helperLib() {
    return {
      "toSide": (LuaState ls) {
        final dir = ls.toInteger(-2);
        final rot = ls.toInteger(-1);

        ls.pushInteger(toSide(dir, rot));

        return 1;
      },
      "frontX": (LuaState ls) {
        final x = ls.toInteger(-2);
        final dir = ls.toInteger(-1);

        ls.pushInteger(frontX(x, dir));

        return 1;
      },
      "frontY": (LuaState ls) {
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);

        ls.pushInteger(frontY(y, dir));

        return 1;
      },
      "ungennable": (LuaState ls) {
        ls.pushNil();
        ls.copy(-5, -1);
        final cell = popCell(ls);
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);

        ls.pushBoolean(isUngennable(cell, x, y, dir));
        return 1;
      },
      "generate": (LuaState ls) {
        final x = ls.toInteger(-11);
        final y = ls.toInteger(-10);
        final dir = ls.toInteger(-9);
        final gendir = ls.toInteger(-8);
        final offX = ls.isNumber(-7) ? ls.toInteger(-7) : null;
        final offY = ls.isNumber(-6) ? ls.toInteger(-6) : null;
        final preaddedRot = ls.toInteger(-5);
        final physical = ls.toBoolean(-4);
        final lvxo = ls.toInteger(-3);
        final lvyo = ls.toInteger(-2);
        final ignoreOptimization = ls.toBoolean(-1);
        doGen(x, y, dir, gendir, offX, offY, preaddedRot, physical, lvxo, lvyo, ignoreOptimization);
        return 0;
      },
      "antiGenerate": (LuaState ls) {
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final dir = ls.toInteger(-2);
        final gdir = ls.toInteger(-1);
        doAntiGen(x, y, dir, gdir);
        return 0;
      },
      "superGenerate": (LuaState ls) {
        final x = ls.toInteger(-7);
        final y = ls.toInteger(-6);
        final dir = ls.toInteger(-5);
        final gendir = ls.toInteger(-4);
        final offX = ls.toInteger(-3);
        final offY = ls.toInteger(-2);
        final preaddedRot = ls.toInteger(-1);
        doSupGen(x, y, dir, gendir, offX, offY, preaddedRot);
        return 0;
      },
      "triggerWin": (LuaState ls) {
        puzzleWin = true;
        return 0;
      },
      "triggerLoss": (LuaState ls) {
        puzzleLost = true;
        return 0;
      },
      "IsGeneratable": (LuaState ls) {
        ls.pushNil();
        ls.copy(-5, -1);
        final cell = popCell(ls);
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);
        ls.pushBoolean(!isUngennable(cell, x, y, dir));
        return 1;
      },
      "canBreak": (LuaState ls) {
        ls.pushNil();
        ls.copy(-6, -1);
        final cell = popCell(ls);
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final dir = ls.toInteger(-2);
        final breakTypeName = ls.toStr(-1)!;

        BreakType? breakType;

        for (var bt in BreakType.values) {
          if (bt.name == breakTypeName) {
            breakType = bt;
            break;
          }
        }

        if (breakType == null) {
          ls.pushBoolean(false);
          return 1;
        }

        ls.pushBoolean(breakable(cell, x, y, dir, breakType));
        return 1;
      },
      "transform": (LuaState ls) {
        final x = ls.toInteger(-8);
        final y = ls.toInteger(-7);
        final dir = ls.toInteger(-6);
        final outdir = ls.toInteger(-5);
        final offX = ls.toInteger(-4);
        final offY = ls.toInteger(-3);
        final off = ls.toInteger(-2);
        final backOff = ls.toInteger(-1);
        doTransformer(x, y, dir, outdir, offX, offY, off, backOff);
        return 0;
      }
    };
  }

  Map<String, dynamic> timeAPI() {
    return {
      "Grid": (LuaState ls) {
        if (timeGrid == null) {
          ls.pushNil();
          return 1;
        }
        pushGrid(timeGrid!, ls);
        return 1;
      },
      "Travel": (LuaState ls) {
        travelTime();
        return 0;
      },
    };
  }

  int _channelCallbackI = 0;

  Map<String, dynamic> channelAPI() {
    return {
      "Create": (LuaState ls) {
        final id = ls.toStr(-1)!;
        scriptingManager.createChannel(id);
        return 0;
      },
      "Exists": (LuaState ls) {
        final id = ls.toStr(-1)!;
        ls.pushBoolean(scriptingManager.hasChannel(id));
        return 1;
      },
      "Send": (LuaState ls) {
        final id = ls.toStr(-2)!;
        final content = ls.toStr(-1)!;
        scriptingManager.sendToChannel(id, content);
        return 0;
      },
      "Listen": (LuaState ls) {
        final id = ls.toStr(-2)!;
        ls.pushNil();
        ls.copy(-2, -1);
        final cbId = _channelCallbackI;
        ls.setGlobal("CHANNEL_CALLBACK_$cbId");
        _channelCallbackI++;

        scriptingManager.listenToChannel(id, (data) {
          ls.getGlobal("CHANNEL_CALLBACK_$cbId");
          ls.pushString(data);
          ls.call(1, 0);
        });
        return 0;
      },
    };
  }

  Map<String, dynamic> typesAPI() {
    return {
      "MarkAsEnemy": (LuaState ls) {
        final id = ls.toStr(-1)!;
        if (!enemies.contains(id)) enemies.add(id);
        return 0;
      },
      "MarkAsMovable": (LuaState ls) {
        final id = ls.toStr(-1)!;
        if (!movables.contains(id)) movables.add(id);
        return 0;
      },
      "MarkAsFriendlyEnemy": (LuaState ls) {
        final id = ls.toStr(-1)!;
        if (!friendlyEnemies.contains(id)) friendlyEnemies.add(id);
        return 0;
      },
      "Enemies": (LuaState ls) {
        ls.createTable(enemies.length, enemies.length);

        for (var i = 0; i < enemies.length; i++) {
          ls.pushString(enemies[i]);
          ls.pushInteger(i + 1);
          ls.setTable(-3);
        }
        return 1;
      },
      "Movables": (LuaState ls) {
        ls.createTable(movables.length, movables.length);

        for (var i = 0; i < movables.length; i++) {
          ls.pushString(movables[i]);
          ls.pushInteger(i + 1);
          ls.setTable(-3);
        }
        return 1;
      },
      "FriendlyEnemies": (LuaState ls) {
        ls.createTable(friendlyEnemies.length, friendlyEnemies.length);

        for (var i = 0; i < friendlyEnemies.length; i++) {
          ls.pushString(friendlyEnemies[i]);
          ls.pushInteger(i);
          ls.setTable(-3);
        }
        return 1;
      },
    };
  }

  Map<String, dynamic> mathAPI() {
    return {
      "phi": mathManager.phi.toDouble(),
      "setGlobal": (LuaState ls) {
        final channel = ls.toNumber(-3);
        final idx = ls.toNumber(-2);
        final val = ls.toNumber(-1);
        mathManager.setGlobal(channel, idx, val);
        return 0;
      },
      "getGlobal": (LuaState ls) {
        final channel = ls.toNumber(-2);
        final idx = ls.toNumber(-1);
        ls.pushNumber(mathManager.getGlobal(channel, idx).toDouble());
        return 1;
      },
      "input": (LuaState ls) {
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);
        ls.pushNumber(mathManager.input(x, y, dir).toDouble());
        return 1;
      },
      "output": (LuaState ls) {
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final dir = ls.toInteger(-2);
        final count = ls.toNumber(-1);
        mathManager.output(x, y, dir, count);
        return 0;
      },
      "logn": (LuaState ls) {
        final x = ls.toNumber(-2);
        final n = ls.toNumber(-1);
        ls.pushNumber(mathManager.logn(x, n));
        return 1;
      },
    };
  }

  Map<String, dynamic> moveAPI() {
    return {
      "canMove": (LuaState ls) {
        final x = ls.toInteger(-5);
        final y = ls.toInteger(-4);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final moveTypeName = ls.toStr(-1);

        var mt = MoveType.unknown_move;

        for (var moveType in MoveType.values) {
          if (moveType.name == moveTypeName) {
            mt = moveType;
          }
        }

        if (!grid.inside(x, y)) {
          ls.pushBoolean(false);
          return 1;
        }

        ls.pushBoolean(canMove(x, y, dir, force, mt));
        return 1;
      },
      "moveInsideOf": (LuaState ls) {
        // Cell is -6
        ls.pushNil();
        ls.copy(-7, -1);
        final cell = popCell(ls);

        final x = ls.toInteger(-5);
        final y = ls.toInteger(-4);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final mtn = ls.toStr(-1)!;

        var mt = MoveType.unknown_move;

        for (var movetype in MoveType.values) {
          if (movetype.name == mtn) {
            mt = movetype;
          }
        }

        ls.pushBoolean(moveInsideOf(cell, x, y, dir, force, mt));
        return 1;
      },
      "handleInside": (LuaState ls) {
        final x = ls.toInteger(-6);
        final y = ls.toInteger(-5);
        final dir = ls.toInteger(-4);
        final force = ls.toInteger(-3);
        ls.pushNil();
        ls.copy(-3, -1);
        final moving = popCell(ls);
        final mt = strToMoveType(ls.toStr(-1));

        handleInside(x, y, dir, force, moving, mt);

        return 0;
      },
      "moveCell": (LuaState ls) {
        final ox = ls.toInteger(-8);
        final oy = ls.toInteger(-7);
        final nx = ls.toInteger(-6);
        final ny = ls.toInteger(-5);
        final dir = ls.isNumber(-4) ? ls.toInteger(-4) : null;

        ls.pushNil();
        ls.copy(-4, -1);
        final cell = ls.isTable(-1) ? popCell(ls, false) : null;
        ls.pop();

        final mt = strToMoveType(ls.toStr(-2));
        final force = ls.toInteger(-1);

        ls.pushBoolean(moveCell(ox, oy, nx, ny, dir, cell, mt, force));
        return 1;
      },
      "swap": (LuaState ls) {
        final x1 = ls.toInteger(-4);
        final y1 = ls.toInteger(-3);
        final x2 = ls.toInteger(-2);
        final y2 = ls.toInteger(-1);

        swapCells(x1, y1, x2, y2);

        return 0;
      },
      "addedForce": (LuaState ls) {
        ls.pushNil();
        ls.copy(-5, -1);
        final cell = popCell(ls);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final mt = strToMoveType(ls.toStr(-1));

        ls.pushInteger(addedForce(cell, dir, force, mt));
        return 1;
      },
      "acidic": (LuaState ls) {
        ls.pushNil();
        ls.copy(-8, -1);

        final cell = popCell(ls);

        final dir = ls.toInteger(-6);
        final force = ls.toInteger(-5);
        final mt = strToMoveType(ls.toStr(-4));
        ls.pushNil();
        ls.copy(-4, -1);
        final melting = popCell(ls);
        final mx = ls.toInteger(-2);
        final my = ls.toInteger(-1);

        ls.pushBoolean(acidic(cell, dir, force, mt, melting, mx, my));
        return 1;
      },
      "handleAcid": (LuaState ls) {
        ls.pushNil();
        ls.copy(-8, -1);
        final cell = popCell(ls);
        final dir = ls.toInteger(-6);
        final force = ls.toInteger(-5);
        final mt = strToMoveType(ls.toStr(-4));
        ls.pushNil();
        ls.copy(-4, -1);
        final melting = popCell(ls);
        final mx = ls.toInteger(-2);
        final my = ls.toInteger(-1);

        handleAcid(cell, dir, force, mt, melting, mx, my);

        return 0;
      },
      "Push": (LuaState ls) {
        final x = ls.toInteger(-6);
        final y = ls.toInteger(-5);
        final dir = ls.toInteger(-4);
        final force = ls.toInteger(-3);
        final mt = strToMoveType(ls.toStr(-2));
        final replaceCell = ls.isTable(-1) ? popCell(ls, false) : null;

        ls.pushBoolean(
          push(x, y, dir, force, mt: mt, replaceCell: replaceCell),
        );
        return 1;
      },
      "Pull": (LuaState ls) {
        final x = ls.toInteger(-5);
        final y = ls.toInteger(-4);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final mt = strToMoveType(ls.toStr(-1));

        ls.pushBoolean(pull(x, y, dir, force, mt));
        return 1;
      },
      "Nudge": (LuaState ls) {
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final dir = ls.toInteger(-2);
        final mt = strToMoveType(ls.toStr(-1));
        ls.pushBoolean(nudge(x, y, dir, mt: mt));
        return 1;
      },
      "speedMover": (LuaState ls) {
        final x = ls.toInteger(-5);
        final y = ls.toInteger(-4);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final speed = ls.toInteger(-1);
        doSpeedMover(x, y, dir, force, speed);
        return 0;
      },
      "speedPuller": (LuaState ls) {
        final x = ls.toInteger(-5);
        final y = ls.toInteger(-4);
        final dir = ls.toInteger(-3);
        final force = ls.toInteger(-2);
        final speed = ls.toInteger(-1);
        doSpeedPuller(x, y, dir, force, speed);
        return 0;
      },
      "grabSide": (LuaState ls) {
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final mdir = ls.toInteger(-2);
        final dir = ls.toInteger(-1);

        ls.pushBoolean(grabSide(x, y, mdir, dir));
        return 1;
      },
      "drill": (LuaState ls) {
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);
        ls.pushBoolean(doDriller(x, y, dir));
        return 1;
      },
      "unstableMove": (LuaState ls) {
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final dir = ls.toInteger(-1);
        unstableMove(x, y, dir);
        return 0;
      },
      "unstablePushOut": (LuaState ls) {
        ls.pushNil();
        ls.copy(-6, -1);
        final cell = popCell(ls);
        final x = ls.toInteger(-4);
        final y = ls.toInteger(-3);
        final dir = ls.toInteger(-2);
        final copy = ls.toBoolean(-1);
        ls.pushBoolean(unstablePushOut(cell, x, y, dir, copy));
        return 1;
      },
    };
  }

  Map<String, dynamic> queuesAPI() {
    return {
      "create": (LuaState ls) {
        QueueManager.create(ls.toStr(-1)!);

        return 0;
      },
      "delete": (LuaState ls) {
        QueueManager.delete(ls.toStr(-1)!);

        return 0;
      },
      "add": (LuaState ls) {
        final key = ls.toStr(-2)!;
        final funcName = "QUEUE-FUNC:${Uuid().v4()}";
        ls.pushNil();
        ls.copy(-2, -1);
        ls.setGlobal(funcName);
        QueueManager.add(key, () {
          ls.getGlobal(funcName);
          ls.call(0, 0);
          ls.pushNil();
          ls.setGlobal(funcName);
        });

        return 0;
      },
      "empty": (LuaState ls) {
        final key = ls.toStr(-1)!;

        QueueManager.empty(key);

        return 0;
      },
      "hasQueue": (LuaState ls) {
        final key = ls.toStr(-1)!;

        ls.pushBoolean(QueueManager.hasInQueue(key));

        return 1;
      },
      "runQueue": (LuaState ls) {
        final key = ls.toStr(-1)!;

        QueueManager.runQueue(key);

        return 0;
      },
      "runLimitedQueue": (LuaState ls) {
        final key = ls.toStr(-2)!;
        final limit = ls.toInteger(-1);

        QueueManager.runQueue(key, limit);

        return 0;
      },
    };
  }

  String fixPath(String p) {
    return path.normalize(path.joinAll([dir.path, ...p.split('/')]));
  }

  Map<String, dynamic> fsAPI() {
    return {
      "create": (LuaState ls) {
        final path = fixPath(ls.toStr(-1)!);

        if (path.startsWith(dir.path)) {
          final f = File(path);
          f.createSync();
        }

        return 0;
      },
      "delete": (LuaState ls) {
        final path = fixPath(ls.toStr(-1)!);

        if (path.startsWith(dir.path)) {
          final f = File(path);
          f.deleteSync();
        }

        return 0;
      },
      "writeTo": (LuaState ls) {
        final path = fixPath(ls.toStr(-2)!);
        final content = ls.toStr(-1)!;

        if (path.startsWith(dir.path)) {
          final f = File(path);
          f.writeAsStringSync(content);
        }

        return 0;
      },
      "readFrom": (LuaState ls) {
        final path = fixPath(ls.toStr(-1)!);

        if (path.startsWith(dir.path)) {
          final f = File(path);
          ls.pushString(f.readAsStringSync());
          return 1;
        }

        return 0;
      },
      "createDir": (LuaState ls) {
        final path = fixPath(ls.toStr(-1)!);

        if (path.startsWith(dir.path)) {
          final f = Directory(path);
          f.createSync();
        }

        return 0;
      },
      "deleteDir": (LuaState ls) {
        final path = fixPath(ls.toStr(-1)!);

        if (path.startsWith(dir.path)) {
          final f = Directory(path);
          f.deleteSync();
        }

        return 0;
      },
      "listDir": (LuaState ls) {
        final p = fixPath(ls.toStr(-1)!);

        if (p.startsWith(dir.path)) {
          final f = Directory(p);
          final files = f.listSync();

          ls.newTable();
          var i = 0;
          for (var file in files) {
            i++;
            ls.pushInteger(i);
            ls.pushString(path.relative(file.path, from: dir.path));
            ls.setTable(-3);
          }

          return 1;
        }

        return 0;
      },
      // Lua is sync btw, meaning that there is no way for this Lua file to know when this completes lol
      // The best chance it has is track file changes lol
      "asyncUpdateRemotes": (LuaState ls) {
        asyncUpdateRemotes();

        return 0;
      },
    };
  }

  var _postInitCbI = 0;

  void loadAPI() {
    ls.openLibs();

    final tpcAPI = <String, dynamic>{
      "OnMsg": ((LuaState ls) => 0),
      "DefineCell": defineCell,
      "Import": importOther,
      "Module": loadModuleLua,
      "Grid": (LuaState ls) {
        pushGrid(grid);
        return 1;
      },
      "enemyParticleCount": (LuaState ls) {
        ls.pushInteger(enemyParticleCounts);
        return 1;
      },
      "emitParticles": (LuaState ls) {
        final amount = ls.toInteger(-4);
        final x = ls.toInteger(-3);
        final y = ls.toInteger(-2);
        final color = ls.toStr(-1)!;

        if (color == "red") game.redparticles.emit(amount, x, y);
        if (color == "blue") game.blueparticles.emit(amount, x, y);
        if (color == "green") game.greenparticles.emit(amount, x, y);
        if (color == "yellow") game.yellowparticles.emit(amount, x, y);
        if (color == "purple") game.purpleparticles.emit(amount, x, y);
        if (color == "teal") game.tealparticles.emit(amount, x, y);
        if (color == "black") game.blackparticles.emit(amount, x, y);
        if (color == "magenta") game.magentaparticles.emit(amount, x, y);

        return 0;
      },
      "ModList": (LuaState ls) {
        final modList = scriptingManager.getScripts();

        ls.createTable(modList.length, modList.length);

        var i = 0;
        for (var mod in modList) {
          i++;
          final name = scriptingManager.modName(mod);
          final desc = scriptingManager.modDesc(mod);
          final author = scriptingManager.modAuthor(mod);

          ls.pushLib({
            "name": name,
            "description": desc,
            "author": author,
          }); // <table> <lib>
          ls.pushInteger(i); // <table> <lib> i
          ls.pushNil(); // <table> <lib> i nil
          ls.copy(-3, -1); // <table> <lib> i <lib>
          ls.setTable(-4); // <table> <lib>
          ls.pop(); // <table>
        }

        return 1;
      },
      "PostInitialization": (LuaState ls) {
        _postInitCbI++;
        var id = _postInitCbI;
        ls.pushNil();
        ls.copy(-1, -2);
        ls.setGlobal("POST_INIT_CB:$id");
        scriptingManager.postInit.add(() {
          ls.getGlobal("POST_INIT_CB:$id");
          ls.call(0, 0);
          ls.pushNil();
          ls.setGlobal("POST_INIT_CB:$id");
        });
        return 0;
      },
      "CreateCategory": (LuaState ls) {
        final host = ls.toStr(-5)!;
        final name = ls.toStr(-4)!;
        final desc = ls.toStr(-3)!;
        final look = ls.toStr(-2)!;
        final max = ls.toInteger(-1);
        scriptingManager.createCategory(host, name, desc, look, max);
        return 0;
      },
      "Move": moveAPI(),
      "Helper": helperLib(),
      "Queues": queuesAPI(),
      "FS": fsAPI(),
      "Math": mathAPI(),
      "Channel": channelAPI(),
      "Types": typesAPI(),
      "Time": timeAPI(),
    };

    ls.makeLib("TPC", tpcAPI);
  }

  int importOther(LuaState ls) {
    final str = ls.toStr(-1) ?? "";
    ls.loadFile(path.joinAll([dir.path, ...str.split('/')]));
    ls.call(0, 0);
    return 0;
  }

  Future<void> asyncUpdateRemotes() async {
    final Map<String, dynamic> remote = info['remoteFiles'] ?? <String, dynamic>{};

    final remoteFiles = remote.entries.toList();

    for (var remoteFile in remoteFiles) {
      final fileName = path.joinAll([dir.path, ...remoteFile.key.split('/')]);

      if (remoteFile.value is Map<String, dynamic>) {
        final data = remoteFile.value;

        final response = await http.get(Uri.parse(data['url']), headers: data['headers']);

        if (response.statusCode == 200) {
          final f = File(fileName);
          f.createSync();
          f.writeAsBytesSync(response.bodyBytes);
        } else {
          print(
            "[ Warning ]\nRemote file download failed! Might be problematic!\nStatus Code: ${response.statusCode}\nBody: ${response.body}\nURL: ${data['url']}",
          );
        }
      } else if (remoteFile.value is String) {
        final response = await http.get(Uri.parse(remoteFile.value));

        if (response.statusCode == 200) {
          final f = File(fileName);
          f.createSync();
          f.writeAsBytesSync(response.bodyBytes);
        } else {
          print(
            "[ Warning ]\nRemote file download failed! Might be problematic!\nStatus Code: ${response.statusCode}\nBody: ${response.body}\nURL: ${remoteFile.key}",
          );
        }
      }
    }

    return;
  }

  String? get minimumVersion => info["tpcMinimumVersion"]?.toString();

  List get experimentalFlags => info["tpcExperimental"] ?? [];

  bool hasExperimentalFlag(String flag) {
    return experimentalFlags.contains(flag);
  }

  Future<void> init() async {
    if (minimumVersion != null) {
      if (higherVersion(minimumVersion!, currentVersion)) {
        return;
      }
    }

    loadAPI();

    final remoteUpdates = info["remoteUpdates"] ?? "auto";
    if (remoteUpdates == "auto") await asyncUpdateRemotes();

    List modules = info["modules"] ?? [];

    for (var module in modules) {
      if (module is String) {
        loadModule(module);
      }
    }

    final status = ls.loadFile(path.joinAll([dir.path, 'main.lua']));
    if (status != LuaThreadStatus.ok) {
      print(
        "[ Crash ]\nMod: $id\nError Type: ${status.name}\nError Message: ${ls.toStr(-1)}",
      );
      exit(0);
    }
    ls.call(0, 0);

    return;
  }

  int loadModuleLua(LuaState ls) {
    final module = ls.toStr(-1)!;
    ls.loadFile(path.joinAll([assetsPath, 'modules', '$module.lua']));
    ls.call(0, 1);
    return 1;
  }

  void loadModule(String module) {
    ls.loadFile(path.joinAll([assetsPath, 'modules', '$module.lua']));
    ls.call(0, 0);
  }

  MoveType strToMoveType(String? str) {
    for (var mt in MoveType.values) {
      if (mt.name == str) {
        return mt;
      }
    }

    return MoveType.unknown_move;
  }

  bool blocksUnstable(Cell cell, int x, int y, int dir, Cell moving) {
    return withDefinedCellProperty<bool>(cell.id, "blocksUnstable", () {
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(x);
        ls.pushInteger(y);
        ls.pushInteger(dir);
        pushCell(moving, ls);
        ls.call(5, 1);
        final b = ls.toBoolean(-1);
        return b;
      }
      return false;
    });
  }

  bool shouldHaveGenBias(String id, int side) {
    return withDefinedCellProperty<bool>(id, "hasGenBias", () {
      if (ls.isFunction(-1)) {
        ls.pushInteger(side);
        ls.call(1, 1);
        return ls.toBoolean(-1);
      }
      return false;
    });
  }

  bool isUngeneratable(Cell cell, int x, int y, int dir) {
    return withDefinedCellProperty<bool>(cell.id, "ungeneratable", () {
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(x);
        ls.pushInteger(y);
        ls.pushInteger(dir);
        ls.call(4, 1);
        return ls.toBoolean(-1);
      }
      return false;
    });
  }

  String? customText(Cell cell, num x, num y) {
    return withDefinedCellProperty<String?>(cell.id, "customText", () {
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushNumber(x.toDouble());
        ls.pushNumber(y.toDouble());
        ls.call(3, 1);
        if (ls.isNilOrNone(-1)) {
          return null;
        } else {
          return ls.toStr(-1);
        }
      } else {
        ls.pop();
      }

      return null;
    });
  }

  bool hasGrabberBias(Cell cell, int x, int y, int dir, int mdir) {
    return withDefinedCellProperty<bool>(cell.id, "hasGrabBias", () {
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(x);
        ls.pushInteger(y);
        ls.pushInteger(dir);
        ls.pushInteger(mdir);
        ls.call(5, 1);
        return ls.toBoolean(-1);
      }
      return false;
    });
  }

  bool breakable(Cell cell, int x, int y, int dir, BreakType bt) {
    return withDefinedCellProperty<bool>(cell.id, "breakable", () {
      if (ls.isFunction(-1)) {
        pushCell(cell, ls);
        ls.pushInteger(x);
        ls.pushInteger(y);
        ls.pushInteger(dir);
        ls.pushString(bt.name);
        ls.call(5, 1);
        return ls.toBoolean(-1);
      }
      return true;
    });
  }
}
