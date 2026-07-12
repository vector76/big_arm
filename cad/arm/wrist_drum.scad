// The wrist DRUM: a full-circle printed ring on the EE fork's LEFT
// side plate (the scale strip owns the right rim), cable centerline
// at wr_drum_r = the nose-cap radius, so the crest pokes only ~2
// proud of the link outline at any pose. Open center: the foot
// flange lands on the plate's outer face AROUND the wrist station's
// green flange (Ø48) and its screw heads, so the ring goes on after
// the joint is assembled and never touches the preload loop. Six
// wood screws (deep head bores reaching in from the outboard face —
// the sector-segment idiom) carry the ~60 N of cable torque into the
// ply disc.
// TWO PLAIN CIRCULAR V-GROOVES, one per run, wr_band apart: with the
// capstan's march only ~2.3 mm over a ~650 mm span (~0.2 deg fleet),
// the ramped-track machinery the shoulder needs is unnecessary here.
// Each groove gets a radial anchor hole through to the open center
// annulus, where the knot ties in free air (anchor azimuths NOMINAL:
// set by wrap phasing — mid-travel wrap + margin from each take-off
// — when the cable routing is finalized).
// V-grooves (not round-bottom): here the groove radius IS the ratio
// radius, but the lever is 50 vs the shoulder's 6.75 — cord-diameter
// error moves the ratio ~0.1%, irrelevant — and the V keeps the rim
// printable printing flat on the inboard face.
// Drawn in the EE frame (wrist axis = y, +y = the drive side); the
// assembly places it unposed.

include <params.scad>
use <../lib/helpers.scad>

wr_apex_r = wr_drum_r - (cable_d / 2) / sin(v_half);   // 49.2
wr_crest_r = wr_drum_r + 1.4;    // cord captive by ~0.85 (sector idiom)
wd_y0 = ee_w / 2;                // 55: the EE plate's outer face
wd_web0 = wr_cab_y - 3;          // 65: web/rim inboard face
wd_y1 = wr_cab_y + wr_band + 3;  // 77.1: outboard face
anchor_az = [264, 90];           // NOMINAL, per groove (see header)

module wd_tube(od, id, y0, y1) difference() {
  ty(y0) rx(-90) cylinder(d = od, h = y1 - y0);
  ty(y0 - 0.5) rx(-90) cylinder(d = id, h = y1 - y0 + 1);
}

module wrist_drum() difference() {
  union() {
    wd_tube(wr_hub_od, wr_hub_id, wd_y0, wd_web0);        // foot + shell
    wd_tube(2 * wr_crest_r, wr_hub_id, wd_web0, wd_y1);   // web + rim
  }
  // the two V-grooves, cut as revolved triangles about the axis
  for (i = [0, 1]) ty(wr_cab_y + i * wr_band) rx(-90)
    rotate_extrude($fn = 120)
      polygon([[wr_apex_r, 0],
               [wr_crest_r + 2, wr_crest_r + 2 - wr_apex_r],
               [wr_crest_r + 2, -(wr_crest_r + 2 - wr_apex_r)]]);
  // radial anchor holes, groove floor through to the open center
  for (i = [0, 1]) ry(-anchor_az[i]) ty(wr_cab_y + i * wr_band)
    ry(90) tz(wr_hub_id / 2 - 2)
      cylinder(d = 2.2, h = wr_crest_r - wr_hub_id / 2 + 4, $fn = 24);
  // six wood screws into the EE plate: shank through the foot, head
  // bore reaching in from the outboard face
  ry([for (k = [0 : 5]) k * 60 + 30]) tx(wr_screw_r) {
    ty(wd_y0 - 1) rx(-90) cylinder(d = 3.6, h = 6, $fn = 24);
    ty(wd_y0 + 4) rx(-90) cylinder(d = 7.5, h = wd_y1 - wd_y0, $fn = 24);
  }
}

wrist_drum();
