// The wrist's gear+capstan — gear_drum.scad's idiom at wrist scale.
// Same stack, same reasons: the 51T stub-addendum herringbone wheel
// INBOARD (straddling the CW fin through its kidney cutout), a short
// neck, the helically grooved capstan core out at the cable plane,
// and a bearing BOSS outboard; 608s pocket into both ends (full-
// shoulder floors, inner-race reliefs) and the part spins on a fixed
// M8 dead axle (inboard support slab + outboard bridge, hung off the
// fin). The core is FAT (Ø32 vs the shoulder's Ø20.4 — ~10 mm of
// wall over the bore) because the ratio lives at the EE drum, not
// here. Mid-groove radial anchor hole splits the wraps into the two
// runs, exactly as at the shoulder; only ~1.6 turns of travel, so
// the whole grooved band is 11 mm.
// Groove hand drawn LH like the shoulder's — VERIFY against the EE
// drum's anchor phasing at detail time (the wrap-math rule in
// params.scad: the march must run WITH the take-offs' walk, not
// against it).
// Local frame: +z outboard, z 0 = the wheel's inboard face (the
// assembly places it at wr_whl_y0).

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>
use <../lib/capstan.scad>

anchor_d = 2.2;                 // cable feed-through, knot behind it
bore_d = shaft_d + 2.5;         // free clearance around the dead axle
relief_d = 15.5;                // pocket-floor relief (see gear_drum)

wr_core_d = 2 * (wr_cap_r - cable_d / 2 + groove_g);   // 32.1
wr_flange_d = 37;               // ~2 proud of the cable crest (33.1)
z_core = wr_core_y0 - wr_whl_y0;   // 38.5: locked to the cable plane

// the groove cutter — the shared hull-chain sweep (LH lay; see
// ../lib/capstan.scad), at the wrist capstan radius and length
module wr_groove()
  tz(2) capstan_groove(wr_cap_r, wr_cap_len, groove_p, groove_w, cable_d);

// flange + grooved core + flange + mid-groove anchor, z 0 = the lower
// flange's bottom face
module wr_capstan_body() difference() {
  union() {
    cylinder(d = wr_flange_d, h = 2);
    tz(2) cylinder(d = wr_core_d, h = wr_cap_len);
    tz(2 + wr_cap_len) cylinder(d = wr_flange_d, h = 2);
  }
  wr_groove();
  tz(2 + wr_cap_len / 2)
    rz(360 * (wr_cap_len / 2 + groove_p / 2) / groove_p)
    ry(90) cylinder(d = anchor_d, h = wr_flange_d, $fn = 24);
}

module wrist_gear_capstan() {
  lt = wr_y1 - wr_whl_y0;   // 58.5: wheel + neck + flanged core + boss
  difference() {
    union() {
      herringbone_gear(gear_module, gear_teeth, gear_width,
                       helix = helix_angle, pa = pressure_angle,
                       backlash = gear_backlash, ha = wheel_addendum);
      // the neck all but vanishes with the cable plane hugging the
      // wood (wr_cab_y 59 leaves ~0.2); clamp it non-negative so a
      // further inboard push degenerates gracefully to flange-on-wheel
      tz(gear_width)
        cylinder(d = 24, h = max(0.1, z_core - 2 - gear_width));
      tz(z_core - 2) wr_capstan_body();
      tz(z_core + wr_cap_len + 2) cylinder(d = 28, h = bearing_w);
    }
    tz(-0.5) cylinder(d = bore_d, h = lt + 1, $fn = 48);
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    tz(-0.5) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = 48);
    tz(lt - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    tz(lt - bearing_w - 1) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = 48);
  }
}

wrist_gear_capstan();
