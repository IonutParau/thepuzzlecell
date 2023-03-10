# What are Mechanical Cells?

Mechanical Cells are cells that use the mechanical signal system.
This means that there is a cell that creates a signal, and a cell that does something when it gets a signal.

# How can a signal be carried?

Mechanical Gears will transfer over a signal, but they have a maximum range.
If you need to carry them for longer, we recommend using some kind of signal extender.

# How do mechanical logic gates work?

They compare whether gears on their inputs are on and based on which are on will give an output as a signal in front.

**NOT takes one input (at the back) and only outputs a signal if it is off.**

**AND takes 2 inputs (left and right) and only outputs a signal if both of them are on.**

**NAND takes 2 inputs (left and right) and only outputs a signal if either none or only one of them is on.**

**OR takes 2 inputs (left and right) and only outputs a signal if one or more is on.**

**NOR takes 2 inputs (left and right) and only outputs a signal if none of them are on.**

**XOR takes 2 inputs (left and right) and only outputs a signal if only one of them is on.**

**XNOR takes 2 inputs (left and right) and only outputs a signal if none or both are on.**

**IMPLY is the opposite of NIMPLY (its to complicated to explain with words, btw, opposite just means this one is gonna be on when the other would be off and off when the other would be on).**

**NIMPLY takes 2 inputs (left and right) and only outputs a signal if the left one is on and the right one is off.**

# How do Displayers work?

You give them a signal and they will emit a Pixel signal out. When that pixel signal hits a pixel it will turn it on. You can also give it a "bias" by putting some number of placeables / biomes in front of it in a line, which will tell it how many pixels to ignore before turning on the last one.

# What can you make with Mechanical?

Basically anything! You can build a processor, a display, or just add some simple logic to a creation.
