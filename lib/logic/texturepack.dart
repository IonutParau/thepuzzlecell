part of logic;

class TexturePack {
  Directory dir;

  TexturePack(this.dir);

  void setupMap(Map<String, dynamic> m) {
    m.forEach(
      (id, p) {
        print('Changed image ID: $id.png');
        textureMap['$id.png'] = 'texture_packs/${(dir.path.split(path.separator).last)}/$p';
      },
    );
  }

  void load([bool reset = true]) {
    print("Loaded folder in ${dir.path}");
    if (reset) {
      textureMap = Map.from(textureMapBackup); // Restore the base stuff lmao
    }

    final f = File(path.join(dir.path, 'pack.json'));

    if (f.existsSync()) {
      setupMap(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
    } else {
      final yamlF = File(path.join(dir.path, 'pack.yaml'));

      if (yamlF.existsSync()) {
        setupMap(loadYaml(f.readAsStringSync()) as Map<String, dynamic>);
      } else {
        final tomlF = File(path.join(dir.path, 'pack.toml'));

        if (tomlF.existsSync()) {
          setupMap(TomlDocument.parse(f.readAsStringSync()).toMap());
        }
      }
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
  print(tpDir.path);
  if (tpDir.existsSync()) {
    final l = tpDir.listSync();
    l.removeWhere((e) => e is File);
    return l.map<TexturePack>((e) => TexturePack(e as Directory)).toList();
  }
  return [];
}
