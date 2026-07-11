// Plywood box-truss link (concept level): two side plates carrying a
// Warren-style triangulated cutout pattern, top and bottom chords
// between them. Tab-and-slot joinery is deferred to detailed design —
// what matters here is the envelope and the look of the structure.
//
// Local frame: runs x0..x1 along +X, width w across Y, depth d across Z,
// centered on the link axis (y = 0, z = 0).

include <params.scad>
use <../lib/helpers.scad>

// Warren cutouts: INTERLEAVED triangles at half-bay pitch between the
// margin chords. Each triangle spans a full bay (2*p wide) so adjacent
// diagonal edges are parallel; insetting both side edges of every
// triangle by g PERPENDICULAR to the edge (a horizontal shift of
// g/sin(theta), which keeps the slope exact) leaves 2*g-wide diagonal
// members that read like the margin-wide chords. Bases stay on the
// margin frame; the apex recedes by the miter (s*h/p), which reads as
// the joint gusset. s0/s1 keep the plate SOLID for that length at the
// start/end — the joint zones, where the bearing stations mount and
// the load concentrates, get no cutouts.
module truss_plate_2d(l, d, margin = 14, s0 = 0, s1 = 0) {
  g = 7;                                    // half-width of a diagonal
  h = d - 2 * margin;
  lp = l - s0 - s1;                         // patterned span
  n = max(2, floor((lp - 2 * margin) / (d * 0.36)) - 1);   // triangles
  p = (lp - 2 * margin) / (n + 1);          // half-bay pitch
  s = min(g * sqrt(h * h + p * p) / h,      // horizontal edge inset...
          0.45 * p);                        // ...capped for short links
  ya = h * (1 - s / p);                     // apex height after inset
  difference() {
    sq([l, d], [0, 1]);
    for (i = [0 : n - 1]) {
      x0 = s0 + margin + i * p;
      up = (i % 2 == 0);
      polygon(up
        ? [[x0 + s, -h / 2], [x0 + 2 * p - s, -h / 2],
           [x0 + p, -h / 2 + ya]]
        : [[x0 + s, h / 2], [x0 + 2 * p - s, h / 2],
           [x0 + p, h / 2 - ya]]);
    }
  }
}

// side plates and chords in distinct colors so the four-plate build-up
// of each box section reads in renders. bot_relief > 0 cuts the bottom
// chord back in a circular arc of that radius about the joint axis at
// x1 — the swept circle of a folding child link's root — so the chords
// are drawn individually rather than mz-mirrored as a pair
module box_truss(x0, x1, w, d, bot_relief = 0, solid0 = 0, solid1 = 0) {
  l = x1 - x0;
  // side plates (2D drawn in XY, stood into XZ); NOT relieved — they
  // run full length past the axis as the joint fork, solid in the
  // solid0/solid1 joint zones
  color("burlywood") my([0, 1]) ty(w / 2) rx(90) linear_extrude(ply_t)
    tx(x0) truss_plate_2d(l, d, 14, solid0, solid1);
  color("sienna") tz(d / 2 - ply_t) linear_extrude(ply_t)
    chord_2d(x0, x1, w);
  color("sienna") mz(1) tz(d / 2 - ply_t) linear_extrude(ply_t)
    chord_2d(x0, x1, w, bot_relief);
}

// chord board 2D: plain plate with rectangular lightening holes and an
// optional end relief circle about the joint at x1
module chord_2d(x0, x1, w, rr = 0) {
  l = x1 - x0;
  tx(x0) difference() {
    sq([l, w - 2 * ply_t], [0, 1]);
    nb = max(1, floor(l / 150));
    for (i = [0 : nb - 1])
      tx(20 + i * (l - 40) / nb + (l - 40) / nb / 2)
        sq([(l - 40) / nb - 30, w - 2 * ply_t - 30], [1, 1], 8);
    if (rr > 0) tx(l) circle(r = rr);
  }
}
