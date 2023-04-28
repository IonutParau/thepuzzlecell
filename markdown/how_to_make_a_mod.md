# How to make a mod

Step one is to Open the mods folder. You can open the modules folder from the Mods menu, Right next is the mods folder.
After that, create a new folder, which is going to contain the files of your mod.
There are a few files your mod will need.
The mod uses the Lua programming language, so you should also have a decent understanding in that.

## icon.png

This is the icon of the mod. There is a default one if none is specified, but it is recommended that your mod has its own icon.

## info.json

This is a file containing information about your mod. We'll cover here the type of information that can be specified.

## README.md

This is an optional file that is recommended to contain information about your mod.

## main.lua

The main entry point of your mod, this is the first file executed.

# What kind of information can be specified in info.json?

## tpcMinimumVersion

This is an optional piece of data specifying the minimum version of TPC supported.

## experimentalFlags

These are list of flags specifying they allow for experimental features. Currently, there are none.

## remoteUpdates

Defaults to auto, specifies if the game should always perform remoteUpdates or if the mod should manually request for it.

## modules

A list of modules to be loaded before the mod loads. Modules are global, shared files meant to contain libraries or compatibility layers.

## name

The name of your mod.

## desc

The description of your mod.

## author

Who you claim to have created this mod.

# What functions are available?

There is [tpc_api_docs.lua](https://github.com/IonutParau/thepuzzlecell/blob/main/extra/tpc_api_docs.lua), which is meant to bring IDE support to TPC. It defines a list of functions you can use, so your IDE knows which functions exist, and their types.

The most important function to know about is `TPC.DefineCell`, which actually defines a cell based off a specified config.
