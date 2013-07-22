Prusa3
======

This is my fork of Misan's modified compact extruder, specifically tailored for my setup, which includes:

 - 3mm filament
 - 11.5/10.5mm "Raptor" drive gear from QU-BD.com
 - 2engineers 50:1 geared 1Nm stepper motor
 - A pretty long TORLON hot end
 - Prusa3/mini/x-carriage.stl in the inverted-T position (for extra build height)

The default settings are good for my 10.5mm/11.5mm diameter Raptor gear and a pretty long hot end, so adjust accordingly.

I made several changes to compact-extruder-2engineers.scad almost worth a pull request:

 - Consolidated code into loops where possible
 - Made the filament path distance configurable (i.e., drive gear radius plus 3mm/2)
 - Made many parameters tunable for easier customization
 - Centered the idler on the gear for a better grip
 - Added build flags to render any set of parts -- or the whole assembly
 - Added build options for the inverted Prusa i3 "mini" x-carriage

The 'merge_extruder' option creates an extruder that mounts onto the back part with two long M3 screws and uses the same front clamp piece with two M3 nuts and washers. This is the design variant of choice for a groove mount hot end.

My fork is sparse because Misan's fork is sparse, and we like it that way.
