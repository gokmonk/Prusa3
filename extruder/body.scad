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
  extruder

  The whole part, either merged with the mount or standalone
*/
module extruder(){
  tran = [11,65.5,ed/2];
  translate([-23,2,0]) {
    difference() {
      union() {
        extruder_base();
        if (extraptor_v2) translate(tran) rotate([0,0,-90]) prusa_compact_adapter(mode=0);
      }
      union() {
        extruder_holes();
        if (extraptor_v2) translate(tran) rotate([0,0,-90]) prusa_compact_adapter(mode=3);
      }
    }
    if (draw_assembled) {
      %extruder_supports();
      if (do_hinge) %translate([30,47.6,2]) rotate([0,180,0]) bolt(h=20);
    }
    else extruder_supports();
  }
}

//
// extruder_base
//
// The extruder has two main parts, the "body" and the "plate"
//
module extruder_base() {

  // Main body
  translate([extruder_body_width/2-1, 56/2+motor_lowness/2, ed/2])
    cube([extruder_body_width, 56-motor_lowness, ed], center=true);

  // Extruder plate mount
  yvar = 5 + (hotend_mount == 1 ? (hotend_groovemount_depth - 1.5) : 0);
  if (!extraptor_v2) {
    translate([10, 49+yvar/2, ed/2])
      cube([extraptor_v2 ? 30 : 52, yvar, ed], center=true);
  }
 
  // hinge mount sizes
  hinge_back = ed - 11 - idler_hinge_width / 2 - idler_hinge_gap;
  hinge_front = 11 - idler_hinge_width / 2 - idler_hinge_gap;

  // Carriage mount cylinders
  if (rear_mounting) {
    translate([11,25,0]) {
      for (x=[-12,12]) translate([x,24,0]) cylinder(r=5, h=ed);
    }
    // Smoother join
    translate([1,41,0]) rotate([0,0,45]) cube([8,8,ed]);
  }
  else {
    // Base bevels
    if (extraptor_v2) {
      for (p=[[-4,51,-1],[24.5, 51 + (!do_hinge && motor_lowness > 3 ? motor_lowness - 2 : 0), 1]])
        translate([p[0],p[1],ed/2])
          rotate([0,0,p[2]*38])
            cube([16,8,ed], center=true);
    }
    else {
      for (x=[1,19.5]) translate([x,42,0]) rotate([0,0,45]) cube([10,10,ed]);
    }

    // Hinged idler starts with two cylinders and two cubes
    if (do_hinge) {
      translate([30, 48-0.4, 0]) {
        for (v=[[hinge_back, ed-hinge_back/2], [hinge_front, hinge_front/2]]) {
          translate([0, 0, v[1]]) {
            cylinder(r=idler_hinge_radius, h=v[0], center=true);
            translate([-idler_hinge_radius,0,0]) cube([idler_hinge_radius*2, idler_hinge_radius*2, v[0]], center=true);
          }
        }
      }
    }
  }
}

//
// extruder_holes
//
module extruder_holes() {
  body_center_x = 1.5 + 11 + 3.5;
  bcx = body_center_x+filament_path_offset;

  translate([11,25,0]) { // Translate to center of the main block

    // Motor shaft and MK7 gear opening
    translate([0,-2+motor_lowness,-1]) cylinder(r=8, h=26, $fn=36);

    // Motor mount holes
    translate([-8.5,18-2+motor_lowness]) {
      for (v=[[-1,hole_3mm,18],[ed-12.5,hole_3mm+1.4,6]], p=[[0,0,!do_high_mount],[0,-36,true]])
        if (v[2]!=6||p[2]) {
          translate([p[0],p[1],v[0]]) rotate([0,0,30]) cylinder(r=v[1], h=36, $fn=v[2]);
        }
        else {
          // translate([p[0],p[1],v[0]]) rotate([0,0,30]) %cylinder(r=v[1], h=36, $fn=v[2]);
        }
    }

    // Direct carriage mount holes, if enabled
    if (rear_mounting)
      for (x=[-12,12], v=[[-3,3.5],[20.5,2]])
        translate([x,24,v[0]]) cylinder(r=v[1], h=23);

    // Top-rear mounting / tensioning hole
    // This easily collides with motor mounting, so...
    // ...use with side-screw mount so there's no front-clamp
    // ...and the motor can mount 1mm lower, hopefully clearing!
    if (sideways_clamp) {
      translate([-6.5,19.1,ed/2]) {
        cylinder(r=hole_3mm, h=ed+1, $fn=18, center=true);
        translate([0,0,-ed/2-0.05]) cylinder(r=hole_3mm + 1.5, h=ed-10, $fn=18);
      }
    }

    // Idler bearing cutout
    translate([11,-2+motor_lowness,-4.5+10]) cylinder(r=11, h=20, $fn=64);
  }
  // Filament path
  color([1,1,1]) {
    translate([bcx,35,11]) rotate([90,0,0]) cylinder(r=filament_radius, h=70, $fn=18, center=true);
    translate([bcx,30+motor_lowness+10/2,11]) rotate([90,0,0]) cylinder(r1=filament_radius, r2=filament_radius+2, h=10, $fn=27, center=true);
    translate([bcx,motor_lowness+7/2,11]) rotate([90,0,0]) cylinder(r1=filament_radius, r2=filament_radius+1, h=7.01, $fn=27, center=true);
    // Hotend hole
    if (hotend_mount == 1 && !extraptor_v2) {
      translate([bcx,66-hotend_hole_depth,11]) rotate([90,0,0]) cylinder(r=hotend_r, h=10, $fn=72, center=true);
    }
  }

  // Hole and nut trap for side-screw, if enabled
  if (sideways_clamp) {

  }

  // For the hinged idler create a mount with a cutaway support wall
  support_wall = draw_assembled ? 0 : 0.5;
  if (do_hinge) {
    translate([30, 48-0.4, ed/2]) {
      // Middle gap for idler hinge
      translate([0,0,-1]) {
        translate([0,support_wall/2,0]) {
          cube([13,idler_hinge_radius+2+0.01-support_wall,idler_hinge_width+0.4], center=true);
          cylinder(r=idler_thickness/2+0.2, h=idler_hinge_width+0.4, center=true);
        }
      }
      // Screw hole for the hinge axle
      cylinder(r=hole_3mm, h=ed+0.1, center=true);
      // Screw cap inset on the front
      translate([0,0,(-ed+2.5)/2]) cylinder(r2=hole_3mm+1, r1=hole_3mm+2, h=2.51, center=true);
      // Nut trap inset on the back
      if (!do_high_mount)
        translate([0,0,(ed-4)/2]) cylinder(r=hole_3mm+1.5, h=4.01, $fn=6, center=true);
    }
  }

  // Hole for drive gear check
  translate([body_center_x-6,22.5+motor_lowness,11]) {
    cube([23,4,8], center=true);
    for (y=[-2,2])
      translate([0,y,0]) rotate([90,0,90]) cylinder(r=4, h=23, $fn=20, center=true);
  }

  // Extruder plate mounting holes
  if (!extraptor_v2 && (!rear_mounting || bottom_mounting))
    for (v=[[9, 1.8, 12],[-9, 3.1, 6]], x=[15,-25])
      translate([body_center_x+x,56+v[0],11]) rotate([90,0,0]) cylinder(r=v[1], h=70, $fn=v[2]);

  // Idler mounting holes
  translate([11-5, 25-2, 11]) {
    for (y=do_hinge?[-15]:[-15,15], z=[-5,5]) {
      translate([-12,y+motor_lowness,z]) rotate([0,90,0]) {
        // Nut traps
        rotate([0,0,30]) cylinder(r=3.3, h=22, $fn=6);
        // Screw holes
        cylinder(r=radius4mm, h=29, $fn=18);
        if (do_hinge) {
          for (n=[1:4]) translate([0,-0.5*n,22]) rotate([n*3,0,0]) rotate([0,0,15]) cylinder(r=radius4mm, h=20, $fn=12, center=true);
        }
      }
    }
  }
  // Top and bottom bevels
  top_bevel = -18 + motor_lowness;
  for (v=extraptor_v2 ? [[-8,top_bevel],[30,top_bevel]] : [[45,47],[-21,47],[-8,top_bevel],[30,top_bevel]]) // ,[-22,24],[46,13] ?
    translate([v[0],v[1],-1]) rotate([0,0,45]) cube([20,20,ed+2]);

  // Chop off extra material from the left side
  if (do_chop)
    translate([-13+filament_path_offset*2,53,ed/2]) cube([10*2,20,ed+0.1], center=true);
}

module extruder_supports() {
  support_wall = 0.7;
  wall_length = idler_hinge_width + idler_hinge_gap * 2;
  if (extraptor_v2 && v2_groove_height > 0) {
    translate([16 + filament_path_offset, 52.5 + v2_above_groove_mm + (v2_groove_height/2), 11 + 0.3/2]) cube([16,v2_groove_height,0.3], center=true);
  }
  if (do_hinge && !draw_assembled) {
    translate([30,48-0.4,11]) {
      difference() {
        hollow_cylinder(r1=idler_hinge_radius, r2=idler_hinge_radius-support_wall, h=wall_length, center=true);
        translate([-4,-idler_hinge_radius+idler_hinge_radius,0]) cube([8,idler_hinge_radius*2,wall_length], center=true);
        // translate([2,4,0]) cube([idler_hinge_radius,idler_hinge_radius,wall_length], center=true);
      }
      translate([-4,-idler_hinge_radius+support_wall/2,0]) cube([4,support_wall,wall_length], center=true);
      translate([0,0,wall_length/2+0.15]) cylinder(r=idler_hinge_radius, h=0.3, center=true);
    }
  }
}

