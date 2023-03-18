-- This is a Lua file containing a mock version of the TPC modding API

if TPC then return TPC end

TPC = {}

---@alias MoveType "push"|"gear"|"mirror"|"pull"|"puzzle"|"grab"|"tunnel"|"unknown_move"|"transform"|"burn"|"sticky_check"

---@alias BreakType "rotate"|"transform"|"burn"|"explode"

--- A binding for when a message is sent. Currently unimplemented.
---@param msg string The message
function TPC.OnMsg(msg)
end

--- Loads a file from the mod's internal folder.
---@param path string
function TPC.Import(path)
end

--- Loads a module.
--- Modules are separate scripts that can be shared between mods.
--- Modules are often used for compatibility layers between APIs.
---@param module string
function TPC.Module(module)
end

---@class CellBinding
CellBinding = {}

--- If not given any parameters, it will return the ID of the cell.
--- If a parameter is given, the ID of the cell will be set to that parameter.
---@param id string|nil
---@return string
function CellBinding.id(id) return "" end

--- If not given any parameters, it will return the lifespan of the cell.
--- If a parameter is given, the lifespan of the cell will be set to that parameter.
---@param lifespan integer|nil
---@return integer
function CellBinding.lifespan(lifespan) return 0 end

--- If not given any parameters, it will return the rotation of the cell.
--- If a parameter is given, the rotation of the cell will be set to that parameter.
---@param rot integer|nil
---@return integer
function CellBinding.rot(rot) return 0 end

--- If not given any parameters, it will return the updated state of the cell.
--- If a parameter is given, the updated state of the cell will be set to that parameter.
---@param updated boolean|nil
---@return boolean
function CellBinding.updated(updated) return false end

--- Gives a binding to a copy of the cell
---@return CellBinding
function CellBinding.copy() return {} end

--- If not given any parameters, it will return if the cell is invisible.
--- If a parameter is given, it will set to cell to either visible or invisible.
---@param invisible boolean|nil
---@return boolean
function CellBinding.invisible(invisible) return false end

--- Gives a list of all the tags of the cell
---@return string[]
function CellBinding.tags() return {} end

--- Adds a tag to the cell
---@param tag string
function CellBinding.tag(tag) return end

--- Returns whether a cell has a specific tag
---@param tag string
---@return boolean
function CellBinding.tagged(tag) return false end

--- Returns the last known X coordinate of the cell
---@return integer
function CellBinding.cx() return 0 end

--- Returns the last known Y coordinate of the cell
---@return integer
function CellBinding.cy() return 0 end

--- If not given any parameters, it will return the JSON encoded version of the data.
--- If a parameter is given, it will set the data to the JSON decoded version of that jsonData.
---@param jsonData string
---@return string
function CellBinding.data(jsonData) return "" end

--- Functions for getting information about the last state
CellBinding.last = {}

--- If not parameter is given, it returns the last X.
--- If a parameter is given, the last X is set to that parameter.
---@param x integer|nil
---@return integer
function CellBinding.last.x(x) return 0 end

--- If not parameter is given, it returns the last Y.
--- If a parameter is given, the last Y is set to that parameter.
---@param y integer|nil
---@return integer
function CellBinding.last.y(y) return 0 end

--- If not parameter is given, it returns the last rotation.
--- If a parameter is given, the last rotation is set to that parameter.
---@param rot integer|nil
---@return integer
function CellBinding.last.rot(rot) return 0 end

--- If not parameter is given, it returns the last id.
--- If a parameter is given, the last id is set to that parameter.
---@param id string|nil
---@return string
function CellBinding.last.id(id) return "" end

--- Releases all associated memory to this object. Each CellBinding also has an __gc metamethod to automatically call this, so this function is rarely useful.
function CellBinding.release() return end

---@class GridBinding
GridBinding = {}

--- Returns the width
---@return integer
function GridBinding.width() return 0 end

--- Returns the height
---@return integer
function GridBinding.height() return 0 end

--- Returns a cell binding to the cell at x, y
---@param x integer
---@param y integer
---@return CellBinding
function GridBinding.get(x, y) return {} end

--- Sets the cell at x, y to the decoded copy of the cell binding given.
---@param x integer
---@param y integer
---@param cell CellBinding
function GridBinding.set(x, y, cell) return end

--- Returns whether x, y is within the grid.
---@param x integer
---@param y integer
---@return boolean
function GridBinding.inside(x, y) return false end

--- Copies a cell from cx, cy to nx, ny and if update is true, it will also mark the copy as updated
---@param cx integer
---@param cy integer
---@param nx integer
---@param ny integer
---@param update boolean
function GridBinding.copyCell(cx, cy, nx, ny, update) return end

--- If the cell at x, y is inside the grid and is empty, it will set the cell at x, y to cell.
---@param x integer
---@param y integer
---@param cell CellBinding
function GridBinding.spawn(x, y, cell) return end

--- Returns the tick count of the Grid
---@return integer
function GridBinding.tickCount() return 0 end

--- If no parameters are given, it returns the title.
--- If a parameter is given, it sets the title of the grid to that parameter.
---@param title string
---@return string
function GridBinding.title(title) return "" end

--- If no parameters are given, it returns the description.
--- If a parameter is given, it sets the description of the grid to that parameter.
---@param description string
---@return string
function GridBinding.desc(description) return "" end

--- If no parameters are given, it returns whether wrap mode is on.
--- If a parameter is given, it sets wrap mode to either on or off based on the parameter.
---@param wrap boolean
---@return boolean
function GridBinding.wrap(wrap) return false end

--- Rotates the cell at x, y by rot.
---@param x integer
---@param y integer
---@param rot integer
function GridBinding.rotate(x, y, rot) return end

--- Returns the placeable at x, y.
---@param x integer
---@param y integer
---@return string
function GridBinding.placeable(x, y) return "" end

--- Sets the placeable at x, y to id.
---@param x integer
---@param y integer
---@param id string
function GridBinding.setPlace(x, y, id) return end

--- Marks the ID id as being present at x, y
---@param x integer
---@param y integer
---@param id string
function GridBinding.setChunk(x, y, id) return end

--- Returns the cell types on the grid
---@return string[]
function GridBinding.types() return {} end

--- Like [CellBinding.release], but for the GridBinding
function GridBinding.release() return end

--- Adds a broken cell (for animation purposes)
---@param cell CellBinding
---@param x integer
---@param y integer
---@param type string
---@param rlvx integer|nil If nil, it's the last x of the cell
---@param rlvy integer|nil If nil, it's the last y of the cell
function GridBinding.addBroken(cell, x, y, type, rlvx, rlvy) return end

--- If you only specify 2 arguments, it will return the number at channel, index.
--- If you specify all 3, it will set the number at channel, index to number
---@param channel integer
---@param index integer
---@param number number
---@return number
function GridBinding.memory(channel, index, number) return 0 end

--- Gives a grid binding to the current grid
---@return GridBinding
function TPC.Grid() return {} end

--- Returns the amount of enemy particles TPC recommends
---@return integer
function TPC.enemyParticleCount() return 0 end

--- Emits <amount> particles at x, y with a specific color
---@param amount integer
---@param x integer
---@param y integer
---@param color "red"|"blue"|"green"|"yellow"|"purple"|"teal"|"black"|"magenta"
function TPC.emitParticles(amount, x, y, color) return end

--- Returns information amount every mod installed
---@return {name: string, description: string, author: string}[]
function TPC.ModList() return {} end

--- Calls cb after all mods initialize
---@param cb function
function TPC.PostInitialization(cb) return {} end

--- Creates a category
---@param host string Path of the category. Empty string means its added to the cell bar. Otherwise, its the name of the category it must be in.
---@param name string The name of the category
---@param desc string The description of the category
---@param look string The ID of the cell that this category should look like
---@param max integer The maximum amount of cells in a row. Recommended value is 3
function TPC.CreateCategory(host, name, desc, look, max) return end

--- Functions related to movement
TPC.Move = {}

--- Checks if a cell can be moved
---@param x integer X coordinate
---@param y integer Y coordinate
---@param dir integer Direction
---@param force integer Force
---@param moveType MoveType Movement type
---@return boolean
function TPC.Move.canMove(x, y, dir, force, moveType) return true end

--- Checks if a cell can be moved into
---@param cell CellBinding The cell you're trying to move into
---@param x integer X coordinate
---@param y integer Y coordinate
---@param dir integer Direction
---@param force integer Force
---@param moveType MoveType Movement type
---@return boolean
function TPC.Move.moveInsideOf(cell, x, y, dir, force, moveType) return false end

--- Checks if a cell can be moved into
---@param x integer
---@param y integer
---@param dir integer
---@param force integer
---@param moving CellBinding
---@param moveType MoveType
function TPC.Move.handleInside(x, y, dir, force, moving, moveType) return end

--- Swaps 2 cells
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
function TPC.Move.swap(x1, y1, x2, y2) return end

--- Returns the amount of extra force requested by this cell
---@param cell CellBinding
---@param dir integer
---@param force integer
---@param moveType MoveType
---@return integer
function TPC.Move.addedForce(cell, dir, force, moveType) return 0 end

--- Returns whether a cell behaves as an acid
---@param cell CellBinding
---@param dir integer
---@param force integer
---@param moveType MoveType
---@param melting CellBinding
---@param mx integer
---@param my integer
---@return boolean
function TPC.Move.acidic(cell, dir, force, moveType, melting, mx, my) return false end

--- Handles acidic behavior
---@param cell CellBinding
---@param dir integer
---@param force integer
---@param moveType MoveType
---@param melting CellBinding
---@param mx integer
---@param my integer
function TPC.Move.handleAcid(cell, dir, force, moveType, melting, mx, my) return end

--- Pushes the cell at x, y
---@param x integer
---@param y integer
---@param dir integer
---@param force integer
---@param moveType MoveType
---@param replaceCell CellBinding|nil
---@return boolean
function TPC.Move.Push(x, y, dir, force, moveType, replaceCell) return false end

--- Pulls forward the cell at x, y
---@param x integer
---@param y integer
---@param dir integer
---@param force integer
---@param moveType MoveType
---@return boolean
function TPC.Move.Pull(x, y, dir, force, moveType) return false end

--- Nudges the cell at x, y. unknown_move is the recommended movetype.
---@param x integer
---@param y integer
---@param dir integer
---@param moveType MoveType
---@return boolean
function TPC.Move.Nudge(x, y, dir, moveType) return false end

--- Functions that help with common problems
TPC.Helper = {}

---@param dir integer
---@param rot integer
---@return integer
function TPC.Helper.toSide(dir, rot) return 0 end

---@param x integer
---@param dir integer
---@return integer
function TPC.Helper.frontX(x, dir) return 0 end

---@param y integer
---@param dir integer
---@return integer
function TPC.Helper.frontY(y, dir) return 0 end

---@param cell CellBinding
---@param x integer
---@param y integer
---@param dir integer
---@return boolean
function TPC.Helper.ungennable(cell, x, y, dir) return false end

---@param x integer
---@param y integer
---@param dir integer
---@param gendir integer
---@param offX integer
---@param offY integer
---@param preaddedRot integer
---@param physical boolean
---@param lvxo integer Offset for Last Vars's X of the generated cell
---@param lvyo integer Offset for Last Vars's Y of the generated cell
---@param ignoreOptimization boolean Tells generate to ignore the generator optimization
---@return nil
function TPC.Helper.generate(x, y, dir, gendir, offX, offY, preaddedRot, physical, lvxo, lvyo, ignoreOptimization) return end

---@param x integer
---@param y integer
---@param dir integer
---@param gdir integer
---@return nil
function TPC.Helper.antiGenerate(x, y, dir, gdir) return end

---@param x integer
---@param y integer
---@param dir integer
---@param gendir integer
---@param offX integer
---@param offY integer
---@param preaddedRot integer
---@return nil
function TPC.Helper.superGenerate(x, y, dir, gendir, offX, offY, preaddedRot) return end

--- Triggers a win
function TPC.Helper.triggerWin() return end

--- Triggers a loss
function TPC.Helper.triggerLoss() return end

---@param cell CellBinding
---@param x integer
---@param y integer
---@param dir integer
---@return boolean
function TPC.Helper.IsGeneratable(cell, x, y, dir) return false end

---@param cell CellBinding
---@param x integer
---@param y integer
---@param dir integer
---@param breakType BreakType
---@return boolean
function TPC.Helper.canBreak(cell, x, y, dir, breakType) return false end

---@param x integer
---@param y integer
---@param dir integer
---@param outdir integer
---@param offX integer
---@param offY integer
---@param off integer
---@param backOff integer
---@return boolean
function TPC.Helper.transform(x, y, dir, outdir, offX, offY, off, backOff) return false end

--- Functions that handle queues
TPC.Queues = {}



--- High-level filesystem functions
TPC.FS = {}



--- Help with math
TPC.Math = {}



--- Mod-to-mod communication
TPC.Channel = {}



--- Cell type information
TPC.Types = {}



--- Help with time-travel
TPC.Time = {}
