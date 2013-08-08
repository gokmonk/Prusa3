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

//
// Utility Functions
//

module hollow_cylinder(r1=1,r2=1,h=1,center=false) {
  difference() {
    cylinder(r=r1,h=h,center=center);
    cylinder(r=r2,h=h+0.05,center=center);
  }
}

module rounded_cube(size=[1,1,1], r=0, center=false) {
  d = r * 2;
  minkowski() {
    cube([size[0]-d,size[1]-d,size[2]], center=center);
    cylinder(r=r, h=0.01, center=true);
  }
}

module bolt(r=1.5, h=15) {
  translate([0,0,-h/2]) {
    cylinder(r=r, h=h, center=true);
    translate([0,0,h/2+0.5]) cylinder(r1=r+1,r2=r+0.5, h=1, center=true);
  }
}

module bearing608() {
  difference() {
    cylinder(r=11, h=7, center=true);
    cylinder(r=4, h=7.01, center=true);
  }
}
