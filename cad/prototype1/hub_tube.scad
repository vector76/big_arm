// Sector pivot bearing tube (printed). Slides snugly through the sector
// stack's pivot bore; two 608s press into pockets at its ends and ride the
// fixed M8 axle, so the sector pivots on ball bearings, not ply-on-bolt —
// pivot friction sits directly in the efficiency measurement, so it must
// be small and repeatable. The tube carries no torque (the six hub bolts
// clamp arm + sector layers directly); it only centers the stack and
// houses the bearings. Print tube-vertical, no supports.

include <params.scad>
use <../lib/helpers.scad>

tube_len = hub_tube_inboard + sector_stack_t + hub_tube_outboard;  // 38

module hub_tube() {
  difference() {
    cylinder(d = hub_tube_od, h = tube_len, $fn = 96);
    // through bore between the pockets (clears the inner-race spacer)
    tz(-0.5) cylinder(d = hub_tube_bore, h = tube_len + 1, $fn = 64);
    // 608 pockets, one from each end
    tz([-0.5, tube_len - bearing_w])
      cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
  }
}

hub_tube();
