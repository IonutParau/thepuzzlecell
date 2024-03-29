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
---@param jsonData string|nil
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
function TPC.enemyParticleCount() return 250 end

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

--- Swaps 2 cells. Does not actually check if it CAN swap the 2 cells. You need to do that.
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

---@param id string
---@return nil
function TPC.Queues.create(id) return end

---@param id string
---@return nil
function TPC.Queues.delete(id) return end

---@param id string
---@param callback fun()
---@return nil
function TPC.Queues.add(id, callback) return end

---@param id string
---@return nil
function TPC.Queues.empty(id) return end

---@param id string
---@return nil
function TPC.Queues.runQueue(id) return end

---@param id string
---@param limit integer
---@return nil
function TPC.Queues.runLimitedQueue(id, limit) return end

--- High-level sandboxed filesystem functions
TPC.FS = {}

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
--- Creates a file
function TPC.FS.create(path) return end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
--- Deletes a file or folder
function TPC.FS.delete(path) return end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
---@param content string The content they want to write to.
--- Overwrites the contents of a file
function TPC.FS.writeTo(path, content) return end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
---@return string
--- Reads the contents of a file as a string
function TPC.FS.readFrom(path) return "" end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
--- Creates a directory
function TPC.FS.createDir(path) return end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
--- Deletes a file or folder
function TPC.FS.deleteDir(path) return end

---@param path string Path is relative to main.lua, which means the path stuff/etc.png is actually mods/<mod folder>/stuff/etc.png.
---@return string[]
--- Returns the subfiles and subfolders inside a directory
function TPC.FS.listDir(path) return {} end

--- Will ask TPC to update the files in the background. This is not on a seperate thread, but instead just uses Dart's async/await loop.
--- This means that your Lua code can block the updates to the files from happening.
--- The updates are grabbed from the remoteFiles field in the info.json file of your mod.
function TPC.FS.asyncUpdateRemotes() return end

--- Help with math
TPC.Math = {}

TPC.Math.phi = (1 + math.sqrt(5)) / 2

---@param channel integer
---@param idx integer
---@param val number
function TPC.Math.setGlobal(channel, idx, val) return end

---@param channel integer
---@param idx integer
---@return number
function TPC.Math.getGlobal(channel, idx) return 0 end

---@param x integer
---@param y integer
---@param dir integer
---@return number
function TPC.Math.input(x, y, dir) return 0 end

---@param x integer
---@param y integer
---@param dir integer
---@param count number
function TPC.Math.output(x, y, dir, count) return end

---@param x number
---@param n number
---@return number
function TPC.Math.logn(x, n) return 0 end

--- Mod-to-mod communication
TPC.Channel = {}

---@param id string
---@return nil
function TPC.Channel.Create(id) return end

---@param id string
---@return boolean
function TPC.Channel.Exists(id) return false end

---@param id string
---@param content string
---@return nil
function TPC.Channel.Send(id, content) return end

---@param id string
---@param callback fun(data: string):nil
---@return nil
function TPC.Channel.Listen(id, callback) return end

--- Cell type information
TPC.Types = {}

---@param id string
---@return nil
--- Marks it as an enemy. This means flags will look for it in order to kill it.
function TPC.Types.MarkAsEnemy(id) return end

---@param id string
---@return nil
--- Marks it as movable. This means if the cell exists then even if the grid is full, stuff can move. This is used to prevent bugs caused by one of TPC's oldest optimizations, the grid-wise movability check.
function TPC.Types.MarkAsMovable(id) return end

---@param id string
---@return nil
--- Friendly enemies are enemies not looked at by flags. They may still be identified as enemies, it's just that flags won't look for them.
function TPC.Types.MarkAsFriendlyEnemy(id) return end

---@return string[]
--- Returns a list of enemies
function TPC.Types.Enemies() return {} end

---@return string[]
--- Returns a list of mpvables
function TPC.Types.Movables() return {} end

---@return string[]
--- Returns a list of friendly enemies
function TPC.Types.FriendlyEnemies() return {} end

--- Help with time-travel
TPC.Time = {}

--- Returns instance to grid to time travel to
---@return GridBinding|nil
function TPC.Time.Grid() return {} end

--- Requests a travel back in time. This is not instant, and can last a bit.
function TPC.Time.Travel() return end

---@class UpdateConfig
--- How to update the cell. 4-way means in a mover-like style, static means in a rotator-like style and 2-way means in a mirror-like style
---@field mode "4-way"|"static"|"2-way"
--- The index the subtick should have
---@field index integer
--- The update function itself
---@field fn fun(cell: CellBinding, x: integer, y: integer):nil

---@class CellConfig
--- The ID of the cell
---@field id string
--- The display name of the cell
---@field name string
--- The description of the cell
---@field desc string
--- The category the cell is in. If in multiple categories, you can put a list of them.
---@field category string[]|string
--- The texture of the cell (relative to main.lua), defaults to default.png
---@field texture string
--- Information about how to update the cell. Nil means the cell should not have a subtick.
---@field update UpdateConfig
--- How much force to add to a push or pull. This can be used to implement weights or mover bias.
---@field addedForce fun(cell: CellBinding, dir: integer, side: integer, force: integer, moveType: MoveType): integer
--- How to handle something going inside of the cell. This can be used to make proper enemies or trashes.
---@field handleInside fun(destroyer: CellBinding, x: integer, y: integer, moving: CellBinding, dir: integer, side: integer, force: integer, mt: MoveType):nil
--- Returns whether or not a cell can move inside of this one.
---@field moveInsideOf fun(into: CellBinding, x: integer, y: integer, dir: integer, side: integer, force: integer, mt: MoveType):boolean
--- Returns whether the cell should behave like mobile trash. cell is the potentially acidic cell and melting is the cell it will move into.
---@field acidic fun(cell: CellBinding, dir: integer, side: integer, force: integer, mt: MoveType, melting: CellBinding, mx: integer, my: integer):boolean
--- Called to properly handle acidic behavior
---@field handleAcid fun(cell: CellBinding, dir: integer, side: integer, force: integer, mt: MoveType, melting: CellBinding, mx: integer, my: integer):nil
--- Returns whether the cell should behave like a sticky cell
---@field isSticky fun(cell: CellBinding, x: integer, y: integer, base: boolean, checkedAsBack: boolean, originX: integer, originY: integer):nil
--- Returns if it sticks specifically to a cell. sticker is the cell this method is bound to, while to is the cell you're checking if it can stick to.
---@field sticksTo fun(sticker: CellBinding, to: CellBinding, dir: integer, base: boolean, checkedAsBack: boolean, originX: integer, originY: integer):boolean
---
---@field movable fun(cell: CellBinding, x: integer, y: integer, dir: integer, side: integer, force: integer, mt: MoveType):boolean
--- Whether the cell is meant to be in References
---@field isReference boolean
--- Code to be executed when a math cell writes a number to this cell
---@field mathWhenWritten fun(cell: CellBinding, x: integer, y: integer, dir: integer, amount: number)
--- Allows the cell to choose its own way of determening its count. If nil is returned, it returns the one stored in the properties.
---@field mathCustomCount fun(cell: CellBinding, x: integer, y: integer, dir: integer): number|nil
--- Decides if the cell's count property should be automatically modified by TPC, or if the cell should do it itself in mathWhenWritten. Can be used to create safeNumbers.
---@field mathAutoApplyCount fun(cell: CellBinding, cx: integer, cy: integer, dir: integer, amount: number, ox: integer, oy: integer): boolean
--- Decides if count can be modified.
---@field mathIsWritable fun(cell: CellBinding, x: integer, y: integer, dir: integer)
--- Decides if the count can be read from that direction.
---@field mathIsOutput fun(cell: CellBinding, x: integer, y: integer, dir: integer)
--- A list of properties for the property editor to allow the modification of.
---@field properties CellProperty[]

---@class CellProperty
--- The name of the property
---@field name string
--- The description of the property
---@field desc string
--- The key in data that the field is bound to.
---@field field string
--- The type of the property so the property editor can properly use it.
---@field type "number"|"integer"|"text"|"boolean"|"cellID"|"cellRot"|"cell"|"background"
--- The default value. Please note: There is no validation that the default value matches the type of the property, so be careful.
---@field default any

---@return nil
---@param config CellConfig
function TPC.DefineCell(config)
  return
end
