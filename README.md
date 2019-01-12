# Woolen Meshes (wesh)

An in-game mesh creator for Minetest

Developed and tested on Minetest 0.4.16 - try in other versions at your own risk :)

If you like my contributions you may consider reading http://entuland.com/en/support-entuland

WIP MOD forum thread: https://forum.minetest.net/viewtopic.php?f=9&t=20115

# Canvas recipes

All recipes can be configured in `/custom.recipes.lua`, which will get created the first time the mod gets run and will never be overwritten.

    W = any wool block
    I = inner ingredient (see list below)

    WWW
    WIW
    WWW

    wesh:canvas02 (steel ingot)
    wesh:canvas04 (copper ingot)
    wesh:canvas08 (tin ingot)
    wesh:canvas16 (bronze ingot) - wesh:canvas gives you wesh:canvas16, kept for compatibility
    wesh:canvas32 (gold ingot)
    wesh:canvas64 (diamond) read notice after the screenshot

![Canvas recipe](/screenshots/canvas-recipe.png)

The largest canvas size may likely create meshes too complex to be rendered if you try to grab too many nodes.

For that reason, there is an optional limit for the amount of captured faces. That limit can be freely altered or disabled in the capture dialog. If you don't alter that limit the game should always generate working meshes.

# How to use

Place down a Canvas block, you'll see that it extends beyond its node space marking a cube (available in sizes 2, 4, 8, 16 and 32)

The following screenshots shows a sample of how the canvases look when placed in the world (you can read the size on the top face), held in hand and in the quickbar (last slot):

![Canvas sizes](/screenshots/canvas-sizes.png)

Here is the example using the canvas with size 16 marking its capture space:

![Empty canvas](/screenshots/canvas-empty.png)

In this space you can build anything you like by using colored wool blocks or most of the built-in blocks shipped with minetest_game:

![Building inside the canvas](/screenshots/canvas-build.png)

Once you're done with your build, go to the Canvas block and right click it: you'll be asked to provide a name for your mesh (you can type any text in there, with uppercases and any symbol).

Here you can also decide whether or not to generate a backup matrix which you can later import to recreate the build, you can also specify what variants you want your mesh to be available in.

Backup matrices are additional files that record your build's nodes and colors. They can be used to rebuild the captures with the original nodes or as wool depending on their matching colors. These files can be safely omitted if you're not worried about rebuilding your creations (that is, if you don't dismantle them or if you don't care about recapturing them).

This capture interface also gives you access to the `Manage Meshes` and the `Giveme Meshes` interfaces, which will be covered later on in this documentation:

![Request for name](/screenshots/prompt-name.png)

When you confirm the name for your capture (you can cancel it by hitting the ESC key) you'll get a confirmation in the chat:

![Save confirmation](/screenshots/save-confirm.png)

Upon saving a few temporary files will be created in the `/mod_storage/wesh_temp_obj_files` subfolder in your world's folder:
- the `.obj` file will contain a model with your build scaled down to fit exactly one block
- the `.obj.dat` file will contain the original name you have chosen for your mesh, along with some other data (read the section about using custom textures below)
- if you have selected the `Generate backup matrix`, you'll also find a `.obj.matrix.dat` file which will contain a serialized version of your build which you can import later on (it only records your build's colors and importing them will result in only wool blocks getting placed at the moment)

The above files are saved there only temporarily because mods don't have writing permission in their own folder while the world is running. In order to use your new meshes in the game you need to restart the world.

During world startup the mod will move all the temporary files to the `/models` folder and will load them.

You can't have two meshes with the same name (during the saving process the mod checks both the temporary meshes that haven't been loaded yet and those that have been already moved to the mod's folder).

By default, four versions of each mesh will be available (which you can toggle in the interface for each capture).

You can optionally ignore variants and create meshes that rely on RGB colors, more about that in the [RGB Colors](#rgb-colors) section.

- plain versions: they use flat colors averaged from the colors of each wool block, with a bordered variant

![Plain version](/screenshots/version-plain.png)

![Plain bordered compare](/screenshots/plain-bordered-compare.png)

- wool versions: they will use the actual textures used by the wool blocks, with a bordered variant

![Wool version](/screenshots/version-wool.png)

![Wool bordered compare](/screenshots/wool-bordered-compare.png)

Sample of natural terrain capture:

![Non wool capture](/screenshots/non-wool-capture.png)

Collision boxes will be built automatically depending on the extent of your mesh:

![Auto collision box](/screenshots/auto-collision-box.png)

Up to 8 collision boxes will be created according to the mesh geometry allowing you to create stairs, slabs, frames, carpets and so forth, collision boxes will be merged into larger ones when fitting:

![Auto collision box 2](/screenshots/auto-collision-box-2.png)

Such new blocks can't be crafted but you can obtain as many as you want by clicking on the "Giveme Meshes" button of the capture interface, which will show you something like this (remember that you need to restart the world for new meshes to appear there):

![Giveme mesh](/screenshots/giveme-mesh.png)

The above names can be used with the `/give` and `/giveme` commands as well

If you're playing in creative mode all such meshes, including all canvases, show up if you filter for either `wesh` or `mesh`:

![Creative search](/screenshots/creative-search.png)

# RGB colors

One of the latest additions to this mod has been allowing the capture of nodes using RGB colors specified in the [/default/colors.txt](/default/colors.txt) file (duped to `/custom.colors.txt` for customization) - this file has been taken from [Minetest Mapper](https://github.com/minetest/minetestmapper/blob/master/colors.txt).

(discussion about this new RGB feature [here](https://github.com/entuland/wesh/issues/6))

Selecting the `Ignore variants, use RGB` option in the capture screen will result in a mesh using a custom palette, built on the fly, that looks like this...

```
variants = {
  rgb = "[combine:4x1:0,0=(px.png\\^[colorize\\:#42701f):1,0=(px.png\\^[colorize\\:#6c9343):2,0=(px.png\\^[colorize\\:#5f4027):3,0=(px.png\\^[colorize\\:#763018)",
},
```

...instead of the regular variants:

```
variants = {
  wool = "wool-72.png",
  plain = "plain-16.png",
  plainborder = "plain-border-72.png",
  woolborder = "wool-border-72.png",
},
```

This RGB palette is *not* compatible with the regular variants and you cannot use RGB meshes with the normal palettes - more about variants in the [Custom properties](#specifying-custom-properties) section.

If you want to have the same mesh with RBB custom palette *and* with the usual variants you need to capture it twice with different names.

# Privileges

Three separate privileges are available:
- `wesh_capture` limits the ability to create new meshes
- `wesh_place` limits the ability to place created meshes in the world
- `wesh_delete` limits the ability to delete meshes from disk
- `wesh_import` limits the ability to import builds from `.obj.matrix.dat` files
- `wesh_fill` limits the ability to fill the canvas with arbitrary nodes (including air)

All of those privileges are granted to `singleplayer` by default.

Since canvases can be crafted and since the canvas interface allows players to get meshes for free, creative mode isn't necessary in order to use this mod.

# Managing Meshes

Temporary meshes (the ones captured in the current playing session, waiting to be moved to the mod's folder) can be deleted right away from "Manage meshes" interface: *there will be NO confirmation when deleting temporary captures!*

![Delete temporary now](/screenshots/delete-temporary-now.png)

Meshes that have already been moved to the mod's folder can't be deleted right away and need to be marked for deletion:

![Mark for deletion](/screenshots/mark-for-deletion.png)

Pending deletions can be canceled:

![Cancel pending deletion](/screenshots/cancel-pending-deletion.png)

## Deletions when playing on multiple worlds

When meshes get marked for deletion that information will go into the mod's storage _associated to that specific world_ - this means that in order for deletions to happen you need to exit the world and enter _the same world again_.

Those deletions will not be performed until you enter _that_ world again.

All meshes will be finally stored in the mod's folder - this means that _all_ worlds will end up sharing the _same_ meshes. If you delete any mesh in a world it will disappear for all worlds.

# Dealing with matrices

Matrix files record only the colors of your build and as such will only use wool blocks to rebuild your creations when imported in normal mode. Other modes are explained here below.

When importing a matrix file it must match the size of the canvas you're currently interacting with. If the size doesn't match, the mod will display a message in the chat saying that and will do nothing. I plan on improving this by storing the size of the matrix itself in the filename.

You can combine different matrices together by importing them into the same canvas in sequence.

You can select three different modes to import the matrices:

- Both `Invert` and `Mononode` unchecked: the matrix will be built normally according to the original colors
- `Invert`: the negative version of the matrix will be filled with whatever node you enter in the textarea
- `Mononode`: uses the entered nodename to import the matrix instead of the original colors

`Mononode` can be checked or unchecked in `Invert` mode, it makes no difference.

![Import matrix](/screenshots/import-matrix.png)

You can also completely fill the canvas space using the `Fill/Empty Canvas` button with whatever node, including air.

![Fill canvas](/screenshots/fill-canvas.png)

Finally, matrices can be accessed and rebuilt immediately, without the need for restarting the world. This means that you can use this feature to blueprint something and rebuild it with wool blocks right away as many times as you want, then go to `Manage meshes` and delete such temporary capture to avoid adding any new meshes to your library.

[Here are some examples](/examples.md) explaining how to use some of the above features.

# Specifying custom properties
In the `.obj.dat` file of each mesh you'll find something like this:

```
return {
    description = "Your mesh name",
    variants = {
        plain = "plain-16.png",
        plainborder = "plain-border-72.png",
        wool = "wool-72.png",
        woolborder = "wool-border-72.png",
    },
}
```

(please consider that the number `16` here above indicates the size of the texture, it has nothing to do with the size of the canvas you use to capture your build)

The variants used in each `.obj.dat` file depend on the ones you select in the interface at capture time.

Default variants are stored in the file [/default/nodevariants.lua](/default/nodevariants.lua) which gets copied over to `/custom.nodevariants.lua` when starting up the mod if no such file exists.

Those variants will be the ones shown in the capture interface.

In order to add a new variant simply add a line with your texture name and make sure you save such texture file in the `/textures` folder of the mod. You can also remove the lines you're not interested in and the mod will not generate those variants.

You can do the above operation either on the `/custom.nodevariants.lua` file (it will affect all new captures) or in the `.obj.dat` file associated to each mesh (will affect only that mesh).

For example, here we remove all but the `plain` version and add a custom one:

    return {
        description = "Your mesh name",
        variants = {
            plain = "plain-16.png",
            my_texture_plain_name = "my-texture-file-name.png",
        },
    }

The above doesn't depend on variants available in `nodevariants.lua` - as long as you're using a different key name and an existing texture file you'll be fine.

Have a look at `wool-72.png` to see where each color goes, or use the included [textures-72.xcf](/textures/textures-72.xcf) file (GIMP format) which has layers for adding the borders as well.

As explained in [RGB Colors](#rgb-colors), the regular variants and the RGB custom palette are not compatible. You cannot add regular variants to the `.obj.dat` file of a mesh captured in RGB mode, and you cannot add a custom RGB palette to a mesh captured using the regular variants. If you need both modes, capture the mesh twice with different names.

You can as well override any property you would normally pass to node_register(), such as `walkable`, `groups`, `collision_box`, `selection_box` and so forth. The only property that doesn't get really overridden but just _mangled_ according to the variants is the `description` one. You shouldn't even be overriding `tiles` cause they will be built according to the `variants` property (property which is specific to this mod's `.obj.dat` files).

A couple considerations:
- the bottom-right transparent area is never used
- the used texture for each face will actually be a bit smaller (in the `wool-72.png` file the squares are 18 pixels in side, but the texture will only use a 16x16 square inside of it)
- you're not forced to use any particular size for your texture as long as it's square (I guess, let me know if you find any problems)

# Changing default colors assigned to nodes

The file [/default/nodecolors.conf](/default/nodecolors.conf) contains the `modname:nodename = color` associations for all the nodes that get loaded in a minetest_game world. This file will be copied over to `/custom.nodecolors.conf` at startup (if no such file exists); in `/custom.nodecolors.conf` you're free to alter existing colors and to add new nodes, just make sure you stick to wool colors cause any invalid color will be replaced by `air`.

In RGB mode the colors are determined by [/default/colors.txt](/default/colors.txt), which gets duped at startup to `/custom.colors.txt` for customization. This file uses a different format `modname:nodename R G B` where R, G and B are *decimal* integers ranging from zero to 255.
