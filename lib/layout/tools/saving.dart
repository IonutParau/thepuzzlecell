part of tools;

String saveGrid(Grid grid) {
  final code = {};

  code['width'] = grid.width;
  code['height'] = grid.height;
  code['cells'] = {};
  grid.forEach(
    (Cell cell, int x, int y) {
      if (cell.id == "empty" && grid.placeable(x, y) == "empty") return;
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
        final isPlaceable = parts[3] == 'true' ? "place" : "empty";

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
    cellBase++;
  }

  if (cellNum == 0) {
    return valueString[0];
  } else {
    var cellString = '';
    for (var i = 0; i < cellBase; i++) {
      var iN = min(n ~/ pow(valueString.length, cellBase - 1 - i), valueString.length - 1);
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
    numb += valueString.indexOf(char) * pow(valueString.length, n.length - 1 - i).toInt();
  }
  return numb;
}

Grid loadStr(String str, [bool allowGameStateChanges = true]) {
  if (str.startsWith('P1;')) return P1.decode(str);
  if (str.startsWith('P1+;')) return P1Plus.decodeGrid(str);
  if (str.startsWith('P2;')) return P2.decodeGrid(str);
  if (str.startsWith('V1;')) return MysticCodes.decodeV1(str);
  if (str.startsWith('V3;')) return MysticCodes.decodeV3(str);
  if (str.startsWith('P3;')) return P3.decodeString(str);
  if (str.startsWith('P4;')) return P4.decodeString(str, allowGameStateChanges);
  if (str.startsWith('P5;')) return P5.decodeString(str, allowGameStateChanges);

  throw "Unsupported saving format";
}

class P1 {
  static String valueString = "qwertyuiopasdfghjklzxcvbnm,<.>/?:'[{]}\\=+-_1234567890!@#\$%^&*()`~";
  static String encode(Grid grid) {
    final rawCellList = <Cell>[];
    final rawCellPlace = <String>[];
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
    final compiledCellPlace = <String>[];

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

        if (lastCell.id == cell.id && lastCell.rot == cell.rot && lastPlace == place) {
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
        str += "${ids.toList().indexOf(cell.id)}|${cell.rot}|${encodeNum(cellCount[i], valueString)}|${compiledCellPlace[i] == "place" ? '+' : ''};";
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

    grid.title = segments[3];
    grid.desc = segments[4];

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
    final cellPlace = <String>[];

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
          cellPlace.add(atts.contains('+') ? "place" : "empty");
        }
      }
    }

    var i = 0;

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
  String place;

  SaveCell(this.id, this.rot, this.place);

  bool sameAs(SaveCell other) => (id == other.id && rot == other.rot && place == other.place);

  Cell asCell(int x, int y) => Cell(x, y)
    ..rot = rot
    ..lastvars.lastRot = rot
    ..id = id;
}

class P1Plus {
  static final sig = "P1+;";

  static final valueString = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/?*.:[]{}()";

  static String encodeCell(List<String> cellTable, SaveCell cell) {
    return encodeNum(
      (cellTable.indexOf(cell.id) * 8 + cell.rot + (cell.place != "empty" ? 4 : 0)),
      valueString,
    );
  }

  static SaveCell decodeCell(List<String> cellTable, String cell) {
    final n = decodeNum(cell, valueString);

    final id = cellTable[n ~/ 8];
    final rot = (n % 8) % 4;
    final placeable = (n % 8) > 3;

    return SaveCell(id, rot, placeable ? "place" : "empty");
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
      str += "${encodeCell(cellTable.toList(), cellList[i])}-${encodeNum(cellCount[i], valueString)};";
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

    grid.title = segments[1];
    grid.desc = segments[2];

    return grid;
  }
}

String placeChar(String place) {
  if (place == "place") return "+";
  if (place == "red_place") return "R+";
  if (place == "blue_place") return "B+";
  if (place == "yellow_place") return "Y+";
  if (place == "rotatable") return "RT";
  return "";
}

String decodePlaceChar(String char) {
  if (char == "+") return "place";
  if (char == "R+") return "red_place";
  if (char == "B+") return "blue_place";
  if (char == "Y+") return "yellow_place";
  if (char == "RT") return "rotatable";

  return "empty";
}

class P2 {
  static String valueString = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM[]{}()-_+=<>./?:'";

  static String encodeCell(Cell cell, Set<String> cellTable) {
    return encodeNum(cellTable.toList().indexOf(cell.id) * 4 + cell.rot, valueString);
  }

  static Cell decodeCell(String cell, List<String> cellTable) {
    final n = decodeNum(cell, valueString);
    final c = Cell(0, 0);
    c.rot = n % 4;
    c.id = cellTable[n ~/ 4];

    return c;
  }

  static String sig = "P2;";

  static String encodeGrid(Grid grid, {String title = "", String description = ""}) {
    var str = sig;
    str += "$title;$description;"; // title and description
    str += (encodeNum(grid.width, valueString) + ';');
    str += (encodeNum(grid.height, valueString) + ';');

    final cellTable = <String>{};

    grid.forEach(
      (cell, x, y) {
        cellTable.add(cell.id);
      },
    );

    str += "${cellTable.join(',')};";

    final cells = [];

    grid.forEach(
      (cell, x, y) {
        cells.add("${encodeCell(cell, cellTable)}|${placeChar(grid.placeable(x, y))}");
      },
    );

    final cellStr = base64.encode(deflate.encode(utf8.encode(cells.join(','))));

    str += (cellStr + ';');

    final props = [];

    if (grid.wrap) props.add("WRAP");

    str += "${props.join(',')};";

    return str;
  }

  static Grid decodeGrid(String str) {
    final segs = str.split(';');
    final grid = Grid(
      decodeNum(segs[3], valueString),
      decodeNum(segs[4], valueString),
    );
    grid.title = segs[1];
    grid.desc = segs[2];

    final cellTable = segs[5].split(',');

    final cellData = utf8.decode(deflate.decode(base64.decode(segs[6])));

    final cells = cellData.split(',');

    var i = 0;
    grid.forEach(
      (cell, x, y) {
        final cell = cells[i];
        grid.set(x, y, decodeCell(cell.split('|').first, cellTable));
        final placeChar = cell.split('|').length == 1 ? '' : cell.split('|')[1];
        grid.setPlace(x, y, decodePlaceChar(placeChar));
        i++;
      },
    );

    if (segs.length >= 7) {
      // Special border mode
      final props = segs[7].split(',');
      grid.wrap = props.contains('WRAP');
    }

    return grid;
  }
}

class MysticCodes {
  static List<int> directions = [0, 1, 2, 3];
  static List<String> types = ["generator", "rotator_cw", "rotator_ccw", "mover", "slide", "push", "wall", "enemy", "trash"];

  static String cellKey = r"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$%&+-.=?^{}";

  static Map<String, int> dictionary = {};

  static bool loaded = false;

  static void init() {
    if (loaded) return;
    loaded = true;
    for (var i = 0; i < 74; i++) {
      dictionary[cellKey[i]] = i;
    }
  }

  static int decodeString(String str) {
    int output = 0;

    for (var char in str.split('')) {
      output *= 74;
      output += dictionary[char]!;
    }

    return output;
  }

  static void setCell(int c, int i, Grid grid) {
    final y = grid.height - (i ~/ grid.width) - 1;

    if (c % 2 == 1) {
      grid.setPlace(i % grid.width, y, "place");
    }

    if (c >= 72) return;

    grid.set(
      i % grid.width,
      y,
      Cell(i % grid.width, y)
        ..id = types[(c ~/ 2) % 9]
        ..rot = (c ~/ 18)
        ..lastvars.lastRot = (c ~/ 18),
    ); // Cascade operator scares me
  }

  static Grid decodeV1(String str) {
    MysticCodes.init();

    List<String> args = str.split(';');

    if (args[0] != "V1") throw "Why are you not giving me a V1 code";

    final grid = Grid(int.parse(args[1]), int.parse(args[2]));

    var placeables = args[3].split(',');

    var cells = args[4].split(',');

    if (placeables.isNotEmpty && placeables.first != "") {
      for (var p in placeables) {
        grid.setPlace(
          int.parse(
            p.split('.').first,
          ),
          grid.height -
              int.parse(
                p.split('.')[1],
              ) -
              1,
          "place",
        );
      }
    }

    if (cells.isNotEmpty && cells.first != "") {
      for (var p in cells) {
        final ps = p.split('.');

        grid.set(
          int.parse(
            ps[2],
          ),
          grid.height -
              int.parse(
                ps[3],
              ) -
              1,
          Cell(
            int.parse(
              ps[2],
            ),
            grid.height -
                int.parse(
                  ps[3],
                ) -
                1,
          )
            ..id = types[int.parse(
              ps.first,
            )]
            ..rot = int.parse(
              ps[1],
            )
            ..lastvars.lastRot = int.parse(
              ps[1],
            ),
        );
      }
    }

    return grid;
  }

  static Grid decodeV3(String str) {
    MysticCodes.init();
    final arguments = str.split(';');
    var length = 0;
    var dataIndex = 0;
    var gridIndex = 0;
    var temp = "";
    final cellDataHistory = <int>[];

    final grid = Grid(decodeString(arguments[1]), decodeString(arguments[2]));

    for (var i = 0; i < grid.width * grid.height; i++) {
      cellDataHistory.add(0);
    }

    var offset = 0;

    while (dataIndex < arguments[3].length) {
      if (arguments[3][dataIndex] == ')' || arguments[3][dataIndex] == '(') {
        if (arguments[3][dataIndex] == ')') {
          dataIndex += 2;
          offset = dictionary[arguments[3][dataIndex - 1]]!;
          length = dictionary[arguments[3][dataIndex]]!;
        } else {
          dataIndex++;
          temp = "";
          while (arguments[3][dataIndex] != ')' && arguments[3][dataIndex] != '(') {
            temp += arguments[3][dataIndex];
            dataIndex++;
          }
          offset = decodeString(temp);
          if (arguments[3][dataIndex] == ')') {
            dataIndex++;
            length = dictionary[arguments[3][dataIndex]]!;
          } else {
            dataIndex++;
            temp = "";
            while (arguments[3][dataIndex] != ')') {
              temp += arguments[3][dataIndex];
              dataIndex++;
            }
            length = decodeString(temp);
          }
        }
        for (int i = 0; i < length; i++) {
          setCell(cellDataHistory[gridIndex - offset - 1], gridIndex, grid);
          cellDataHistory[gridIndex] = cellDataHistory[gridIndex - offset - 1];
          gridIndex++;
        }
      } else {
        setCell(dictionary[arguments[3][dataIndex]]!, gridIndex, grid);
        cellDataHistory[gridIndex] = dictionary[arguments[3][dataIndex]]!;
        gridIndex++;
      }

      dataIndex++;
    }

    return grid;
  }
}

class P3 {
  static String valueString = r"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$%&+-.=?^{}";

  static String signature = "P3;";

  static String encodeData(Map<String, dynamic> data) {
    var dataParts = [];
    data.forEach(
      (key, value) {
        dataParts.add("$key=$value");
      },
    );
    return dataParts.join('.');
  }

  static String encodeCell(int x, int y, Grid grid) {
    final c = grid.at(x, y);
    final bg = grid.placeable(x, y);

    final tagsStr = c.tags.join('.');

    final dataStr = encodeData(c.data);

    return "${c.id}:$x:$y:${c.rot}:$dataStr:$tagsStr:$bg:${c.lifespan}";
  }

  // P3 Compex Validation System
  static bool validate(int x, int y, Grid grid) {
    final c = grid.at(x, y);
    final bg = grid.placeable(x, y);

    return (c.id != "empty" || bg != "empty");
  }

  static String encodeGrid(Grid grid, {String title = "", String description = ""}) {
    var str = signature;
    str += "$title;$description;"; // Title and description
    str += "${encodeNum(grid.width, valueString)};";
    str += "${encodeNum(grid.height, valueString)};";

    final cellDataList = [];

    grid.forEach(
      (cell, x, y) {
        if (validate(x, y, grid)) {
          cellDataList.add(encodeCell(x, y, grid));
        }
      },
    );

    final cellDataStr = base64.encode(
      zlib.encode(
        utf8.encode(
          cellDataList.join(','),
        ),
      ),
    );

    str += "$cellDataStr;";

    final props = [];

    if (grid.wrap) props.add("W");

    str += "${props.join('')};";

    return str;
  }

  static Map<String, dynamic> getData(String str) {
    if (str == "") return <String, dynamic>{};
    final segs = str.split('.');
    final data = <String, dynamic>{};
    if (segs.isEmpty) return data;
    segs.forEach((part) {
      final p = part.split('=');

      dynamic v = p[1];

      if (v == "true" || v == "false") v = (v == "true");
      if (int.tryParse(v) != null) v = int.parse(v);

      data[p[0]] = v;
    });
    return data;
  }

  static P3Cell decodeCell(String str) {
    final segs = str.split(':');

    if (segs.length < 8) segs.add("0");

    return P3Cell(
      segs[0],
      int.parse(segs[1]),
      int.parse(segs[2]),
      int.parse(segs[3]),
      getData(segs[4]),
      segs[5].split('.').toSet(),
      segs[6],
      int.parse(segs[7]),
    );
  }

  static Grid decodeString(String str) {
    final segs = str.split(';');
    final newGrid = Grid(
      decodeNum(segs[3], valueString),
      decodeNum(segs[4], valueString),
    );

    newGrid.title = segs[1];
    newGrid.desc = segs[2];

    final cellDataStr = segs[5] == "eJwDAAAAAAE=" ? "" : utf8.decode(zlib.decode(base64.decode(segs[5])));

    if (cellDataStr != "") {
      final cellDataList = cellDataStr.split(',');

      for (var cellData in cellDataList) {
        decodeCell(cellData).placeOn(newGrid);
      }
    }

    final props = segs[6].split('');
    if (props.contains("W")) newGrid.wrap = true;

    return newGrid;
  }
}

class P3Cell {
  int x, y, rot;
  String id, bg;

  Map<String, dynamic> data;
  Set<String> tags;
  int lifespan;

  P3Cell(this.id, this.x, this.y, this.rot, this.data, this.tags, this.bg, this.lifespan);

  void placeOn(Grid grid) {
    final c = Cell(x, y);
    c.lastvars.lastRot = rot;
    c.rot = rot;
    c.id = id;
    c.data = data;
    c.tags = tags;
    c.lifespan = lifespan;

    grid.set(x, y, c);
    grid.setPlace(x, y, bg);
  }
}

List<String> fancySplit(String thing, String sep) {
  final chars = thing.split("");

  var depth = 0;

  var things = [""];

  var instring = false;

  var alt = false;

  for (var c in chars) {
    if (c == "\\") {
      if (alt) {
        alt = false;
        things.last += c;
      } else {
        alt = true;
      }
      continue;
    }
    if (c == "\"") {
      if (alt) {
        things.last += c;
        continue;
      } else {
        instring = !instring;
        things.last += c;
        continue;
      }
    }
    if (!instring) {
      if (c == "(" && !alt) {
        depth++;
      } else if (c == ")" && !alt) {
        depth--;
      }
    }
    if (depth == 0 && (c == sep || sep == "") && !instring && !alt) {
      if (sep == "") {
        things.last += c;
      }
      things.add("");
    } else {
      things.last += c;
    }
  }

  return things;
}

bool stringContainsAtRoot(String thing, String char) {
  final chars = thing.split("");
  var depth = 0;

  for (var c in chars) {
    if (c == "(") {
      depth++;
    } else if (c == ")") {
      depth--;
    }
    if (depth == 0 && (c == char || char == "")) {
      return true;
    }
  }

  return false;
}

class P4 {
  static final String valueString = r"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!$%&+-.=?^{}";

  static final String base = r"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~/?:@&=+$,#()[]{}%'|^";

  static final baseEncoder = BaseXCodec(base);

  static String header = "P4;";

  static String encodeCell(int x, int y, Grid grid) {
    final c = grid.at(x, y);
    final bg = grid.placeable(x, y);

    final m = {
      "id": c.id,
      "rot": c.rot,
      "data": c.data,
      "tags": c.tags,
      "bg": bg,
      "lifespan": c.lifespan,
      "invisible": c.invisible,
    };

    return encodeValue(m);
  }

  static void setCell(String str, int x, int y, Grid grid) {
    final m = decodeValue(str);

    final c = Cell(x, y);
    c.lastvars.lastRot = m['rot'].toInt();
    c.rot = m['rot'].toInt();
    c.data = m['data'];
    c.tags = {};
    m['tags'].forEach((v) => c.tags.add(v.toString()));
    c.id = m['id'];
    c.lifespan = m['lifespan'].toInt();
    c.invisible = m['invisible'] ?? false;
    final bg = m['bg'];

    grid.set(x, y, c);
    grid.setPlace(x, y, bg);
  }

  static String encodeGrid(Grid grid, {String title = "", String description = ""}) {
    var str = header + '$title;$description;'; // Header, title and description

    str += '${encodeNum(grid.width, valueString)};';
    str += '${encodeNum(grid.height, valueString)};';

    final cellDataList = [];

    grid.forEach(
      (cell, x, y) {
        final cstr = encodeCell(x, y, grid);
        if (cellDataList.isNotEmpty) {
          final m = decodeValue(cellDataList.last);
          final c = m['count'];

          if (encodeValue(m['cell']) == cstr) {
            m['count'] = c + 1;
            cellDataList.last = encodeValue(m);
            return;
          }
        }
        cellDataList.add(encodeValue({"cell": cstr, "count": 1}));
      },
    );

    final cellDataStr = baseEncoder.encode(
      Uint8List.fromList(zlib.encode(
        utf8.encode(
          cellDataList.join(''),
        ),
      )),
    );

    str += '$cellDataStr;';

    final props = {};

    if (grid.wrap) props['W'] = true;

    str += '${encodeValue(props)};';

    return str;
  }

  static Grid decodeString(String str, [bool handleCustomProps = true]) {
    final segs = str.split(';');

    final width = decodeNum(segs[3], valueString);
    final height = decodeNum(segs[4], valueString);

    final g = Grid(width, height);

    g.title = segs[1];
    g.desc = segs[2];

    final rawCellDataList = fancySplit(utf8.decode(zlib.decode(baseEncoder.decode(segs[5])).toList()), '');

    while (rawCellDataList.first == "") {
      rawCellDataList.removeAt(0);
    }
    while (rawCellDataList.last == "") {
      rawCellDataList.removeLast();
    }

    final cellDataList = [];

    for (var cellData in rawCellDataList) {
      final m = decodeValue(cellData);

      final c = m['count'] ?? 1;

      for (var i = 0; i < c; i++) {
        cellDataList.add(encodeValue(m['cell']));
      }
    }

    var i = 0;

    g.forEach(
      (cell, x, y) {
        if (cellDataList.length > i) {
          setCell(cellDataList[i], x, y, g);
        }
        i++;
      },
    );

    final props = decodeValue(segs[6]);
    g.wrap = props['W'] ?? false;

    if (handleCustomProps) {
      if (props['update_delay'] is num) {
        QueueManager.add("post-game-init", () {
          game.delay = props['update_delay']!;
        });
      }
      if (props['viewbox'] != null) {
        QueueManager.add("post-game-init", () {
          final vb = props['viewbox'] as Map;

          game.viewbox = (Offset(vb['x'].toDouble(), vb['y'].toDouble()) & Size(vb['w'].toDouble(), vb['h'].toDouble()));
        });
      }
      // We gotta decode le' RAM stick
      if (props['memory'] != null) {
        final m = props['memory'] as Map;
        m.forEach((key, value) {
          final c = <int, num>{};

          value.forEach((key, value) {
            c[int.parse(key)] = decodeValue(value);
          });

          g.memory[int.parse(key)] = c;
        });
      }
    }

    return g;
  }

  static String encodeValue(dynamic value) {
    if (value is Set) {
      value = value.toList();
    }
    if (value is List) {
      return '(' + value.map<String>((e) => encodeValue(e)).join(":") + ')';
    } else if (value is Map) {
      final keys = value.isEmpty ? ["="] : [];

      value.forEach((key, value) {
        keys.add('$key=${encodeValue(value)}');
      });

      return '(${keys.join(':')})';
    }

    if (value == double.infinity) {
      return "inf";
    }
    if (value == double.nan) {
      return "nan";
    }
    if (value == double.negativeInfinity) {
      return "-inf";
    }

    return value.toString();
  }

  static dynamic decodeValue(String str) {
    if (str == '{}') return <String>{};
    if (str == '()') return <String>{};
    if (str == "inf") return double.infinity;
    if (str == "nan") return double.nan;
    if (str == "-inf") return double.negativeInfinity;
    if (int.tryParse(str) != null) {
      return int.parse(str);
    } else if (double.tryParse(str) != null) {
      return double.parse(str);
    } else if (str == "true" || str == "false") {
      return str == "true";
    } else if (str.startsWith('(') && str.endsWith(')')) {
      final s = str.substring(1, str.length - 1);

      if (stringContainsAtRoot(s, '=')) {
        // It is a map, decode it as a map
        final map = <String, dynamic>{};

        final parts = fancySplit(s, ':');

        for (var part in parts) {
          final kv = fancySplit(part, '=');
          final k = kv[0];
          final v = decodeValue(kv[1]);

          map[k] = v;
        }
        return map;
      } else {
        // It is a list, decode it as a list
        return fancySplit(s, ':').map<dynamic>((e) => decodeValue(e)).toSet();
      }
    }

    return str;
  }
}

// The current saving format
typedef SavingFormat = P5;

class P5 {
  static final String valueString = r"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-.={}";

  static final String base = r"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  static final baseEncoder = BaseXCodec(base);

  static String header = "P5;";

  static String encodeCell(int x, int y, Grid grid) {
    final c = grid.at(x, y);
    final bg = grid.placeable(x, y);

    final m = {
      "id": c.id,
      "rot": c.rot,
      "bg": bg,
    };

    if (c.data.isNotEmpty) m['data'] = c.data;
    if (c.tags.isNotEmpty) m['tags'] = c.tags;
    if (c.lifespan != 0) m['lifespan'] = c.lifespan;
    if (c.invisible) m['invisible'] = true;

    return TPCML.encodeValue(m);
  }

  static void setCell(String str, int x, int y, Grid grid) {
    final m = TPCML.decodeValue(str);

    final c = Cell(x, y);
    c.lastvars.lastRot = (m['rot'] ?? 0).toInt();
    c.rot = (m['rot'] ?? 0).toInt();
    c.data = m['data'] ?? {};
    c.tags = {};
    (m['tags'] ?? []).forEach((v) => c.tags.add(v.toString()));
    c.id = m['id'] ?? "empty";
    c.lifespan = (m['lifespan'] ?? 0).toInt();
    c.invisible = m['invisible'] ?? false;
    final bg = m['bg'] ?? "empty";

    grid.set(x, y, c);
    grid.setPlace(x, y, bg);
  }

  static String encodeGrid(Grid grid, {String title = "", String description = ""}) {
    var str = header + '$title;$description;'; // Header, title and description

    str += '${encodeNum(grid.width, valueString)};';
    str += '${encodeNum(grid.height, valueString)};';

    final cellDataList = [];

    grid.forEach(
      (cell, x, y) {
        final cstr = encodeCell(x, y, grid);
        if (cellDataList.isNotEmpty) {
          final m = TPCML.decodeValue(cellDataList.last);
          final c = m['count'];

          if (TPCML.encodeValue(m['cell']) == cstr) {
            m['count'] = c + 1;
            cellDataList.last = TPCML.encodeValue(m);
            return;
          }
        }
        cellDataList.add(TPCML.encodeValue({"cell": TPCML.decodeValue(cstr), "count": 1}));
      },
    );

    final cellDataStr = baseEncoder.encode(
      Uint8List.fromList(zlib.encode(
        utf8.encode(
          cellDataList.join(':'),
        ),
      )),
    );

    str += '$cellDataStr;';

    final props = {};

    if (grid.wrap) props['W'] = true;

    str += '${TPCML.encodeValue(props)};';

    return str;
  }

  static Grid decodeString(String str, [bool handleCustomProps = true]) {
    try {
      final segs = str.split(';');

      final width = decodeNum(segs[3], valueString);
      final height = decodeNum(segs[4], valueString);

      final g = Grid(width, height);

      g.title = segs[1];
      g.desc = segs[2];

      final rawCellDataList = fancySplit(utf8.decode(zlib.decode(baseEncoder.decode(segs[5])).toList()), ':');

      final cellDataList = [];

      for (var cellData in rawCellDataList) {
        final m = TPCML.decodeValue(cellData);

        final c = m['count'] ?? 1;

        for (var i = 0; i < c; i++) {
          cellDataList.add(TPCML.encodeValue(m['cell']));
        }
      }

      var i = 0;

      g.forEach(
        (cell, x, y) {
          if (cellDataList.length > i) {
            setCell(cellDataList[i], x, y, g);
          }
          i++;
        },
      );

      final props = TPCML.decodeValue(segs[6]);
      g.wrap = props['W'] ?? false;

      if (handleCustomProps) {
        if (props['update_delay'] is num) {
          QueueManager.add("post-game-init", () {
            game.delay = props['update_delay']!;
          });
        }
        if (props['viewbox'] != null) {
          QueueManager.add("post-game-init", () {
            final vb = props['viewbox'] as Map;

            game.viewbox = (Offset(vb['x'].toDouble(), vb['y'].toDouble()) & Size(vb['w'].toDouble(), vb['h'].toDouble()));
          });
        }
        // We gotta decode le' RAM stick
        if (props['memory'] != null) {
          final m = props['memory'] as Map;
          m.forEach((key, value) {
            final c = <int, num>{};

            value.forEach((key, value) {
              c[int.parse(key)] = TPCML.decodeValue(value);
            });

            g.memory[int.parse(key)] = c;
          });
        }
      }

      return g;
    } catch (e, st) {
      print(e);
      print(st);
    }

    return grid;
  }
}

class TPCML {
  static String encodeValue(dynamic value) {
    if (value is Set) {
      return 's(' + value.map<String>((e) => encodeValue(e)).join(":") + ')';
    }
    if (value is List) {
      return 'l(' + value.map<String>((e) => encodeValue(e)).join(":") + ')';
    } else if (value is Map) {
      final keys = value.isEmpty ? ["="] : [];

      value.forEach((key, value) {
        keys.add('"$key"=${encodeValue(value)}');
      });

      return 'm(${keys.join(':')})';
    }

    if (value == double.infinity) {
      return "inf";
    }
    if (value == double.nan) {
      return "nan";
    }
    if (value == double.negativeInfinity) {
      return "-inf";
    }

    if (value is int) {
      return "ni$value";
    }
    if (value is double) {
      return "nd$value";
    }
    if (value is String) {
      var v = "";
      var chars = value.split('');

      for (var char in chars) {
        if (char == "\\") {
          v += "\\";
        } else if (char == "\"") {
          v += "\"";
        } else {
          v += char;
        }
      }
      return '"$v"';
    }

    return value.toString();
  }

  static dynamic decodeValue(String str) {
    if (str == '{}') return <String>{};
    if (str == '()') return <String>{};
    if (str == 's()') return <String>{};
    if (str == 'l()') return <String>[];
    if (str == 'm()') return <String, dynamic>{};
    if (str == "inf") return double.infinity;
    if (str == "nan") return double.nan;
    if (str == "-inf") return double.negativeInfinity;
    if (int.tryParse(str) != null) {
      return int.parse(str);
    } else if (double.tryParse(str) != null) {
      return double.parse(str);
    } else if (str == "true" || str == "false") {
      return str == "true";
    } else if (str.startsWith('l(') && str.endsWith(')')) {
      final s = str.substring(2, str.length - 1);
      return fancySplit(s, ':').map<dynamic>((e) => decodeValue(e)).toList();
    } else if (str.startsWith('s(') && str.endsWith(')')) {
      final s = str.substring(2, str.length - 1);
      return fancySplit(s, ':').map<dynamic>((e) => decodeValue(e)).toSet();
    } else if (str.startsWith('m(') && str.endsWith(')')) {
      final s = str.substring(2, str.length - 1);
      // It is a map, decode it as a map
      final map = <String, dynamic>{};

      final parts = fancySplit(s, ':');

      for (var part in parts) {
        final kv = fancySplit(part, '=');
        final k = kv[0].startsWith('\"') && kv[0].endsWith('\"') ? kv[0].substring(1, kv[0].length - 1) : kv[0];
        final v = decodeValue(kv[1]);

        map[k] = v;
      }
      return map;
    } else if (str.startsWith('(') && str.endsWith(')')) {
      final s = str.substring(1, str.length - 1);

      if (stringContainsAtRoot(s, '=')) {
        // It is a map, decode it as a map
        final map = <String, dynamic>{};

        final parts = fancySplit(s, ':');

        for (var part in parts) {
          final kv = fancySplit(part, '=');
          final k = kv[0];
          final v = decodeValue(kv[1]);

          map[k] = v;
        }
        return map;
      } else {
        // It is a list, decode it as a list
        return fancySplit(s, ':').map<dynamic>((e) => decodeValue(e)).toSet();
      }
    } else if (str.startsWith('\"') && str.endsWith('\"')) {
      final chars = str.substring(1, str.length - 1).split('');

      var s = "";
      var alt = false;

      for (var char in chars) {
        if (char == "\\") {
          if (alt) {
            s += "\\";
            alt = false;
          } else {
            alt = true;
          }
        } else {
          if (alt) {
            if (char == "\"") {
              s += "\"";
            }
          } else {
            s += char;
          }
        }
      }

      if (alt) s += "\\";

      return s;
    } else if (str.startsWith('ni') && int.tryParse(str.substring(2)) != null) {
      return int.parse(str.substring(2));
    } else if (str.startsWith('nd') && double.tryParse(str.substring(2)) != null) {
      return double.parse(str.substring(2));
    }

    return str;
  }
}
