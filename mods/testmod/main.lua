TPC.DefineCell({
  id = "testcell",
  name = "Test Cell",
  desc = "Just a test cell",
  category = "Base",
})

TPC.Stableton.registerStableton("testcell", 5, { -1, 1, 2, -2 },
  { { x = 1, y = 0 }, { x = -1, y = 0 }, { x = 0, y = 1 }, { x = 0, y = -1 } }, {}, true, false, {}, 0)
