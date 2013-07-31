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

include <configuration.scad>

$fn = 36;

// The V2 extruder has the clamped groove mount and reduced size
extraptor_v2 = true;

// Draw assembled for easier development
draw_assembled = true;

// Which parts to show
draw_extruder = true;
draw_idler = true;
draw_clamp = true;
draw_mount = true;

// V2 has a hinged idler option
hinged_idler = true;
idler_hinge_width = 10; // width of the centered hinge
idler_hinge_gap = 0.2;  // gap around the hinge
idler_hinge_radius = radius3mm + 3.0; // radius of the mounts on the extruder

merge_amount = 8;       // how much the platform area moves up into the extruder
merge_chopchop = true;  // minimize the base of the extruder
merge_endspace = 4.7;   // space above the groove in the hotend

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

groove_height = 3;
groove_depth = 1;

mount_length = 40;
mount_thickness = 6;
corner_radius = extraptor_v2 ? 10 : 15;
platform_y_offset = 0;

clamp_hole_dist = extraptor_v2 ? 24 : 22;
clamp_thickness = 10;
clamp_gap = 1.5;       // This gives room to tighten the clamp

// Idler options
idler_w = 20;
idler_h = 40;
idler_axle_inset = 2.6;
idler_thickness = 8 + 3;  // room for an M8 rod and a little more
idler_bearing_offset = 3; // how far to move the rod off-center, adding a groove

// Shorthand and calculated variables
ed = extruder_depth;
hotend_r = hotend_groovemount_diameter / 2;
do_chop = extraptor_v2 && merge_chopchop;
do_hinge = extraptor_v2 && hinged_idler;
motor_lower = extraptor_v2 ? 6 : 1.5;
motor_lowness = (rear_mounting && motor_lower > 1.5) ? 1.5 : motor_lower;

draw_everything();

//
// Decide what to draw based on flags
//
module draw_everything() {

  ioffs = (draw_clamp ? platform_height + 4 : (do_hinge ? idler_hinge_width / 2 - 1 : 0));
  moffs = extraptor_v2 ? ioffs + (draw_idler ? idler_w + 4 : 0) : -mount_length/2 - (draw_extruder ? 56 : 32);

  // EXTRUDER
  if (draw_extruder || draw_assembled) {
    color([0.6,0.5,1]) {
      if (draw_assembled) {
        rotate([0,0,90]) extruder();
      }
      else {
        translate([-30,-25, 0]) {
          %cube(1, center=true);
          extruder();
        }
      }
    }
  }

  // CLAMP
  if (draw_clamp || draw_assembled) {
    if (draw_assembled) {
      translate([-67.5+(extraptor_v2 ? merge_amount : 0),-12,12])
        prusa_adapter_clamp();
    }
    else {
      translate([-30 + platform_height/2 + 2,-8, 12+clamp_thickness]) {
        prusa_adapter_clamp();
        %cube(1, center=true);
      }
    }
  }

  // IDLER
  if (draw_idler) {
    if (draw_assembled) {
      translate([-5,12,1])
        rotate([0,-90,90])
          idler();
    }
    else {
      translate([-27 + ioffs,-22,0]) {
        %cube(1, center=true);
        idler();
      }
    }
  }

  // MOUNT
  if (draw_mount || draw_assembled) {
    color([1,1,1]) {
      if (draw_assembled) {
        translate([-67.5+platform_y_offset,-12+(do_chop?5+filament_path_offset:0),ed-12])
          prusa_compact_adapter(mode = extraptor_v2 ? 2 : 1);
      }
      else {
        translate([moffs-1,0,platform_height+ed-16]) {
          %cube(1, center=true);
          rotate([0,180,0])
            prusa_compact_adapter(mode = extraptor_v2 ? 2 : 1);
        }
      }
    }
  }

  if (draw_assembled) %translate([-25-motor_lowness,-2.5,0]) motor_dummy();

} // draw_everything

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
    translate([-8.5,18-2+motor_lowness])
      for (v=[[-1,hole_3mm,18],[ed-3,hole_3mm+1.5,6]], p=[[0,0],[0,-36],[36,0]])
        translate([p[0],p[1],v[0]]) rotate([0,0,30]) cylinder(r=v[1], h=35, $fn=v[2]);

    // Carriage mount holes
    if (rear_mounting)
      for (x=[-12,12], v=[[-3,3.5],[20.5,2]])
        translate([x,24,v[0]]) cylinder(r=v[1], h=23);

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
  if (extraptor_v2 && groove_height > 0) {
    translate([16 + filament_path_offset, 52.5 + merge_endspace + (groove_height/2), 11 + 0.3/2]) cube([16,groove_height,0.3], center=true);
  }
  if (do_hinge && !draw_assembled) {
    translate([30,48-0.4,11]) {
      difference() {
        hollow_cylinder(r1=idler_hinge_radius, r2=idler_hinge_radius-support_wall, h=wall_length, center=true);
        translate([-4,-idler_hinge_radius+idler_hinge_radius,0]) cube([8,idler_hinge_radius*2,wall_length], center=true);
        // translate([2,4,0]) cube([idler_hinge_radius,idler_hinge_radius,wall_length], center=true);
      }
      translate([-4,-idler_hinge_radius+support_wall/2,0]) cube([8,support_wall,wall_length], center=true);
      translate([0,0,wall_length/2+0.15]) cylinder(r=idler_hinge_radius, h=0.3, center=true);
    }
  }
}

module hollow_cylinder(r1=1,r2=1,h=1,center=false) {
  difference() {
    cylinder(r=r1,h=h,center=center);
    cylinder(r=r2,h=h+0.01,center=center);
  }
}

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
    minkowski() {
      cube([idler_w-roundness*2,idler_h-roundness*2-(do_hinge ? motor_lowness : 0),idler_thickness], center=true);
      cylinder(r=roundness,h=0.01,$fn=12,center=true);
    }
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
  mount_x = 16 + (platform_height - mount_length) / 2;
  mount_z = 12 + mount_thickness / 2;
  b_dist = (18 - (45 - mount_length) / 2);

  do_solid = (mode != 3);
  do_platf = (mode != 2);
  do_back = (mode == 1 || mode == 2);

  difference() {
    if (do_solid) union() {

      if (do_platf) // draw platform modes 0,1
        translate([(extraptor_v2 ? merge_amount : -platform_y_offset),0,0]) color([0,0,1]) cube([platform_height,mount_w,ed], center=true);

      // draw the back part
      if (do_back) {
        translate([mount_x,0,mount_z]) {
          minkowski() {
            cube([mount_length-corner_radius*2,mount_w-corner_radius*2-(do_chop?4:0),mount_thickness], center=true);
            cylinder(r=corner_radius,h=0.01,$fn=36,center=true);
          }
        }
      }
      if (do_platf && !extraptor_v2) {
        // Angled Ends
        for (y=[-25.6,27.6]) {
          translate([(extraptor_v2 ? 0 : -platform_y_offset),y,0]) rotate([0,0,45]) cube([17,17,ed], center=true);
        }
      }
      // Top Screw Mount Plate
      if (do_back) {
        color([1,1,1])
          translate([42/2,-12,mount_z+(mount_thickness-3)/2]) {
            cylinder(r=hole_3mm+5, h=3, center=true);
          }
      }

    } // union

    union() {

      if (do_platf) translate([(extraptor_v2 ? merge_amount : -platform_y_offset),0,0]) {
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
            cube([10.01,hotend_groovemount_diameter-groove_depth*2,15], center=true);
            translate([0,0,6.5-10/2]) cube([10.01,hotend_groovemount_diameter,10.01], center=true);
          }
          // Hotend Hole - Remove Narrow
          rotate([0,90,0]) cylinder(r=hotend_r-groove_depth, h=10.01, $fn=72, center=true);
          translate([0,0,-7.5]) cube([10.01,hotend_groovemount_diameter+0.3,15], center=true);
          // Remove Non-Groove Parts
          if (extraptor_v2) {
            // Hotend hole - Wider part, remove where the groove isn't
            translate([-groove_height-merge_endspace,0,0]) {
              rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
            }
            // Remove the area above the groove
            translate([5-merge_endspace/2,0,0])
              rotate([0,90,0]) cylinder(r=hotend_r, h=merge_endspace, $fn=72, center=true);
          }
          else {
            // Make the groove flush with the top for non-merged
            translate([-groove_height,0,0]) {
              rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
            }
          }
        }
      } // do_platf

      // Front-to-back long mounting holes & traps
      translate([ (extraptor_v2 ? merge_amount - (do_back ? platform_y_offset : 0) : -platform_y_offset),
                  platform_height/2+filament_path_offset-(do_chop&&mode==2?5+filament_path_offset:0),
                  5]) {
        for (y=[-1,1]) {
          translate([0,y*clamp_hole_dist/2,0]) cylinder(r=hole_3mm, h=ed+platform_height+0.02, $fn=12, center=true);
          translate([0,y*clamp_hole_dist/2,(ed+platform_height)/2-3.5-2.2]) cylinder(r=hole_3mm+1.5, h=3.51, $fn=12, center=true);
        }
      }

      if (do_back) {

        // Mount Screw Holes
        for (x=(rear_mounting ? [-1,1] : [-1]), y=[-1,1]) {
          translate([mount_x + b_dist * x, 12 * y, mount_z]) {
            cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
            translate([0,0,x*mount_thickness/2]) cylinder(r=hole_3mm + 1.75, h=4, $fn=18, center=true);
          }
        }
        // Top screw hole
        translate([42/2,-12,mount_z]) {
          cylinder(r=hole_3mm, h=mount_thickness+1, $fn=12, center=true);
          translate([0,0,-mount_thickness/2]) cylinder(r=hole_3mm+2.5, h=6, $fn=18, center=true);
        }
        // // Save material
        translate([(extraptor_v2 ? -8 : -16)-platform_y_offset,0,15]) {
          cube([22.01,12,mount_thickness+1], center=true);
          for (y=[-1,1]) translate([-1,y*15,-mount_thickness/2]) rotate([y*275,0,0]) cube([22,3,22],center=true);
        }

      } // do_back

    } // union

  } // difference

  // Front-to-back long screws for show
  if (draw_assembled && do_back)
    translate([(extraptor_v2?merge_amount:0)-platform_y_offset, platform_height/2+filament_path_offset-(do_chop?5+filament_path_offset:0), 5])
      for (y=[-1,1])
        translate([0,y*clamp_hole_dist/2,12]) %bolt(h=45);

} // prusa_compact_adapter

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
      rotate([0,90,0]) cylinder(r=hotend_r-groove_depth, h=10.01, $fn=72, center=true);
      if (extraptor_v2) {
        // Hotend hole - Wider part, remove where the groove isn't
        translate([-groove_height-merge_endspace,0,0]) {
          rotate([0,90,0]) cylinder(r=hotend_r, h=10.01, $fn=72, center=true);
        }
        translate([5-merge_endspace/2,0,0])
          rotate([0,90,0]) cylinder(r=hotend_r, h=merge_endspace, $fn=72, center=true);
      }
      else {
        translate([-groove_height,0,0]) {
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

//
// Utility Functions
//

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

module motor_dummy(){
  mw = 43.8;
  hd = 36.0;
  ax = 11.675; ay = 22.025;
  gr = gear_radius/2;
  gh = gear_height;

  // Flat Part
  translate([0,0,-0.5]) difference() {
    cube([mw,mw,1], center=true);
    for (x=[-1,1]) translate([x*hd/2,hd/2]) cylinder(r=hole_3mm, h=2.1, center=true);
  }
  // M3 Bolts
  for (x=[-1,1]) translate([x*hd/2,-hd/2,-1]) {
    rotate([0,180,0]) bolt(h=25);
    // translate([0,0,12.5]) cylinder(r=1.55, h=25, center=true);
    // translate([0,0,-0.75]) cylinder(r1=2,r2=2.5, h=1.5, center=true);
  }

  // Motor body
  for (p=[[42.6,15.5],[42,36],[10,37],[2,37.5]])
    translate([0,0,-p[1]/2]) cylinder(r=p[0]/2, h=p[1], $fn=0, $fa=2, $fs=2, center=true);

  // Axle and Gear
  translate([-mw/2+ay,-mw/2+ax]) {
    // Axle
    translate([0,0,7]) color([0.8,0.8,0.8]) cylinder(r=2.5, h=14, center=true);
    // Gear
    translate([0,0,gh/2+3]) color([1,0.75,0]) cylinder(r=gr, h=gh, $fn=36, center=true);
  }
}
