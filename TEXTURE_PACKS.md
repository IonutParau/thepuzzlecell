# Texture Packs Guide

This markdown file is to help with making or installing texture packs.

# What is a texture pack?

A texture pack is how you can change textures of cells

# How do I install a texture pack?

Go to the Texture Packs UI and click Install from File.
Then select a zip containing the contents of the texture pack.

# Where are they stored?

Next to the executable of the game there is a `data` folder, inside is a `flutter_assets` folder, inside of that is an `assets` folder, inside of that is an `images` folder, and then, finally, the `texture_packs` folder inside is where texture packs are stored.

If you create a texture pack, it'll also be located there.

# How do I enable it?

You don't, the game will automatically load all the texture packs together (except for the disabled ones).
You can disable it in the Texture Packs menu if you so choose.

# How do I make one?

You can go to the Texture Packs menu and click "Create".
You can specify an ID and then a title.

There are 2 ways, the simple way and advanced way.

## What is the simple way?

"I don't want it to be hard, I wanna do the simple way"

Ok, remember that `images` folder? Copy it.

Then, paste it in your texture pack folder (its located where texture packs are stored, and its name should be the texture pack's ID)

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

(Please note: The Modify button next to texture packs can automate this step by copying over the file and putting it into the pack.json)

### What are the issues with this method?

For each cell you have to specify where the texture is.

## Can I combine them?

Yes! You can combine them to get the best of both worlds. `autoDetect` only matches by file name with the cell who's ID is the same, so for `mover` you'd have to do `mover.png`. If, for example, the ID is too weird for you, you can use the advanced way to name it, whatever you want. In both cases, folder structure doesn't matter.

## Do I HAVE to use JSON? Seems confusing

Nope, you can use TOML or YAML. Just make sure the file name is correct.
For TOML that would be `pack.toml` and for YAML that would be `pack.yaml`.
