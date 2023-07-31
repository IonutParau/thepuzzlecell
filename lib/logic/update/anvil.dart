part of logic;

void anvil() {
  grid.updateCell((cell, x, y) {
    final dir = cell.rot;
    final double gravity = cell.data["gravity"].toDouble();
    final double velocity = cell.data["velocity"].toDouble();
    final double breakingVelocity = cell.data["breaking_velocity"].toDouble();
    final double lossUponLethalImpact = cell.data["impact_loss"].toDouble();
    final double terminalVelocity = cell.data["speed_limit"].toDouble();
  }, null, "anvil");
}