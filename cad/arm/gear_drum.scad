// The shoulder's gear+drum, FLIPPED stack: the 51T stub-addendum
// herringbone wheel INBOARD — it straddles the boom plate through the
// plate's kidney cutout — then a short neck, the helically grooved
// capstan core laying across the fixed sector band's tracks (the lay
// is positively located; length = the shared two-cable lay: travel +
// gap + end dead wraps), and past
// the core's outboard flange a bearing BOSS. A gear-outboard stack
// jammed the free end against the boom plate, where no 608 could
// seat without severing the core (pocket 22.1 vs core 20.4);
// flipped, both ends have meat: one 608 pockets into the wheel's
// inboard face, the other into the boss, each with a full-shoulder
// floor and an inner-race relief, and the part spins on a fixed M8
// dead axle (printed inboard support slab + outboard bridge).
// The drum core carries a HELICAL GROOVE at groove_p pitch: the lay
// is positively located, so the take-offs' deterministic march (see
// the two-cable wrap-math note in params.scad) can never bunch or
// climb. TWO CABLES share the one groove — each anchors in a radial
// hole near ITS core end (knot or crimp in the bore annulus behind
// it): run A's at the inboard (z 0) end, run B's at the outboard end,
// with dead_turns of resident wraps between each anchor and its
// take-off extreme. The empty groove between the two take-offs stays
// exactly gap_turns wide at every pose — one cable winds on as the
// other pays off — so drum_len covers travel + gap + both dead zones,
// barely more than half the old pinned-midpoint band + march.
// Local frame: +z outboard, z 0 = the wheel's inboard face (the
// assembly places it at whl_y0).

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>
use <../lib/capstan.scad>

anchor_d = 2.2;                 // cable feed-through, knot or crimp behind it
bore_d = shaft_d + 2.5;         // free clearance around the dead axle
relief_d = 15.5;                // pocket-floor relief: the floor ring
                                // catches the OUTER race only, so the
                                // static inner race never rubs

z_core = core_y0 - whl_y0;      // 35: grooved core start, from the
                                // lane math — locked to the tracks

// flange + grooved core + flange + one anchor hole per core end,
// z 0 = the lower flange's bottom face
module drum_body() difference() {
  union() {
    cylinder(d = drum_flange_d, h = 2);
    tz(2) cylinder(d = drum_core_d, h = drum_len);
    tz(2 + drum_len) cylinder(d = drum_flange_d, h = 2);
  }
  drum_groove();
  // cable anchors: a radial hole anchor_off in from each core end
  // (run A inboard, run B outboard), each rotated to the groove's
  // phase at its height so it lands in the groove floor (the phase
  // sign mirrors the twist's)
  for (h = [anchor_off, drum_len - anchor_off])
    tz(2 + h) rz(360 * (h + groove_p / 2) / groove_p)
      ry(90) cylinder(d = anchor_d, h = drum_flange_d, $fn = 24);
}

// the groove cutter — the shared hull-chain sweep (see
// ../lib/capstan.scad for the construction and its verification
// against the old twisted-extrude crescent).
// LEFT-HAND helix — DERIVED, not chosen: with the real segments in
// the assembly (run A's knot at the lower/gusset end), the winding
// sense demands a LH lay to march WITH the track ramp. The old
// right-hand note predated drawing the segments real: a RH groove
// crosses the tracks at 2.7 deg — the in-opposition failure the
// params wrap-math note warns about.
module drum_groove()
  tz(2) capstan_groove(drum_eff_r, drum_len, groove_p, groove_w, cable_d);

// the shared gear: 51T stub-addendum herringbone
module drive_wheel()
  herringbone_gear(gear_module, gear_teeth, gear_width,
                   helix = helix_angle, pa = pressure_angle,
                   backlash = gear_backlash, ha = wheel_addendum);

module gear_drum() {
  lt = drum_y1 - whl_y0;   // 74: wheel + neck + flanged core + boss
  difference() {
    union() {
      drive_wheel();
      tz(gear_width) cylinder(d = 24, h = z_core - 2 - gear_width);
      tz(z_core - 2) drum_body();
      tz(z_core + drum_len + 2) cylinder(d = 28, h = drum_boss_l);
    }
    tz(-0.5) cylinder(d = bore_d, h = lt + 1, $fn = $twin ? 24 : 48);
    // 608 pockets into both ends; the relief past each floor keeps
    // the rotating floor ring off the static inner race
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = $twin ? 24 : 96);
    tz(-0.5) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = $twin ? 24 : 48);
    tz(lt - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = $twin ? 24 : 96);
    tz(lt - bearing_w - 1) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = $twin ? 24 : 48);
  }
}

gear_drum();
