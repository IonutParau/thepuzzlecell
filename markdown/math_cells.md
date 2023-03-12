# What are Math cells?

Math cells use the numerical system in TPC.
This means they interact with and modify numbers.

# How do they work?

To put it simply, to understand math cells you need to understand Numbers (Safe/Unsafe), Functions & Core Operations.
There are also Getters & Setters to explain stuff like _setting_ a number to a value based on a condition.

# The Basics

## Numbers (Number, Safe Number & Counter)

Number cells store a number, that can be configured in the property editor.
The number can be configured in the property editor, or by other cells.
Number cells can also be read by other cells.

_Number_ is the most basic one. This one is unsafe because the update order can cause unpredictable behavior if you try to modify the number and then use it immediately afterwards.
_Safe Number_ is the only safe number from these. Any changes to it only apply at the end of the tick, which means that its behavior is perfectly predictable at all times.
_Counter_ is a _Number_ combined with a trash cell. When something goes into it, the number increments.

## Functions

These take some amount of numbers and perform some operation.
They are all based on actual math functions, the only exceptions being Randomizer and Pseudo-Randomizer.

## Core Operations

These are like functions, but are straight up core mathematical operation.
Stuff like Multiplication, Division, Addition, etc. is found here.

# More Advanced Concepts

## Numerical Memory

The global math store consists of a 2-dimensional array.
Each spot in the array is associated with a channel and an index.
Getters and Setters manage the global math store in some way.
Getters get numbers from specified spots while Setters set numbers into specified spots.

Setters perform their subtick before Getters perform theirs.
This means that if a number is set into the global math store, Getters can get these the next tick.
