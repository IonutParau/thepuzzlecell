import 'dart:async';
import 'dart:io';

import 'package:glue_lang/glue.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

class GlueScript {
  File f;
  String id;
  var vm = GlueVM();
  var printController = StreamController<String>();

  GlueScript(this.id, this.f) {
    init();
  }

  void sandbox() {
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
        printController.sink.add(arg.asString(vm, stack));
      }

      return GlueNull();
    });

    vm.globals['write'] = GlueExternalFunction((vm, stack, args) {
      final lines = <String>[];

      for (var arg in args) {
        lines.add(arg.asString(vm, stack));
      }

      printController.sink.add(lines.join(" "));

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
        m["id"] = GlueNumber(0);
      }

      if (!covered.contains("lifespan")) {
        m["lifespan"] = GlueNumber(0);
      }

      if (!covered.contains("invisible")) {
        m["invisible"] = GlueNumber(0);
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

      return GlueTable(m.map((k, v) => MapEntry(GlueString(k), v)));
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

      if (ccx is GlueNumber && (ccx.n.isInfinite || ccx.n.isNaN)) return GlueNull();

      if (ccy is GlueNumber && (ccy.n.isInfinite || ccy.n.isNaN)) return GlueNull();

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

  Stream<String> run(List<String> args) {
    reset();
    printController = StreamController<String>();
    vm.globals['@cmdargs'] = GlueList(args.map((a) => GlueString(a)).toList());
    vm.evaluate(f.readAsStringSync());
    return printController.stream;
  }
}
