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
  fan_duct
  This mounts on the bottom fan screws
*/
module fan_duct(side=false) {
  cylr = hole_3mm + 2.5;
  ht1 = 1.5;
  accel = 5;
  detail = 6;

  // Mount to bottom of fan
  difference() {
    // Fan bottom mount
    rounded_cube([cylr*2,40+4.3*2,ht1], r=cylr-0.1, center=true);
    // M3 Bolt holes
    for (x=[-1,1]) translate([0,x*20,0]) cylinder(r=hole_3mm, h=ht1+0.05, center=true);
    // Cut out the middle hole
    translate([20,0,0]) cylinder(r=22,h=ht1+0.05, center=true);
  }
  translate([20,0,0]) {
    difference() {
      for (v=[0:13.4*detail],m=[-1,1]) assign(vv=v/detail) {
        intersection() {
          translate([vv/6,m*vv*(accel+1),vv*ht1]) hollow_cylinder(r1=23+vv*accel,r2=23+vv*accel-ht1,h=ht1, center=true);
          translate([-4,-m*23,10]) {
            intersection() {
              cube([38,46,30], center=true);
              translate([-5,0,-5]) rotate([0,-35,0]) cube([50,46,40], center=true);
            }
          }
        }
      }
      // Remove area around hotend to clean up this part
      translate([-24,0,18]) rotate([0,90-35,0]) cylinder(r=hotend_r*2-2, h=40, $fn=36, center=true);
    }
  }

  // One side funnel, mirror both ways
}

