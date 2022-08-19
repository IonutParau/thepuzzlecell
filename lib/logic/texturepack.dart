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
          textureMap[file.split('/').last.split('.').first + '.png'] = fixPath(file);
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

  String fixPath(String p) {
    final i = path.split(p).indexOf('texture_packs');

    return 'texture_packs/' + dir.path.split(path.separator).last + "/" + path.split(p).sublist(i + 2).join('/');
  }

  List<String> getFiles(String p) {
    var dir = Directory(p);

    final l = dir.listSync();

    final parts = <String>[];

    l.forEach((subentry) {
      if (subentry is File) {
        parts.add(subentry.path);
      } else if (subentry is Directory) {
        parts.addAll(getFiles(subentry.path).map((str) => path.join(subentry.path, str)));
      }
    });

    return parts;
  }

  Map<String, dynamic> getMap() {
    final f = File(path.join(dir.path, 'pack.json'));

    if (f.existsSync()) {
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    } else {
      final yamlF = File(path.join(dir.path, 'pack.yaml'));

      if (yamlF.existsSync()) {
        return loadYaml(f.readAsStringSync()) as Map<String, dynamic>;
      } else {
        final tomlF = File(path.join(dir.path, 'pack.toml'));

        if (tomlF.existsSync()) {
          return TomlDocument.parse(f.readAsStringSync()).toMap();
        }
      }
    }

    return <String, dynamic>{};
  }

  void load([bool reset = true]) {
    print("Loaded folder in ${dir.path}");
    if (reset) {
      textureMap = Map.from(textureMapBackup); // Restore the base stuff lmao
    }

    setupMap(getMap());
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
