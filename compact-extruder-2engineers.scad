// not to be used with PG35L motor
// modified by misan
// modified by thinkyhead

// PRUSA iteration3
// Compact extruder
// GNU GPL v3
// Josef Průša <iam@josefprusa.cz> and contributors
// http://www.reprap.org/wiki/Prusa_Mendel
// http://prusamendel.org

include <configuration.scad>

$fn = 18;

draw_assembled = true;

draw_extruder = false;
draw_idler = true;
draw_mount = false;
draw_holder = false;
draw_motor = false;

rear_mounting = false;
extruder_plate = false; // keep bottom holes on the extruder

hotend_groovemount_depth = 8;
hotend_groovemount_diameter = 15.88 + 0.2;

filament_radius = 1.5 + 0.5;
filament_path_offset = 0.25; // 0.25 for Raptor (5.25-5.5mm radius)

hole_3mm = 1.5 + 0.2;
hole_4mm = 2.0 + 0.2;
hotend_r = hotend_groovemount_diameter / 2;

part_thickness = 10;
extruder_depth = 24;
extra_depth = 0;

groove_height = 0; // 3.15;
groove_depth = 1.45;

mount_length = 40;
mount_thickness = 6;
corner_radius = 15;

holder_thickness = 10;
holder_gap = 1.5;
holder_hole_dist = 22;

idler_thickness = 8 + 3;
idler_bearing_offset = 2;

module motor_dummy(){
  mw = 43.8;
  hd = 36.0;
  ax = 11.675; ay = 22.025;
  gr = 10.5/2; gh = 11.0;

  // Flat Part
  translate([0,0,-0.5]) difference() {
    cube([mw,mw,1], center=true);
    for (x=[-1,1]) translate([x*hd/2,hd/2]) cylinder(r=1.6, h=2.1, center=true);
  }
  // M3 Bolts
  for (x=[-1,1]) translate([x*hd/2,-hd/2,-1]) {
    translate([0,0,12.5]) cylinder(r=1.55, h=25, center=true);
    translate([0,0,-0.75]) cylinder(r1=2,r2=2.5, h=1.5, center=true);
  }

  // Motor body
  for (p=[[42.6,15.5],[42,36],[10,37],[2,37.5]])
    translate([0,0,-p[1]/2]) cylinder(r=p[0]/2, h=p[1], center=true);

  // Axle and Gear
  translate([-mw/2+ay,-mw/2+ax]) {
    // Axle
    translate([0,0,7]) color([0.8,0.8,0.8]) cylinder(r=2.5, h=14, center=true);
    // Gear
    translate([0,0,gh/2+3]) color([1,0.75,0]) cylinder(r=gr, h=gh, $fn=36, center=true);
  }
}

module extruder_base(){
 // Main body
 translate([-1,-2,0]) cube([23,56,24]);
 // Extruder plate mount
 if (hotend_mount == 1) { // groove-mount
  translate([-16,49,0]) cube([55,5 + hotend_groovemount_depth - 1.5,24]);
 } else {
  translate([-16,49,0]) cube([55,5,24]);
 }
 
 // Carriage mount cylinders
  if (rear_mounting) {
    translate([11,25,0]){
      translate([-12,24,0]) cylinder(r=5, h=24);
      translate([12,24,0]) cylinder(r=5, h=24);
    }
    // Smoother join
    translate([1,38,0]) rotate([0,0,45])  cube([10,10,24]);
  }
  else {
    // Base bevels
    for (x=[1,19.5]) translate([x,42,0]) rotate([0,0,45])  cube([10,10,24]);
  }
}

module extruder_holes() {
  body_center_x = 1.5 + 11 + 3.5;
  translate([11,25,0]) { // Translate to center of the main block
    // Main shaft opening
    translate([0,-2,-1]) cylinder(r=8, h=26);

    translate([-8.5,18-2]) {
      for (v=[[-1,2],[21,3.1]]) {
        // Lower motor mount hole
        translate([0,0,v[0]]) cylinder(r=v[1], h=35);
        // Upper motor mount hole
        translate([0,-(18-2)-18-2,v[0]]) cylinder(r=v[1], h=35);
        // Idler motor mount hole
        translate([36,0,v[0]]) cylinder(r=v[1], h=35);
      }
    }

    if (rear_mounting) {
      // Carriage mount holes
      for (x=[-12,12]) for (v=[[-3,3.5],[20.5,2]]) {
        translate([x,24,v[0]]) cylinder(r=v[1], h=23);
      }
    }
    // Idler bearing cutout
    translate([11,0-2,-4.5+10]) cylinder(r=11, h=20);
  }
  // Filament path
  color([1,1,1]) {
    translate([body_center_x+filament_path_offset,65,11]) rotate([90,0,0]) cylinder(r=filament_radius, h=70, $fn=18);
    translate([body_center_x+filament_path_offset,30+7,11]) rotate([90,0,0]) cylinder(r1=filament_radius, r2=filament_radius+2, h=7, $fn=27);
    // Hole for hotend
    if (hotend_mount == 1) {
      translate([body_center_x+filament_path_offset,65,11]) rotate([90,0,0]) cylinder(r=hotend_groovemount_diameter/2, h=12.5);
    }
  }
  // Hole for drive gear check
  for (y=[25:21])
    translate([body_center_x-30,y,11]) rotate([90,0,90]) cylinder(r=4, h=70, $fn=20);

  // Extruder plate mounting holes
  if (!rear_mounting || extruder_plate) {
    for (v=[[9,1.8,12],[-9,3.1,6]]) for (x=[15,-25]) {
      translate([body_center_x+x,56+v[0],11]) rotate([90,0,0]) cylinder(r=v[1], h=70, $fn=v[2]);
    }
  }

  // Idler mounting holes
  translate([11,25-2,11]){
    for (y=[-15,15], z=[-5,5]) {
      // Nut traps
      translate([-30,y,z]) rotate([0,90,0]) rotate([0,0,30]) cylinder(r=3.3, h=30, $fn=6);
      // Screws
      translate([-30,y,z]) rotate([0,90,0]) cylinder(r=2, h=70, $fn=18);
    }
  }
  for (v=[[46,46],[46,13],[-22,46],[-22,24],[-8,-20],[30,-20]]) {
    translate([v[0],v[1],-1]) rotate([0,0,45]) cube([20,20,26]);
  }
}

module extruder_idler_base() {
  roundness = 4;
  translate([10,20,idler_thickness/2]) {
    minkowski() {
      cube([11.5,32,idler_thickness], center=true);
      cylinder(r=roundness,h=0.01,$fn=12,center=true);
    }
  }
}

module extruder_idler_holes(){
  axle_inset = 2;
  translate([10,20,idler_thickness/2]){
    // Main cutout
    // cube([10.5,21,12], center=true);
    translate([0,0,idler_bearing_offset]) {
      // round cutout too
      rotate([0,90,0]) cylinder(r=11.5, h=10.5, center=true);
      // Idler shaft
      rotate([0,90,0]) cylinder(r=4.1, h=19.5-axle_inset, center=true);
      if (idler_bearing_offset > 0)
        translate([0,0,4.1]) cube([19.5-axle_inset,7.5,8.2], center=true);
    }
    // Screw holes
    for (x=[-1,1],y=[-1,1]) translate([x*5,y*15,0]) cylinder(r=2.2, h=12, center=true);
  }
}


// Idler final part
module idler(){
 difference() {
  extruder_idler_base();
  extruder_idler_holes();
 }
}

//translate([10,0,1]) rotate([0,-90,0]) idler();
//translate([-47,-2,0])  idler();
// Extruder final part
module extruder(){
 translate([-23,2,0])difference(){
  extruder_base();
  extruder_holes();
 }
}

/*
  prusa_compact_adapter

  This is adapted for the inverted-T x-carriage, my own eccentricity. This brings
  the nozzle up to add some vertical space, and forward 6mm.

  This part dovetails with the compact extruder body. It can mount either
  through the back or through the bottom with two M3 screws. Set
  rear_mounting according to preference.

  There is a groove setting, but it's optional. The holder piece that you screw on
  with two M3 nuts has more than enough hold to keep the nozzle in place.
  Since the top 1cm of the nozzle will be in direct contact with the plastic
  you have to print this in ABS, nylon, PEEK, etc. Be sure to cool the heat barrier
  with a fan as close to the heater block as possible.
*/
module prusa_compact_adapter() {

  mount_x = 16 + (part_thickness - mount_length) / 2;
  mount_z = 12 + mount_thickness / 2;
  b_dist = (18 - (45 - mount_length) / 2);

  difference() {
    union() {
      translate([0,0,-extra_depth/2]) color([0,0,1]) cube([part_thickness,50,extruder_depth+extra_depth], center=true);
      translate([mount_x,0,mount_z]) {
        minkowski() {
          cube([mount_length-corner_radius*2,50-corner_radius*2,mount_thickness], center=true);
          cylinder(r=corner_radius,h=0.01,$fn=36,center=true);
        }
      }
      for (y=[-24.6,26.6]) {
        translate([0,y,-extra_depth/2]) rotate([0,0,45]) cube([15,15,extruder_depth+extra_depth], center=true);
      }
      // Top Screw Mount Plate
      color([1,1,1])
        translate([42/2,-12,mount_z]) {
          // cube([10,hole_3mm*2+8,mount_thickness], center=true);
          cylinder(r=hole_3mm+5, h=mount_thickness, center=true);
        }
    }
    for (y=[-1,1]) {
      // platform screw holes
      if (!rear_mounting) {
        translate([0,y*20,0]) rotate([0,90,0]) cylinder(r=hole_3mm, h=part_thickness + 10, $fn=12, center=true);
        translate([-4,y*20,0]) rotate([0,90,0]) cylinder(r=hole_3mm+1.5, h=3, $fn=12, center=true);
      }
      // end choppers
      translate([0,y*40,-extra_depth/2]) cube([30,30,extruder_depth+extra_depth+0.01], center=true);
      // bottom chopper
      translate([-5-part_thickness/2,y*30,-extra_depth/2]) cube([10,30,extruder_depth+extra_depth+0.01], center=true);
    }
    // Groove mount
    translate([0,part_thickness/2+filament_path_offset,-1.0]) {
      // Groove - Narrow Part
      translate([0,0,-7.5-extra_depth/2]) {
        cube([11,hotend_groovemount_diameter-groove_depth*2,15+extra_depth], center=true);
        translate([0,0,6.5-(10+extra_depth)/2]) cube([11,hotend_groovemount_diameter,10.01+extra_depth], center=true);
      }
      // Center Hole - Narrow Part
      rotate([0,90,0]) cylinder(r=hotend_r-groove_depth, h=11, $fn=72, center=true);
      // Groove - Wide Part
      translate([-groove_height,0,0]) {
        translate([0,0,-7.5-extra_depth/2]) cube([11,hotend_groovemount_diameter,15+extra_depth], center=true);
        rotate([0,90,0]) cylinder(r=hotend_r, h=11, $fn=72, center=true);
      }
    }
    // Mount Screw Holes
    for (x=(rear_mounting ? [-1,1] : [-1]), y=[-1,1]) {
      translate([mount_x + b_dist * x, 12 * y, mount_z]) {
        cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
        translate([0,0,x*mount_thickness/2]) cylinder(r=hole_3mm + 1.75, h=4, $fn=18, center=true);
      }
    }
    // Top screw hole - oh fun
    translate([42/2,-12,mount_z]) {
      cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
      translate([0,0,-mount_thickness/2]) cylinder(r=hole_3mm * 2, h=6, $fn=18, center=true);
    }
    // Holder part mounting holes & traps
    translate([0,part_thickness/2+filament_path_offset,5]) {
        for (y=[-1,1]) {
          translate([0,y*holder_hole_dist/2,0]) cylinder(r=hole_3mm, h=extruder_depth+part_thickness+0.02, $fn=12, center=true);
          translate([0,y*holder_hole_dist/2,(extruder_depth+part_thickness)/2-3.5-2.2]) cylinder(r=hole_3mm+1.5, h=3.51, $fn=12, center=true);
        }
    }
  }

} // prusa_compact_adapter

/*
  prusa_adapter_holder

  This piece slides onto the two long M3 bolts to hold the hot end
  and keep it from rotating or sliding out.
*/
module prusa_adapter_holder() {

  holder_width = (20 - filament_path_offset) * 2;

  difference() {
    union() {
      translate([0,part_thickness/2+filament_path_offset,-extruder_depth/2-extra_depth/2-holder_thickness/2]) color([1,1,1]) {
        translate([0,0,-holder_gap/2]) cube([part_thickness,holder_width,holder_thickness-holder_gap], center=true);
        translate([0,0,5-holder_gap+(8+holder_gap)/2]) cube([part_thickness,hotend_groovemount_diameter-0.25,8+holder_gap], center=true);
      }
    }

    // Bevel the block
    translate([0,part_thickness/2+filament_path_offset,-extruder_depth/2-extra_depth/2-holder_thickness/2]) color([1,1,1]) {
        for (y=[-22,22]) translate([0,y,-holder_thickness/2]) rotate([y*2.5,0,0]) cube([10.1,part_thickness,10], center=true);
    }

    // Groove mount
    translate([0,part_thickness/2+filament_path_offset,-1.0]) {
      // Center Hole - Narrow Part
      rotate([0,90,0]) cylinder(r=hotend_r-groove_depth, h=11, $fn=72, center=true);
      // Groove - Wide Part
      translate([-groove_height,0,0]) {
        rotate([0,90,0]) cylinder(r=hotend_r, h=11, $fn=72, center=true);
      }
    }

    // Mounting holes
    translate([0,part_thickness/2+filament_path_offset,-(extruder_depth+extra_depth)/2]) {
        for (y=[-1,1]) {
          translate([0,y*holder_hole_dist/2,-5]) cylinder(r=hole_3mm, h=10.1, $fn=12, center=true);
          // translate([0,y*holder_hole_dist/2,-10+(2.2/2)]) cylinder(r=hole_3mm+1, h=2.21, $fn=12, center=true);
        }
    }

  }

} // prusa_adapter_holder

if (draw_extruder || draw_assembled) {
  if (draw_assembled) {
    rotate([0,0,90]) extruder();
  }
  else {
    translate(draw_mount?[-30,-25]:[0,0])
      rotate([0,0,draw_mount?0:90])
        extruder();
  }
}

if (draw_motor || draw_assembled) {
  if (draw_assembled) {
    translate([-25,-2,0]) %motor_dummy();
  }
  else {
    translate([-2.5,25,0]) %motor_dummy();
  }
}

if (draw_idler || draw_assembled) {
  if (draw_assembled) {
    translate([-5,12,1])
      rotate([0,-90,90])
        idler();
  }
  else {
    if (draw_mount) {
      translate([draw_holder?40:22,-15]) idler();
    }
    else
      translate([-5,4]) rotate([0,0,90]) idler();
  }
}

if (draw_mount || draw_assembled) {
  if (draw_assembled) {
    translate([-67.5,-12,12])
      prusa_compact_adapter();
  }
  else {
    translate([0,0,part_thickness+extruder_depth-16])
      rotate([0,180,0])
        prusa_compact_adapter();
  }
}

if (draw_holder || draw_assembled) {
  if (draw_assembled) {
    translate([-67.5,-12,12])
      %prusa_adapter_holder();
  }
  else {
    translate([draw_mount ? 30 : 0,0,22])
      prusa_adapter_holder();
  }
}
