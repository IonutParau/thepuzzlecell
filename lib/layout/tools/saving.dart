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
    return valueString[0];
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

Grid loadStr(String str) {
  try {
    if (str.startsWith('P1;')) return P1.decode(str);
    if (str.startsWith('P1+;')) return P1Plus.decodeGrid(str);

    throw "Unsupported saving format";
  } catch (e) {
    if (e is RangeError) {
      print(e.toString());
      print(e.stackTrace?.toString());
    }
  }

  return grid;
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

class SaveCell {
  String id;
  int rot;
  bool place;

  SaveCell(this.id, this.rot, this.place);

  bool sameAs(SaveCell other) =>
      (id == other.id && rot == other.rot && place == other.place);

  Cell asCell(int x, int y) => Cell(x, y)
    ..rot = rot
    ..lastvars.lastRot = rot
    ..id = id;
}

class P1Plus {
  static final sig = "P1+;";

  static final valueString =
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/?\\\':[]{}()";

  static String encodeCell(List<String> cellTable, SaveCell cell) {
    return encodeNum(
      (cellTable.indexOf(cell.id) * 8 + cell.rot + (cell.place ? 4 : 0)),
      valueString,
    );
  }

  static SaveCell decodeCell(List<String> cellTable, String cell) {
    final n = decodeNum(cell, valueString);

    final id = cellTable[n ~/ 8];
    final rot = (n % 8) % 4;
    final placeable = (n % 8) > 3;

    return SaveCell(id, rot, placeable);
  }

  static String encodeGrid(Grid grid) {
    var str = sig;
    str += ";;"; // Title and description
    str += "${encodeNum(grid.width, valueString)};";
    str += "${encodeNum(grid.height, valueString)};";

    final rawCellList = <SaveCell>[];
    final cellTable = <String>{};
    grid.forEach(
      (cell, x, y) {
        rawCellList.add(SaveCell(cell.id, cell.rot, grid.placeable(x, y)));
        cellTable.add(cell.id);
      },
    );

    str += "${cellTable.join(',')};";
    final props = [];
    if (grid.wrap) props.add('WRAP');
    str += "${props.join(',')};";

    // Cell stuff
    final cellList = <SaveCell>[];
    final cellCount = <int>[];
    for (var cell in rawCellList) {
      if (cellList.isEmpty) {
        cellList.add(cell);
        cellCount.add(1);
      } else if (cellList.last.sameAs(cell)) {
        cellCount.last++;
      } else {
        cellList.add(cell);
        cellCount.add(1);
      }
    }

    for (var i = 0; i < cellList.length; i++) {
      str +=
          "${encodeCell(cellTable.toList(), cellList[i])}-${encodeNum(cellCount[i], valueString)};";
    }

    return str;
  }

  static Grid decodeGrid(String code) {
    final segments = code.split(';');

    final width = decodeNum(segments[3], valueString);
    final height = decodeNum(segments[4], valueString);

    final cellTable = segments[5].split(',');

    final props = segments[6];

    final cellList = <SaveCell>[];

    for (var i = 7; i < segments.length; i++) {
      var cellSeg = segments[i];
      if (cellSeg != "") {
        final splitCellSeg = cellSeg.split('-');
        final cell = decodeCell(cellTable, splitCellSeg[0]);
        final count = decodeNum(splitCellSeg[1], valueString);
        for (var j = 0; j < count; j++) {
          cellList.add(cell);
        }
      }
    }

    final grid = Grid(width, height);
    if (props.contains('WRAP')) {
      grid.wrap = true;
    }
    var i = 0;
    grid.forEach(
      (cell, x, y) {
        grid.set(x, y, cellList[i].asCell(x, y));
        grid.place[x][y] = cellList[i].place;
        i++;
      },
    );

    return grid;
  }
}
