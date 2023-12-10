part of logic;

class GameRendering {
  final PuzzleGame game;
  GameRendering(this.game);

  // Main game rendering
  void render(Canvas canvas) {
    try {
      game.canvas = canvas;

      if (game.overlays.isActive("loading")) {
        canvas.drawRect(
          Offset.zero & Size(game.canvasSize.x, game.canvasSize.y),
          Paint()..color = Colors.black,
        );
        return;
      }

      if (game.emptyImage == null) {
        canvas.drawRect(
          Offset.zero & Size(game.canvasSize.x, game.canvasSize.y),
          Paint()..color = Colors.black,
        );
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: 'Building Empty Image composition',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        );
        tp.layout();

        final pos = (game.canvasSize - tp.size.toVector2()) / 2;

        tp.paint(
          canvas,
          pos.toOffset(),
        );
        return;
      }

      canvas.drawRect(
        Offset.zero & Size(game.canvasSize.x, game.canvasSize.y),
        Paint()..color = settingsColor('game_bg', Color.fromARGB(255, 27, 27, 27)),
      );

      //canvas.save();

      canvas.translate(game.offX, game.offY);

      if (!game.firstRender) {
        final opacity = storage.getDouble("grid_opacity")!;
        if (game.replaceBgWithRect) {
          canvas.drawRect(Offset.zero & Size(grid.width / 1, grid.height / 1) * cellSize, Paint()..color = Color.fromARGB((opacity * 255).toInt(), 49, 47, 47));
        } else {
          var downscaleTarget = defaultCellSize / cellSize;
          var i = 0;

          while (downscaleTarget > PuzzleGame.emptyLinearEffect) {
            downscaleTarget /= PuzzleGame.emptyLinearEffect;
            i++;
          }

          if (game.empties.isNotEmpty && i >= game.empties.length) {
            i = game.empties.length - 1;
          }

          var jpeg = game.empties.elementAtOrNull(i);
          jpeg?.render(
            canvas,
            position: Vector2.zero(),
            size: Vector2(
              grid.width * cellSize,
              grid.height * cellSize,
            ),
            overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
          );
        }
      }

      game.firstRender = false;

      var sx = floor((-game.offX - cellSize) / cellSize);
      var sy = floor((-game.offY - cellSize) / cellSize);
      var ex = ceil((game.canvasSize.x - game.offX) / cellSize);
      var ey = ceil((game.canvasSize.y - game.offY) / cellSize);

      sx = max(sx, 0);
      sy = max(sy, 0);
      ex = min(ex, grid.width);
      ey = min(ey, grid.height);

      if (game.viewbox != null) {
        sx = game.viewbox!.topLeft.dx.toInt();
        sy = game.viewbox!.topLeft.dy.toInt();
        ex = game.viewbox!.bottomRight.dx.toInt();
        ey = game.viewbox!.bottomRight.dy.toInt();
      }

      if (game.realisticRendering) {
        const extra = 5;
        sx = max(sx - extra, 0);
        sy = max(sy - extra, 0);
        ex = min(ex + extra, grid.width);
        ey = min(ey + extra, grid.height);
      }

      final cellsPos = grid.quadChunk.fetch("all", sx, sy, ex, ey);

      for (var p in cellsPos) {
        final x = p[0];
        final y = p[1];

        if (grid.placeable(x, y) != "empty") {
          renderEmpty(grid.at(x, y), x, y);
        }
      }

      game.fancyRender(canvas);

      for (var p in cellsPos) {
        final x = p[0];
        final y = p[1];

        if (grid.at(x, y).id != "empty") {
          renderCell(grid.at(x, y), x, y);
        }
      }

      for (var fc in grid.fakeCells) {
        fc.render(canvas);
      }

      grid.fakeCells.removeWhere((fc) => fc.dead);

      if (game.hideUI) {
        return;
      }

      if (game.edType == EditorType.making && game.realisticRendering && game.mouseInside && !(game.pasting || game.selecting)) {
        var mx = game.cellMouseX; // shorter names
        var my = game.cellMouseY; // shorter names

        final brushSize = game.brushSize;

        for (var cx = mx - brushSize; cx <= mx + brushSize; cx++) {
          for (var cy = my - brushSize; cy <= my + brushSize; cy++) {
            if (grid.inside(cx, cy)) {
              final ocx = cx;
              final ocy = cy;
              if (grid.wrap) {
                cx += grid.width;
                cx %= grid.width;
                cy += grid.height;
                cy %= grid.height;
              }
              renderCell(
                Cell(cx, cy)
                  ..id = game.currentSelection
                  ..rot = game.currentRotation
                  ..lastvars.lastRot = game.currentRotation
                  ..data = game.currentData,
                cx,
                cy,
                Paint()..color = Colors.white.withOpacity(0.5),
              );
              cx = ocx;
              cy = ocy;
            }
          }
        }
      }

      if (game.edType == EditorType.making && game.interpolation && game.mouseInside && !game.selecting) {
        final mx = game.cellMouseX;
        final my = game.cellMouseY;

        final coolOverlayThickness = cellSize / 8;
        final coolOverlayWidth = (game.pasting ? game.gridClip.width : (game.brushSize + 1) * 2 - 1) * cellSize + coolOverlayThickness * 2;
        final coolOverlayHeight = (game.pasting ? game.gridClip.height : (game.brushSize + 1) * 2 - 1) * cellSize + coolOverlayThickness * 2;
        const coolOverlayAnimTime = 1;
        final delta = lerp(0, 1, (sin(game.alltime / coolOverlayAnimTime).abs()));

        final coolOverlaySpacingW = coolOverlayWidth + cellSize * delta;
        final coolOverlaySpacingH = coolOverlayHeight + cellSize * delta;

        final sx = mx * cellSize;
        final sy = my * cellSize;

        final rect = Offset(
              sx - (coolOverlaySpacingW - cellSize) / 2 + (game.pasting ? (game.gridClip.width ~/ 2 + (game.gridClip.width % 2 - 1) / 2) * cellSize : 0),
              sy - (coolOverlaySpacingH - cellSize) / 2 + (game.pasting ? (game.gridClip.height ~/ 2 + (game.gridClip.height % 2 - 1) / 2) * cellSize : 0),
            ) &
            Size(coolOverlaySpacingW, coolOverlaySpacingH);

        var coolOverlayColor = settingsColor('cellbar_border', Colors.grey[60]);

        if (game.pasting) {
          if (grid.inside(mx, my) || grid.inside(mx + game.gridClip.width, my) || grid.inside(mx, my + game.gridClip.height) || grid.inside(mx + game.gridClip.width, my + game.gridClip.height)) {
            for (var x = 0; x < game.gridClip.width; x++) {
              for (var y = 0; y < game.gridClip.height; y++) {
                if (grid.inside(mx + x, my + y)) {
                  if (game.gridClip.cells[x][y].id != "empty" && grid.at(mx + x, my + y).id != "empty") {
                    final c = (grid.at(mx + x, my + y).copy)..lifespan = 0;
                    if (c != game.gridClip.cells[x][y]) {
                      coolOverlayColor = Colors.red;
                    }
                  }
                } else {
                  coolOverlayColor = Colors.red;
                }
              }
            }
            canvas.drawRect(
              rect,
              Paint()
                ..color = coolOverlayColor
                ..strokeWidth = coolOverlayThickness
                ..style = PaintingStyle.stroke,
            );
          }
        } else if (grid.inside(mx, my)) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = coolOverlayColor
              ..strokeWidth = coolOverlayThickness
              ..style = PaintingStyle.stroke,
          );
        }
      }

      if (game.edType == EditorType.loaded && game.currentSelection != "empty" && game.mouseInside && !game.running) {
        final c = Cell(0, 0);
        c.lastvars = LastVars(game.currentRotation, 0, 0, game.currentSelection);
        c.lastvars.lastPos = Offset(
          (game.mouseX - game.offX) / cellSize,
          (game.mouseY - game.offY) / cellSize,
        );
        c.id = game.currentSelection;
        c.rot = game.currentRotation;
        c.data = game.currentData;
        renderCell(
          c,
          (game.mouseX - game.offX) / cellSize - 0.5,
          (game.mouseY - game.offY) / cellSize - 0.5,
        );
      }
      if (game.isMultiplayer && !game.running) {
        game.hovers.forEach(
          (id, hover) {
            if (id != game.clientID) {
              renderCell(
                Cell(0, 0)
                  ..id = hover.id
                  ..rot = hover.rot
                  ..data = hover.data,
                hover.x,
                hover.y,
              );
            }
          },
        );
      }

      if (game.pasting) {
        final mx = grid.wrap ? (game.cellMouseX + grid.width) % grid.width : game.cellMouseX;

        final my = grid.wrap ? (game.cellMouseY + grid.height) % grid.height : game.cellMouseY;
        game.gridClip.render(canvas, mx, my);
      } else if (game.selecting && game.setPos) {
        final selScreenX = (game.selX * cellSize);
        final selScreenY = (game.selY * cellSize);
        canvas.drawRect(
          Offset(selScreenX, selScreenY) & Size(game.selW * cellSize, game.selH * cellSize),
          Paint()..color = (Colors.grey[100].withOpacity(0.4)),
        );

        if (game.isDebugMode) {
          final tp = TextPainter(
            text: TextSpan(
              text: 'X: ${game.selX}\nY: ${game.selY}\nA: ${game.selW.abs()} x ${game.selH.abs()}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20 * uiScale,
              ),
            ),
            textDirection: TextDirection.ltr,
          );

          tp.layout();

          tp.paint(canvas, Offset(selScreenX, selScreenY + game.selH * cellSize));
        }
      }

      game.redparticles.render(canvas);
      game.blueparticles.render(canvas);
      game.greenparticles.render(canvas);
      game.yellowparticles.render(canvas);
      game.purpleparticles.render(canvas);
      game.tealparticles.render(canvas);
      game.blackparticles.render(canvas);
      game.magentaparticles.render(canvas);

      //grid.forEach(renderCell);

      canvas.restore();

      if (!game.running) {
        game.cursors.forEach(
          (id, cursor) {
            if (id != game.clientID) {
              if (cursor.selection != "empty" && game.edType == EditorType.making) {
                renderCell(
                  Cell(0, 0)
                    ..id = cursor.selection
                    ..rot = cursor.rotation,
                  cursor.x + game.offX / cellSize,
                  cursor.y + game.offY / cellSize,
                );
              }

              final p = (cursor.pos + Vector2.all(0.5)) * cellSize + Vector2(game.offX, game.offY);

              var c = 'interface/cursor.png';
              // Haha cool
              if (cursor.texture != "cursor") {
                c = textureMap["${cursor.texture}.png"] ?? "${cursor.texture}.png";
              }
              if (!Flame.images.containsKey(c) || !cursorTextures.contains(cursor.texture)) {
                c = 'base.png'; // No crashing rendering or setting stuff to other things :trell:
              }
              // Haha cooln't
              Sprite(Flame.images.fromCache(c)).render(
                canvas,
                position: p,
                size: Vector2.all(cellSize / 2),
              );

              if (game.isDebugMode) {
                final tp = TextPainter(
                  textDirection: TextDirection.ltr,
                  text: TextSpan(
                    text: id,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: cellSize / 3,
                    ),
                  ),
                );
                tp.layout();
                tp.paint(canvas, p.toOffset());
              }
            }
          },
        );
      }

      if (game.cellbar && game.edType == EditorType.making) {
        final cellbarBackground = settingsColor('cellbar_background', Colors.grey[180]);
        final cellbarBorder = settingsColor('cellbar_border', Colors.grey[60]);

        canvas.drawRect(
          Offset(0, game.canvasSize.y - 110 * uiScale) & Size(game.canvasSize.x, 110 * uiScale),
          Paint()..color = cellbarBackground,
        );

        final w = 5.0 * uiScale;

        canvas.drawRect(
          Offset(w, game.canvasSize.y - 110 * uiScale + w) & Size(game.canvasSize.x - w, 110 * uiScale - w),
          Paint()
            ..color = cellbarBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = w,
        );
      }

      AchievementRenderer.draw(canvas, game.canvasSize);

      game.buttonManager.forEach(
        (key, button) {
          button.canvasSize = game.canvasSize;
          button.render(canvas, game.canvasSize);
        },
      );

      if (game.isDebugMode && !game.isinitial) {
        final tp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: 'Tick Count: ${grid.tickCount}',
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
        );

        tp.layout();

        tp.paint(canvas, Offset(10 * uiScale, 70 * uiScale));
      }
      if (storage.getBool('show_titles') ?? true) {
        var hasShown = false;
        game.buttonManager.forEach(
          (key, button) {
            if (button.isHovered(game.mouseX.toInt(), game.mouseY.toInt()) && button.shouldRender() && game.mouseInside && !key.startsWith('hidden-') && !hasShown) {
              hasShown = true;
              renderInfoBox(canvas, button.title, button.description);
            }
          },
        );
      }

      if (keys[LogicalKeyboardKey.shiftLeft.keyLabel] == true && !game.selecting) {
        final mx = game.cellMouseX;
        final my = game.cellMouseY;

        final c = safeAt(mx, my);

        if (c != null) {
          var id = c.id;

          if (id == "empty") {
            id = grid.placeable(mx, my);
          }

          if (c.data["trick_as"] != null && game.edType == EditorType.loaded) {
            id = c.data["trick_as"];
          }

          var d = lang("$id.desc", (cellInfo[id] ?? defaultProfile).description);
          if (game.isDebugMode) {
            d += "\nID: $id";
            d += "\nX: $mx";
            d += "\nY: $my";
            final prop = props[id];
            if (prop != null) {
              var strings = <String>[];

              for (var property in prop) {
                strings.add("${lang("property.$id.${property.key}", property.name)}: ${c.data[property.key] ?? property.def}");
              }

              var str = strings.join("\n");
              d += "\n\n$str";
            }
          }

          renderInfoBox(canvas, "${lang("$id.title", (cellInfo[id] ?? defaultProfile).title)} (${rotToString(c.rot)})", d);
        }
      }

      if (grid.title != "") {
        // Render title and description

        final titletp = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: grid.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40 * uiScale,
            ),
          ),
        );

        titletp.layout();

        titletp.paint(
          canvas,
          Offset(
            (game.canvasSize.x - titletp.width) / 2,
            50 * uiScale,
          ),
        );

        if (grid.desc != "") {
          final descriptiontp = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            text: TextSpan(
              text: grid.desc,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30 * uiScale,
              ),
            ),
          );

          descriptiontp.layout(maxWidth: 50.w);

          descriptiontp.paint(
            canvas,
            Offset((game.canvasSize.x - descriptiontp.width) / 2, 70 * uiScale + titletp.height),
          );
        }
      }

      canvas.translate(game.offX, game.offY);
    } catch (e) {
      print(e);
      Navigator.of(game.context).push(MaterialPageRoute<void>(
        builder: (ctx) => ErrorWidget(e),
      ));
    }
  }

  void renderEmpty(Cell cell, int x, int y) {
    if (grid.placeable(x, y) != "empty" && backgrounds.contains(grid.placeable(x, y))) {
      final off = Vector2(x * cellSize.toDouble(), y * cellSize.toDouble());
      Sprite(Flame.images.fromCache(textureMap['${grid.placeable(x, y)}.png'] ?? 'backgrounds/${grid.placeable(x, y)}.png')).render(
        game.canvas,
        position: off,
        size: Vector2(
          cellSize.toDouble(),
          cellSize.toDouble(),
        ),
      );
    }
  }

  void drawSkin(String skin, Offset off, Paint? paint) {
    if (SkinManager.skinEnabled(skin)) {
      Sprite(Flame.images.fromCache('skins/$skin.png'))
        ..paint = paint ?? Paint()
        ..render(
          game.canvas,
          position: Vector2(off.dx, off.dy),
          size: Vector2.all(cellSize.toDouble()),
        );
    }
  }

  void renderCell(Cell cell, num x, num y, [Paint? paint, num scaleX = 1, num scaleY = 1, num? rrot]) {
    if ((paint?.color.opacity ?? 0) < 1 && cell.id == "empty") {
      final p = Offset(x.toDouble(), y.toDouble()) * cellSize;
      final r = p & Size(cellSize, cellSize);

      game.canvas.drawRect(
        r,
        Paint()
          ..color = (Colors.black.withOpacity(
            paint?.color.opacity ?? 0.5,
          )),
      );

      return;
    } // Help

    if (cell.id == "empty") return;
    if (cell.invisible) {
      if (game.edType == EditorType.making) {
        paint ??= Paint()..color = Colors.white.withOpacity(0.1);
      } else {
        return;
      }
    }
    var file = cell.id;

    var ignoreSafety = false;

    if ((cell.id == "pixel" && MechanicalManager.on(cell))) {
      file = 'pixel_on';
      ignoreSafety = true;
    }

    if (cell.id == "checkpoint" && cell.data['checkpoint_enabled'] == true) {
        file = "checkpoint_on";
        ignoreSafety = true;
    }

    if (cell.id == "electric_wire" && electricManager.directlyReadPower(cell) > 0) {
      file = 'electric_wire_on';
      ignoreSafety = true;
    }

    if (cell.id == "invis_tool") {
      file = "interface/tools/invis_tool";
      ignoreSafety = true;
    }

    if(cell.id == "sentry" && cell.data['friendly'] == true) {
      file = "destroyers/sentry_friendly";
      ignoreSafety = true;
    }

    if (file.startsWith('totrick_')) {
      file = "interface/tools/trick_tool";
      ignoreSafety = true;
    }

    if (cell.data["trick_as"] != null) {
      if (game.edType == EditorType.loaded) {
        file = cell.data["trick_as"]!;
      }
    }

    if (cell.id == "trick_tool") {
      file = "interface/tools/trick_tool";
      ignoreSafety = true;
    }

    if (backgrounds.contains(cell.id)) {
      ignoreSafety = true;
    }

    if (!ignoreSafety && !cells.contains(file)) {
      file = "missing";
    }

    var sprite = Sprite(
      Flame.images.fromCache(textureMap['$file.png'] ?? '$file.png'),
    );
    final rot = (((game.running || game.onetick) && game.interpolation ? lerpRotation(cell.lastvars.lastRot, rrot ?? cell.rot, game.itime / game.delay) : cell.rot) +
            (game.edType == EditorType.loaded ? cell.data["trick_rot"] ?? 0 : 0) % 4) *
        halfPi;
    final center = Offset(cellSize.toDouble() * scaleX, cellSize.toDouble() * scaleY) / 2;

    game.canvas.save();

    final lp = cell.lastvars.lastPos;
    final past = Offset(
              (lp.dx + grid.width) % grid.width,
              (lp.dy + grid.height) % grid.height,
            ) *
            cellSize.toDouble() +
        center;
    final current = Offset(x.toDouble(), y.toDouble()) * cellSize.toDouble() + center;

    var off = ((game.running || game.onetick) && game.interpolation) ? interpolate(past, current, game.itime / game.delay) : current;

    game.canvas.rotate(rot);

    off = rotateOff(off, -rot) - center;

    final last = cell.lastvars.id;
    var opacity = 1.0;

    if (last != cell.id && cells.contains(last) && game.running) {
      opacity = game.itime / game.delay;

      Sprite(Flame.images.fromCache(textureMap['$last.png'] ?? '$last.png')).render(
        game.canvas,
        position: Vector2(off.dx, off.dy),
        size: Vector2.all(cellSize.toDouble()),
        overridePaint: Paint()..color = Colors.white.withOpacity(1 - opacity),
      );
    }

    sprite
      ..paint = paint ?? (Paint()..color = Colors.white.withOpacity(opacity))
      ..render(
        game.canvas,
        position: Vector2(off.dx, off.dy),
        size: Vector2(
          cellSize.toDouble() * scaleX,
          cellSize.toDouble() * scaleY,
        ),
      );

    if (game.edType == EditorType.making && cell.data["trick_as"] != null) {
      final texture = textureMap[cell.data["trick_as"] + '.png'] ?? "${cell.data["trick_as"]}.png";
      final rotoff = (cell.data["trick_rot"] ?? 0) * halfPi;
      var trickOff = rotateOff(Offset(off.dx + cellSize / 2, off.dy + cellSize / 2), -rotoff);

      game.canvas.rotate(rotoff);

      Sprite(Flame.images.fromCache(texture))
        ..paint = paint ?? Paint()
        ..render(
          game.canvas,
          position: Vector2(trickOff.dx * scaleX, trickOff.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX / 2,
            cellSize.toDouble() * scaleY / 2,
          ),
          anchor: Anchor.center,
        );

      game.canvas.rotate(-rotoff);
    }

    if (game.edType == EditorType.making && cell.id.startsWith('totrick_')) {
      final trickAs = cell.id.substring(8);
      final texture = textureMap['$trickAs.png'] ?? "$trickAs.png";

      Sprite(Flame.images.fromCache(texture))
        ..paint = paint ?? Paint()
        ..render(
          game.canvas,
          position: Vector2(off.dx * scaleX + cellSize / 2, off.dy * scaleY + cellSize / 2),
          size: Vector2(
            cellSize.toDouble() * scaleX / 2,
            cellSize.toDouble() * scaleY / 2,
          ),
          anchor: Anchor.center,
        );
    }

    // Skins
    if (cell.id == "puzzle") {
      drawSkin('computer', off, paint);
      drawSkin('hands', off, paint);
      drawSkin('christmas', off, paint);
    }

    // Effects
    if ((paint != null && game.brushTemp != 0) || ((cell.data['heat'] ?? 0) != 0 && !(cell.id == "magma" || cell.id == "snow"))) {
      final heat = paint == null ? (cell.data['heat'] ?? 0) : game.brushTemp;

      Sprite(Flame.images.fromCache(heat > 0 ? 'effects/heat.png' : 'effects/cold.png'))
        ..paint = paint ?? Paint()
        ..render(
          game.canvas,
          position: Vector2(off.dx * scaleX, off.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX,
            cellSize.toDouble() * scaleY,
          ),
        );

      final tp = TextPainter(
        text: TextSpan(
          text: "${abs(heat)}",
          style: TextStyle(
            fontSize: cellSize * 0.25,
            color: heat > 0 ? Colors.orange["light"] : Color.fromARGB(255, 33, 162, 194),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        game.canvas,
        Offset(
          off.dx * scaleX + cellSize * 0.3,
          off.dy * scaleY - cellSize * 0.07,
        ),
      );
    }

    final effects = <String>{};

    if (cell.tags.contains("consistent")) {
      effects.add("consistent");
    }
    if (cell.tags.contains("stopped")) {
      effects.add("stopped");
    }
    if (cell.tags.contains("shielded")) {
      effects.add("shield");
    }

    for (var effect in effects) {
      Sprite(Flame.images.fromCache("effects/$effect.png"))
        ..paint = paint ?? Paint()
        ..render(
          game.canvas,
          position: Vector2(off.dx * scaleX, off.dy * scaleY),
          size: Vector2(
            cellSize.toDouble() * scaleX,
            cellSize.toDouble() * scaleY,
          ),
        );
    }

    // Custom cell stuff

    var text = textToRenderOnCell(cell, x, y);

    if (text != "") {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: cellSize * 0.25,
            color: paint?.color,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(cellSize, cellSize) * 0.025,
                blurRadius: cellSize / 200,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();
      tp.paint(
        game.canvas,
        Offset(
          off.dx * scaleX + cellSize / 2 - tp.width / 2,
          off.dy * scaleY + cellSize / 2 - tp.height / 2,
        ),
      );
    }

    game.canvas.restore();
  }
}
