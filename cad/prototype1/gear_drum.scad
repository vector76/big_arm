// Driven gear (51T herringbone) with integrated cable drum. Two 608
// bearings press into the part (one inset in the gear underside, one in
// the boss above the drum), so it spins on a fixed M8 bolt through the
// rig board — no pillow blocks, no grub screws. Cable anchors in a radial
// hole at the drum base and wraps the smooth core; flanges keep it captive.

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>

anchor_d = 2.2;                 // cable feed-through, knot or crimp behind it
bore_d = shaft_d + 2.5;         // free clearance around the dead axle

z_top = drum_z_top;             // shared with the axle spacer stack

module gear_drum() {
  difference() {
    union() {
      herringbone_gear(gear_module, gear_teeth, gear_width,
                       helix = helix_angle, pa = pressure_angle,
                       backlash = gear_backlash, ha = wheel_addendum);
      // drum: lower flange on the gear face, core, upper flange
      tz(gear_width) cylinder(d = drum_flange_d, h = 2);
      tz(gear_width + 2) cylinder(d = drum_core_d, h = drum_len);
      tz(gear_width + 2 + drum_len) cylinder(d = drum_flange_d, h = 2);
      // bearing boss above the drum
      tz(gear_width + 2 + drum_len + 2) cylinder(d = top_hub_d, h = top_hub_h);
    }
    // axle clearance bore, full length
    tz(-0.5) cylinder(d = bore_d, h = z_top + 1, $fn = 48);
    // lower bearing pocket, inset into the gear underside
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    // upper bearing pocket, from the top of the boss
    tz(z_top - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    // cable anchor: radial hole through the core just above the lower flange
    tz(gear_width + 2 + cable_d) ry(90) cylinder(d = anchor_d, h = drum_flange_d, $fn = 24);
  }
}

gear_drum();
