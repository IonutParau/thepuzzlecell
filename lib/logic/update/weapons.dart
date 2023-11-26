part of logic;

final sentryCommonTargets = <String>[];
final sentryEnemyTargets = <String>[
  "robot",
  "assistant",
  "puzzle",
  "flipped_puzzle",
  "molten_puzzle",
  "frozen_puzzle",
  "unstable_puzzle",
  "trash_puzzle",
  "mover_puzzle",
  "temporal_puzzle",
  "transform_puzzle",
];
// Enemies are automatically friendly targets
final sentryFriendlyTargets = <String>[
  "enemy",
  "semi_enemy",
  "mobile_enemy",
  "physical_enemy",
  "explosive",
  "mech_enemy",
  "friend",
  "debt_enemy",
  "roadblock",
  "strong_enemy",
  "weak_enemy",
  "mech_enemy_gen",
  "balanced_enemy",
  "puzzle_buster",
];

void doSentry(Cell cell, int x, int y) {
  final double interval = cell.data['gun_interval'].toDouble();
  final int bulletSpeed = cell.data['bullet_speed'].toInt();
  final bool isFriendly = cell.data['friendly'];
    final bool needsPower = cell.data['needs_power'] ?? false;

    if(needsPower) {
       final double passiveCost = cell.data['passive_cost'].toDouble();

       if(!electricManager.removePower(cell, x, y, passiveCost)) {
           return;
        }
    }

  cell.data['time'] = (cell.data['time'] ?? 0.0) + 1.0;
  if(cell.data['time'] >= interval) {
    for(var rot in rotOrder) {
      if(grid.at(frontX(x, rot), frontY(y, rot)).id != "empty") {
        continue;
      }
      final seen = raycast(x, y, frontX(0, rot), frontY(0, rot), const {"bullet"});
      if(!seen.successful) {
        continue;
      }
      var shoot = false;
      if(isFriendly && (sentryFriendlyTargets.contains(seen.hitCell.id) || enemies.contains(seen.hitCell.id))) {
        shoot = true;
      } else if(!isFriendly && (sentryEnemyTargets.contains(seen.hitCell.id))) {
        shoot = true;
      }

      if(shoot) {
        final double gunCost = cell.data['gun_cost'].toDouble();
        if(needsPower && !electricManager.removePower(cell, x, y, gunCost)) {
            continue;
        }
        cell.data['time'] = 0.0;
        cell.rot = rot;
        final bullet = Cell(x, y, rot)..id = "bullet";
        bullet.data['speed'] = bulletSpeed;
        bullet.rot = rot;
        grid.set(frontX(x, rot), frontY(y, rot), bullet);
        return;
      }
    }
  }

  cell.rot = (cell.rot + 1) % 4;
}

void doBullet(Cell cell, int x, int y) {
  final int speed = cell.data['speed'].toInt();
  var cx = x, cy = y;
  for(int i = 0; i < speed; i++) {
    if(push(cx, cy, cell.rot, 0)) {
      cx = frontX(cx, cell.rot);
      cy = frontY(cy, cell.rot);
      if(grid.at(cx, cy).id != "bullet") {
        break;
      }
    } else {
      grid.set(cx, cy, Cell(cx, cy, 0));
      break;
    }
  }
}

void doSentryBuster(Cell cell, int x, int y) {
  var range = (grid.width * grid.height ~/ 4);

  final dirToSentry = pathFindToCell(x, y, ['sentry'], range);
  if(dirToSentry == null) {
    return;
  }

  final c = grid.at(frontX(x, dirToSentry), frontY(y, dirToSentry));
  if(c.id == "sentry") {
    doExplosive(cell, x, y, cell.data['silent'] == true, {"radius": 1});
  } else {
    push(x, y, dirToSentry, 1);
  }
}

void doPuzzleBuster(Cell cell, int x, int y) {
  var range = (grid.width * grid.height ~/ 4);

  final dirToPuzzle = pathFindToCell(x, y, ['puzzle'], range);
  if(dirToPuzzle == null) {
    return;
  }

  final c = grid.at(frontX(x, dirToPuzzle), frontY(y, dirToPuzzle));
  if(c.id == "puzzle") {
    doExplosive(cell, x, y, cell.data['silent'] == true, {"radius": 1});
  } else {
    push(x, y, dirToPuzzle, 1);
  }
}

void weapons() {
  grid.updateCell(doSentryBuster, null, "sentry_buster");
  grid.updateCell(doPuzzleBuster, null, "puzzle_buster");

  grid.updateCell(doSentry, null, "sentry");

  for(var rot in rotOrder) {
    grid.updateCell(doBullet, rot, "bullet");
  }
}
