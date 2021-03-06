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
  prusa_compact_adapter

  This is adapted for the inverted-T x-carriage, my own eccentricity. This brings
  the nozzle up to add some vertical space, and forward 6mm.

  This part dovetails with the compact extruder body. It can mount either
  through the back or through the bottom with two M3 screws. Set
  rear_mounting according to preference.

  There is a groove setting, but it's optional. The clamp piece that you screw on
  with two M3 nuts has more than enough hold to keep the nozzle in place.
  Since the top 1cm of the nozzle will be in direct contact with the plastic
  you have to print this in ABS, nylon, PEEK, etc. Be sure to cool the heat barrier
  with a fan as close to the heater block as possible.
*/
module prusa_compact_adapter(mode=1) {

  mount_w = extraptor_v2 ? 48 : 50;
  less_w = mount_w - (do_chop?4:0);
  mount_x = 16 + (platform_height - mount_length) / 2;
  mount_z = 12 + mount_thickness / 2;
  b_dist = (18 - (45 - mount_length) / 2);

  do_solid = (mode != 3);
  do_platf = (mode != 2);
  do_back = (mode == 1 || mode == 2);

  difference() {
    if (do_solid) union() {

      if (do_platf) // draw platform modes 0,1
        translate([(extraptor_v2 ? v2_merge_amount : -platform_y_offset),0,0]) color([0,0,1]) cube([platform_height,mount_w,ed], center=true);

      // draw the back part
      if (do_back) {
        if (do_high_mount) {
          translate([mount_x-3.5,-0.25,mount_z]) {
            rounded_cube([mount_length-7, less_w-7.5, mount_thickness], r=corner_radius-2, center=true, $fn=36);
            translate([5,-5,0]) cube([mount_length-7-10, less_w-7.5-10, mount_thickness], center=true);
          }
        }
        else {
          translate([mount_x,0,mount_z])
            rounded_cube([mount_length, less_w, mount_thickness], r=corner_radius, center=true, $fn=36);
        }
      }
      if (do_platf && !extraptor_v2) {
        // Angled Ends
        for (y=[-25.6,27.6]) {
          translate([(extraptor_v2 ? 0 : -platform_y_offset),y,0]) rotate([0,0,45]) cube([17,17,ed], center=true);
        }
      }
      // Top Screw Mount Plate
      if (do_back) assign(topd=do_high_mount?6:3) {
        color([1,1,1])
          translate([mount_x - b_dist + 36,-12,mount_z+(mount_thickness-topd)/2]) {
            if (do_high_mount) {
              hull() {
                cylinder(r2=hole_3mm+1.5, r1=hole_3mm+4.5, h=topd, center=true);
                translate([-8,8.6,0]) cube([1,(hole_3mm+4.6)*2+17.3,topd], center=true);
              }
            }
            else
              cylinder(r=hole_3mm+5, h=topd, center=true);
          }

        // Connection for the high connected mount
        if (do_high_mount) {
          // (mount_w-(do_chop?4:0)-4-8)/2
          translate([mount_x,0,mount_z]) intersection() {
            translate([-mount_length/4,-0.25,-mount_thickness/2-ed/2]) {
              for (y=[-1,1]) intersection() {
                translate([6.5,0,0]) rounded_cube([mount_length-7, less_w-7.5, ed], r=corner_radius-2, center=true, $fn=36);
                translate([0,y*13.5,0]) cube([mount_length/2+5,9,ed], center=true);
              }
            }
            union() {
              translate([0,0,-3.5])
                rotate([0,30,0])
                  cube([38,less_w,18], center=true);
              translate([5,0,-9.5])
                rotate([0,65,0])
                  cube([28,less_w,18], center=true);
            }
          }
        }

      }

    } // union

    union() {

      if (do_platf) translate([(extraptor_v2 ? v2_merge_amount : -platform_y_offset),0,0]) {
        for (y=[-1,1]) {
          // platform screw holes
          if (!rear_mounting && !extraptor_v2) {
            translate([0,y*20,0]) rotate([0,90,0]) cylinder(r=hole_3mm, h=platform_height + 10, $fn=18, center=true);
            translate([-4,y*20,0]) rotate([0,90,0]) cylinder(r=hole_3mm+1.5, h=3, $fn=12, center=true);
          }
          // end choppers
          translate([0,y*40,0]) cube([30,30.01,ed+0.01], center=true);
          // bottom chopper
          translate([-5-platform_height/2,y*30,0]) cube([10,30,ed+0.01], center=true);
        }
        // Groove mount
        translate([0,platform_height/2+filament_path_offset,-1.0]) {
          // Groove - Narrow Part
          translate([0,0,-7.5]) {
            cube([10.01,hotend_groovemount_diameter-v2_groove_depth*2,15], center=true);
            translate([0,0,6.5-10/2]) cube([10.01,hotend_groovemount_diameter,10.01], center=true);
          }
          // Hotend Hole - Remove Narrow
          rotate([0,90,0]) cylinder(r=hotend_r-v2_groove_depth, h=10.01, $fn=72, center=true);
          translate([0,0,-7.5]) cube([10.01,hotend_groovemount_diameter+0.3,15], center=true);
          // Remove Non-Groove Parts
          if (extraptor_v2) {
            // Hotend hole - Wider part, remove where the groove isn't
            translate([-v2_groove_height-v2_above_groove_mm,0,0]) {
              rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
            }
            // Remove the area above the groove
            translate([5-v2_above_groove_mm/2,0,0])
              rotate([0,90,0]) cylinder(r=hotend_r, h=v2_above_groove_mm, $fn=72, center=true);
          }
          else {
            // Make the groove flush with the top for non-merged
            translate([-v2_groove_height,0,0]) {
              rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
            }
          }
        }
      } // do_platf

      // Front-to-back long mounting holes & traps
      if (do_high_mount) {
        // Make holes and traps for front-mounting on the v2 extruder
        // ...keeping the clamp but without any rear mount through-holes.
        translate([ (extraptor_v2 ? v2_merge_amount - (do_back ? platform_y_offset : 0) : -platform_y_offset),
                    platform_height/2+filament_path_offset-(do_chop&&mode==2?5+filament_path_offset:0),
                    5]) {
          for (y=[-1,1]) {
            translate([0,y*clamp_hole_dist/2,0]) cylinder(r=hole_3mm, h=ed+platform_height+0.02, $fn=12, center=true);
            translate([0,y*clamp_hole_dist/2,(ed+platform_height)/2-3.5-2.2]) cylinder(r=hole_3mm+1.5, h=40, $fn=6, center=true);
          }
        }
      }
      else {
        translate([ (extraptor_v2 ? v2_merge_amount - (do_back ? platform_y_offset : 0) : -platform_y_offset),
                    platform_height/2+filament_path_offset-(do_chop&&mode==2?5+filament_path_offset:0),
                    5]) {
          for (y=[-1,1]) {
            translate([0,y*clamp_hole_dist/2,0]) cylinder(r=hole_3mm, h=ed+platform_height+0.02, $fn=12, center=true);
            translate([0,y*clamp_hole_dist/2,(ed+platform_height)/2-3.5-2.2]) cylinder(r=hole_3mm+1.5, h=3.51, $fn=12, center=true);
          }
        }
      }

      if (do_back) {

        // Mount Screw Holes
        for (x=(rear_mounting ? [-1,1] : [-1]), y=[-1,1]) {
          translate([mount_x + b_dist * x, 12 * y, mount_z - (do_high_mount ? mount_thickness/2 : 0)]) {
            cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
            translate([0,0,x*mount_thickness/2]) {
              cylinder(r=hole_3mm + 1.75, h=8, $fn=18, center=true);
              if (do_high_mount) translate([-4,0,0]) cube([2*(hole_3mm+1.75),mount_thickness+1,8], center=true);
            }
          }
        }
        // Top screw hole
        translate([mount_x - b_dist + 36,-12,mount_z]) {
          cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
          if (!do_high_mount)
            translate([0,0,-mount_thickness/2]) cylinder(r=hole_3mm+2.5, h=6, $fn=18, center=true);
        }
        // Save material
        translate([(extraptor_v2 ? -8 : -16)-platform_y_offset,0,15]) {
          cube([22.01, do_high_mount?18:12, mount_thickness+20], center=true);
          if (!do_high_mount)
            for (y=[-1,1]) translate([-1,y*15,-mount_thickness/2]) rotate([y*278,0,0]) cube([22,5,22],center=true);
        }

      } // do_back

    } // union

  } // difference

  if (draw_assembled) {
    // Front-to-back long screws for show
    if (do_back)
      translate([(extraptor_v2?v2_merge_amount:0)-platform_y_offset, platform_height/2+filament_path_offset-(do_chop?5+filament_path_offset:0), 5])
        for (y=[-1,1])
          translate([0,y*clamp_hole_dist/2,11]) %bolt(h=45);

    // Nozzle Cylinder
    if (do_platf && extraptor_v2)
      translate([v2_merge_amount+5-v2_above_groove_mm/2-50,platform_height/2+filament_path_offset,-1.0]) {
        rotate([0,90,0]) %cylinder(r=hotend_r, h=v2_above_groove_mm + 50, $fn=36);
      }

  }

} // prusa_compact_adapter

