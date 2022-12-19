local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "Never touch this ever",
  update = {
    mode = "4-way",
    fn = function(cell, x, y)
      TPC.Move.Push(x, y, cell.rot(), 0, "push", nil)
    end,
  },
  addedForce = function(cell, dir, side, force, moveType)
    if side == 0 then
      return 1
    end

    if side == 2 then
      return -1
    end

    return 0
  end,
  category = "Base/Push Cells",
}

TPC.DefineCell(cell)
