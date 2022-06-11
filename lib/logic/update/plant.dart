part of logic;

final rng = Random();
var plantID = 0;

Set<String> getPlant(int x, int y, int plantID, [Set<String>? plant]) {
  if (plant == null) {
    plant = {};
  }

  if (!grid.inside(x, y)) return plant;

  if (plant.contains('$x $y')) return plant;

  final c = grid.at(x, y);

  if (c.id.startsWith('plant_') && c.id != "plant_spore" && c.data['plant_id'] == plantID) {
    plant.add('$x $y');

    getPlant(x - 1, y, plantID, plant);
    getPlant(x + 1, y, plantID, plant);
    getPlant(x, y - 1, plantID, plant);
    getPlant(x, y + 1, plantID, plant);
  }

  return plant;
}

bool checkPlantDeath(Cell cell, int x, int y) {
  final vars = cell.data;

  if (!cell.tags.contains("plant_given_energy")) {
    vars['energy'] = (vars['energy'] ?? 0) - 1;
  }

  if ((vars['energy'] ?? 0) <= 0) {
    vars['deathtime'] = (vars['deathtime'] ?? 0) + 1;
    if (vars['deathtime'] > 30) {
      grid.set(x, y, Cell(x, y));
      return true;
    }
  } else {
    vars['deathtime'] = 0;
  }
  return false;
}

void buildPlant(int x, int y, int dir, double lChance, int plantID, [int depth = 0]) {
  if (!grid.inside(x, y)) return;
  if (depth > 500) return;
  if (rng.nextBool()) {
    if (rng.nextBool()) {
      dir = (dir + 3) % 4;
    } else {
      dir = (dir + 1) % 4;
    }
  }

  var buildFlower = rng.nextDouble() < lChance;

  final fx = frontX(x, dir);
  final fy = frontY(y, dir);

  if (!grid.inside(fx, fy)) return;

  if (grid.at(fx, fy).id != "empty") return;

  if (buildFlower) {
    push(fx, fy, dir, 1,
        replaceCell: Cell(x, y)
          ..id = "plant_flower"
          ..data = {"plant_id": plantID});
  } else {
    push(fx, fy, dir, 1,
        replaceCell: Cell(x, y)
          ..id = rng.nextBool() ? "plant_body" : "plant_leaf"
          ..data = {"plant_id": plantID});
    buildPlant(fx, fy, dir, lChance, plantID, depth + 1);
    if (rng.nextDouble() < 0.5) {
      buildPlant(fx, fy, dir + (rng.nextBool() ? 1 : -1), lChance, plantID, depth + 1);
    }
  }
}

void doPlantSeed(Cell cell, int x, int y) {
  final vars = cell.data;

  if (vars['energy'] == null) vars['energy'] = 0;
  if (vars['deathtime'] == null) vars['deathtime'] = 0;
  if (vars['spore_rate'] == null) vars['spore_rate'] = rng.nextDouble() * 0.1;
  if (vars['growth_rate'] == null) vars['growth_rate'] = rng.nextDouble() * 0.001;
  if (vars['spore_percentage'] == null) vars['spore_percentage'] = rng.nextDouble();
  if (vars['length_chance'] == null) vars['length_chance'] = rng.nextDouble();
  if (vars['plant_id'] == null) {
    vars['plant_id'] = plantID;
    plantID++;
  }

  if (checkPlantDeath(cell, x, y)) return;

  if (vars['plant_loaded'] == null) {
    vars['plant_loaded'] = true;

    final lChance = vars['length_chance'] ?? rng.nextDouble();

    buildPlant(x, y, (cell.rot + 2) % 4, lChance, vars['plant_id'] ?? plantID);
  }

  final plant = getPlant(x, y, vars['plant_id'] ?? plantID);

  if (plant.length == 1) {
    vars.remove('plant_loaded');
  }

  final fx = frontX(x, cell.rot);
  final fy = frontY(y, cell.rot);

  var extraEnergy = 0;

  if (grid.inside(fx, fy)) {
    final f = grid.at(fx, fy);
    if (f.id == "wall") {
      extraEnergy += 100;
    }
  }

  // Leaves
  for (var part in plant) {
    final px = int.parse(part.split(' ')[0]);
    final py = int.parse(part.split(' ')[1]);
    final p = grid.at(px, py);

    if (p.id == "plant_leaf") {
      extraEnergy += 10;
    }
  }

  var eToAdd = extraEnergy / max(plant.length, 1); // No division by 0 exception for u

  // Energy
  for (var part in plant) {
    final px = int.parse(part.split(' ')[0]);
    final py = int.parse(part.split(' ')[1]);
    final p = grid.at(px, py);

    if (p.data['energy'] == null) {
      p.data['energy'] = eToAdd;
    } else {
      p.data['energy'] += eToAdd;
    }
    if (eToAdd > 0) {
      cell.tags.add("plant_given_energy");
    }
  }

  // Flowers and body
  for (var part in plant) {
    final px = int.parse(part.split(' ')[0]);
    final py = int.parse(part.split(' ')[1]);
    final p = grid.at(px, py);

    if (p.id == "plant_flower" && (rng.nextDouble() < vars['spore_rate'])) {
      final dir = p.rot + (rng.nextInt(3) - 1);
      final sporeEnergy = vars['spore_percentage'] * p.data['energy'];

      p.data['energy'] -= sporeEnergy;

      final spore = Cell(px, py);
      spore.id = "plant_spore";
      spore.data = Map<String, dynamic>.from(vars);
      spore.data['energy'] = sporeEnergy;
      spore.data.remove("deathtime");
      final fx = frontX(px, dir);
      final fy = frontY(py, dir);

      push(fx, fy, dir, 1, replaceCell: spore);
    } else if (p.id == "plant_body" || p.id == "plant_leaf") {
      doPlantBody(p, px, py);

      if (rng.nextDouble() < vars['growth_rate']) {
        buildPlant(px, py, p.rot, vars['length_chance'], vars['plant_id']);
      }
    }
  }

  vars['energy'] += eToAdd;
  if (eToAdd > 0) {
    cell.tags.add("plant_given_energy");
  }
}

void doPlantBodyKill(int x, int y, int pid) {
  if (!grid.inside(x, y)) return;
  if (rng.nextDouble() < 0.1) {
    final cell = grid.at(x, y);

    if (!cell.id.startsWith('plant_') && cell.id != "darty" && cell.id != "karl") return;

    if (cell.data['plant_id'] == pid) {
      return;
    }

    grid.set(x, y, Cell(x, y));
  }
}

void doPlantBody(Cell cell, int x, int y) {
  final pid = cell.data['plant_id'] ?? plantID;

  doPlantBodyKill(x - 1, y, pid);
  doPlantBodyKill(x + 1, y, pid);
  doPlantBodyKill(x, y - 1, pid);
  doPlantBodyKill(x, y + 1, pid);
}

void doPlantPartDie(Cell cell, int x, int y) {
  checkPlantDeath(cell, x, y);
}

void doPlantSpore(Cell cell, int x, int y) {
  final dir = rng.nextInt(4);

  final fx = frontX(x, dir);
  final fy = frontY(y, dir);

  if (!grid.inside(fx, fy)) {
    cell.id = "plant_seed";
    cell.rot = dir;
    cell.data.remove('plant_id');
    cell.data.remove('plant_loaded');
    cell.data.forEach(
      (key, value) {
        if (value is double && rng.nextBool()) {
          cell.data[key] += rng.nextBool() ? -0.001 : 0.001;
        }
      },
    );
    grid.setChunk(x, y, "plant_seed");
    return;
  }

  if (checkPlantDeath(cell, x, y)) return;

  final f = grid.at(fx, fy);

  if (!canMove(fx, fy, dir, 1, MoveType.push)) {
    cell.id = "plant_seed";
    cell.rot = dir;
    cell.data.remove('plant_id');
    cell.data.remove('plant_loaded');
    cell.data.forEach(
      (key, value) {
        if (value is double && rng.nextBool()) {
          cell.data[key] += rng.nextBool() ? -0.001 : 0.001;
        }
      },
    );
    grid.setChunk(x, y, "plant_seed");
    return;
  } else if (f.id == "plant_seed") {
    f.data.forEach((key, value) {
      if (key != "plant_id") {
        if (rng.nextBool()) {
          cell.data[key] = value; // Breeding lmao
        }
      }
    });
    return;
  } else if (f.id == "empty") {
    push(x, y, dir, 1);
  }
}

void plants() {
  grid.updateCell(doPlantSeed, null, "plant_seed");

  grid.updateCell(doPlantPartDie, null, "plant_flower");

  grid.updateCell(doPlantPartDie, null, "plant_body");

  grid.updateCell(doPlantPartDie, null, "plant_leaf");

  grid.updateCell(doPlantSpore, null, "plant_spore");
}
