// Printed spacer set for the two M8 dead axles and the travel stops.
//
// Each axle is a preloaded stack: bolt head + fender washer behind the
// board, board, a thick-walled standoff tube (flange bolted to the board
// face — the flange, not the bolt, reacts the cantilever moment), a small
// step that bears only on the 608 inner race, the spinning part with its
// two bearings and an inner-race spacer between them, a top washer, nyloc.
// Torqued up, the stack acts as one rigid post.
//
// Standoffs print flange-down (no supports); sleeves and spacers vertical.
// Local z = 0 is the board face for the standoffs and sleeves.

include <params.scad>
use <../lib/helpers.scad>

module tube(od, id, h, f = 48) difference() {
  cylinder(d = od, h = h, $fn = f);
  tz(-0.5) cylinder(d = id, h = h + 1, $fn = f);
}

// board face -> inboard face of the sector's inboard bearing inner race
sector_standoff_len = -(sector_stack_t / 2) - hub_tube_inboard - board_face_z;
// board face -> underside of the gear (its lower bearing sits flush there)
drum_standoff_len = gear_z - board_face_z;
// the stop sleeves run all the way up to the pivot beam they now carry;
// the spoke (single-ply core) still strikes them at its own height, and
// the arm passing above at z 6..18 clears the sleeve OD
stop_sleeve_len = pivot_beam_z - board_face_z;

module standoff(od, len, flange_d, bolt_r, n_bolt, a0 = 0, flat = 0) {
  difference() {
    union() {
      cylinder(d = flange_d, h = standoff_flange_t, $fn = 96);
      cylinder(d = od, h = len - race_tip_h, $fn = 96);
      cylinder(d = race_tip_d, h = len, $fn = 48);
    }
    tz(-0.5) cylinder(d = axle_hole_d, h = len + 1, $fn = 48);
    rz([for (i = [0 : n_bolt - 1]) a0 + i * 360 / n_bolt]) tx(bolt_r)
      tz(-0.5) cylinder(d = 4.5, h = standoff_flange_t + 1, $fn = 24);
    // optional flat on the flange (clearance to the motor plate, which
    // sits radially outboard: 90 + travel_mid in board coords)
    if (flat > 0) rz(90 + travel_mid) tx(flat) tz(-0.5)
      cub([flange_d, flange_d + 2, standoff_flange_t + 2], [0, 1, 0]);
  }
}

module sector_standoff()
  standoff(sector_standoff_od, sector_standoff_len,
           sector_standoff_flange_d, sector_standoff_bolt_r, 4, 45);

// The motor plate edge comes within 24 mm of the drum axis at board level,
// so the flange is flatted toward the pinion (radially outboard) and the
// two bolts sit perpendicular to that direction. The M8's own preload
// through the board carries the moment; the M4s just stop the foot walking.
module drum_standoff()
  standoff(drum_standoff_od, drum_standoff_len,
           drum_standoff_flange_d, drum_standoff_bolt_r, 2, travel_mid,
           flat = 20);

// between the inner races inside the hub tube / gear+drum
module hub_inner_spacer()  tube(11, axle_hole_d, sector_stack_t);
module drum_inner_spacer() tube(10.2, axle_hole_d, drum_z_top - 2 * bearing_w);

// under the nyloc, bearing only on the inner race
module top_washer() tube(12, axle_hole_d, 2);

module stop_sleeve() tube(stop_sleeve_od, shaft_d + 0.6, stop_sleeve_len);

// drops from the pivot beam through the arm's center hole onto the
// outboard 608's inner race: nut -> beam -> flange -> nub -> race
module pivot_pilot() {
  difference() {
    union() {
      cylinder(d = 20, h = 2, $fn = 48);
      cylinder(d = race_tip_d, h = pivot_beam_z - sector_stack_t / 2
                                   - hub_tube_outboard, $fn = 48);
    }
    tz(-0.5) cylinder(d = axle_hole_d, h = pivot_beam_z + 1, $fn = 32);
  }
}

// ---- print plate ----
sector_standoff();
tx(80) drum_standoff();
tx(150) hub_inner_spacer();
tx(180) drum_inner_spacer();
tx(210) top_washer();   // sector axle only: the bridge's integral race
                        // pilot serves the drum axle
txy([[150, 40], [180, 40]]) stop_sleeve();
txy([240, 0]) pivot_pilot();
