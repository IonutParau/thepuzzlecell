local function fill(x, y, cell, grid)
  cell.updated(true)

  if (grid.get(x - 1, y) == nil) or (grid.get(x - 1, y).id() == "empty") then
    grid.set(cell, x - 1, y)
  end
  if (grid.get(x + 1, y) == nil) or (grid.get(x + 1, y).id() == "empty") then
    grid.set(cell, x + 1, y)
  end
  if (grid.get(x, y - 1) == nil) or (grid.get(x, y - 1).id() == "empty") then
    grid.set(cell, x, y - 1)
  end
  if (grid.get(x, y + 1) == nil) or (grid.get(x, y + 1).id() == "empty") then
    grid.set(cell, x, y + 1)
  end
end

local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "ooh, what am I testing now!!!",
  update = {
    mode = "static",
    fn = function(cell, x, y)
      local grid = TPC.Grid()

      fill(x, y, cell, grid)
    end,
  },
  category = "Base"
}

TPC.DefineCell(cell)
