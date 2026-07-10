// Capstan cable sector: three CNC-cut plywood layers. The middle (core)
// layer's edge is the cable-riding surface; the two flange layers overhang
// to keep the cable captive. Pivot bore at the origin.
//
// Export DXFs for the CNC:
//   openscad -o sector_core.dxf   -D layer=1 sector.scad
//   openscad -o sector_flange.dxf -D layer=2 sector.scad
// layer=0 renders the 3D stack for inspection.

include <params.scad>
use <../lib/helpers.scad>

layer = 0;

pivot_d = hub_tube_od + 0.15; // snug slip over the printed bearing tube
hub_r = sector_hub_r;
arc_band = 45;                // depth of the rim band
bolt_d = 4.5;                 // layer-stacking bolts
flange_r = sector_core_r + cable_d + sector_flange_extra;

module pie(r, ang) {
  n = max(12, ceil(ang / 4));
  polygon(concat([[0, 0]], [for (i = [0 : n]) [r * cos(-ang / 2 + ang * i / n),
                                               r * sin(-ang / 2 + ang * i / n)]]));
}

module sector_shape(r) {
  union() {
    // rim band
    difference() {
      pie(r, sector_angle);
      pie(r - arc_band, sector_angle + 10);
    }
    // hub
    circle(r = hub_r);
    // spoke: hub to rim mid-arc
    intersection() {
      pie(r, sector_angle);
      sq([r, spoke_w], [0, 1]);
    }
  }
}

module sector_holes() {
  circle(d = pivot_d);
  // stacking bolts: along the rim band and around the hub
  rz([for (a = [-sector_angle / 2 + 8 : 22 : sector_angle / 2 - 8]) a])
    tx(sector_core_r - arc_band / 2) circle(d = bolt_d);
  // hub circle: stacks the layers AND mounts the arm across the stack
  rz([for (i = [0 : hub_bolt_n - 1]) i * 360 / hub_bolt_n])
    tx(hub_bolt_r) circle(d = hub_bolt_d);
  // cable termination holes near both ends of the arc
  rz([-(sector_angle / 2 - 4), sector_angle / 2 - 4])
    tx(sector_core_r - 12) circle(d = 3.2);
}

module sector_core_2d() {
  difference() { sector_shape(sector_core_r); sector_holes(); }
}

module sector_flange_2d() {
  difference() { sector_shape(flange_r); sector_holes(); }
}

if (layer == 1) sector_core_2d();
else if (layer == 2) sector_flange_2d();
else {
  color("burlywood") tz(sector_flange_t)
    linear_extrude(sector_core_t) sector_core_2d();
  color("tan") tz([0, sector_flange_t + sector_core_t])
    linear_extrude(sector_flange_t) sector_flange_2d();
}
