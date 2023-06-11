part of logic;

int fixRot(int rot) {
  if (rot > 3) return fixRot(rot - 4);
  if (rot < 0) return fixRot(rot + 4);
  return rot;
}

void memGen(int x, int y, int indir, int outdir) {
  indir = fixRot(indir);
  outdir = fixRot(outdir);
  final c = grid.at(x, y);

  final bx = frontX(x, indir, -1);
  final by = frontY(y, indir, -1);

  final fx = frontX(x, outdir);
  final fy = frontY(y, outdir);

  if (!grid.inside(bx, by)) return;

  final b = grid.at(bx, by).copy;

  if (b.tags.contains("gend $outdir")) return;

  b.tags.add("gend $outdir");

  if (!ungennable.contains(b.id)) {
    c.data["memcell"] = b.toMap;
  }

  if (!grid.inside(fx, fy)) return;

  var addedRot = (outdir - indir) % 4;

  while (addedRot < 0) {
    addedRot += 4;
  }

  if (c.data["memcell"] != null) {
    final tgc = Cell.fromMap(c.data["memcell"]!, x, y)..rotate(addedRot);

    if (shouldHaveGenBias(tgc.id, toSide(outdir, tgc.rot))) tgc.updated = true;
    push(
      fx,
      fy,
      outdir,
      1,
      replaceCell: tgc.copy,
    );
    tgc.tags.remove("gend $outdir");
    c.data["memcell"] = tgc.toMap;
  }
}

void memgens() {
  for (var rot in rotOrder) {
    grid.updateCell((c, x, y) => memGen(x, y, rot, rot), rot, "mem_gen");
    grid.updateCell((c, x, y) => memGen(x, y, rot, rot + 1), rot, "mem_gen_cw");
    grid.updateCell(
      (c, x, y) => memGen(x, y, rot, rot - 1),
      rot,
      "mem_gen_ccw",
    );
    grid.updateCell((c, x, y) {
      memGen(x, y, rot, rot + 1);
      memGen(x, y, rot, rot - 1);
    }, rot, "mem_gen_double");

    grid.updateCell((c, x, y) {
      memGen(x, y, rot, rot + 1);
      memGen(x, y, rot, rot);
      memGen(x, y, rot, rot - 1);
    }, rot, "mem_gen_triple");
  }
}
