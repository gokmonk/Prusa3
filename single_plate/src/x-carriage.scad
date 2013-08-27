// PRUSA iteration3
// X carriage
// GNU GPL v3
// Josef Průša <iam@josefprusa.cz> and contributors
// http://www.reprap.org/wiki/Prusa_Mendel
// http://prusamendel.org

include <../configuration.scad>
use <inc/bearing.scad>

module x_carriage_base() {
  // Small bearing holder
  translate([-33/2,+2,0]) rotate([0,0,90]) horizontal_bearing_base(1);
  hull() {
    // Long bearing holder
    translate([-33/2,x_rod_distance+2,0]) rotate([0,0,90]) horizontal_bearing_base(2);
    // Belt holder base
    translate([-36,20,0]) cube([39,16,17]);
  }
     // Base plate
  translate([-38,-11.5,0]) cube([39+4,68,7+1.5]);
}

module x_carriage_beltcut(){
  position_tweak = -0.3;
  // Cut in the middle for belt
  translate([-2.5-16.5+1,19,7]) cube([4.5,13,15]);
  // Cut clearing space for the belt
  translate([-39,5,7]) cube([50,13,15]);
  // Belt slit
  translate([-50,21.5+10,6]) cube([67,1,15]);
  // Smooth entrance
  translate([-56,21.5+10,14]) rotate([45,0,0]) cube([67,15,15]);
  // Teeth cuts
  for (i=[2:25])
    translate([10-i*belt_tooth_distance+position_tweak,21.5+8.75,6.5]) cube([1.25,2,15]);
}

module x_carriage_holes(){
  // Top hole to make it work like the mini carriage
  translate([-16.5+12,24+36,-1+8]) cylinder(r=1.7+2, h=20, $fn=32);
  translate([-16.5+12,24+36,-1]) cylinder(r=1.7, h=20, $fn=32);

  // Small bearing holder holes cutter
  translate([-33/2,2,0]) rotate([0,0,90]) horizontal_bearing_holes(1);
  // Long bearing holder holes cutter
  translate([-33/2,x_rod_distance+2,0]) rotate([0,0,90]) horizontal_bearing_holes(2);
  // Extruder mounting holes
  translate([-16.5+15,24,-1]) cylinder(r=1.7, h=20, $fn=32);
  translate([-16.5+15,24,10]) cylinder(r=3.3, h=20, $fn=6); 
  translate([-16.5-15,24,-1]) cylinder(r=1.7, h=20, $fn=32);
  translate([-16.5-15,24,10]) cylinder(r=3.3, h=20, $fn=6); 	

  // Inner holes
  for(x=[12,-12],v=[[-1,1.7,32],[10,3.3,6]])
    translate([-16.5+x,24,v[0]]) cylinder(r=v[1], h=20, $fn=v[2]);

  // Connect them to make slots
  for(x=[13.5,-13.5]) translate([-16.5+x,24,-1]) cube([4,3.4,50], center=true);

}

module x_carriage_fancy(){
 // Top right corner
 translate([13.5,-5,0]) translate([0,45+11.5,-1]) rotate([0,0,45]) translate([0,-15,0]) cube([30,30,20]);
 // Bottom right corner
 translate([0,5,0]) translate([0,-11.5,-1]) rotate([0,0,-45]) translate([0,-15,0]) cube([30,30,20]);
 // Bottom ĺeft corner
 translate([-33,5,0]) translate([0,-11.5,-1]) rotate([0,0,-135]) translate([0,-15,0]) cube([30,30,20]);
 // Top left corner
 translate([-33-13.5,-5,0]) translate([0,45+11.5,-1]) rotate([0,0,135]) translate([0,-15,0]) cube([30,30,20]);	
}

module x_carriage_addons(){
  translate([0,0,1]) {
    difference() {
      // Top hole to make it work like the mini carriage
      translate([-16.5+12,24+36,-1]) cylinder(r=1.7+2, h=8, $fn=32);
      translate([-16.5+12,24+36,-1]) cylinder(r=1.7, h=20, $fn=32, center=true);
    }
  }
}

// Final part
module x_carriage(){
 difference(){
  x_carriage_base();
  x_carriage_beltcut();
  x_carriage_holes();
  x_carriage_fancy();
 }
 x_carriage_addons();
}

x_carriage();
