local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "Never touch this ever",
  moveInsideOf = function(cell, x, y, dir, side, force, mt)
    return ((cell.field("remaining") or 0) > 0)
  end,
  handleInside = function(cell, x, y, moving, dir, side, force, mt)
    cell.field("remaining", (cell.field("remaining") or 0) - 1)

    local brokenType = "normal"
    if cell.field("silent") == true then
      brokenType = "silent"
    end

    TPC.Grid().addBroken(moving, x, y, brokenType)
  end,
  category = "Base/Push Cells",
  properties = {
    { name = "Remaining", field = "remaining", type = "integer", default = 10 },
    { name = "Silent", field = "silent", type = "boolean", default = false },
  },
}

TPC.DefineCell(cell)
