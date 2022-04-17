part of layout;

class AchievementRenderer {
  static String? _latest;
  static double _time = 0;

  static void show(String thing) {
    _latest = thing;
    _time = 0;
  }

  static void draw(Canvas canvas, Vector2 canvasSize) {
    if (_latest == null) return;
    final title = achievementData[_latest]!.title;
    var description = achievementData[_latest]!.description;
    final prize = achievementData[_latest]!.prize;
    final scale = uiScale;

    if (prize > 0) {
      description += "\n+$prize Puzzle Points";
    } else if (prize < 0) {
      description += "\n$prize Puzzle Points";
    }

    final titleTP = TextPainter(
        textWidthBasis: TextWidthBasis.longestLine,
        textDirection: TextDirection.ltr);
    final descriptionTP = TextPainter(textDirection: TextDirection.ltr);

    titleTP.text = TextSpan(
      text: title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 9.sp * scale,
      ),
    );

    descriptionTP.text = TextSpan(
      text: description,
      style: TextStyle(
        color: Colors.white,
        fontSize: 7.sp * uiScale,
      ),
    );

    titleTP.layout();
    final width = max(titleTP.width, 20.w * scale);
    descriptionTP.layout(maxWidth: width);
    final height = titleTP.height + descriptionTP.height;
    final border = 10 * scale;

    var size = Size(width + border * 2, height + border * 2);
    var off = Offset(
      game.canvasSize.x - size.width - border,
      game.canvasSize.y - size.height - border,
    );

    final rect = off & size;

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawRect(
      rect,
      Paint()..color = Colors.grey[180],
    );
    canvas.drawRect(
      (off + Offset(0, height + border * 2)) &
          Size(size.width * (_time / 2), border),
      Paint()..color = Colors.green,
    );
    titleTP.paint(canvas, Offset(off.dx + border, off.dy + border));
    descriptionTP.paint(
      canvas,
      Offset(
        off.dx + border,
        off.dy + titleTP.height + border * 2,
      ),
    );
  }

  static void update(double dt) {
    if (_latest != null) {
      _time = _time + dt;
      if (_time > 2) {
        _latest = null;
      }
    }
  }
}
