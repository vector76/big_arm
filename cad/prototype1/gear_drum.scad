// Driven gear (51T herringbone) with integrated cable drum — TWO
// build variants sharing the same drum_body() and gear call, so they
// cannot drift apart:
//  - gear_drum(): the original stack — gear at the base, drum above,
//    bearing boss on top; two 608s press in, spins on a fixed M8
//    dead axle.
//  - arm_gear_drum(neck): the ARM's shoulder part — REVERSED: drum at
//    the base (its groove lays across the fixed sector band's
//    tracks), a short printed neck spanning the band's outboard wall
//    (length from the arm's lane math), and the gear outboard past
//    the band's end. A gear at the base would sweep through the
//    fixed band, and the boss would collide with the arm's boom
//    plate, so here both 608s pocket INTO the part's ends.
// The drum core carries a HELICAL GROOVE at groove_p pitch: the lay
// is positively located, so the wrap band's deterministic march (see
// the wrap-math note in params.scad) can never bunch or climb —
// drum_len covers band + march. Cable anchors in a radial hole
// MID-GROOVE (knot or crimp in the bore annulus behind it), splitting
// the wraps into the two runs.

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>

anchor_d = 2.2;                 // cable feed-through, knot or crimp behind it
bore_d = shaft_d + 2.5;         // free clearance around the dead axle

z_top = drum_z_top;             // shared with the axle spacer stack
groove_turns = drum_len / groove_p;

// flange + grooved core + flange + mid-groove anchor hole, z 0 = the
// lower flange's bottom face — the shared heart of both variants
module drum_body() difference() {
  union() {
    cylinder(d = drum_flange_d, h = 2);
    tz(2) cylinder(d = drum_core_d, h = drum_len);
    tz(2 + drum_len) cylinder(d = drum_flange_d, h = 2);
  }
  drum_groove();
  // cable anchor: radial hole mid-groove, rotated to the groove's
  // phase at that height so it lands in the groove floor
  tz(2 + drum_len / 2) rz(-360 * (drum_len / 2 + groove_p / 2) / groove_p)
    ry(90) cylinder(d = anchor_d, h = drum_flange_d, $fn = 24);
}

// the groove cutter, by twisted extrude. Under twist, a 2D shape's
// ARC ANGLE maps to AXIAL EXTENT: at fixed azimuth, material spans
// z = delta * p / 360 for each arc-degree delta the shape covers. So
// the cutter must be an annular CRESCENT spanning 360*w/p degrees
// (300 here) whose inner edge traces the groove's round bottom as a
// function of that axial offset — the cord then seats on the floor
// with its center exactly at drum_eff_r. (A small offset CIRCLE does
// NOT work: it subtends ~10 deg, which sweeps a hairline ribbon coil
// ~0.05 tall — the "groove" the first two attempts actually cut.)
// RIGHT-HAND helix (negative twist) — the sector track ramp direction
// must match (params wrap-math note).
module drum_groove() {
  n = 40;
  cw = 360 * groove_w / groove_p;   // crescent arc width, deg
  tz(2 - groove_p / 2)
    linear_extrude(drum_len + groove_p, twist = -360 * (groove_turns + 1),
                   slices = ceil(groove_turns + 1) * 72, convexity = 10)
      polygon(concat(
        [for (i = [0 : n])
          let (d = -cw / 2 + cw * i / n,
               u = d * groove_p / 360,
               ri = drum_eff_r - cable_d / 2 + groove_w / 2
                    - sqrt(max(0, pow(groove_w / 2, 2) - u * u)))
            ri * [cos(d), sin(d)]],
        [for (i = [0 : n]) let (d = cw / 2 - cw * i / n)
          (drum_core_d / 2 + 0.7) * [cos(d), sin(d)]]));
}

// the shared gear: 51T stub-addendum herringbone
module drive_wheel()
  herringbone_gear(gear_module, gear_teeth, gear_width,
                   helix = helix_angle, pa = pressure_angle,
                   backlash = gear_backlash, ha = wheel_addendum);

module gear_drum() {
  difference() {
    union() {
      drive_wheel();
      tz(gear_width) drum_body();
      // bearing boss above the drum
      tz(gear_width + 4 + drum_len) cylinder(d = top_hub_d, h = top_hub_h);
    }
    // axle clearance bore, full length
    tz(-0.5) cylinder(d = bore_d, h = z_top + 1, $fn = 48);
    // lower bearing pocket, inset into the gear underside
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    // upper bearing pocket, from the top of the boss
    tz(z_top - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
  }
}

// the ARM variant; `neck` comes from the arm's lane math (assembly
// passes whl_y0 - cab_y0 - 2 - drum core-and-flanges)
module arm_gear_drum(neck = 3.5) {
  lt = 4 + drum_len + neck + gear_width;   // total length
  difference() {
    union() {
      drum_body();
      tz(4 + drum_len) cylinder(d = 24, h = neck);
      tz(4 + drum_len + neck) drive_wheel();
    }
    tz(-0.5) cylinder(d = bore_d, h = lt + 1, $fn = 48);
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    tz(lt - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
  }
}

gear_drum();
