local cell = {
  id = "test_cell",
  name = "Test Cell",
  desc = "Never touch this ever",
  update = {
    mode = "4-way",
    fn = function(cell, x, y)
      TPC.emitParticles(50, x, y, "teal")
      TPC.Move.Push(x, y, math.floor(math.random(0, 3)), 1, "push", nil)
    end,
  },
  category = "Base/Push Cells",
}

TPC.DefineCell(cell)
