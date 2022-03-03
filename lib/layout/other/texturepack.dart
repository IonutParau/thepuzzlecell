import 'dart:convert';
import 'dart:io';

final texturePackDir = Directory('texture_packs');

void fixDefault() {
  if (texturePackDir.existsSync() == false) texturePackDir.createSync();

  final defaultPackDir = Directory('texture_packs/Default');

  if (defaultPackDir.existsSync() == false) {
    defaultPackDir.createSync();
  }

  final compiledMap = {
    "title": "Default",
    "description": "The default textures",
  };

  final assetDir = Directory('data/flutter_assets/assets/images');

  final textures = assetDir.listSync(recursive: true);

  for (var texture in textures) {
    if (texture is File) {
      final f = texture.path.replaceAll(
        'data/flutter_assets/assets/images',
        'texture_packs/Default',
      );
      texture.copySync(
        f,
      );
      final sf = f.replaceAll('textures_packs/Default/', '');
      compiledMap[sf] = sf;
    }
  }

  final packJSON = File('texture_packs/Default/pack.json');

  if (packJSON.existsSync() == false) {
    packJSON.createSync();
  }

  packJSON.writeAsStringSync(jsonEncode(compiledMap));
}

void loadTexturePack(String folder) {}
