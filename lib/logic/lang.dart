part of logic;

final langDir = Directory(path.join(assetsPath, 'languages'));

var currentLang = <String, dynamic>{};

final langEvents = StreamController<bool>();

void resetLang() {
  currentLang = {};
  storage.remove("lang");
  langEvents.sink.add(true);
}

void loadLang(File file) {
  currentLang = jsonDecode(file.readAsStringSync());
  storage.setString("lang", currentLang['title'] ?? 'Untitled');
  langEvents.sink.add(true);
}

const _noData = <String, String>{};

String lang(String key, String fallback, [Map<String, String> data = _noData]) {
  var v = currentLang[key] as String?;
  if (v == null) return fallback;
  currentLang.forEach((key, value) {
    v = v!.replaceAll("\#$key", value);
  });
  data.forEach((key, value) {
    v = v!.replaceAll("\@$key", value);
  });
  return v!;
}

List<File> get langs {
  if (!langDir.existsSync()) {
    langDir.createSync();
  }

  return (langDir.listSync()..removeWhere((f) => !f.path.endsWith(".json")))
      .map<File>((item) => item as File)
      .toList()
    ..addAll(externalLangs);
}

List<File> get externalLangs {
  if (!Platform.isWindows) return [];
  final d = Directory('%APPDATA%\\The Puzzle Cell\\languages');
  if (d.existsSync()) {
    return d.listSync().map<File>((item) => item as File).toList();
  } else {
    return [];
  }
}

void loadLangByName(String name) {
  for (var f in langs) {
    final l = jsonDecode(f.readAsStringSync());
    if ((l['title'] ?? 'Untitled') == name) {
      loadLang(f);
    }
  }
}

Future<List<String>> downloadableLanguages() async {
  final url =
      'https://raw.githubusercontent.com/IonutParau/tpc-langs-repo/main/languages.txt';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode >= 400) {
    throw response.body;
  }

  final r = response.body.split('\n');

  r.removeWhere((str) => str.isEmpty);

  return r;
}

Future downloadLanguage(String languageName) async {
  final url =
      "https://raw.githubusercontent.com/IonutParau/tpc-langs-repo/main/$languageName.json";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw response.body;
  }

  if (!langDir.existsSync()) {
    langDir.createSync();
  }

  final f = File(path.join(langDir.path, '$languageName.json'));

  if (!f.existsSync()) {
    f.createSync();
  }

  f.writeAsStringSync(response.body);

  return;
}
