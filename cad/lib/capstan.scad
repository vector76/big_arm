// Helical round-bottom groove cutter for cable capstans — shared by
// the shoulder drum and the elbow/wrist capstans: a chain of pairwise-
// hulled discs marching down the helix. Each disc is the groove's
// circular cross-section made thinly 3D (hull needs a solid), held
// normal to the cable path; hulling each adjacent pair sweeps the
// round-bottom groove directly, with the mesh quads lying ALONG the
// lay. (A twisted-extrude crescent cuts the same groove — verified on
// the shoulder drum, ~15 mm^3 of residue, all at the run-out ends —
// but its facets crosshatch the surface as 20-micron slivers.)
// LEFT-hand helix (rz marches negative with z), the hand every capstan
// in the arm wants; see the winding-sense notes in the callers.
// Frame: the grooved core spans z 0..len; the groove runs a half pitch
// past each end so it is full depth at the core faces (it tails out
// round instead of the old chopped flat, staying inside the flanges).
// The disc center rides the groove ARC's center — half the w-vs-cable
// clearance outboard of arc_r, the cord centerline radius — so the
// seated cord's center lands exactly at arc_r.
// render(): bakes the hulls to one mesh, else F5 preview's CSG
// normalization explodes on difference-over-hundreds-of-hulls.

// $twin (params.scad) renders the three.js twin with NO groove at all —
// the cutter emits nothing, so the core stays a smooth cylinder. The
// groove can't be coarsened instead: the sweep is n = (turns + 1) * seg
// hulls of an fn-gon disc, so seg and fn multiply into the largest
// triangle bill in the viewer's meshes, and at a cheap 8/8 the chain's
// kinks bite past the groove envelope and read as holes punched through
// the wall. Wrong-looking loses to smooth. The print keeps 60/24. A
// special variable so it reaches this lib, which has no params.scad to
// include.
use <helpers.scad>

module capstan_groove(arc_r, len, p, w, cable, seg = 60, fn = 24) {
  turns = len / p;
  lay = atan(p / (2 * PI * arc_r));
  n = ceil((turns + 1) * seg);
  if (!$twin) render(convexity = 10)
    for (i = [0 : n - 1]) hull() for (f = [i / n, (i + 1) / n])
      tz(-p / 2 + (len + p) * f)
        rz(-360 * (turns + 1) * f)
          tx(arc_r - cable / 2 + w / 2)
            rx(-lay) rx(90)
              cylinder(d = w, h = 0.02, center = true, $fn = fn);
}
