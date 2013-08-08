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

/*
  prusa_adapter_clamp

  This piece slides onto the two long M3 bolts to hold the hot end
  and keep it from rotating or sliding out.
*/
module prusa_adapter_clamp() {

  clamp_width = ((extraptor_v2 ? 19 : 20) - filament_path_offset) * 2;

  difference() {
    union() {
      translate([0,platform_height/2+filament_path_offset,-ed/2-clamp_thickness/2]) color([1,1,1]) {
        // Wide clamp part - will have screw holes
        translate([0,0,-clamp_gap/2]) cube([platform_height,clamp_width,clamp_thickness-clamp_gap], center=true);
        // Middle clamp part - will have a groove cut out
        translate([0,0,5-clamp_gap+(8+clamp_gap)/2]) cube([platform_height,hotend_groovemount_diameter-0.25,8+clamp_gap], center=true);
      }
    }

    // Bevel the block
    translate([0,platform_height/2+filament_path_offset,-ed/2-clamp_thickness/2]) color([1,1,1]) {
        for (y=[-22,22]) translate([0,y,-clamp_thickness/2]) rotate([y*2.5,0,0]) cube([10.1,platform_height,10], center=true);
    }

    // Groove mount
    translate([0,platform_height/2+filament_path_offset,-1.0]) {
      // Center Hole - Narrow Part, remove full height
      rotate([0,90,0]) cylinder(r=hotend_r-v2_groove_depth, h=10.01, $fn=72, center=true);
      if (extraptor_v2) {
        // Hotend hole - Wider part, remove where the groove isn't
        translate([-v2_groove_height-v2_above_groove_mm,0,0]) {
          rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
        }
        translate([5-v2_above_groove_mm/2,0,0])
          rotate([0,90,0]) cylinder(r=hotend_r, h=v2_above_groove_mm, $fn=72, center=true);
      }
      else {
        translate([-v2_groove_height,0,0]) {
          rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
        }
      }
    }

    // Mounting holes
    translate([0,platform_height/2+filament_path_offset,-ed/2]) {
        for (y=[-1,1]) {
          translate([0,y*clamp_hole_dist/2,-5]) cylinder(r=hole_3mm, h=10.1, $fn=12, center=true);
          // translate([0,y*clamp_hole_dist/2,-10+(2.2/2)]) cylinder(r=hole_3mm+1, h=2.21, $fn=12, center=true);
        }
    }

  }

} // prusa_adapter_clamp

