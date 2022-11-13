local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "ooh, what am I testing now!!!",
  moveInsideOf = function(into, x, y, dir, force, mt)
    return true
  end,
  handleInside = function(destroyer, x, y, moving, dir, side, force, mt)
    TPC.Grid().addBroken(moving, x, y, "normal")
  end,
  category = "Base",
}

TPC.DefineCell(cell)
