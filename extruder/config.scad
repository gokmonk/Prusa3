//
// PRUSA iteration3
// Compact extruder
// GNU GPL v3
// Josef Průša <iam@josefprusa.cz> and contributors
// http://www.reprap.org/wiki/Prusa_Mendel
// http://prusamendel.org
//
// [misan]      modify for 2engineers 50:1 geared stepper motor
// [thinkyhead] reduce size, add mounting options, parameterize
//

$fn = 36;

// The V2 extruder has the clamped groove mount and reduced size
extraptor_v2 = true;

// Which parts to show
draw_extruder = true;
draw_idler = true;
draw_clamp = true;
draw_mount = true;
draw_fan_mount = true;
draw_fan_duct = true;   // for the hinged fan at about 35°

draw_fan_sidemount = false; // incomplete

// V2 has a hinged idler option
hinged_idler = true;
idler_hinge_width = 10; // width of the centered hinge
idler_hinge_gap = 0.2;  // gap around the hinge
idler_hinge_radius = radius3mm + 3.0; // radius of the mounts on the extruder

// Extra V1-only options
rear_mounting = false;   // V1 can have rear-mounting holes spaced 24mm apart
bottom_mounting = false; // V1 may keep bottom mounting holes when there are rear holes

hotend_groovemount_depth = 8; // Depth of the hot end mount part
hotend_hole_depth = 6;        // depth of the round hot end hole
hotend_groovemount_diameter = 15.88 + 0.2;

filament_radius = radius3mm + 0.5;
filament_path_offset = 0.5; // 0.25 okay for Raptor (5.25mm groove radius / 5.5mm full radius)

// The filament gear on the motor
gear_radius = 10.5;
gear_height = 11;

platform_height = 10;
extruder_body_width = 23;
extruder_depth = 24; // front-to-back extruder size

// V2 groove dimensions
v2_above_groove_mm = 4.7;   // space above the hotend groove
v2_groove_height = 3;          // height of the groove
v2_groove_depth = 1;           // depth of the groove

mount_length = 40;
mount_thickness = 6;
corner_radius = extraptor_v2 ? 10 : 15;
platform_y_offset = 0;

//
// Idler options
//
idler_w = 20;
idler_h = 40;
idler_axle_inset = 2.6;
idler_thickness = 8 + 3;  // room for an M8 rod and a little more
idler_bearing_offset = 3; // how far to move the rod off-center, adding a groove

//
// Clamp options
//
clamp_hole_dist = extraptor_v2 ? 24 : 22;
clamp_thickness = 10;
clamp_gap = 1.5;       // This gives room to tighten the clamp

//
// Experimental
//
v2_merge_amount = 8;       // how much the platform area moves up into the extruder
v2_chopchop = true;  // minimize the base of the extruder

// Shorthand and calculated variables
ed = extruder_depth;
hotend_r = hotend_groovemount_diameter / 2;
do_chop = extraptor_v2 && v2_chopchop;
do_hinge = extraptor_v2 && hinged_idler;
motor_lower = extraptor_v2 ? 6 : 1.5;
motor_lowness = (rear_mounting && motor_lower > 1.5) ? 1.5 : motor_lower;

