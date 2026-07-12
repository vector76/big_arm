// Printed capstan channel L-SEGMENT for a plain CIRCULAR ply rim (in
// the arm: the left base board's sector web). Cross-section is an L:
// the top arm — the TWO-TRACK band — seats flush ON the rim, so cable
// tension presses printed part onto wood and the fasteners only
// locate; the leg drops down the OUTBOARD ply face and takes three
// wood screws. The band is ONE-SIDED: flush with the arm-side face
// (band_z0), growing outboard, per the flush stack-up (params).
//
// The two track slots are 45-deg V's that climb across the arc at the
// shared ~1.9 deg lead (track_z in params.scad): the sector-side lay
// is positively located, the free spans leave square (zero fleet),
// and the V self-centers the cord. The ramp direction must match the
// drum groove's hand (params wrap-math note).
//
// Three ~180 mm prints: -D idx=<0..seg_n-1>. idx 0 and seg_n-1 grow a
// full-height anchor wall with the cable hole at ITS track's station —
// run A anchors at the idx-0 end, run B at the far end, the tracks'
// diagonal extremes (the other track never reaches that end, so the
// full wall costs it nothing).
//
// Print lying on the flush face: the arc lies in the bed plane, the V
// walls print at 45 deg, and the only support needed is the one flat
// plane under the leg (or swap the leg for ribs + screw bosses at
// print time and skip support entirely).
//
// Local frame: arc bisector on +X, joint axis = Z.

include <params.scad>
use <../lib/helpers.scad>

idx = 1;                      // which segment (0..seg_n-1); -D override

half = seg_ang / 2;

// this segment's bisector on the sector arc (deg from the arc bisector)
function seg_bis(i) = -sector_angle / 2 + (i + 0.5) * seg_ang;

// r-z cross-section of the L: track band over the rim, leg down the
// outboard face
module seg_profile() polygon([
  [rim_r, band_z0], [crest_r, band_z0],
  [crest_r, band_z0 + band_wt], [rim_r, band_z0 + band_wt],
  [rim_r, sector_core_t / 2 + leg_t],
  [rim_r - leg_d, sector_core_t / 2 + leg_t],
  [rim_r - leg_d, sector_core_t / 2], [rim_r, sector_core_t / 2]]);

// one track slot: pairwise hulls of thin V slabs step the ramp —
// exact, since the ramp is linear in arc angle
module track_slot(i, run, a0, a1) {
  n = max(2, ceil((a1 - a0) / 3));
  for (k = [0 : n - 1]) hull() {
    slot_slab(i, run, a0 + k * (a1 - a0) / n);
    slot_slab(i, run, a0 + (k + 1) * (a1 - a0) / n);
  }
}
// the V cross-section (apex inward), stood tangentially thin at
// local angle a
module slot_slab(i, run, a) rz(a) rx(90)
  linear_extrude(0.05, center = true)
    polygon(let (zt = track_z(a + seg_bis(i), run),
                 o = (crest_r + 0.5 - apex_r) * tan(v_half))
      [[apex_r, zt], [crest_r + 0.5, zt + o], [crest_r + 0.5, zt - o]]);

module sector_segment(i = idx, end = 0) {
  za = track_z(end * (half - 1.5) + seg_bis(i), end);  // anchored track's
                                                       // station at the wall
  difference() {
    union() {
      difference() {
        // the L, swept over this segment's arc
        rz(-half) rotate_extrude(angle = seg_ang, $fn = 240) seg_profile();
        // both track slots, wall-to-wall across the segment
        track_slot(i, -1, -half - 0.5, half + 0.5);
        track_slot(i,  1, -half - 0.5, half + 0.5);
        // leg screw holes, into the ply face
        rz([-14, 0, 14]) tx(leg_screw_r) tz(sector_core_t / 2 - 0.5)
          cylinder(d = leg_screw_d, h = leg_t + 1, $fn = 16);
      }
      // anchor wall at an end variant: full band height, added after
      // the slots so it closes the anchored track
      if (end != 0) rz(end * (half - 1.5)) tx(apex_r - 2) tz(band_z0)
        cub([crest_r - apex_r + 3, 5, band_wt], [0, end == 1 ? -1 : 0, 0]);
    }
    // anchor: cable hole through the wall in line with the track,
    // knot cavity behind
    if (end != 0) rz(end * (half - 1.5)) tx(sector_eff_r) tz(za) {
      rz(end * 90) ty(-6) rx(-90) cylinder(d = 2.2, h = 12, $fn = 16);
      rz(end * 90) ty(-14) rx(-90) cylinder(d = 7, h = 8, $fn = 24);
    }
  }
}

sector_segment(idx, idx == 0 ? -1 : idx == seg_n - 1 ? 1 : 0);
