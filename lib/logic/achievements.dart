part of logic;

class Achievement {
  String title;
  String description;
  int prize;

  Achievement(this.title, this.description, [this.prize = 0]);
}

final Map<String, Achievement> achievementData = {
  "solving": Achievement("Solving a Problem", "Start playing a puzzle"),
  "editor": Achievement("I'm a maker", "Open the editor"),
  "overload": Achievement("Wait, there's more?", "Open a category", 5),
  "subcells": Achievement("EVEN MORE??", "Open a subcategory", 10),
  "winner": Achievement("I'm a winner!", "Win a level", 6),
  "loser": Achievement("Game Over", "Lose a level by killing a friend", 2),
  "start": Achievement("Start of it all", "Start a simulation", 15),
  "incontrol": Achievement("In control", "Move a puzzle cell around", 50),
  "friends": Achievement("Friends??", "Join a multiplayer server", 23),
  "circuitry": Achievement("Circuitry", "Use mechanical cells", 50),
};

class AchievementManager {
  static List<String> get achievements =>
      storage.getStringList("achievements") ?? [];

  static bool hasAchievement(String achievement) =>
      achievements.contains(achievement);

  static void complete(String achievement) {
    if (hasAchievement(achievement)) return;
    final a = achievements;
    a.add(achievement);
    CoinManager.give(achievementData[achievement]!.prize);
    storage.setStringList("achievements", a);
    AchievementRenderer.show(achievement);
  }
}
