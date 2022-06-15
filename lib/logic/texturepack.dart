part of logic;

class TexturePack {
  Directory dir;

  TexturePack(this.dir);

  static List<String> allowedFiles = [
    ".png",
    ".jpg",
    ".jpeg",
    ".bmp",
  ];

  void setupMap(Map<String, dynamic> m) {
    if (m['autoDetect'] == true) {
      final f = getFiles(dir.path);

      for (var file in f) {
        var allowed = false;

        for (var fileExt in allowedFiles) if (file.endsWith(fileExt)) allowed = true;

        if (allowed) {
          textureMap[file.split('/').last.split('.').first + '.png'] = file;
        }
      }
    }

    m.forEach(
      (id, p) {
        if (p is String) {
          textureMap['$id.png'] = 'texture_packs/${(dir.path.split(path.separator).last)}/$p';
        }
      },
    );
  }

  List<String> getFiles(String p) {
    var dir = Directory(p);

    final l = dir.listSync();

    final parts = <String>[];

    l.forEach((subentry) {
      if (subentry is File) {
        parts.add(path.split(subentry.path).last);
      } else if (subentry is Directory) {
        parts.addAll(getFiles(subentry.path).map((str) => "$p/$str"));
      }
    });

    return parts;
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
