# What are master cells?

Master cells are the most meta cells in the game capable of manipulating the grid like no other cell can.
All master cells use either the numerical system or mechanical signal system.

# The master states

Most master cells use master states. A master state consists of 7 integer variables:

· Cell ID (default Empty/0) - Each cell is associated with an index number,

· X and Y (default 0,0) - Position in 2 coordinates,

· Last X and Last Y (default 0,0) - When a cell is created through a master state with interpolation enabled,
it will visually move from last X and last Y to current X and Y,

· Rotation (default right) - Each direction is associated with a number: 0 is right, 1 is down, 2 is left and 3 is up. 4 and above just repeat integers 0-3,

· Last Rotation (default right) - Like Last X and Last Y,
Newly created cell from a master state will visually rotate itself from Last Rotation to current Rotation if interpolation is enabled.

The master states are placed in a stack. The master cells use the topmost master state for everything.

# Getters

The simplest of master cells. They will simply output a number forward based on a simple parameter.

# Setters

When setters receive a mechanical signal from behind,
they will change a variable or two in the topmost master state and will also send that mechanical signal forward.
All setters (excluding Change to Constant ID) require a numerical input from their left,
some requiring a second input from their right, to set variables from topmost master state.
Change to Constant ID will take the ID from properties instead of a numerical input.

# Checkers

If their check succeeds, they will send a mechanical signal out front.
Comparers will check if the current Cell ID from topmost master state matches their properties or numerical input(s), if they have one.

# Controllers

When controllers receive a mechanical signal from behind,
they will control either the grid or master states and will also send that mechanical signal forward, like setters do.
As this subcategory is most complicated, this help page explains all controller cells.

· Set Master State to New Cell - Simply resets topmost Cell ID, Rotation and Last Rotation to their defaults.

· Place Cell from Master State - By using all of topmost master state's parameters,
it places a cell with corresponding ID in the stored X and Y coordinates with the stored rotation.
If interpolation setting is enabled, the newly created cell will visually move from last X and last Y with last rotation to stored X, Y with stored rotation.

· Add as Fake Cell - Shares similarities with "Place Cell from Master State",
but the placed cell will only be visual (not affect the grid in any way other than visual).
It takes numerical input from left to determine how many ticks the fake cell will be seen before it disappears.

· Push cell - By using topmost master state's X and Y, it pushes the cell in corresponding coordinates.
The pushing direction is determined by the numerical input on its left (similar, but not same as the master state's rotation).

· Pop and Push - Push adds a new default master state in a stack on top of other master states.
Pop will delete the topmost master state from existence and the next master state on the stack will become the topmost.
If there is only one detected master state, pop will reset all of that master state's parameters to their defaults instead.

· Select Cell at X and Y - By taking 2 numeric inputs on its left (as X) and right (as Y),
it sets the topmost master state's X, Y, last X and last Y to the corresponding numeric inputs, but more importantly,
will take the current cell in corresponding XY coordinates and set that cell's ID as topmost master state's Cell ID.

· Fill until XY - By taking 2 positions (one from topmost master state's X and Y and other from numeric inputs),
it will create a square with the 2 positions are opposite corners, and fill that square entirely with the corresponding cells with topmost master state's Cell ID.
