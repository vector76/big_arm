// Yaw hub station — annotated standalone diagram: the shoulder/elbow
// bearing_station idiom FLIPPED onto the baseplate to become the slew
// disc's hub (the shared module is hub_station() in joints.scad; this
// file adds the wood proxies and the install sheath). Assembled view
// on the left, axis cross-section on the right.
//
// What changed vs the joint station (bearing_station.scad):
// - The fixed side mounts FLAT on the plate — no through-hole, no
//   recess, nothing pocketed into ply (hard to cut tight anyway), so
//   the baseplate bottom stays FLAT for clamping. Green is a broad
//   conical foot: EIGHT perimeter screws on the d 84 circle replace
//   the joint's snout-in-board-hole pilot as the radial shear path —
//   and radial is the hub's real job: the rim rollers take only
//   vertical, so every side load on the machine, plus the yaw
//   pinion's separating force, lands here. The preloaded pair is
//   what locates the gear mesh.
// - The main bearing rides HIGH in the cone (13.5..20.5, outer race
//   held 2.5 under the disc by a thick printed wall), which shortens
//   pink's cantilever from flange to inner race to 15.5 — less
//   deflection in the printed part, with the beefy cone carrying the
//   race instead.
// - The M3 head is CAPTIVE: a hex pocket up into green's underside
//   swallows it, the plate traps it axially, and the pocket flats
//   react wrenching torque. Because a hex socket this small can
//   round out in printed plastic under repeated torque, a DIAGONAL
//   LOCK SCREW (a wood screw driven 45 deg down the cone face,
//   between two flange screws) lands with its tip against the head's
//   flat as a backstop. The jam nuts are set from ABOVE, through the
//   upper sheet's cutout, with no access to (or need for) the head.
// - The disc's LOWER sheet plays the moving-plate role: pink's flange
//   screws to its top face and the sleeve drops down its 15.5 bore to
//   the main bearing. The UPPER sheet's 48 cutout swallows the
//   flange, the 2nd bearing and the centering sheath, so only the tee
//   washer + jam nuts + bolt tip stand proud of the disc top: a
//   16-dia pillar reaching z 59, 11 proud (the counterweight block's
//   worst corner passes z 67 over it).
//
// UNCHANGED from the joint stations: the preload loop is entirely
// internal — bolt tension compresses, in series: green web -> green
// shoulder -> main outer race -> balls -> main inner race -> pink
// (sleeve, flange) -> 2nd outer race -> balls -> 2nd inner race ->
// blue washer -> jam nuts. Wood never enters the loop, so ply
// compression or drift can't unload the bearings. Rotation split:
// pink, red pin, main INNER race and 2nd OUTER race turn with the
// disc; green, bolt, nuts, blue washer stand still (the 2nd bearing
// exists so the stationary bolt can clamp across the rotating
// interface; it carries thrust only and floats radially). Race-
// contact rule: no single piece bridges both rings of one bearing —
// green's shoulder ID 17, pink's tapered relief, the washer's OD 16.
// The bolt sees pure tension inside the pin's 1 mm radial clearance.
//
// Axial overconstraint note: the preloaded pair fixes the disc's
// height at the axis while the rim rollers define it at r 185 — snug
// the station FIRST, then set the rollers to just kiss; overturning
// uplift stays with the rim hold-downs, not this M3.
//
// Assembly order: bolt up through green (head into the hex pocket),
// green screwed down flat, lock screw driven onto the head's flat;
// main 608 dropped in the pocket; pin pressed into pink; the disc
// (pink pre-screwed under the upper sheet's cutout) lowered so the
// pin enters the bearing bore; 2nd 608 + washer over the bolt;
// sheath on to center them; jam nuts snugged by feel; sheath off.
//
// z 0 = baseplate top. Main 608 at 13.5..20.5, disc sheets 24..48,
// pink flange 36..42, 2nd 608 at 42..49, nuts to 57.4.

include <params.scad>
use <../lib/helpers.scad>
use <joints.scad>

$fn = $twin ? 32 : 64;

// baseplate proxy: a plain flat slab — nothing cut into it at all
module base_plate() part("wheat")
  tz(-ply_t) cub([130, 130, ply_t], [1, 1, 0]);

// disc proxy: both sheets, hub bores only (no rim, no board slots)
module disc_sheets() part("rosybrown") {
  tz(disc_z0) linear_extrude(ply_t)
    difference() { circle(d = 130); circle(d = 15.5); }
  tz(disc_z0 + ply_t) linear_extrude(ply_t)
    difference() { circle(d = 130); circle(d = 48); }
}

// gold: temporary centering sheath (installation tool), the joint
// station's cup working upside-down: it drops LOOSELY over the pink
// flange OD and the 2nd bearing OD (both rotate together, so it ties
// the bearing concentric to pink and thus the bolt concentric inside
// the pin). The top hole passes the washer and keeps the nuts
// reachable, and the big bore swallows the pink screw heads; OD 44
// rides free in the upper sheet's 48 cutout. Prints on the face that
// sits UP in use: from that end the bore only ever steps larger
module sheath() {
  s1 = disc_z0 + ply_t;
  part("gold") difference() {
    tz(s1 + 0.5) cylinder(d = 44, h = 15);
    tz(s1 - 0.5) cylinder(d = 40.6, h = 9.5);
    tz(s1 + 8.9) cylinder(d = 22.3, h = 5.1);
    tz(s1 + 13.9) cylinder(d = 18, h = 2.7);
  }
}

module station() {
  base_plate();
  disc_sheets();
  hub_station();
  sheath();
}

// left: assembled (turned for a 3/4 view); right: cross-section — the
// removed half faces the camera, so the section plane reads face-on
tx(85) rz(65) station();
tx(-85) station($section = true);
