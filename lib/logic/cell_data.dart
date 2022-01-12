part of logic;

var defaultCellSize = 40;
var cellSize = defaultCellSize.toDouble();
var wantedCellSize = defaultCellSize;

final cells = [
  "empty",
  "place",
  "wall",
  "ghost",
  "mover",
  "puller",
  "grabber",
  "liner",
  "bird",
  "releaser",
  "fan",
  "sync",
  "wormhole",
  "generator",
  "generator_cw",
  "generator_ccw",
  "triplegen",
  "constructorgen",
  "crossgen",
  "physical_gen",
  "replicator",
  "tunnel",
  "karl",
  "darty",
  "push",
  "slide",
  "rotator_cw",
  "rotator_ccw",
  "opposite_rotator",
  "gear_cw",
  "gear_ccw",
  "mirror",
  "enemy",
  "trash",
  "puzzle",
  "lock",
  "unlock",
  "key",
  "flag",
  "antipuzzle",
  "pmerge",
  "trash_puzzle",
  "mover_puzzle",
];

final hiddenCells = [
  "unlock",
  "trash_puzzle",
  "mover_puzzle",
];

final cellbar = cells
    .where(
      (element) => !hiddenCells.contains(element),
    )
    .toList();

class CellProfile {
  String title;
  String description;

  CellProfile(this.title, this.description);
}

final defaultProfile = CellProfile("Unnamed", "No description available");

String profileToMessage(CellProfile profile) {
  return "${profile.title} - ${profile.description}";
}

final cellInfo = <String, CellProfile>{
  "empty": CellProfile(
    "Empty",
    "Placing it will erase what was before it. You can also right click to achieve the same effect",
  ),
  "wall": CellProfile("Wall", "Can't be moved"),
  "ghost": CellProfile("Ghost Wall", "Can't be moved or generated"),
  "place": CellProfile(
    "Placeable",
    "Toggles if a cell is placeable. Placeable cells can be erased or placed on by people when solving the puzzle at the start",
  ),
  "mover": CellProfile("Mover", "Moves forward, and it can also push forward"),
  "puller": CellProfile(
    "Puller",
    "Moves forward, unable to push, but instead pulls all cells behind it",
  ),
  "grabber": CellProfile(
    "Grabber",
    "Moves forward, unable to push, grabs everything on its sides",
  ),
  "liner": CellProfile(
    "Liner",
    "It pushes the front and pulls the back, basically puller + pusher",
  ),
  "bird": CellProfile(
    "Bird",
    "It flies around and does its thing, its a bird after all",
  ),
  "releaser": CellProfile(
    "Releaser",
    "A mover, except if a cell is in front of it, it stops it from updating. If it is stopped from moving ,it will allow the catched cell to update again",
  ),
  "fan": CellProfile(
    "Fan",
    "It pushes away everything in front of it",
  ),
  "wormhole": CellProfile(
    "Wormhole",
    "When wrap around is enabled (you can enable it in the editor using Alt + W), any cell that falls in will be spawned on the opposite side of the map. Can be buggy. It destroys the incoming cell if wrap mode is disabled",
  ),
  "generator": CellProfile(
    "Generator",
    "Generates the cell behind it in front of it",
  ),
  "generator_cw": CellProfile(
    "Generator CW",
    "Generates the cell behind it in the right of it, applying rotation based on that",
  ),
  "generator_ccw": CellProfile(
    "Generator CCW",
    "Generates the cell behind it i nthe left of it, appyling rotation based on that",
  ),
  "triplegen": CellProfile(
    "Triple Generator",
    "Basically Generator, Generator CW and Generator CCW combined as one",
  ),
  "constructorgen": CellProfile(
    "Constructor",
    "Triple generator except also generates the cell behind it front-left and front-right to it with no applied rotation",
  ),
  "crossgen": CellProfile(
    "Cross Generator",
    "Two generators perpendicular to eachother stacked as one",
  ),
  "replicator": CellProfile(
    "Replicator",
    "Generates the cell in front of it... in front of it.",
  ),
  "karl": CellProfile(
    "Karl",
    "Hello, I am Karl, I avoid stuff and eat walls. SEND HELP PLEASE I AM TRAPPED HERE",
  ),
  "darty": CellProfile(
    "Darty",
    "Moves forward, if it can push the cell in front it eats it and replicates, if it cant push it, it turns goes in another direction",
  ),
  "floppy": defaultProfile,
  "push": CellProfile(
    "Push",
    "Can be pushed from any sides",
  ),
  "slide": CellProfile(
    "Slide",
    "Can only be pushed from the sides parallel to the 2 white lines",
  ),
  "rotator_cw": CellProfile(
    "Rotator CW",
    "Rotates all the cells touching it clockwise",
  ),
  "rotator_ccw": CellProfile(
    "Rotator CCW",
    "Rotates all the cells touching it counter-clockwise",
  ),
  "gear_cw": CellProfile(
    "Gear CW",
    "Spins the cells touching it around itself clockwise",
  ),
  "gear_ccw": CellProfile(
    "Gear CCW",
    "Spins the cells touching it around itself counter-clockwise",
  ),
  "mirror": CellProfile(
    "Mirror",
    "Swaps the cells the arrows are pointing to, if movable",
  ),
  "enemy": CellProfile(
    "Enemy",
    "When something moves into it, it dies and so does the thing going into it",
  ),
  "trash": CellProfile(
    "Trash",
    "When something moves into it, the thing moving into it dies, but the trash cell remains",
  ),
  "puzzle": CellProfile(
    "Puzzle",
    "It's you! Can be moved with WASD when the game is running, when it moves a cell it is touching it \"interacts\" with it",
  ),
  "key": CellProfile(
    "Key",
    "Can be picked up by player using interaction",
  ),
  "lock": CellProfile(
    "Lock",
    "Cant be moved, except if the player has a key when interacting with it, in which case it unlocks itself and becomes pushable",
  ),
  "flag": CellProfile(
    "Flag",
    "When a puzzle cell interacts with it, if there are no enemy cells on the grid, triggers a win",
  ),
  "antipuzzle": CellProfile(
    "Anti-Puzzle",
    "Can be pushed by any cell except the puzzle cell",
  ),
  "tunnel": CellProfile(
    "Tunnel",
    "Moves the cell from the back to the front instantly",
  ),
  "physical_gen": CellProfile(
    "Physical Generator",
    "Like a generator except, if it cant move whats in front of it, it tries to move backwards to generate the cell",
  ),
  "pmerge": CellProfile(
    "PuzzleMerge™",
    "Using the latest quantum Sci-Fi stuff, we can combine specific cells with your puzzle cell to give it special stuff",
  ),
  "sync": CellProfile(
    "Sync Cell",
    "If you move or rotate it, it also moves or rotates all the other sync cells",
  ),
  "opposite_rotator": CellProfile(
    "Opposite Rotator",
    "On one side we have a Rotator CW, on the opposite side a Rotator CCW, and inbetween, nothing",
  ),
};
