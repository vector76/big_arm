// Joint hardware, concept level. The shoulder and elbow pitch joints
// use PAIRED PRELOADED BEARING STATIONS (bearing_station() below; the
// annotated standalone diagram with rationale is bearing_station.scad).
// The wrist still uses the older proxy idiom: a fixed dead axle with a
// printed hub tube (joint_axle). The elbow and wrist DRIVES are being
// overhauled with something different — their old worm proxies are
// gone, and those joints carry bare stations/axles in the model until
// the redesign lands.
//
// Conventions: pitch joints rotate about local Y. The shoulder sector
// is drawn in the base frame with its arc bisector opposite the
// mid-travel arm direction; the drive rides the arm (assembly.scad).

include <params.scad>
use <../lib/helpers.scad>

module pie(r, ang) {
  n = max(12, ceil(ang / 4));
  polygon(concat([[0, 0]],
    [for (i = [0 : n]) [r * cos(-ang / 2 + ang * i / n),
                        r * sin(-ang / 2 + ang * i / n)]]));
}

// (The sector's rim cable channel is no longer sketched here: the
// assembly places the REAL prints — sector_segment.scad — directly,
// the same no-drift rule as the drivetrain parts. The sector WEB is
// no separate part either: it's CNC'd as one piece with the left
// base board, see the assembly's left_board_2d.)

// ---- preloaded joint bearing station ----
// Shared by the shoulder and elbow; see bearing_station.scad for the
// annotated standalone diagram (sketch palette: orchid arm bushing,
// yellowgreen fixed bushing, red split pin, deepskyblue tee washer).
// Local frame: axis = Y, y = 0 at the MOVING plate's inner face, +y
// toward the FIXED board; `gap` = moving plate outer face to fixed
// board inner face (3 at BOTH the shoulder and the elbow — one
// printed design serves every joint; at that gap the main bearing
// sits flush with the board's inner face rather than proud, and the
// hub flips the same idiom onto the baseplate). Preload loop is
// internal, never through
// wood: bolt head -> green web + shoulder -> main outer race -> balls
// -> inner race -> pink -> 2nd outer race -> balls -> inner race ->
// blue washer -> jam nuts. Pink, pin, main inner race and 2nd outer
// race rotate with the arm; green, bolt, nuts, blue washer stand
// still. Bolt sees pure tension (1 mm radial clearance inside the pin)

// cylinders/tubes along the joint axis (Y)
module ycyl(d, y0, y1) ty(y0) rx(-90) cylinder(d = d, h = y1 - y0);
module ytube(od, id, y0, y1) difference() {
  ycyl(od, y0, y1);
  ycyl(id, y0 - 0.5, y1 + 0.5);
}

// color + optional sectioning (cut inside the color scope keeps the
// section faces colored; pass $section = true to cut the x < 0 half)
module part(col) color(col)
  if (!is_undef($section) && $section)
    difference() { children(); cub([400, 400, 400], [-1, 1, 1]); }
  else children();

// 608: outer race, inner race, cage hint, from y0 inboard face
module b608(y0) {
  part("silver") { ytube(22, 18, y0, y0 + 7); ytube(13.5, 8, y0, y0 + 7); }
  part("dimgray") ytube(17.5, 14, y0 + 1, y0 + 6);
}

module bearing_station(gap = 8) {
  bif = ply_t + gap;           // fixed board inner / outer face
  bof = bif + ply_t;
  pr = min(4.5, gap - 2);      // how proud the snout sits of that face
  b0 = bif - pr + 1;           // main bearing inboard face
  // pink arm bushing: flange on the moving plate's inner face, sleeve
  // (chamfered tip) through the plate to the main inner race; tapered
  // inner-race relief on the inboard face for the 2nd bearing
  part("orchid") difference() {
    union() {
      ycyl(40, -6, 0);
      ycyl(15, 0, b0 - 1.2);
      ty(b0 - 1.2) rx(-90) cylinder(d1 = 15, d2 = 12.6, h = 1.2);
    }
    ycyl(8.2, -2, b0 + 1);
    ty(-6.2) rx(-90) cylinder(d1 = 16, d2 = 8.2, h = 4.5);
    ry([0, 120, 240]) tx(16) ycyl(3.4, -7, -3);
  }
  part("silver") ry([0, 120, 240]) tx(16) {
    ycyl(3, -7, 8);
    ycyl(5.5, -8, -6);
  }
  // green fixed-side bushing: flange on the board's outer face, snout
  // (chamfered) piloting the 28.5 board hole, bearing pocket open
  // inboard, shoulder ID 17, solid web under the proud bolt head
  part("yellowgreen") difference() {
    union() {
      ycyl(48, bof, bof + 5);
      ty(b0 - 1) rx(-90) cylinder(d1 = 25, d2 = 28, h = 1.5);
      ycyl(28, b0 + 0.5, bof);
    }
    ycyl(22.1, b0 - 1.5, b0 + 7);
    ycyl(17, b0 + 6.9, bof + 1);
    ycyl(3.4, bof, bof + 6);
    ry([45, 135, 225, 315]) tx(20) ycyl(3.4, bof - 1, bof + 6);
  }
  part("silver") ry([45, 135, 225, 315]) tx(20) {
    ycyl(3, bof - 8, bof + 4);
    ycyl(5.5, bof + 4, bof + 6);
  }
  b608(b0);        // main bearing
  b608(-13);       // second bearing, thrust only
  // split roll-pin: snug in pink and the main bearing bore, 1 mm
  // radial clearance around the stationary bolt
  part("red") difference() {
    ytube(8, 5, -1.5, b0 + 7);
    ty(-2.5) tz(1.5) cub([1.3, b0 + 11, 3.2], [1, 0, 0]);
  }
  // printed tee washer: flange presses the 2nd inner ring, spigot
  // centers loosely in its bore
  part("deepskyblue") difference() {
    union() { ycyl(16, -16, -13); ycyl(7.6, -13, -7.5); }
    ycyl(3.4, -17, -7);
  }
  // M3, head proud of green's face; jam nut pair fixes the stack
  part("dimgray") {
    ycyl(3, -23, bof + 5.2);
    ycyl(5.5, bof + 5, bof + 7.8);
    ty(-16) rx(90) cylinder(d = 6.9, h = 2.4, $fn = 6);
    ty(-18.5) rx(90) cylinder(d = 6.9, h = 2.4, $fn = 6);
  }
}

// ---- yaw hub station ----
// bearing_station FLIPPED onto the baseplate as the slew-disc hub
// (annotated standalone diagram: hub_station.scad). Same internal
// preload loop and rotation split; the fixed-side mounting is new:
// green is a broad FLAT-BOTTOMED CONE sitting on the plate — no
// through-hole, no recess, the plate bottom stays flat for clamping
// and nothing needs a tight pocket cut in ply. EIGHT perimeter
// screws on the d 84 circle carry the radial shear (the joint's
// snout-in-board-hole pilot has no equivalent here), and the M3
// head is CAPTIVE in a hex pocket up into green's underside: the
// plate traps it and the pocket flats react wrenching torque —
// backed by a DIAGONAL LOCK SCREW driven down the cone face to bear
// on the head's flat, because a hex socket this small can round out
// in printed plastic under repeated torque. The jam nuts are set
// from above with no access to (or need for) the head. The
// main bearing rides HIGH in the cone — outer race held just 2.5
// under the disc — so pink's cantilever from its flange to the
// inner race is short (15.5). The disc's LOWER sheet is the moving
// plate (pink's flange screws to its top face, its sleeve drops
// down the 15.5 bore); the UPPER sheet's 48 cutout swallows flange,
// 2nd bearing and centering sheath, so only the washer + jam nuts +
// bolt tip stand proud of the disc top: a 16-dia pillar reaching
// z 59, 11 proud. Drawn in the bench frame (axis = Z, z 0 = plate
// top), written along +y inside an rx(90) so the ycyl idiom carries
// over (y reads as z)
module hub_station() rx(90) {
  b0 = 13.5;                // main bearing lower face (raised: the
                            // outer race sits just under the disc)
  s1 = disc_z0 + ply_t;     // pink's flange seat: the lower sheet's top
  // green: flat base, cone up to the bearing pocket; shoulder ID 17
  // contacts the outer ring only
  part("yellowgreen") difference() {
    union() {
      ycyl(100, 0, 5);
      ty(5) rx(-90) cylinder(d1 = 64, d2 = 34, h = 16.5);
    }
    ty(-0.1) rx(-90) cylinder(d = 7, h = 2.6, $fn = 6);  // head pocket
    ycyl(3.4, 2, 11.1);
    ycyl(17, 11, b0 + 0.1);
    ycyl(22.1, b0, 22.5);
    ry([22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5])
      tx(42) ycyl(3.4, -0.5, 5.5);
    // lock-screw pilot: 45 deg down the cone face at the M3 head's flat
    ry(90) tx(3.2) ty(1.2) rz(-45) ycyl(2.6, 2, 26);
  }
  part("silver") ry([22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5])
    tx(42) {
      ycyl(3, -8, 4);
      ycyl(5.5, 4, 6);
    }
  // the anti-rotation lock screw: a wood screw entering the cone face
  // between two flange screws, tip against the side of the M3 head
  // (azimuth 90: right on the diagram's section plane)
  part("silver") ry(90) tx(3.2) ty(1.2) rz(-45) {
    ycyl(3, 0.5, 22);
    ycyl(5.5, 22, 24);
  }
  b608(b0);          // main bearing
  b608(s1 + 6);      // second bearing, thrust only
  // pink: flange down on the lower sheet's top face, sleeve to the
  // main inner race, tapered relief up top for the 2nd bearing
  part("orchid") difference() {
    union() {
      ycyl(40, s1, s1 + 6);
      ycyl(15, b0 + 8.2, s1);
      ty(b0 + 7) rx(-90) cylinder(d1 = 12.6, d2 = 15, h = 1.2);
    }
    ycyl(8.2, b0 - 1, s1 + 2);
    ty(s1 + 6.2) rx(90) cylinder(d1 = 16, d2 = 8.2, h = 4.5);
    ry([0, 120, 240]) tx(16) ycyl(3.4, s1 + 3, s1 + 7);
  }
  part("silver") ry([0, 120, 240]) tx(16) {
    ycyl(3, s1 - 8, s1 + 7);
    ycyl(5.5, s1 + 6, s1 + 8);
  }
  // split roll-pin: snug in pink and the main bearing bore, bottom
  // flush with the bearing's lower face
  part("red") difference() {
    ytube(8, 5, b0, s1 + 1.5);
    ty(b0 - 1) tz(1.5) cub([1.3, s1 - b0 + 4, 3.2], [1, 0, 0]);
  }
  // printed tee washer: flange presses the 2nd inner ring from above,
  // spigot centers loosely in its bore
  part("deepskyblue") difference() {
    union() { ycyl(16, s1 + 13, s1 + 16); ycyl(7.6, s1 + 7.5, s1 + 13); }
    ycyl(3.4, s1 + 7, s1 + 17);
  }
  // M3: head captive on the plate under green, jam nut pair set from
  // above
  part("dimgray") {
    ycyl(3, 2, s1 + 23);
    ty(0) rx(-90) cylinder(d = 6.35, h = 2.4, $fn = 6);
    ty(s1 + 16) rx(-90) cylinder(d = 6.9, h = 2.4, $fn = 6);
    ty(s1 + 19) rx(-90) cylinder(d = 6.9, h = 2.4, $fn = 6);
  }
}

// dead axle + printed hub tube, spanning `span` across the joint (Y)
module joint_axle(span) {
  color("silver") ty(-span / 2 - 10) rx(-90)
    cylinder(d = 8, h = span + 20, $fn = 24);
  color("khaki") ty(-19) rx(-90) tube(30, 22, 38);
}

module tube(od, id, h) difference() {
  cylinder(d = od, h = h);
  tz(-0.5) cylinder(d = id, h = h + 1);
}
