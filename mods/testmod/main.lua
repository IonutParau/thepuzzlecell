TPC.CreateCategory("Base", "Test", "A test category", "test_cell", 3)

local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "Never touch this ever",
  update = {
    mode = "4-way",
    fn = function(cell, x, y)
      print("Hello, world!")
    end,
  },
  category = "Base/Test",
}

TPC.DefineCell(cell)
