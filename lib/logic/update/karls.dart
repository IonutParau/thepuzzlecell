part of logic;

void karls() {
  grid.updateCell(
    (cell, x, y) {
      cell.updated = true;
      // print(cell.data['velX']);
      // print(cell.data['velY']);
      var velX = 0;
      var velY = 0;
      if (grid.inside(x - 1, y) && grid.inside(x + 1, y)) {
        if (grid.at(x - 1, y).id != "empty" && grid.at(x - 1, y).id != "wall")
          velX++;
        if (grid.at(x + 1, y).id == "wall") velX++; // Get to food dammit

        if (grid.at(x + 1, y).id != "empty" && grid.at(x + 1, y).id != "wall")
          velX--;
        if (grid.at(x - 1, y).id == "wall") velX--; // Get to food dammit
      }

      if (grid.inside(x, y - 1) && grid.inside(x, y + 1)) {
        if (grid.at(x, y - 1).id != "empty" && grid.at(x, y - 1).id != "wall")
          velY++;
        if (grid.at(x, y + 1).id == "wall") velY++; // Get to food dammit

        if (grid.at(x, y + 1).id != "empty" && grid.at(x, y + 1).id != "wall")
          velY--;
        if (grid.at(x, y - 1).id == "wall") velY--; // Get to food dammit
      }

      velX = clamp(velX, -1, 1).toInt();
      velY = clamp(velY, -1, 1).toInt();

      if (velX == 0 && velY == 0) {
        velX = cell.data['velX'] ?? 0;
        velY = cell.data['velY'] ?? 0;
      } else {
        cell.data['velX'] = velX;
        cell.data['velY'] = velY;
      }

      var fx = x + velX;
      var fy = y + velY;

      final vX = velX;
      final vY = velY;

      if (grid.inside(fx, fy)) {
        for (var i = 0; i < 3; i++) {
          fx = x + velX;
          fy = y + velY;
          if (grid.at(fx, fy).id == "wall") {
            grid.set(fx, fy, cell.copy);
            return;
          } else if (grid.at(fx, fy).id == "empty") {
            grid.set(fx, fy, cell.copy);
            grid.set(x, y, Cell(x, y));
            return;
          }
          if (i == 1) {
            velX = 0;
            velY = vY;
          }
          if (i == 2) {
            velX = vX;
            velY = 0;
          }
        }
      }
    },
    null,
    "karl",
  );
}
