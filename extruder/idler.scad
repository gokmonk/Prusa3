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
  extruder_idler_base
  extruder_idler_holes

  Set idler_bearing_offset above to 0 for standard through-axle, or
  increase it to move the axle and bearing closer to one side. With
  an open axle groove you might want to make the bearing holder
  wider to get more leverage.
*/
module extruder_idler_base() {
  roundness = 4;
  translate([idler_w/2,idler_h/2+(do_hinge ? motor_lowness/2 : motor_lowness),idler_thickness/2]) {
    // translate([0,1]) cube([1,10.5,50], center=true);
    rounded_cube([idler_w,idler_h-(do_hinge ? motor_lowness : 0),idler_thickness], r=roundness, center=true);
    if (do_hinge) {
      translate([0,(idler_h+10-motor_lowness)/2]) {
        difference() {
          union() {
            rotate([0,90,0]) cylinder(r=idler_thickness/2, h=idler_hinge_width, center=true);
            translate([0,-10/2,0]) cube([idler_hinge_width,10,idler_thickness], center=true);
          }
          rotate([0,90,0]) cylinder(r=hole_3mm, h=idler_hinge_width + 0.01, center=true);          
        }
      }
    }
  }
}
module extruder_idler_holes() {
  axle_diam = 8.1;
  hole_r = 1.5+0.3;
  translate([idler_w/2,20+motor_lowness,idler_thickness/2]) {
    // Main cutout
    // cube([10.5,21,12], center=true);
    translate([0,0,idler_bearing_offset]) {
      // round cutout around the bearing
      rotate([0,90,0]) cylinder(r=radius608zz+1, h=10.5, $fn=72, center=true);
      // Idler shaft
      rotate([0,90,0]) cylinder(r=axle_diam/2, h=idler_w-idler_axle_inset, center=true);
      if (idler_bearing_offset > 0)
        translate([0,0,axle_diam/2]) cube([idler_w-idler_axle_inset,axle_diam-0.4,axle_diam], center=true);
    }
    // Screw holes
    for (x=[-1,1],y=do_hinge?[-1]:[-1,1]) translate([x*5,y*15,0]) {
      cylinder(r=hole_r, h=12, center=true);
      if (do_hinge) translate([0,-3,0]) cube([hole_r*2,6,20], center=true);
    }
  }
}


/*
  idler

  This part uses four M3 bolts and optional springs to press
  a roller bearing against the filament and MK7 gear. Pressure should
  be enough to hold the filament against the gear but not so much that
  it distorts the filament. Retraction needs to be able to work.
*/
module idler() {
  color([1,0.8,0.7])
    difference() {
      extruder_idler_base();
      extruder_idler_holes();
    }
    // If showing assembled draw bolts, bearing, etc.
    if (draw_assembled) {
      %translate([10,20+motor_lowness,0]) {
        for (x=[-1,1],y=do_hinge?[-1]:[-1,1]) translate([x*5,y*15,0]) rotate([180,0,0]) bolt(h=25);
        translate([0,0,idler_thickness/2+idler_bearing_offset])
          rotate([0,90,0]) {
            // 608ZZ Bearing
            bearing608();
            // Bearing Axle
            cylinder(r=4, h=idler_w-idler_axle_inset, center=true);
          }
      }
    }
}


