// Printed capstan channel segment. Flat on the inside (registers against
// one polygon facet of the single-ply sector core, gripped by cheeks and
// two M4 through-bolts), true arc on the outside with a U-groove that
// carries the cable between flange walls. Print 7 plain (end = 0) plus
// one of each end variant (end = -1 / +1), which close the groove with
// an anchor wall: the cable exits through a 2.2 mm hole and knots in the
// cavity behind — no more routing around ply edges.
//
// Local frame: facet centered on +X, joint axis = Z. Print flat-side
// down (cheek side up needs no support at these overhang widths).

include <params.scad>
use <../lib/helpers.scad>

half = seg_ang / 2;
chord = 2 * facet_d * tan(half);

// r-z cross-section of the channel: facet plane to groove floor to walls
module seg_profile() polygon([
  [facet_d - 1, -seg_cheek], [seg_flange_r, -seg_cheek],
  [seg_flange_r, -1.6], [sector_core_r, -1.6],
  [sector_core_r, 1.6], [seg_flange_r, 1.6],
  [seg_flange_r, seg_cheek], [facet_d - 1, seg_cheek]]);

module sector_segment(end = 0) {
  difference() {
    union() {
      // the arc body: profile swept over this facet's angle
      rz(-half) rotate_extrude(angle = seg_ang, $fn = 180) seg_profile();
      // gripping cheeks astride the ply, inward of the facet
      intersection() {
        tx(facet_d - seg_grip)
          cub([seg_grip + 1, chord - 2, 2 * seg_cheek], [0, 1, 1]);
        rz(-half) pie_block();
      }
      // anchor wall at an end variant
      if (end != 0) rz(end * (half - 1.5))
        tx(sector_core_r - 6) cub([seg_flange_r - sector_core_r + 6, 5, 2 * seg_cheek],
                                  [0, end == 1 ? -1 : 0, 1]);
    }
    // ply slot between the cheeks
    tx(facet_d - seg_grip - 0.5)
      cub([seg_grip + 2, chord + 2, sector_core_t + 0.3], [0, 1, 1]);
    // cheek bolts (match the core's facet holes)
    ty([-chord / 4, chord / 4]) tx(facet_d - 7) tz(-seg_cheek - 0.5)
      cylinder(d = 4.5, h = 2 * seg_cheek + 1, $fn = 24);
    // anchor: cable hole through the wall, knot cavity behind
    if (end != 0) rz(end * (half - 1.5)) tx(sector_eff_r) {
      rz(end * 90) ty(-6) rx(-90) cylinder(d = 2.2, h = 12, $fn = 16);
      rz(end * 90) ty(-14) rx(-90) cylinder(d = 7, h = 8, $fn = 24);
    }
  }
}

// angular wedge used to trim the cheeks to this facet's slice
module pie_block() rotate_extrude(angle = seg_ang, $fn = 60)
  sq([facet_d + 20, 2 * seg_cheek + 2], [0, 1]);

sector_segment();
