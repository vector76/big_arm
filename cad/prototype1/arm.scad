// Pendulum test arm (CNC 12 mm ply). Bolts flat against the sector's
// outboard flange on the six-bolt hub circle (M4 x 50 through arm, sector
// stack, and nuts behind); the center hole rides around the protruding
// hub tube and axle hardware. Weights hang in the calibrated holes:
// tau = m * g * r * sin(theta) — at the 450 mm hole, 6.05 kg gives the
// full 26.7 N*m worst-case shoulder torque at horizontal. Weigh the arm
// and include its own first moment in the analysis.
//
// Export: openscad -o build/arm.dxf -D layer=1 arm.scad

include <params.scad>
use <../lib/helpers.scad>

layer = 0;

module arm_2d() {
  difference() {
    hull() {
      circle(r = arm_root_r);
      tx(arm_len - arm_tip_r) circle(r = arm_tip_r);
    }
    circle(d = arm_center_hole_d);
    rz([for (i = [0 : hub_bolt_n - 1]) i * 360 / hub_bolt_n])
      tx(hub_bolt_r) circle(d = hub_bolt_d);
    tx(arm_holes) circle(d = arm_hole_d);
  }
}

if (layer == 1) arm_2d();
else color("burlywood") linear_extrude(board_t) arm_2d();
