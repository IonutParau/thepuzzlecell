local function fill(x, y, grid)
  if (grid.get(x - 1, y) == nil) or (grid.get(x - 1, y).id() == "empty") then
    grid.copyCell(x, y, x - 1, y, true)
  end
  if (grid.get(x + 1, y) == nil) or (grid.get(x + 1, y).id() == "empty") then
    grid.copyCell(x, y, x + 1, y, true)
  end
  if (grid.get(x, y - 1) == nil) or (grid.get(x, y - 1).id() == "empty") then
    grid.copyCell(x, y, x, y - 1, true)
  end
  if (grid.get(x, y + 1) == nil) or (grid.get(x, y + 1).id() == "empty") then
    grid.copyCell(x, y, x, y + 1, true)
  end
end

local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "ooh, what am I testing now!!!",
  update = {
    mode = "static",
    fn = function(cell, x, y)
      fill(x, y, TPC.grid())
    end,
  },
  category = "Base",
}

TPC.DefineCell(cell)
