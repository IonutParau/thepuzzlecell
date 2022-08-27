import 'package:fluent_ui/fluent_ui.dart';
import 'package:the_puzzle_cell/utils/ScaleAssist.dart';

import '../../logic/logic.dart';

class TexturePacksUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TexturePacksUIState();
}

class _TexturePacksUIState extends State<TexturePacksUI> {
  Widget tile(TexturePack tp) {
    return ListTile(
      title: Text(tp.title),
      leading: Image.asset(tp.icon),
      trailing: Checkbox(
        checked: tp.enabled,
        onChanged: (v) {
          if (v != null && v != tp.enabled) {
            tp.toggle();
            applyTexturePacks();
            setState(() {});
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ScaffoldPage(
        header: Container(
          color: Colors.grey[100],
          child: Row(
            children: [
              Spacer(),
              Text(
                lang("texture_packs", "Texture Packs"),
                style: TextStyle(
                  fontSize: 10.sp,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        bottomBar: Row(
          children: [
            Spacer(),
            Button(
              child: Text(lang("enable_all", "Enable All"), style: TextStyle(fontSize: 7.sp)),
              onPressed: () async {
                await storage.remove("disabled_texturepacks");
                await applyTexturePackSettings();
                applyTexturePacks();
                setState(() {});
              },
            ),
            Button(
              child: Text(lang("reload", "Reload"), style: TextStyle(fontSize: 7.sp)),
              onPressed: () {
                loadTexturePacks();
                setState(() {});
              },
            ),
          ],
        ),
        content: texturePacks.isEmpty
            ? Center(
                child: Text(lang("no_texturepacks", "Couldn't find texture packs"), style: TextStyle(fontSize: 12.sp)),
              )
            : Scrollbar(
                child: ListView(
                  children: texturePacks.map<Widget>(tile).toList(),
                ),
              ),
      );
    });
  }
}
