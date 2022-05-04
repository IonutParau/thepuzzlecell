part of logic;

String get versionToCheck => currentVersion.split(' ').first;

bool higherVersion(String v1, String v2) {
  final segs1 = v1.split('.'); // Version to check
  final segs2 = v2.split('.'); // Version to check against

  final l = max(segs1.length, segs2.length);
  while (segs1.length < segs2.length) {
    segs1.add("0");
  }
  while (segs2.length < segs1.length) {
    segs2.add("0");
  }

  for (var i = 0; i < l; i++) {
    if (int.parse(segs1[i]) > int.parse(segs2[i])) {
      return true;
    }
  }

  return false;
}

Future<String> getVersion() async {
  final versionYAMLResponse = await http.get(
    Uri.parse(
      "https://raw.githubusercontent.com/IonutParau/thepuzzlecell/main/pubspec.yaml",
    ),
  );

  if (versionYAMLResponse.statusCode >= 400) {
    throw versionYAMLResponse.body;
  }

  final versionYAML = loadYaml(versionYAMLResponse.body);

  return (versionYAML['gameVersion'] ?? versionYAML['version']);
}
