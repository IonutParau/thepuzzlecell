# Texture Packs Guide

This markdown file is to help with making or installing texture packs.

# What is a texture pack?

A texture pack is how you can change textures of cells

# How do I install a texture pack?

If it's a ZIP file, step 0 is to extract it into a folder.
Make sure that folder contains a `pack.json` file!

Then, simply move that folder in the folder for texture packs.

# Where is this folder for texture packs?

Next to the executable of the game there is a `data` folder, inside is a `flutter_assets` folder, inside of that is an `assets` folder, inside of that is an `images` folder, and then, finally, the `texture_packs` folder inside is where you gotta move the folder.

# How do I enable it?

You don't, the game will automatically load all the texture packs together.

# How do I make one?

"I have epic texture style I wanna make"

There are 2 ways, the simple way and advanced way.

## What is the simple way?

"I don't want it to be hard, I wanna do the simple way"

Ok, remember that `images` folder? Copy it.
Then, paste it somewhere. We're gonna turn it into a texture pack.

Inside of it, we're gonna make a `pack.json` file.

Inside of that `pack.json` file, add this code:

```json
{
  "autoDetect": true
}
```

This tells it to automatically match it.

Please note: Not all cells work with this method. Sometimes, you have to rename some of the images to match the ID of the cell.

### What are the issues with this method?

Well, unless if you delete the files you didn't change, they might undo the changes of other texture packs due to conflicts and restore the vanilla look.

Also, you can't rename the files, as they have to match the ID of the cell for `autoDetect` to find them.

## What is the advanced way?

Make a folder, make the textures, name the files whatever you want, then in your `pack.json`, do:

```
{
  "id of cell": "path/to/texture.png"
}
```

### What are the issues with this method?

For each cell you have to specify where the texture is.

## Can I combine them?

Yes! You can combine them to get the best of both worlds. `autoDetect` only matches by file name with the cell who's ID is the same, so for `mover` you'd have to do `mover.png`. If, for example, the ID is too weird for you, you can use the advanced way to name it, whatever you want. In both cases, folder structure doesn't matter.

## Do I HAVE to use JSON? Seems confusing

Nope, you can use TOML or YAML. Just make sure the file name is correct.
For TOML that would be `pack.toml` and for YAML that would be `pack.yaml`.
