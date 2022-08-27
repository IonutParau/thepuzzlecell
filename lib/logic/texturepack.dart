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

  bool enabled = true;

  void toggle() {
    final l = storage.getStringList("disabled_texturepacks") ?? [];
    if (enabled) {
      l.remove(id);
    } else {
      if (!l.contains(id)) l.add(id); // Add but avoid duplicates (duplicates would suck)
    }
    storage.setStringList("disabled_texturepacks", l);
    enabled = !enabled;
  }

  String get title => getMap()['title'] ?? "Untitled";
  String get icon {
    final i = getMap()['icon'];

    if (i == null) return "assets/images/logo.png";
    return "assets/images/texture_packs/${dir.path.split(path.separator).last}/$i";
  }

  String get id => dir.path.split(path.separator).last;

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

List<TexturePack> texturePacks = [];

List<TexturePack> get enabledTexturePacks => [...texturePacks]..removeWhere((tp) => !tp.enabled);

void loadTexturePacks() {
  print("Loading texture packs in ${tpDir.path}");
  if (tpDir.existsSync()) {
    final l = tpDir.listSync();
    l.removeWhere((e) => e is File);
    texturePacks = l.map<TexturePack>((e) => TexturePack(e as Directory)).toList();
  }
}

void applyTexturePacks() {
  final e = enabledTexturePacks;
  for (var i = 0; i < e.length; i++) {
    e[i].load(i == 0);
  }
}

Future applyTexturePackSettings() async {
  if (storage.getStringList("disabled_texturepacks") == null) {
    await storage.setStringList("disabled_texturepacks", []);
  }
  final disabled = storage.getStringList("disabled_texturepacks")!;

  for (var tp in texturePacks) {
    if (disabled.contains(tp.id)) {
      tp.enabled = false;
    }
  }
}
