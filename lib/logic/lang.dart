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
  data.forEach((key, value) {
    v = v!.replaceAll("\@$key", value);
  });
  return v!;
}

List<File> get langs =>
    langDir.listSync().map<File>((item) => item as File).toList();

void loadLangByName(String name) {
  for (var f in langs) {
    final l = jsonDecode(f.readAsStringSync());
    if ((l['title'] ?? 'Untitled') == name) {
      loadLang(f);
    }
  }
}
