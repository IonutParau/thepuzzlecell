part of logic;

class SkinManager {
  static List<String> get skins => storage.getStringList('skins') ?? [];
  static List<String> get usedSkins => storage.getStringList('usedSkins') ?? [];

  static bool hasSkin(String skin) => skins.contains(skin);

  static bool skinEnabled(String skin) => usedSkins.contains(skin);

  static Future<bool> addSkin(String skin) async {
    final s = skins;
    if (s.contains(skin)) return true;
    s.add(skin);
    return await storage.setStringList('skins', s);
  }

  static Future<bool> enableSkin(String skin) async {
    final s = usedSkins;
    if (s.contains(skin)) return true;
    s.add(skin);
    return await storage.setStringList('usedSkins', s);
  }

  static Future<bool> disableSkin(String skin) async {
    final s = usedSkins;
    if (!s.contains(skin)) return true;
    s.remove(skin);
    return await storage.setStringList('usedSkins', s);
  }
}
