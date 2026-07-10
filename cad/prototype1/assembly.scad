// Full pendulum test-stand assembly: vertical board at the bench edge,
// sector + arm swinging on bearings, drum/gear and motor above, weights
// hanging on the arm. Checks proportions, clearances, and the stack-up;
// not a build drawing.
//
// Coordinates: sector pivot at origin, +Y up (gravity -Y), +Z out of the
// board. Arm angle `pose` from straight-down: travel -25..+95.
//   openscad -o build/rig.png --viewall --autocenter assembly.scad
//   openscad -o build/rig_horiz.png -D pose=90 --viewall --autocenter assembly.scad

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>
use <pinion.scad>
use <gear_drum.scad>
use <motor_mount.scad>
use <bridge.scad>
use <sector.scad>
use <hub_tube.scad>
use <spacers.scad>
use <arm.scad>
use <baseplate.scad>

pose = travel_mid;   // arm angle; try -D pose=90 or -D pose=-25

// ---- structure: board, base, gussets ----
color("wheat") tz(board_face_z - board_t) linear_extrude(board_t) board_2d();
color("tan") ty(board_y0) tz(rig_base_front_z) mz(1) rx(90)
  linear_extrude(board_t) base_2d();
color("peru") tx([for (x = gusset_x) x - board_t / 2]) ty(board_y0)
  tz(board_face_z - board_t) ry(90) linear_extrude(board_t) gusset_2d();

// ---- standoffs, stops, axles ----
color("lightsteelblue") tz(board_face_z) sector_standoff();
color("lightsteelblue") txy(drum_pos) tz(board_face_z) drum_standoff();
color("lightsteelblue") rz([90 + travel_mid - stop_beta,
                            90 + travel_mid + stop_beta])
  tx(stop_r) tz(board_face_z) stop_sleeve();
axle_z0 = board_face_z - board_t - 6;    // head + washer behind the board
color("silver") {
  // sector axle and stop posts run up through the pivot beam + nylocs
  tz(axle_z0) cylinder(d = shaft_d, h = pivot_beam_z + board_t + 8 - axle_z0, $fn = 32);
  // drum axle continues through the bridge beam + nyloc
  txy(drum_pos) tz(axle_z0)
    cylinder(d = shaft_d, h = gear_z + drum_z_top + 18 - axle_z0, $fn = 32);
  rz([90 + travel_mid - stop_beta, 90 + travel_mid + stop_beta]) tx(stop_r)
    tz(axle_z0) cylinder(d = shaft_d, h = pivot_beam_z + board_t + 8 - axle_z0, $fn = 32);
}
color("plum") txy(drum_pos) rz(travel_mid) tz(board_face_z) bridge();
color("navajowhite") tz(pivot_beam_z) linear_extrude(board_t) pivot_beam_2d();

// ---- sector + hub tube + arm at the commanded pose ----
color("burlywood") rz(90 + pose) tz(-sector_core_t / 2 - sector_flange_t) {
  linear_extrude(sector_flange_t) sector_flange_2d();
  tz(sector_flange_t) linear_extrude(sector_core_t) sector_core_2d();
  tz(sector_flange_t + sector_core_t)
    linear_extrude(sector_flange_t) sector_flange_2d();
}
color("khaki") tz(-sector_stack_t / 2 - hub_tube_inboard) hub_tube();
color("sandybrown") rz(pose - 90) tz(sector_stack_t / 2)
  linear_extrude(board_t) arm_2d();
// ghost weight at the 450 mm hole
%txy(450 * [sin(pose), -cos(pose)]) ty(-40) tz(18)
  rx(90) cylinder(d = 80, h = 100);

// ---- gear + drum on its dead axle ----
color("steelblue") txy(drum_pos) tz(gear_z) rz(7) gear_drum();

// ---- pinion + motor + rigid mount plate ----
txy(pinion_pos) rz(90 + travel_mid) {
  color("tomato") tz(gear_z) rz(360 / pinion_teeth / 2) pinion();
  color("dimgray") tz(face_z - motor_body_len)
    cub([nema17_body, nema17_body, motor_body_len], [1, 1, 0]);
  color("lightgreen") tz(board_face_z) motor_mount();
}
