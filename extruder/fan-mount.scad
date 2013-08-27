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
  fan_sidemount
  This mounts on the front screws but hangs the fan on the side
*/
module fan_sidemount() {
  wide = clamp_hole_dist + 6;
  cylr = hole_3mm + 2.5;
  ht1 = 2.0;
  ht2 = 3.1;
  cylw = 25 - (ht2 + 2) * 2;

  // Screw mounts exactly like the front mount
  difference() {
    union() {
      // part that connects to the bolts
      rounded_cube([10, wide + 2, ht1], r=4.9, center=true);
      translate([0,wide/2-1,0]) {
        cube([10, wide/2, ht1], r=4.9, center=true);
        translate([0,2/2+4.5+1,30/2-ht1/2]) rotate([90,0,0]) {
          cube([10, 30, ht1], r=4.9, center=true);
          translate([0,13,0]) rounded_cube([10, 38-20, ht1], r=4.9, center=true);
        }
      }
    }
    for (x=[-1,1]) translate([0,x*clamp_hole_dist/2,0]) rotate([0,0,0]) cylinder(r=hole_3mm, h=ht1+0.1, center=true);
  }
}

/*
  fan_mount
  This mounts on the front screws
*/
module fan_mount(mode=3) {
  wide = clamp_hole_dist + 6;
  cylr = hole_3mm + 2.5;
  ht1 = 2.0;
  ht2 = 3.1;
  cylw = 16 - (ht2 + 1) * 2;
  do_part1 = mode % 2;
  do_part2 = mode > 1;

  // Hinge for the Prusa
  if (do_part1) difference() {
    union() {
      // part that connects to the bolts
      rounded_cube([10, wide + 2, ht1], r=4.9, center=true);

      // Extender
      translate([-5,0,-2.3]) rotate([0,-72,0]) {
        cube([6.2, cylw, ht1], center=true);
        rotate([0,10,0]) cube([6.2, cylw, ht1], center=true);
      }
      translate([-6.3,0,-4.4]) rotate([0,-72+32,0]) cube([2, cylw, 2.5], center=true);
      translate([-5.3,0,-4.4]) rotate([0,-20,0]) cube([2, cylw, 2], center=true);
      translate([-6.5,0,-8]) rotate([90,0,0]) hollow_cylinder(r2=hole_3mm, r1=cylr, h=cylw-0.2, center=true);
    }
    for (x=[-1,1]) translate([0,x*clamp_hole_dist/2,0]) rotate([0,0,0]) cylinder(r=hole_3mm, h=ht1+0.1, center=true);
  }

  // Connect to the fan
  if (do_part2) translate(draw_assembled ? [-11.4,0,-11.6] : [0,0,0]) {
    rotate([0,35,0]) {
      difference() {
        union() {
          rounded_cube([cylr*2,40+4.1*2,ht1], r=4.1, center=true);
          for (x=[-1,1]) {
            // translate([0,x*20,0]) cylinder(r=cylr, h=ht1, center=true);
            translate([2,x*(cylw+ht2+0.4)/2,cylr+ht1/2+0.5]) {
              rotate([90,0,0]) cylinder(r=cylr, h=ht2, center=true);
              translate([-1,0,-cylr/2-1]) cube([cylr*2-2,ht2,cylr+2], center=true);
            }
          }
        }
        for (x=[-1,1]) {
          translate([0,x*20,0]) cylinder(r=hole_3mm, h=ht2+0.1, center=true);
          translate([2,x*(cylw+ht2+0.4)/2,cylr+ht1/2+0.5]) rotate([90,0,0]) {
            cylinder(r=hole_3mm, h=ht2+0.1, center=true);
            if (x==1 && ht2 > 3) translate([0,0,-ht2/2-0.1]) rotate([0,0,22.5]) cylinder(r=hole_3mm+1.5, h=1.5, $fn=6);
          }
        }
      }
      // Dummy fan
      if (draw_assembled) translate([-20,0,-(12+ht1)/2]) %fan_dummy();
    }
  }

}

