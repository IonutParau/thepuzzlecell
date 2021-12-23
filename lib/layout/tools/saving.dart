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
