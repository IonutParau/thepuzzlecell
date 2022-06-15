part of layout;

final Map<String, Svg> _svgCache = {};

Future loadImage(String path) async {
  final tp = textureMap[path] ?? path;

  if (tp.toLowerCase().endsWith('.svg')) {
    _svgCache[path] = await Svg.load(tp);
  } else {
    Flame.images.load(tp);
  }
}

void drawSprite(String path, Canvas canvas, Vector2 position, Vector2 size) {
  final tp = textureMap[path] ?? path;

  if (tp.toLowerCase().endsWith('.svg')) {
    final svg = _svgCache[tp]!;
    svg.renderPosition(canvas, position, size);
  } else {
    final img = Flame.images.fromCache(tp);

    Sprite(img).render(canvas, position: position, size: size);
  }
}
