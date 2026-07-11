// Capstan sector core: a SINGLE CNC plywood plate. The rim is a polygon
// of seg_n flat facets; printed channel segments (sector_segment.scad)
// clip over each facet and carry the true cable arc. Pivot bore at the
// origin fits the hub tube; the six-bolt hub circle stacks the arm.
//
// Export: openscad -o build/sector_core.dxf -D layer=1 sector.scad
// layer=0 renders the core with the printed segments for inspection.

include <params.scad>
use <../lib/helpers.scad>
use <sector_segment.scad>

layer = 0;

pivot_d = hub_tube_od + 0.15; // snug slip over the printed bearing tube
hub_r = sector_hub_r;
arc_band = 45;                // depth of the rim band

// pie with a controllable facet count: n = seg_n gives the rim polygon
module pie(r, ang, n = 0) {
  nn = n > 0 ? n : max(12, ceil(ang / 4));
  polygon(concat([[0, 0]], [for (i = [0 : nn]) [r * cos(-ang / 2 + ang * i / nn),
                                                r * sin(-ang / 2 + ang * i / nn)]]));
}

module sector_core_2d() {
  difference() {
    union() {
      // rim band: polygonal outer edge (the facets), round inner edge
      difference() {
        pie(facet_d / cos(seg_ang / 2), sector_angle, seg_n);
        pie(facet_d - arc_band, sector_angle + 10);
      }
      circle(r = hub_r);
      // spoke: hub to rim mid-arc
      intersection() {
        pie(facet_d, sector_angle);
        sq([facet_d, spoke_w], [0, 1]);
      }
    }
    circle(d = pivot_d);
    // hub circle: stacks the arm across the core
    rz([for (i = [0 : hub_bolt_n - 1]) i * 360 / hub_bolt_n])
      tx(hub_bolt_r) circle(d = hub_bolt_d);
    // segment cheek bolts: two per facet (cartesian in each facet frame,
    // matching the printed segments)
    rz([for (k = [0 : seg_n - 1]) -sector_angle / 2 + (k + 0.5) * seg_ang])
      ty([-facet_d * tan(seg_ang / 2) / 2, facet_d * tan(seg_ang / 2) / 2])
        tx(facet_d - 7) circle(d = 4.5);
  }
}

if (layer == 1) sector_core_2d();
else {
  color("burlywood") tz(-sector_core_t / 2)
    linear_extrude(sector_core_t) sector_core_2d();
  for (k = [0 : seg_n - 1])
    color(k == 0 || k == seg_n - 1 ? "tomato" : "khaki")
      rz(-sector_angle / 2 + (k + 0.5) * seg_ang)
        sector_segment(end = k == 0 ? -1 : k == seg_n - 1 ? 1 : 0);
}
