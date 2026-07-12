// Printed capstan channel segment for a plain CIRCULAR ply rim (in
// the arm: the left base board's sector web), WEDGE-BACKED: the
// TWO-TRACK band seats flush ON the rim, so cable tension presses
// printed part onto wood; outboard of the board face the section
// fills solid from the band down past the rim to the leg — radial
// backing for the track loads — and the leg lands on the OUTBOARD
// ply face with three wood screws, each at the bottom of a deep
// counterbore reaching in from the outboard end face. The band is
// ONE-SIDED: flush with the arm-side face (band_z0), growing
// outboard, per the flush stack-up (params).
//
// The two track slots are 45-deg V's that climb across the arc at the
// shared ~1.4 deg lead (track_z in params.scad): the sector-side lay
// is positively located, the free spans leave square (zero fleet),
// and the V self-centers the cord. The ramp direction must match the
// drum groove's hand (params wrap-math note).
//
// Three ~180 mm prints: -D idx=<0..seg_n-1>. On the end prints the
// anchored run's slot STOPS 2 deg short of the arc end — the
// remaining band IS the anchor abutment: the cord continues through a
// 2.2 hole in line with its track and knots in a shallow recess on
// the segment END face, load path straight along the cord, no bend.
// Run A anchors at the idx-0 end, run B at the far end, the tracks'
// diagonal extremes; the other track runs wall-to-wall (its cable
// never reaches that end anyway). TWO SEPARATE CABLES (params
// wrap-math note): each run's other end knots at its own drum core
// end, not at a shared mid-drum pin — which is why the tracks now sit
// only track_sep apart, and why the band's inboard wall is dead_w
// wider than the outboard one (it faces the drum's inboard anchor +
// dead-wrap zone, where no cable ever lands on the sector).
//
// Print INVERTED, on the wide outboard end face: the arc lies in the
// bed plane, the V walls and the wedge diagonal print at >= 45 deg,
// the leg's board-side land faces UP, and the counterbores rise
// straight off the bed — no support anywhere.
//
// Local frame: arc bisector on +X, joint axis = Z.

include <params.scad>
use <../lib/helpers.scad>

idx = 1;                      // which segment (0..seg_n-1); -D override

half = seg_ang / 2;

// this segment's bisector on the sector arc (deg from the arc bisector)
function seg_bis(i) = -sector_angle / 2 + (i + 0.5) * seg_ang;

// r-z cross-section: track band over the rim; outboard of the board
// face the section fills SOLID down to the leg, closed by the print
// diagonal from the leg's reach up to the wide outboard end face
module seg_profile() polygon([
  [rim_r, band_z0], [crest_r, band_z0],
  [crest_r, band_z0 + band_wt],
  [rim_r - seg_back, band_z0 + band_wt],       // wide outboard face
  [rim_r - leg_d, sector_core_t / 2 + leg_t],  // print diagonal
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
  za = track_z(end * half + seg_bis(i), end);  // anchored track's
                                               // station at the end face
  difference() {
    // the wedge section, swept over this segment's arc
    rz(-half) rotate_extrude(angle = seg_ang, $fn = 240) seg_profile();
    // track slots: the ANCHORED one stops 2 deg short of its arc end,
    // leaving the band itself as the anchor abutment
    track_slot(i, -1, end == -1 ? -half + 2 : -half - 0.5, half + 0.5);
    track_slot(i,  1, -half - 0.5, end == 1 ? half - 2 : half + 0.5);
    // leg screws into the ply face: shaft hole through the leg, head
    // at the bottom of a deep counterbore reaching in from the
    // outboard end face
    rz([-14, 0, 14]) tx(leg_screw_r) {
      tz(sector_core_t / 2 - 0.5)
        cylinder(d = leg_screw_d, h = leg_t + 1, $fn = 16);
      tz(sector_core_t / 2 + leg_t)
        cylinder(d = cb_d, h = band_z0 + band_wt + 1
                 - sector_core_t / 2 - leg_t, $fn = 24);
    }
    // anchor: the cord continues from the slot end through a 2.2 hole
    // in line with its track and knots in a shallow recess on the
    // segment END face — pull is straight along the cord, the knot is
    // tied in the open and seats as it tensions. (In the arm, the
    // lower end's knot sits in the board plane: nick the left board's
    // gusset corner to clear it.)
    if (end != 0) rz(end * half) tx(sector_eff_r) tz(za) {
      ty(-10) rx(-90) cylinder(d = 2.2, h = 16, $fn = 16);
      ty(-3) rx(-90) cylinder(d = 7, h = 6, $fn = 24);
    }
    // ALTERNATIVE anchor, outboard end only: a RADIAL hole just
    // forward of the slot stop — the cord dives from the track floor
    // through the wedge and knots against the inner (diagonal) face,
    // which is open air at run B's station. Either anchor can be
    // used. Run A's end gets no radial hole: its track rides the
    // board plane, so the hole would exit into the ply seat.
    if (end == 1) rz(half - 3) tz(track_z(half - 3 + seg_bis(i), 1))
      tx(218) ry(90) cylinder(d = 2.2, h = 22, $fn = 16);
  }
}

sector_segment(idx, idx == 0 ? -1 : idx == seg_n - 1 ? 1 : 0);
