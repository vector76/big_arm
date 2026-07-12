// Motor pinion: herringbone, press-on 5 mm D-bore. No hub, no grub
// screw: the bore's flat sits at the nominal 2.0 mm from axis and carries
// the torque as an interference fit (dimensions copied verbatim from the
// proven david_gears.scad pinion), and the herringbone self-centers
// axially even if it ever slips slightly.

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>

// round (no-flat) entry length at the bore mouth: the first 8.725 mm of
// the motor shaft is round, the D flat only starts beyond that
// (base_ht in the source file)
shaft_round_len = 8.725;

module motor_shaft_bore() {
  cylinder(d = 5 + 0.1, h = shaft_round_len, $fn = 60);
  tz(-0.1) difference() {
    cylinder(d = 5 + 0.1, h = 21, $fn = 60);
    rz(190.8) ty(2.0) cub([5, 5, 21], c = [1, 0, 0]);
  }
}

module pinion() {
  difference() {
    herringbone_gear(gear_module, pinion_teeth, gear_width,
                     helix = helix_angle, pa = pressure_angle,
                     backlash = gear_backlash);
    tz(-0.1) motor_shaft_bore();
  }
}

pinion();
