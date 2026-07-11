// Shoulder testbench — the REAL base + upper arm ARE the test rig
// (supersedes the prototype1 pendulum stand). Same modules, same
// coordinates as assembly.scad; only the environment differs:
//
// - The two-ply slew disc lies FLAT on the desk, clamped dead. The
//   desk top sits at z = disc_z0, so every part keeps its final-
//   assembly coordinates; the board tabs are flush with the disc
//   underside, so the base sits flat. Gear segments, rim rollers,
//   hold-downs, the hub station and the yaw motor are simply not
//   installed yet (all of them live in bench_env(), which this file
//   never draws) — graduating the rig = unclamp the disc and set it
//   on its roller ring.
// - NO forearm, NO elbow bearings: printed bushings fill the empty
//   28.5 elbow pilot bores (where the green joint bushings later
//   land) and standard weight plates slide BARBELL-STYLE onto the
//   ends of the M8 rod through them, outboard of the fork plates.
//   Their CG sits exactly ON the elbow axis — a statically EXACT
//   replica of the whole forearm assembly at every shoulder pose,
//   because the elbow CW is designed to put the forearm+CW CG right
//   there — and the assembly is RIGID: no pendulum dynamics, nothing
//   hanging to foul the truss at steep poses. The plates sweep only
//   r ~67 about the axis, inside the r 72 forearm-root relief and in
//   the |y| > 55 lane nothing else uses, so they clear at every pose.
//   Match the total to the forearm assembly (~6 kg by the model;
//   weigh the real parts) and re-stack to sweep torque margin:
//   tau = m*g*450*cos(pose), max at pose 0, zero crossing at 90
//   exposing backlash as the load swaps gear flanks. (Dynamics read
//   slightly optimistic: a stack AT the axis has less inertia about
//   the shoulder than the real, spread-out forearm.)
//
// Exercised AS-FINAL: the inverted capstan (cable tracking on the
// fixed sector, preload retention, stiffness), the paired-bearing
// shoulder stations, boom fan + counterweight balance and their sweep
// clearances, motor sizing/holding, and the camera + scale-strip
// joint sensor. Left for later phases: yaw drive, the elbow/wrist
// drives (being redesigned), forearm truss, elbow-CW hanger sweep.
//
// CLAMP ZONING: yaw is frozen, so only the pitch sweep matters — the
// boom fan / CW / drive stack own the strip y -75..117 behind the
// shoulder (x < 0), dipping to z 54 just 6 mm over the rim. Keep
// clamp hardware off the rim within ~35 deg of azimuth 180 (or under
// 6 mm tall there); the four bars at 45/135/225/315 all sit outside
// the strip (|y| >= 141 at r 200). Drawn as generic riser-bar
// hold-downs screwed to the desk; C-clamps at a desk edge work the
// same — mind the zoning.
//
// Pose via -D pose_shoulder=<deg> (-20..100, 0 = horizontal).

include <params.scad>
use <../lib/helpers.scad>
use <assembly.scad>

// desk slab, top plane at disc_z0 (see header)
color("wheat") tz(disc_z0 - tb_desk[2]) cub(tb_desk, [1, 1, 0]);

// hold-down bars over the disc rim: bar on the rim, riser block on
// the desk outside it, M8 screw between rim edge and riser
rz(tb_clamp_az) {
  color("khaki") {
    tx(150) tz(disc_z0 + 2 * ply_t) cub([120, 35, 14], [0, 1, 0]);
    tx(225) tz(disc_z0) cub([45, 35, 2 * ply_t], [0, 1, 0]);
  }
  color("silver") tx(212) {
    tz(disc_z0 - 20) cylinder(d = 8, h = 60, $fn = 24);
    tz(disc_z0 + 2 * ply_t + 14) cylinder(d = 14, h = 5, $fn = 24);
  }
}

slew_base(segs = false);
tz(shoulder_h) ry(-pose_shoulder) {
  upper_arm();
  tx(upper_len) test_weight();
}

// the forearm stand-in, at the elbow origin in the upper-arm frame:
// printed bushings fill the pilot bores, the M8 rod spans them, and
// the plates ride sleeves on its overhanging ends, collared — one
// rigid barbell whose CG is the elbow axis itself
module test_weight() {
  color("silver") ty(-(upper_w / 2 + tb_stack + 22)) rx(-90)
    cylinder(d = 8, h = upper_w + 2 * tb_stack + 44, $fn = 24);
  my([0, 1]) {
    color("khaki") {
      ty(upper_w / 2 - ply_t) rx(-90) tube(28, 8.4, ply_t);  // bore filler
      ty(upper_w / 2) rx(-90) tube(40, 8.4, 5);              // flange
      ty(upper_w / 2 + 6) rx(-90) tube(25, 8.4, tb_stack + 4); // sleeve
      ty(upper_w / 2 + 11 + tb_stack) rx(-90) tube(40, 8.4, 6); // collar
    }
    color("slategray") ty(upper_w / 2 + 8) rx(-90)
      cylinder(d = tb_plate_d, h = tb_stack);
  }
}
