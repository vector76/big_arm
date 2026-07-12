// Capstan sector core reference: a SINGLE CNC plywood plate with a
// plain CIRCULAR rim at rim_r; the printed L-segments
// (sector_segment.scad) seat their track band flush on that rim and
// screw to the outboard face. In the arm the web is no separate part —
// the fixed sector is one CNC piece with the left base board — so this
// file survives as the reference for that board's rim radius and screw
// pattern. The pivot bore and six-bolt hub circle belong to the
// superseded pendulum stand.
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

module pie(r, ang) {
  n = max(12, ceil(ang / 4));
  polygon(concat([[0, 0]],
    [for (i = [0 : n]) [r * cos(-ang / 2 + ang * i / n),
                        r * sin(-ang / 2 + ang * i / n)]]));
}

module sector_core_2d() {
  difference() {
    union() {
      // rim band: circular outer edge the segment bands seat on
      difference() {
        pie(rim_r, sector_angle);
        pie(rim_r - arc_band, sector_angle + 10);
      }
      circle(r = hub_r);
      // spoke: hub to rim mid-arc
      intersection() {
        pie(rim_r, sector_angle);
        sq([rim_r, spoke_w], [0, 1]);
      }
    }
    circle(d = pivot_d);
    // hub circle: stacks the arm across the core
    rz([for (i = [0 : hub_bolt_n - 1]) i * 360 / hub_bolt_n])
      tx(hub_bolt_r) circle(d = hub_bolt_d);
    // leg screw pilots: three per segment, matching the printed legs
    rz([for (k = [0 : seg_n - 1], da = [-14, 0, 14])
        -sector_angle / 2 + (k + 0.5) * seg_ang + da])
      tx(leg_screw_r) circle(d = 2.5);
  }
}

if (layer == 1) sector_core_2d();
else {
  color("burlywood") tz(-sector_core_t / 2)
    linear_extrude(sector_core_t) sector_core_2d();
  for (k = [0 : seg_n - 1])
    color(k == 0 || k == seg_n - 1 ? "tomato" : "khaki")
      rz(-sector_angle / 2 + (k + 0.5) * seg_ang)
        sector_segment(k, k == 0 ? -1 : k == seg_n - 1 ? 1 : 0);
}
