import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

final texturePackDir = Directory('texture_packs');

String winp(String p) {
  if (Platform.isWindows) {
    return p.replaceAll("/", r"\");
  }
  return p;
}

void fixDefault() {
  if (texturePackDir.existsSync() == false) texturePackDir.createSync();

  final defaultPackDir = Directory(winp('texture_packs/Default'));

  if (defaultPackDir.existsSync() == false) {
    defaultPackDir.createSync();
  }

  final compiledMap = {
    "title": "Default",
    "description": "The default textures",
  };

  final assetDir = Directory(winp('/data/flutter_assets/assets/images'));

  final textures = assetDir.listSync(recursive: true);

  for (var texture in textures) {
    if (texture is File) {
      final f = texture.path.replaceAll(
        'data/flutter_assets/assets/images',
        'texture_packs/Default',
      );
      texture.copySync(
        winp(f),
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

void loadTexturePack(String folder) {
  if (folder != 'Default') {
    loadTexturePack('Default');
  }
  final pack = jsonDecode(
    File('texture_packs/$folder/pack.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  pack.forEach(
    (k, v) {
      if (v != "title" && v != "description") {
        File(winp('texture_packs/$folder/$k')).copySync(
          winp('data/flutter_assets/assets/images/$v'),
        );
      }
    },
  );
}

class TexturePack extends StatelessWidget {
  const TexturePack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = Directory('texture_packs').listSync();
    return Scaffold(
      appBar: AppBar(
        title: Text('Texture packs'),
      ),
      body: ListView(
        children: [
          for (var i in items)
            if (i is Directory)
              ListTile(
                title: Text(
                  jsonDecode(
                    File(winp(i.path + '/pack.json')).readAsStringSync(),
                  )["title"],
                ),
                subtitle: Text(
                  jsonDecode(
                    File(winp(i.path + '/pack.json')).readAsStringSync(),
                  )["description"],
                ),
                leading: SizedBox(
                  width: 10.w,
                  height: 10.w,
                  child: Image.file(
                    File(
                      winp('${i.path}/icon.png'),
                    ),
                    fit: BoxFit.fill,
                    width: 10.w,
                    height: 10.w,
                  ),
                ),
                onTap: () {
                  loadTexturePack(i.path.split('/').last);
                },
              ),
        ],
      ),
    );
  }
}
