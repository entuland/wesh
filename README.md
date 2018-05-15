# Woolen Meshes (wesh)
An in-game mesh creator for Minetest

Developed and tested on Minetest 0.4.16 - try in other versions at your own risk :)

If you like my contributions you may consider reading http://entuland.com/en/support-entuland

# Recipe for the Canvas block

    wesh:canvas
    
    W = any wool block
    B = bronze ingot
  
    WWW
    WBW
    WWW

![Canvas recipe](/screenshots/canvas-recipe.png)

# How to use
Place down a Canvas block, you'll see that it extends beyond its node space marking a 16x16x16 space.

![Empty canvas](/screenshots/canvas-empty.png)

In this space you can build anthing you like by using colored wool blocks.

![Building inside the canvas](/screenshots/canvas-build.png)

Once you're done with your build, go to the Canvas block and right click it: you'll be asked to provide a name for your mesh (you can type any text in there, with uppercases and any symbol).

![Request for name](/screenshots/prompt-name.png)

When you confirm such name (you can cancel it by hitting the ESC key) you'll likely get a confirmation like this:

![Save confirmation](/screenshots/save-confirm.png)

If you confirm the name by hitting ENTER you may not be presented with the above confirmation. It will appear in the chat as well just in case.

Upon saving a few temporary files will be created in the "/modstorage/wesh" subfolder in your world's folder:
- the .obj file will contain a model with your build scaled down 16 times (so that it will occupy only one block)
- the .dat file will contain the original name you have chosen for your mesh, along with some other data (read the section about using custom textures below)
- the .matrix.dat file will contain a serialized version of your build, that may eventually get used to rebuild / reimport it in the game allowing you to alter it (right now you can't import them, so make sure you don't dismantle your build if you want to alter and capture it again)

The above files are saved there only temporarily because mods don't have writing permission in their own folder while the world is running. In order to use your new meshes in the game you need to restart the world.

During world startup the mod will move all the temporary files to the "/models" folder and will load them.

By default, two versions of each mesh will be available:
- plain version: it uses flat colors averaged from the colors of each wool block
![Plain version](/screenshots/version-plain.png)

- wool version: it will use the actual textures used by the wool blocks
![Wool version](/screenshots/version-wool.png)

Such new blocks can't be crafted (I plan to make sort of a crafting station where you put some material and chose the model you want to craft), so you either need to give them to yourself or to find them in the Creative inventory. All such meshes show up if you filter for either "wesh" or "mesh".

![Creative search](/screenshots/creative-search.png)

Looking at the filename (or knowing how the name gets converted) you can also work out the actual nodename to be used in your "/give" or "/giveme" chat command, for example:
- chosen name: "Test One!"
- resulting filename: "mesh_test_one.obj"
- resulting nodename: "wesh:mesh_test_one"

# Using custom textures
In the .dat file of each mesh you'll find something like this:
    return {
        description = "Your mesh name",
        variants = {
            wool = "wool-72.png",
            plain = "wool-16.png",
        },
    }

In order to add a new variant simply add a line with your texture name and make sure you save such texture file in the "/textures" folder of the mod. You can also remove the lines you're not interested in and the mod will not generate those variants.

For example, here we remove the "wool" version and add a custom one:

    return {
        description = "Your mesh name",
        variants = {
            plain = "wool-16.png",
            my_texture_plain_name = "my-texture-file-name.png",
        },
    }

Have a look at "wool-72.png" to see where each color goes.

A couple considerations:
- the bottom-right transparent area never gets used
- the used texture for each face will actually be a bit smaller (in the "wool-72.png" file the squares are 18 pixels in side, but the texture will only use a 16x16 square inside of it)
- you're not forced to use any particular size for your texture as long as it's square (I guess, let me know if you find any problems)
