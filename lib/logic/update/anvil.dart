part of logic;

void anvil() {
  grid.updateCell((cell, x, y) {
    final dir = cell.rot;
    final double gravity = cell.data["gravity"];
    final double velocity = cell.data["velocity"];
    final double breakingVelocity = cell.data["breaking_velocity"];
    final double lossUponLethalImpact = cell.data["impact_loss"];
    final double terminalVelocity = cell.data["speed_limit"];
  }, null, "anvil");
}