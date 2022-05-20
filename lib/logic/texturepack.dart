part of logic;

class TexturePack {
  Directory dir;

  TexturePack(this.dir);

  void load([bool reset = true]) {
    if (reset) {
      textureMap = Map.from(textureMapBackup); // Restore the base stuff lmao
    }

    final f = File(path.join(dir.path, 'pack.json'));

    if (f.existsSync()) {
      final m = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;

      m.forEach(
        (id, p) {
          if (p is String) {
            textureMap['$id.png'] = path.joinAll([
              dir.path,
              ...(p.split('/')),
            ]); // So they can put it with / and it will still work on Windows
          }
        },
      );
    }
  }
}

final tpDir = Directory(
  path.join(
    assetsPath,
    'assets',
    'images',
    'texture_packs',
  ),
); // This is totally the teleporation directory. What is a texture pack

List<TexturePack> get texturePacks {
  if (tpDir.existsSync()) {
    final l = tpDir.listSync();
    l.removeWhere((e) => e is File);
    return l.map<TexturePack>((e) => TexturePack(e as Directory)).toList();
  }
  return [];
}
