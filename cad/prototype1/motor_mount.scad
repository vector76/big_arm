// Rigid NEMA 17 mount plate. The motor body plunges through the board
// cutout and hangs from this plate by its face screws (counterbored so
// the heads clear the pinion above); the plate sits flat on the board.
// Mesh is set by sliding the plate along its foot slots (local X, the
// radial/mesh direction), pressing the gears together, and tightening —
// no preload flexure on the test rig.
//
// Local coords: pinion axis at the origin, gear toward -X, z = 0 at the
// board face. Print flat.

include <params.scad>
use <../lib/helpers.scad>

module motor_mount() {
  difference() {
    linear_extrude(motor_plate_t) {
      sq(motor_plate, [1, 1], 5);
      // tangential wings carry the inboard feet clear of the gear shadow
      tx(motor_wing_x) sq(motor_wing, [1, 1], 5);
    }
    // NEMA face screws, counterbored
    txy([for (x = [-1, 1], y = [-1, 1]) [x, y] * (nema17_hole_spacing / 2)]) {
      tz(-0.5) cylinder(d = 3.4, h = motor_plate_t + 1, $fn = 24);
      tz(motor_plate_t - 2) cylinder(d = 6.2, h = 2.5, $fn = 24);
    }
    tz(-0.5) cylinder(d = nema17_pilot_d + 0.4, h = motor_plate_t + 1, $fn = 64);
    // foot slots along the mesh direction
    txy(motor_feet) tz(-0.5)
      linear_extrude(motor_plate_t + 1)
        hull() tx([-motor_slide, motor_slide]) circle(d = 4.5, $fn = 24);
  }
}

motor_mount();
