part of logic;

void anvil() {
  grid.updateCell((cell, x, y) {
    final dir = (cell.rot+1)%4;
    final double gravity = cell.data["gravity"].toDouble();
    double velocity = cell.data["velocity"].toDouble();
    final double breakingVelocity = cell.data["breaking_velocity"].toDouble();
    final double lossUponLethalImpact = cell.data["impact_loss"].toDouble();
    final double terminalVelocity = cell.data["speed_limit"].toDouble();

    velocity += gravity;
    if(velocity > terminalVelocity) {
      velocity = terminalVelocity;
    }
    final int intVelocity = velocity.toInt();
    
    for (var i = 0; i < intVelocity; i++) {
      if (!push(x, y, dir, intVelocity)) {
        if(velocity >= breakingVelocity) {
          final dx = frontX(x, dir);
          final dy = frontY(y, dir);
          if(grid.inside(dx, dy) && breakable(grid.at(dx, dy), dx, dy, dir, BreakType.gravity)) {
            grid.addBroken(grid.at(dx, dy), dx, dy);
            grid.set(dx, dy, Cell(dx, dy));
            cell.data["velocity"] = velocity * (1 - lossUponLethalImpact);
            return;
          }
        }
        cell.data["velocity"] = 0;
        return;
      }
      x = frontX(x, dir);
      y = frontY(y, dir);
    }
    cell.data["velocity"] = velocity;
  }, null, "anvil");
}
