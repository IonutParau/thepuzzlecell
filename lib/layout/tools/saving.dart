part of tools;

String saveGrid(Grid grid) {
  final code = {};

  code['width'] = grid.width;
  code['height'] = grid.height;
  code['cells'] = {};
  grid.forEach(
    (Cell cell, int x, int y) {
      if (cell.id == "empty" && !grid.placeable(x, y)) return;
      if (code['cells'][cell.id] == null) code['cells'][cell.id] = [];

      code['cells'][cell.id].add("$x $y ${cell.rot} ${grid.placeable(x, y)}");
    },
  );

  return JsonEncoder.withIndent("  ").convert(code);
}

Grid loadGrid(Map<String, dynamic> code) {
  final grid = Grid(code['width'], code['height']);

  grid.wrap = code['wrap'] ?? false;

  final cells = code['cells'] as Map;
  cells.forEach(
    (id, places) {
      for (var place in places) {
        final parts = place.split(' ');
        final x = int.parse(parts[0]);
        final y = int.parse(parts[1]);
        final rot = int.parse(parts[2]);
        final isPlaceable = parts[3] == 'true';

        final cell = Cell(x, y);
        cell.id = id;
        cell.rot = rot;
        cell.lastvars.lastRot = rot;
        grid.set(x, y, cell);
        grid.place[x][y] = isPlaceable;
      }
    },
  );

  return grid;
}

String encodeNum(int n, String valueString) {
  final cellNum = n;
  var cellBase = 0;

  while (cellNum >= pow(valueString.length, cellBase)) {
    //print('$cellBase');
    cellBase++;
  }

  if (cellNum == 0) {
    return '';
  } else {
    var cellString = '';
    for (var i = 0; i < cellBase; i++) {
      var iN = min(n ~/ pow(valueString.length, cellBase - 1 - i),
          valueString.length - 1);
      cellString += valueString[iN];
      n -= iN * pow(valueString.length, cellBase - 1 - i).toInt();
    }
    return cellString;
  }
}

int decodeNum(String n, String valueString) {
  var numb = 0;
  for (var i = 0; i < n.length; i++) {
    final char = n[i];
    numb += valueString.indexOf(char) *
        pow(valueString.length, n.length - 1 - i).toInt();
  }
  return numb;
}

class P1 {
  static String valueString =
      "qwertyuiopasdfghjklzxcvbnm,<.>/?:'[{]}\\=+-_1234567890!@#\$%^&*()`~";
  static String encode(Grid grid) {
    final rawCellList = <Cell>[];
    final rawCellPlace = <bool>[];
    final ids = <String>{};

    grid.forEach(
      (cell, x, y) {
        rawCellList.add(cell);
        ids.add(cell.id);
        rawCellPlace.add(grid.placeable(x, y));
      },
    );

    var str = "P1;";
    str += "${valueString.length};";
    str += encodeNum(grid.width, valueString) + ';';
    str += encodeNum(grid.height, valueString) + ';';
    for (var i = 0; i < ids.length; i++) {
      if (i == ids.length - 1) {
        str += ids.elementAt(i) + ';';
      } else {
        str += ids.elementAt(i) + ',';
      }
    }
    str += ";;";
    if (grid.wrap) str += "WRAP;";

    final cellList = <Cell>[];
    final cellCount = <int>[];
    final compiledCellPlace = <bool>[];

    for (var i = 0; i < rawCellList.length; i++) {
      final cell = rawCellList[i];
      final place = rawCellPlace[i];

      if (cellList.isEmpty) {
        cellList.add(cell);
        cellCount.add(1);
        compiledCellPlace.add(place);
      } else {
        final lastCell = cellList.last;
        final lastPlace = compiledCellPlace.last;

        if (lastCell.id == cell.id &&
            lastCell.rot == cell.rot &&
            lastPlace == place) {
          cellCount.last++;
        } else {
          cellList.add(cell);
          cellCount.add(1);
          compiledCellPlace.add(place);
        }
      }
    }

    for (var i = 0; i < cellList.length; i++) {
      final cell = cellList[i];
      if (cell != "") {
        str +=
            "${ids.toList().indexOf(cell.id)}|${cell.rot}|${encodeNum(cellCount[i], valueString)}|${compiledCellPlace[i] ? '+' : ''};";
      }
    }

    return str;
  }

  static Grid decode(String code) {
    final segments = code.split(';');
    segments.removeAt(0);

    final vstr = valueString.substring(0, int.parse(segments[0]));

    final grid = Grid(
      decodeNum(
        segments[1],
        vstr,
      ),
      decodeNum(
        segments[2],
        vstr,
      ),
    );

    final cellTable = segments[3].split(',');

    if (segments[6] == "WRAP") {
      grid.wrap = true;
    }

    var segmentRemCount = 6;
    if (grid.wrap) segmentRemCount++;
    for (var i = 0; i < segmentRemCount; i++) {
      segments.removeAt(0);
    }

    final cellList = <Cell>[];
    final cellPlace = <bool>[];

    for (var i = 0; i < segments.length; i++) {
      if (segments[i] != "") {
        final cellSegs = segments[i].split('|');
        final cell = Cell(0, 0);
        cell.id = cellTable[int.parse(cellSegs.first)];
        cell.rot = int.parse(cellSegs[1]);
        cell.lastvars.lastRot = cell.rot;
        final count = decodeNum(cellSegs[2], vstr);
        final atts = cellSegs[3];
        for (var i = 0; i < count; i++) {
          cellList.add(cell);
          cellPlace.add(atts.contains('+'));
        }
      }
    }

    var i = 0;

    grid.chunkSize = 25;

    grid.reloadChunks();

    grid.forEach(
      (cell, x, y) {
        if (i < cellList.length) {
          final cell = Cell(x, y);
          cell.id = cellList[i].id;
          cell.rot = cellList[i].rot;
          cell.lastvars.lastRot = cell.rot;
          grid.set(x, y, cell);
          grid.place[x][y] = cellPlace[i];
        }
        i++;
      },
    );

    return grid;
  }
}
