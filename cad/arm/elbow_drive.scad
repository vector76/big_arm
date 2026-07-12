// The elbow's gear+capstan — gear_drum.scad's stack with the wheel
// grown to 66T (primary 8.25: the worm-era 90:1 relaxed to ~65:1
// through the r 80 nose capstan — see the elbow section in
// params.scad). Same shoulder-size grooved core (eff_r 10.125, the
// 1.1 cord's bend floor), same TWO-CABLE end anchors (run A's at the
// inboard end feeding the inboard nose track via sheave A, run B's
// outboard), same 608s pocketed into wheel face + boss, spinning on
// a fixed M8 dead axle between the printed slab and bridge hung off
// the fin. The 66T wheel keeps the 0.45 stub addendum: at C = 74 the
// tips reach r 66.9 vs the 8T interference limit 67.0 — the same
// 0.1 margin the 51T wheel runs at C = 59 (transverse contact stays
// ~1.07-thin; the herringbone face overlap covers, as ever).
// Groove hand drawn LH like the shoulder's — VERIFY against the nose
// anchor phasing at detail time (the march must run WITH the
// take-offs' walk, not against it; the sheaves eat it as fleet).
// Local frame: +z outboard, z 0 = the wheel's inboard face (the
// assembly places it at el_whl_y0).

include <params.scad>
use <../lib/helpers.scad>
use <../lib/gears.scad>

anchor_d = 2.2;                 // cable feed-through, knot or crimp behind it
bore_d = shaft_d + 2.5;         // free clearance around the dead axle
relief_d = 15.5;                // pocket-floor relief (see gear_drum)

el_groove_turns = el_core_len / groove_p;
z_core = el_core_y0 - el_whl_y0;   // 37.7: locked to the track planes

// the groove cutter — gear_drum's twisted annular crescent verbatim
// (see the long note there), at the elbow core length
module el_groove() {
  n = 40;
  cw = 360 * groove_w / groove_p;
  tz(2 - groove_p / 2)
    linear_extrude(el_core_len + groove_p,
                   twist = 360 * (el_groove_turns + 1),
                   slices = ceil(el_groove_turns + 1) * 72, convexity = 10)
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

// flange + grooved core + flange + one anchor hole per core end,
// z 0 = the lower flange's bottom face
module el_drum_body() difference() {
  union() {
    cylinder(d = drum_flange_d, h = 2);
    tz(2) cylinder(d = drum_core_d, h = el_core_len);
    tz(2 + el_core_len) cylinder(d = drum_flange_d, h = 2);
  }
  el_groove();
  for (h = [anchor_off, el_core_len - anchor_off])
    tz(2 + h) rz(360 * (h + groove_p / 2) / groove_p)
      ry(90) cylinder(d = anchor_d, h = drum_flange_d, $fn = 24);
}

module el_wheel()
  herringbone_gear(gear_module, el_teeth, gear_width,
                   helix = helix_angle, pa = pressure_angle,
                   backlash = gear_backlash, ha = wheel_addendum);

module elbow_gear_capstan() {
  lt = el_y1 - el_whl_y0;   // 63.7: wheel + neck + flanged core + boss
  difference() {
    union() {
      el_wheel();
      tz(gear_width) cylinder(d = 24, h = z_core - 2 - gear_width);
      tz(z_core - 2) el_drum_body();
      tz(z_core + el_core_len + 2) cylinder(d = 28, h = bearing_w);
    }
    tz(-0.5) cylinder(d = bore_d, h = lt + 1, $fn = 48);
    tz(-0.5) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    tz(-0.5) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = 48);
    tz(lt - bearing_w) cylinder(d = bearing_pocket_d, h = bearing_w + 0.5, $fn = 96);
    tz(lt - bearing_w - 1) cylinder(d = relief_d, h = bearing_w + 1.5, $fn = 48);
  }
}

elbow_gear_capstan();
