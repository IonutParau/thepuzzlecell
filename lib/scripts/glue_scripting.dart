import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:glue_lang/glue.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart';
import 'package:the_puzzle_cell/logic/logic.dart';
import 'package:the_puzzle_cell/scripts/scripts.dart';

class GlueScript {
  File? f;
  String id;
  var vm = GlueVM();
  var printController = StreamController<bool>();
  String writeBuffer = "";
  var output = <String>[];

  GlueScript(this.id, this.f) {
    init();
  }

  GlueScript.noFile(this.id) : f = null {
    init();
  }

  void sandbox() {
    vm.globals.remove('print');
    vm.globals.remove('write');
    vm.globals.remove('read');
    vm.globals.remove('exit');
    vm.globals.remove('list-dir');
    vm.globals.remove('create-dir');
    vm.globals.remove('delete-dir');
    vm.globals.remove('read-file');
    vm.globals.remove('write-file');
    vm.globals.remove('create-file');
    vm.globals.remove('delete-file');
  }

  void loadAPI() {
    vm.globals['print'] = GlueExternalFunction((vm, stack, args) {
      for (var arg in args) {
        output.add(arg.asString(vm, stack));
      }

      printController.sink.add(true);

      return GlueNull();
    });

    vm.globals['write'] = GlueExternalFunction((vm, stack, args) {
      final lines = <String>[];

      for (var arg in args) {
        lines.add(writeBuffer + arg.asString(vm, stack));
        writeBuffer = "";
      }

      var toWrite = lines.join(" ").split("");

      for (var char in toWrite) {
        if (char == '\n') {
          output.add(writeBuffer);
        } else {
          writeBuffer += char;
        }
      }

      printController.sink.add(true);

      return GlueNull();
    });

    vm.globals['cell'] = GlueExternalFunction((vm, stack, args) {
      final m = <String, GlueValue>{};

      var covered = <String>[];

      for (var i = 0; i < args.length; i += 2) {
        final key = args[i];
        final val = args[i + 1].toValue(vm, stack);

        if (key is GlueVariable) {
          m[key.varname] = val;
          covered.add(key.varname);
        } else if (key is GlueString) {
          m[key.str] = val;
          covered.add(key.str);
        }
      }

      if (!covered.contains("id")) {
        m["id"] = GlueString("empty");
      }

      if (!covered.contains("rot")) {
        m["rot"] = GlueNumber(0);
      }

      if (!covered.contains("lifespan")) {
        m["lifespan"] = GlueNumber(0);
      }

      if (!covered.contains("invisible")) {
        m["invisible"] = GlueBool(false);
      }

      if (!covered.contains("last-rot")) {
        m["last-rot"] = m['rot'] ?? GlueNumber(0);
      }

      if (!covered.contains("last-x")) {
        m["last-x"] = m['cx'] ?? GlueNumber(0);
      }

      if (!covered.contains("last-y")) {
        m["last-y"] = m['cy'] ?? GlueNumber(0);
      }

      if (!covered.contains("last-id")) {
        m["last-id"] = m['id'] ?? GlueString("empty");
      }

      return GlueTable(m.map((k, v) => MapEntry(GlueString(k), v))).toValue(vm, stack);
    });

    vm.globals['grid-get-cell'] = GlueExternalFunction((vm, stack, args) {
      args = vm.processedArgs(stack, args);

      if (args.length != 2) {
        throw "grid-get-cell wasn't called with 2 arguments (more specifically, was called with ${args.length})";
      }

      final x = args[0];
      final y = args[1];

      if (x is! GlueNumber) return GlueNull();
      if (y is! GlueNumber) return GlueNull();

      if (x.n.isNegative || x.n.isNaN || x.n.isInfinite) return GlueNull();
      if (y.n.isNegative || y.n.isNaN || y.n.isInfinite) return GlueNull();

      final cx = x.n.toInt();
      final cy = y.n.toInt();

      final c = grid.get(cx, cy);

      if (c == null) {
        return GlueNull();
      }

      final m = <String, GlueValue>{};

      m['id'] = GlueString(c.id);
      m['rot'] = GlueNumber(c.rot.toDouble());
      m['cx'] = c.cx == null ? GlueNull() : GlueNumber(c.cx!.toDouble());
      m['cy'] = c.cy == null ? GlueNull() : GlueNumber(c.cy!.toDouble());
      m['lifespan'] = GlueNumber(c.lifespan.toDouble());
      m['invisible'] = GlueBool(c.invisible);
      m['last-rot'] = GlueNumber(c.lastvars.lastRot.toDouble());
      m['last-x'] = GlueNumber(c.lastvars.lastPos.dx.toDouble());
      m['last-y'] = GlueNumber(c.lastvars.lastPos.dy.toDouble());
      m['last-id'] = GlueString(c.lastvars.id);

      return GlueTable(m.map((k, v) => MapEntry(GlueString(k), v)));
    });

    vm.globals['grid-set-cell'] = GlueExternalFunction((vm, stack, args) {
      args = vm.processedArgs(stack, args);

      if (args.length != 3) {
        throw "grid-set-cell wasn't given 3 arguments (more specifically, was given ${args.length})";
      }

      final x = args[0];
      final y = args[1];
      final cell = args[2];

      if (x is! GlueNumber) return GlueNull();
      if (y is! GlueNumber) return GlueNull();
      if (cell is! GlueTable) return GlueNull();

      if (x.n.isNegative || x.n.isNaN || x.n.isInfinite) return GlueNull();
      if (y.n.isNegative || y.n.isNaN || y.n.isInfinite) return GlueNull();

      final cx = x.n.toInt();
      final cy = y.n.toInt();

      if (!grid.inside(cx, cy)) return GlueNull();

      final c = Cell(cx, cy);

      final id = cell.read(vm, stack, GlueString("id"));
      final rot = cell.read(vm, stack, GlueString("rot"));
      final ccx = cell.read(vm, stack, GlueString("cx"));
      final ccy = cell.read(vm, stack, GlueString("cy"));
      final lifespan = cell.read(vm, stack, GlueString("lifespan"));
      final invisible = cell.read(vm, stack, GlueString("invisible"));
      final lastRot = cell.read(vm, stack, GlueString("last-rot"));
      final lastX = cell.read(vm, stack, GlueString("last-x"));
      final lastY = cell.read(vm, stack, GlueString("last-y"));
      final lastID = cell.read(vm, stack, GlueString("last-id"));

      if (id is! GlueString) return GlueNull();

      if (rot is! GlueNumber) return GlueNull();
      if (rot.n.isInfinite || rot.n.isNaN) return GlueNull();

      if (ccx is GlueNumber && (ccx.n.isInfinite || ccx.n.isNaN))
        return GlueNull();

      if (ccy is GlueNumber && (ccy.n.isInfinite || ccy.n.isNaN))
        return GlueNull();

      if (lifespan is! GlueNumber) return GlueNull();
      if (lifespan.n.isInfinite || lifespan.n.isNaN) return GlueNull();

      if (invisible is! GlueBool) return GlueNull();

      if (lastRot is! GlueNumber) return GlueNull();
      if (lastRot.n.isInfinite || lastRot.n.isNaN) return GlueNull();

      if (lastX is! GlueNumber) return GlueNull();
      if (lastY is! GlueNumber) return GlueNull();

      if (lastID is! GlueString) return GlueNull();

      c.id = id.str;
      c.rot = rot.n.toInt();
      c.cx = ccx is GlueNumber ? ccx.n.toInt() : null;
      c.cy = ccy is GlueNumber ? ccy.n.toInt() : null;
      c.lifespan = lifespan.n.toInt();
      c.invisible = invisible.b;
      c.lastvars = LastVars(lastRot.n.toInt(), lastX.n, lastY.n, lastID.str);

      grid.set(cx, cy, c);

      return GlueNull();
    });

    vm.globals["grid-inside"] = GlueExternalFunction((vm, stack, args) {
      args = vm.processedArgs(stack, args);

      if (args.length != 2) {
        throw "grid-inside wasn't given 2 arguments (more specifically, was given ${args.length})";
      }

      final x = args[0];
      final y = args[1];

      if (x is! GlueNumber) return GlueBool(false);
      if (y is! GlueNumber) return GlueBool(false);

      if (x.n.isInfinite || x.n.isInfinite) return GlueBool(grid.wrap);
      if (y.n.isInfinite || y.n.isInfinite) return GlueBool(grid.wrap);

      return GlueBool(grid.inside(x.n.toInt(), y.n.toInt()));
    });

    vm.globals["grid-load-str"] = GlueExternalFunction((vm, stack, args) {
      args = vm.processedArgs(stack, args);

      if (args.length != 1) {
        throw "grid-load-str wasn't given 1 argument (more specifically, was given ${args.length})";
      }

      final code = args[0].asString(vm, stack);

      grid = loadStr(code);

      return GlueNull();
    });

    vm.globals["grid-save-str"] = GlueExternalFunction((vm, stack, args) {
      return GlueString(SavingFormat.encodeGrid(grid,
          title: grid.title, description: grid.desc));
    });

    vm.globals["grid-toggle-wrap"] = GlueExternalFunction((vm, stack, args) {
      game.toggleWrap();

      return GlueNull();
    });

    vm.globals["grid-has-wrap"] = GlueExternalFunction((vm, stack, args) {
      return GlueBool(grid.wrap);
    });

    vm.globals["fill"] = GlueExternalFunction((vm, stack, args) {
      if (args.length != 5) {
        throw "fill wasn't given 5 arguments (more specifically, was given ${args.length})";
      }

      final rawX = args[0].toValue(vm, stack);
      final rawY = args[1].toValue(vm, stack);
      final rawEndX = args[2].toValue(vm, stack);
      final rawEndY = args[3].toValue(vm, stack);
      final body = args[4];

      if (rawX is! GlueNumber) return GlueNull();
      if (rawY is! GlueNumber) return GlueNull();
      if (rawEndX is! GlueNumber) return GlueNull();
      if (rawEndY is! GlueNumber) return GlueNull();

      if (rawX.n.isInfinite || rawX.n.isNaN) return GlueNull();
      if (rawY.n.isInfinite || rawY.n.isNaN) return GlueNull();
      if (rawEndX.n.isInfinite || rawEndX.n.isNaN) return GlueNull();
      if (rawEndY.n.isInfinite || rawEndY.n.isNaN) return GlueNull();

      final sx = max(rawX.n.toInt(), 0);
      final sy = max(rawY.n.toInt(), 0);
      final ex = min(rawEndX.n.toInt(), grid.width - 1);
      final ey = min(rawEndY.n.toInt(), grid.width - 1);

      void iterFromTo(int s, int e, void Function(int) cb) {
        if (s == e) return cb(s);

        if (s > e) {
          for (var n = s; n >= e; n--) cb(n);
          return;
        }

        if (s < e) {
          for (var n = s; n <= e; n++) cb(n);
          return;
        }
      }

      iterFromTo(sy, ey, (y) {
        iterFromTo(sx, ex, (x) {
          final s = stack.linked;
          s.push(r"$cx", GlueNumber(x.toDouble()));
          s.push(r"$cy", GlueNumber(y.toDouble()));
          body.toValue(vm, s); // toValue executes it, so...
        });
      });

      return GlueNull();
    });

    vm.globals["cam-x"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        final n = args.first;

        if (n is! GlueNumber) return n;

        if (n.n.isInfinite || n.n.isNaN) return n;

        game.storedOffX =
            game.cellToPixelX(n.n.toInt()) + game.canvasSize.x ~/ 2;

        return n;
      }

      return GlueNumber(game.pixelToCellX(game.canvasSize.x ~/ 2).toDouble());
    });

    vm.globals["cam-y"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        final n = args.first;

        if (n is! GlueNumber) return n;

        if (n.n.isInfinite || n.n.isNaN) return n;

        game.storedOffY =
            game.cellToPixelY(n.n.toInt()) + game.canvasSize.y ~/ 2;

        return n;
      }

      return GlueNumber(game.pixelToCellY(game.canvasSize.y ~/ 2).toDouble());
    });

    vm.globals["mouse-x"] = GlueExternalFunction((vm, stack, args) {
      return GlueNumber(game.cellMouseX.toDouble());
    });

    vm.globals["mouse-y"] = GlueExternalFunction((vm, stack, args) {
      return GlueNumber(game.cellMouseY.toDouble());
    });

    vm.globals["current-selection"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        game.currentSelection = args[0].asString(vm, stack);
        game.whenSelected(game.currentSelection);
      }

      return GlueString(game.currentSelection);
    });

    vm.globals["current-rotation"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        final n = args[0];

        if (n is GlueNumber && (n.n.isNaN || n.n.isInfinite)) {
          game.currentRotation = n.n.toInt() % 4;
          for (var i = 0; i < categories.length; i++) {
            game.buttonManager.buttons['cat$i']!.rotation =
                game.currentRotation;
            for (var j = 0; j < categories[i].items.length; j++) {
              game.buttonManager.buttons['cat${i}cell$j']!.rotation =
                  game.currentRotation;

              if (categories[i].items[j] is CellCategory) {
                for (var k = 0; k < categories[i].items[j].items.length; k++) {
                  game.buttonManager.buttons['cat${i}cell${j}sub$k']!.rotation =
                      game.currentRotation;
                }
              }
            }
          }
        }
      }

      return GlueNumber(game.currentRotation.toDouble());
    });

    vm.globals["brush-size"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        final bs = args[0];

        if (bs is! GlueNumber) return GlueNull();
        if (bs.n.isInfinite || bs.n.isNaN || bs.n.isNegative) return GlueNull();
        game.brushSize = bs.n.toInt();
      }

      return GlueNumber(game.brushSize.toDouble());
    });

    vm.globals["brush-temp"] = GlueExternalFunction((vm, stack, args) {
      if (args.isNotEmpty) {
        args = vm.processedArgs(stack, args);

        final bt = args[0];

        if (bt is! GlueNumber) return GlueNull();
        if (bt.n.isInfinite || bt.n.isNaN) return GlueNull();
        game.brushTemp = bt.n.toInt();
      }

      return GlueNumber(game.brushTemp.toDouble());
    });

    vm.globals["q"] = GlueExternalFunction((vm, stack, args) {
      game.q();
      return GlueNull();
    });

    vm.globals["e"] = GlueExternalFunction((vm, stack, args) {
      game.e();
      return GlueNull();
    });

    vm.globals["get-category-info"] = GlueExternalFunction((vm, stack, args) {
      args = vm.processedArgs(stack, args);

      if (args.length != 1) {
        throw "get-category-info wasn't given 1 argument (more specifically, was given ${args.length})";
      }

      final cat = scriptingManager.catByName(args[0].asString(vm, stack));

      if (cat != null) return getCategoryInfo(cat);

      return GlueNull();
    });
  }

  GlueTable getCategoryInfo(CellCategory category) {
    final m = <String, GlueValue>{};

    m["title"] = GlueString(category.title);
    m["description"] = GlueString(category.description);
    m["look"] = GlueString(category.look);
    m["opened"] = GlueBool(category.opened);
    m["max"] = GlueNumber(category.max.toDouble());
    m["items"] = GlueList(List<GlueValue>.generate(category.items.length, (i) {
      final item = category.items[i];

      if (item is String) return GlueString(item);
      if (item is CellCategory) return getCategoryInfo(item);

      return GlueNull();
    }));

    return GlueTable(
      m.map(
        (key, value) => MapEntry(GlueString(key), value),
      ),
    );
  }

  void init() {
    // This loads the standard library
    vm.loadStandard();

    // This deletes unsafe functions
    sandbox();

    // This loads TPC API
    loadAPI();
  }

  void reset() {
    vm = GlueVM();
    init();
  }

  Stream<bool> run(List<String> args) {
    reset();
    printController = StreamController<bool>();
    vm.globals['@cmdargs'] = GlueList(args.map((a) => GlueString(a)).toList());
    if (f != null) {
      vm.evaluate(f!.readAsStringSync());
    }
    return printController.stream;
  }

  Stream<bool> runCode(String code, [GlueStack? stack]) {
    final s = stack ?? GlueStack();
    final val = GlueValue.fromString(code);
    val.toValue(vm, s);
    return printController.stream;
  }
}
