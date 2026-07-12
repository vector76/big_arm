// Plywood box-truss link (concept level): two side plates carrying a
// Warren-style triangulated cutout pattern, top and bottom chords
// between them. Tab-and-slot joinery is deferred to detailed design —
// what matters here is the envelope and the look of the structure.
//
// Local frame: runs x0..x1 along +X, width w across Y, depth across Z,
// centered on the link axis (y = 0, z = 0). The links TAPER: depth d0
// at x0, d1 at x1, symmetric about the axis, so the side plates are
// trapezoids and the chords are sloped boards lying on the tapered
// edges (upper and forearm share the taper angle and the elbow depth,
// making the extended arm's edges one continuous line — see params).

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
// cut0 > 0 truncates the ROOT corner: everything behind the 45-deg
// line tangent (from below-behind) to an r = cut0 lobe circle at the
// x = 0 joint axis — i.e. x + y < -cut0*sqrt(2) — is cut off, so the
// plate's lower-rear corner chamfers into the lobe instead of jutting
// past it (the tangency means the lobe circle itself is untouched)
module truss_plate_2d(l, d0, d1, margin = 28, s0 = 0, s1 = 0, cut0 = 0) {
  g = 14;                                   // half-width of a diagonal
  dm = (d0 + d1) / 2;                       // mean depth sizes the bays
  h = dm - 2 * margin;
  k = (d1 - d0) / (2 * l);                  // edge slope (z per x)
  lp = l - s0 - s1;                         // patterned span
  n = max(2, floor((lp - 2 * margin) / (dm * 0.36)) - 1);  // triangles
  p = (lp - 2 * margin) / (n + 1);          // half-bay pitch
  s = min(g * sqrt(h * h + p * p) / h,      // horizontal edge inset...
          0.45 * p);                        // ...capped for short links
  rec = s * h / p;                          // apex recede (the miter)
  // margin lines follow the tapered edges
  function yb(x) = -(d0 / 2 + k * x) + margin;
  function yt(x) =  (d0 / 2 + k * x) - margin;
  difference() {
    polygon([[0, -d0 / 2], [l, -d1 / 2], [l, d1 / 2], [0, d0 / 2]]);
    if (cut0 > 0) tx(-cut0 * sqrt(2)) rz(45) sq([600, 600], [-1, 1]);
    for (i = [0 : n - 1]) {
      x0 = s0 + margin + i * p;
      up = (i % 2 == 0);
      polygon(up
        ? [[x0 + s, yb(x0 + s)], [x0 + 2 * p - s, yb(x0 + 2 * p - s)],
           [x0 + p, yt(x0 + p) - rec]]
        : [[x0 + s, yt(x0 + s)], [x0 + 2 * p - s, yt(x0 + 2 * p - s)],
           [x0 + p, yb(x0 + p) + rec]]);
    }
  }
}

// side plates and chords in distinct colors so the four-plate build-up
// of each box section reads in renders. bot_relief > 0 cuts the bottom
// chord back in a circular arc of that radius about the joint axis at
// x1 — the swept circle of a folding child link's root — so the chords
// are drawn individually rather than mz-mirrored as a pair. cut0 > 0
// applies the 45-deg root truncation (see truss_plate_2d) to the side
// plates AND squares the bottom chord back — a straight (not beveled)
// end cut placed so the chord's lowest edge just meets the same line
module box_truss(x0, x1, w, d0, d1, bot_relief = 0, solid0 = 0, solid1 = 0,
                 cut0 = 0) {
  l = x1 - x0;
  a = atan((d0 - d1) / 2 / l);   // taper angle per edge
  lc = l / cos(a);               // chord length along the sloped edge
  // side plates (2D drawn in XY, stood into XZ); NOT relieved — they
  // run full length past the axis as the joint fork, solid in the
  // solid0/solid1 joint zones
  color("burlywood") my([0, 1]) ty(w / 2) rx(90) linear_extrude(ply_t)
    tx(x0) truss_plate_2d(l, d0, d1, 28, solid0, solid1, cut0);
  // chords lie ON the tapered edges: outer face on the edge line,
  // board thickness inward
  color("sienna") tx(x0) tz(d0 / 2) ry(a) tz(-ply_t) linear_extrude(ply_t)
    chord_2d(lc, w);
  // bottom chord start station: its outer-face corner sits on the
  // taper line, so along the sloped axis the cut line is met at
  // (d0/2 - cut0*sqrt(2)) / (cos a + sin a) from the axis
  c0 = cut0 <= 0 ? 0
     : max(0, (d0 / 2 - cut0 * sqrt(2)) / (cos(a) + sin(a)));
  color("sienna") tx(x0) tz(-d0 / 2) ry(-a) linear_extrude(ply_t)
    tx(c0) chord_2d(lc - c0, w, bot_relief);
}

// chord board 2D, drawn along its own (sloped) axis from 0..l: plain
// plate with rectangular lightening holes and an optional end relief
// circle about the joint at x = l
module chord_2d(l, w, rr = 0) {
  difference() {
    sq([l, w - 2 * ply_t], [0, 1]);
    nb = max(1, floor(l / 150));
    for (i = [0 : nb - 1])
      tx(20 + i * (l - 40) / nb + (l - 40) / nb / 2)
        sq([(l - 40) / nb - 30, w - 2 * ply_t - 30], [1, 1], 8);
    if (rr > 0) tx(l) circle(r = rr);
  }
}
