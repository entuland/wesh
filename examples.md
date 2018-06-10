# Matrix Rebuild Examples

In order to use these techniques you need to leave the `Generate matrix` checkbox ticked when capturing with the canvas - generated meshes can only be used after restarting the world and only as standalone nodes; matrices can be reimported immediately but you need to make sure you generate them with the above option.

## Simple hollow / replace

You can place a canvas and rotate it face down to operate on the ground:

![Head down](/screenshots/examples/head-down.png)

You can either fill everything with air:

![Filled with air](/screenshots/examples/filled-with-air.png)

Or whatever else you prefer, such as water (`default:water_source`)

![Filled with water](/screenshots/examples/filled-with-water.png)

## Replace all captured blocks with a different one

Another thing you can do is overwrite portions of terrain with whatever block, in this case I'm about to grab the top of a hill with a couple acacias with the canvas of size 64:

![Lonely acacias](/screenshots/examples/lonely-acacias.png)

Such captures are immediately available as matrices to be imported, in fact I've just reimported the above capture using `Mononode` mode with `default:ice`:

![Frozen acacias](/screenshots/examples/frozen-acacias.png)

Grass hasn't been replaced cause it hasn't been grabbed at all. I could have got rid of them by first filling the entire canvas with `air` and then rebuilding the captured terrain.

Once you're done with a temporary capture you can get immediately get rid of it:

![Delete temporary](/screenshots/examples/delete-temporary-capture.png)


## Carving tunnel sections

When using nodes of the same type and carving / hollowing stuff out, it doesn't really matter if you start with the positive or the negative versions of your build.

In this case I fill a cube of size 8 with wool:

![Wool cube](/screenshots/examples/wool-cube.png)

Then I carve out the tunnel section with a shape I can repeat and I capture it:

![Carved wool cube](/screenshots/examples/carved-wool-cube.png)

Once I have the above capture ready I can go underground and reimport it in `Invert` mode using `air` as nodename:

![Hollow matrix with air](/screenshots/examples/hollow-matrix-with-air.png)

The above action gives me the first tunnel section where I added some torches:

![First tunnel section](/screenshots/examples/first-tunnel-section.png)

At that point I can place down the canvas in different positions to continue digging the tunnel in the same way making sure the canvas itself is placed properly. After having carved six sections and adding torches this is the result:

![Multiple tunnel sections](/screenshots/examples/multiple-tunnel-sections.png)

I could have as well emptied the whole canvas range by filling it with `air` then I could have rebuilt the section in `Mononode` mode using `default:cobble` or whatever other node.

## Simple staircase heading down

Here I placed down a canvas of size 8 and I rotated it face down, then I filled the whole canvas range with `default:cobble` to ensure sand doesn't crumble down on me, then I dug a simple staircase heading down till the bottom edge of the canvas and I've grabbed the whole thing:

![Staircase down](/screenshots/examples/staircase-down.png)

Due to the inclination of the staircase matching the diagonal of the cube, carving the next section at the end of the first one would result in some filled ceiling which I would need to dig separately.

Instead I place the canvas midway, rotate it properly and import the capture I've just grabbed in `Invert` mode, leaving `air` as nodename:

![Halfway staircase one](/screenshots/examples/halfway-staircase-one.png)

From there on I can repeat the same action using the bottom edge of the previous canvas to decide where to place the next one:

![Halfway staircase two](/screenshots/examples/halfway-staircase-two.png)
