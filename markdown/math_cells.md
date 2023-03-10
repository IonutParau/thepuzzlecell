# What are Math cells?

Math cells use the numerical system in TPC.
This means they interact with and modify numbers.

# How do they work?

To put it simply, to understand math cells you need to understand Numbers (Safe/Unsafe), Functions & Core Operations.
There is also Getters & Setters to explain stuff like _setting_ a number to a value based on a condition.

# The Basics

## Numbers (Number, Safe Number & Counter)

Numbers store a number, that can be configured in the property editor.
The number can be configured in the property editor, or by other cells.
It can also be read by other cells and thus be useful.

_Number_ is the most basic one. This one is unsafe because the update order can cause unpredictable behavior if you try to modify the number and then use it immediately afterwards.
_Safe Number_ is the only safe number from these. Any changes to it only apply next tick, which means that its behavior is perfectly predictable at all times.
_Counter_ is like _Number_ but a trash cell. When something goes into it, the number increments.

## Functions

These take some amount of numbers and perform some operation.
They are all based on actual math functions, the only exceptions being RNG and PRNG.

## Core Operations

These are like functions, but are straight up core mathematical operation.
Stuff like Multiplication, Division, Addition, etc. is found here.

# More Advanced Concepts

## Getters

When a cell reads a number, it uses a "getter".
Cells that manage Memory use this to not store the number in themselves, but rather somewhere else, yet have it behave like a regular number.

## Setters

When a cell modifies a number, it uses a "setter". By using tunnels, pistons and some mechanical, you can optionally block this. This can be used to set numbers to values based on conditions (preferably, you should use Safe Numbers when dealing with this)
Cells that manage Memory use this to modify the number in the grid's memory channels.
