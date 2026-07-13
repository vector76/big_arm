// Parametric involute gear library for big_arm.
// Self-contained: 2D involute profile + herringbone extrusion.
// All angles in degrees (OpenSCAD convention), lengths in mm.

use <helpers.scad>

// ---- involute helpers ----

// involute function inv(a) for pressure angle a (deg), returned in degrees
function _inv_deg(a) = (tan(a) - a * PI / 180) * 180 / PI;

function _polar(r, a) = [r * cos(a), r * sin(a)];

// Flank sample angles: at radius r on a base circle rb, the involute has
// unrolled by inv(acos(rb/r)) degrees from its start.
function _flank_ang(rb, r) = _inv_deg(acos(min(rb / max(r, rb), 1)));

// One tooth's outline, centered on angle 0, spanning the root gap halves
// on both sides so consecutive teeth join seamlessly.
// Returns points from -180/z (root mid) around to just before +180/z.
// ha: addendum coefficient (1 = standard; < 1 stubs the tips, e.g. so a
// large wheel's tips clear a small pinion's base circle).
function _tooth_pts(m, z, pa, backlash, steps, ha = 1) =
  let (
    rp = m * z / 2,
    rb = rp * cos(pa),
    ra = rp + ha * m,
    rf = rp - 1.25 * m,
    r0 = max(rb, rf),                       // involute starts here
    ht = 90 / z - (backlash / 2) / rp * 180 / PI, // half tooth angle at pitch, backlash as linear mm at pitch
    base = ht + _inv_deg(pa),               // flank base offset from tooth center
    psi_l = function(r) -base + _flank_ang(rb, r),
    psi_r = function(r)  base - _flank_ang(rb, r),
    rootA = -180 / z,                       // leading root-gap midpoint
    lroot = psi_l(r0),                      // left flank angle at its lowest point
    rroot = psi_r(r0),
    narc = max(2, steps / 2),
    tipL = psi_l(ra),
    tipR = psi_r(ra)
  )
  concat(
    // leading root arc: from root mid to below the left flank
    [for (i = [0 : narc - 1]) _polar(rf, rootA + (lroot - rootA) * i / narc)],
    // radial rise from rf to involute start (only matters when rf < rb)
    rf < r0 ? [_polar(rf, lroot)] : [],
    // left flank, root to tip
    [for (i = [0 : steps]) let (r = r0 + (ra - r0) * i / steps) _polar(r, psi_l(r))],
    // tip arc
    [for (i = [1 : narc - 1]) _polar(ra, tipL + (tipR - tipL) * i / narc)],
    // right flank, tip to root
    [for (i = [0 : steps]) let (r = ra - (ra - r0) * i / steps) _polar(r, psi_r(r))],
    rf < r0 ? [_polar(rf, rroot)] : [],
    // trailing root arc: from below right flank toward next root mid (exclusive)
    [for (i = [0 : narc - 1]) _polar(rf, rroot + (-rootA - rroot) * i / narc)]
  );

function _rot_pts(pts, a) = [for (p = pts) [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)]];

// Full gear outline.
// backlash: linear tooth thinning at the pitch circle, mm (apply to one
// gear of a pair, or half to each).
function gear_points(m, z, pa = 20, backlash = 0, steps = 10, ha = 1) =
  let (tooth = _tooth_pts(m, z, pa, backlash, steps, ha))
  [for (k = [0 : z - 1]) each _rot_pts(tooth, k * 360 / z)];

// ---- public modules ----

module gear2d(m, z, pa = 20, backlash = 0, steps = 10, ha = 1) {
  polygon(gear_points(m, z, pa, backlash, steps, ha));
}

// Herringbone gear: two opposite-hand helical halves meeting at mid-height.
// helix: helix angle in degrees. bore: through-hole diameter (0 = solid).
module herringbone_gear(m, z, height, helix = 25, pa = 20, backlash = 0,
                        bore = 0, steps = undef, ha = 1) {
  rp = m * z / 2;
  half = height / 2;
  // rotation of the cross-section over one half, from the helix angle
  tw = half * tan(helix) / (PI * m * z) * 360;
  // flank samples drive the whole cost: the 2D profile is z * ~3 * steps
  // points and the twist sweeps every one of them up every slice. The
  // involute needs 10 to MESH; it needs only a straight flank (1) to
  // LOOK like a gear, and these halves twist ~7 deg — one slice each.
  // Measured on the 51T wheel: 8.6k tris at 3/3, 2.4k at 1/1, renders
  // indistinguishable.
  st = !is_undef(steps) ? steps : ($twin ? 1 : 10);
  difference() {
    tz(half) mz([0, 1])
      linear_extrude(height = half, twist = tw,
                     slices = $twin ? max(1, ceil(tw / 8)) : max(8, ceil(tw)),
                     convexity = 10)
        gear2d(m, z, pa, backlash, st, ha);
    if (bore > 0)
      tz(-1) cylinder(d = bore, h = height + 2, $fn = $twin ? 24 : 64);
  }
}

// Convenience: pitch/outer diameters for layout math.
function gear_pitch_d(m, z) = m * z;
function gear_outer_d(m, z, ha = 1) = m * z + 2 * ha * m;
function gear_center_distance(m, z1, z2) = m * (z1 + z2) / 2;

// Width at which each herringbone half advances by `phase` whole teeth
// from center to edge. At phase = 1, every systematic per-tooth profile
// error is engaged across a full tooth-phase cycle at any rotation angle,
// so periodic transmission error averages out. Independent of tooth count,
// so mating gears get the same width.
function gear_phase_width(m, helix, phase = 1) = 2 * phase * PI * m / tan(helix);
