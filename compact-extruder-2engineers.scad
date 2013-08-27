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
include <extruder/config.scad>
include <extruder/utility.scad>
include <extruder/body.scad>
include <extruder/idler.scad>
include <extruder/mount.scad>
include <extruder/clamp.scad>
include <extruder/fan-mount.scad>
include <extruder/fan-duct.scad>

// Draw assembled for easier development
draw_assembled = false;

if (draw_assembled)
  translate([0,6.5,120]) rotate([0,-90,0]) draw_everything();
else
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
      translate([-67.5+(extraptor_v2 ? v2_merge_amount : 0),-12,12])
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
        if (do_high_mount) {
          translate([platform_y_offset-36,37+(do_chop?5+filament_path_offset:0),ed-12-0.25]) {
            %cube(1, center=true);
            rotate([0,0,-90])
              prusa_compact_adapter(mode = extraptor_v2 ? 2 : 1);
          }
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
  }

  // FAN MOUNT
  if (draw_fan_mount || draw_assembled) {
    color([1,0,0.25]) {
      if (draw_assembled) {
        translate([-59.5+platform_y_offset,-12+(do_chop?5+filament_path_offset:0),-clamp_thickness - 1 - 2.5]) {
          fan_mount();
        }
      }
      else {
        // draw_extruder ? [-20,47,0] : [ioffs-30, draw_idler ? 37 : 30,0]
        translate([ioffs-30, draw_idler ? 37 : 32, 0]) {
          %cube(1, center=true);
          translate([4,16,1]) rotate([0,180,180]) fan_mount(mode=1);
          translate([15,16,1]) rotate([0,-35,0]) fan_mount(mode=2);
        }
      }
    }
  }

  // FAN SIDE MOUNT
  if (draw_fan_sidemount) {
    color([0.5,1,0.25]) {
      if (draw_assembled) {
        translate([-59.5+platform_y_offset,-12+(do_chop?5+filament_path_offset:0),-clamp_thickness - 1 - 2.5]) {
          fan_sidemount();
        }
      }
      else {
        translate(draw_extruder ? [-30,47,0] : [0, draw_idler ? 37 : 30,0]) {
          %cube(1, center=true);
          translate([0,12,1]) rotate([0,180,90]) fan_sidemount();
        }
      }
    }
  }

  // FAN DUCT, SIDE OR FAN-MOUNTED
  if (draw_fan_duct || draw_assembled) {
    color([1,0.5,0.5,0.25]) {
      if (draw_assembled) {
        translate([-103.5+platform_y_offset,-12+(do_chop?5+filament_path_offset:0),-clamp_thickness - 1 - 2.5 + 11.5])
          rotate([0,35,0])
            fan_duct();
      }
      else {
        // [moffs-(draw_fan_mount&&draw_mount ? 15 : 25),draw_mount?50:10,0.75]
        translate([ioffs,50,1.5/2]) {
          %cube(1, center=true);
          rotate([0,0,0]) fan_duct();
        }
      }
    }
  }

  if (draw_assembled) %translate([-25-motor_lowness,-2.5,0]) motor_dummy();

} // draw_everything


//
// Placeholder Objects
//
module motor_dummy(){
  mw = 43.8;
  hd = 36.0;
  ax = 11.675; ay = 22.025;
  gr = gear_diameter/2;
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

module fan_dummy() {
  difference() {
    rounded_cube([50, 50, 12], r=2, center=true);
    cylinder(r=22, h=12.1, center=true);
    for(x=[-1,1],y=[-1,1],z=[-1,1]) translate([x*20,y*20,z*2-1]) cylinder(r=hole_3mm-z+1, h=12.1, center=true);
  }

  // if (draw_assembled)
  //   for(x=[1],y=[-1,1]) translate([x*20,y*20,-4]) rotate([0,180,0]) bolt(h=15);
}
