Prusa3
======

This is my fork of Misan's modified compact extruder, specifically tailored for my setup, which includes:

 - 3mm filament
 - 11.5/10.5mm "Raptor" drive gear from QU-BD.com
 - 2engineers 50:1 geared 1Nm stepper motor
 - A pretty long TORLON hot end
 - I also use an upside-down Prusa3/mini/x-carriage.stl to get extra build height

The default settings are good for my 10.5mm diameter Raptor gear, so you'd want to adjust from there.

I made several changes to compact-extruder-2engineers.scad almost worth a pull request:

 - Consolidated code into loops where possible
 - Made the filament path distance configurable (i.e., drive gear radius plus 3mm/2)
 - Centered the idler on the gear for a better grip
 - Added build flags to render any set of parts -- or the whole assembly

My fork is sparse because Misan's fork is sparse, and we like it that way.

This repo contains my fork which is a work in progress. I'd like to chop down the extruder to a minimum size and complexity, and the idler needs some adjustment also.
