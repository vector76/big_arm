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

// A hull CHORDS the helix: between two discs the cutter's outer surface is
// a straight line, so mid-hull it sags BELOW the arc it should be riding.
// That sag is what seg buys down, and the number to read it against is the
// groove's DEPTH (groove_g, 0.6) — not the drum, which is 17x bigger and
// flatters any seg. The sag also scales with arc_r, so a single slice count
// canNOT serve all three drives.
//
// $twin (params.scad) renders the three.js twin, where a whole capstan is
// worth ~30 px and the groove's round bottom is worth none of them: the
// sweep is n = (turns + 1) * seg hulls of an fn-gon disc, so seg and fn
// multiply into the single largest triangle bill in the viewer's meshes.
// The disc (fn) coarsens freely — nobody counts a hexagon's corners at
// 30 px — but seg is DERIVED, not chosen. A flat seg = 8 sagged the chord
// 0.41 mm on the shoulder/elbow and 0.64 mm on the WRIST, whose bigger
// radius made it worst; against a 0.6-deep groove that meant the cutter
// never broke the core surface between nodes at all, and the thread
// rendered as a lattice of detached NUBS instead of a helix. Solving
// twin_err pins the sag to a fixed fraction of the groove on every drive
// (17 slices at arc_r 10.1, 21 at 16) — the twin's mesh now costs its
// triangles where the eye actually reads the part, ALONG the lay.
//
// THE PRINT PATH IS UNTOUCHED — 60/24 and the arc-riding disc center, byte
// for byte what upstream renders. Everything below that moves is gated on
// $twin. A special variable so it reaches this lib, which has no
// params.scad to include.
use <helpers.scad>

// the twin's chord-sag ceiling, mm — 1/6 of the 0.6 groove depth, i.e. the
// coarsest sweep that still cuts a groove you can see. Lower = more slices.
twin_err = 0.1;

module capstan_groove(arc_r, len, p, w, cable,
                      seg = undef, fn = undef) {
  // the cutter's OUTER radius — the surface that has to clear the core, and
  // so the one the slice count must be solved against
  rim = arc_r - cable / 2 + w;
  sg = !is_undef(seg) ? seg
     : ($twin ? ceil(180 / acos(1 - 2 * twin_err / rim)) : 60);
  nf = !is_undef(fn) ? fn : ($twin ? 6 : 24);
  turns = len / p;
  lay = atan(p / (2 * PI * arc_r));
  n = ceil((turns + 1) * sg);
  // ...and, in the twin only, STRADDLE the arc instead of sitting inside it:
  // riding the disc centers out to the mid-chord radius halves the worst sag
  // and centers it on the true groove, so a coarse sweep still lands on the
  // right surface. The print rides the arc itself (k = 1) — at 60 slices its
  // sag is 15 microns and correcting it would be a change to manufacturing
  // truth for no manufacturing reason.
  k = $twin ? (1 + 1 / cos(180 / sg)) / 2 : 1;
  render(convexity = 10)
    for (i = [0 : n - 1]) hull() for (f = [i / n, (i + 1) / n])
      tz(-p / 2 + (len + p) * f)
        rz(-360 * (turns + 1) * f)
          tx((arc_r - cable / 2 + w / 2) * k)
            rx(-lay) rx(90)
              cylinder(d = w, h = 0.02, center = true, $fn = nf);
}
