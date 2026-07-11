// Joint hardware, concept level. The shoulder and elbow pitch joints
// use PAIRED PRELOADED BEARING STATIONS (bearing_station() below; the
// annotated standalone diagram with rationale is bearing_station.scad).
// The wrist still uses the older proxy idiom: a fixed dead axle with a
// printed hub tube (joint_axle). The elbow and wrist DRIVES are being
// overhauled with something different — their old worm proxies are
// gone, and those joints carry bare stations/axles in the model until
// the redesign lands.
//
// Conventions: pitch joints rotate about local Y. Sectors are drawn in
// the child link's frame with their arc bisector at 180 deg (opposite
// the link direction), exactly like the prototype1 rig; the drive unit
// (gear + drum + motor, drawn as envelope proxies) is drawn in the
// parent's frame along the direction of the child's mid-travel bisector.

include <params.scad>
use <../lib/helpers.scad>

module pie(r, ang) {
  n = max(12, ceil(ang / 4));
  polygon(concat([[0, 0]],
    [for (i = [0 : n]) [r * cos(-ang / 2 + ang * i / n),
                        r * sin(-ang / 2 + ang * i / n)]]));
}

// the sector's rim cable channel (printed clip-on segments in the
// detail design — see prototype1), stood into the XZ plane (joint
// axis = Y), bisector rotated to `bis` degrees from +X (measured in
// the XZ plane, toward +Z); `plane` sets the mid-plane's y. The
// sector WEB itself is no separate part: the fixed sector is a solid
// web CNC'd as one piece with the left base board (see the assembly's
// left_board_2d)
module sector_channel(r, ang, bis = 180, plane = 0) {
  ty(plane) rx(90) rz(bis)
    color("khaki") linear_extrude(20, center = true)
      difference() { pie(r + 5.5, ang); pie(r - 8, ang + 8); }
}

// drive unit envelope: 51T wheel + drum on a dead axle, pinion + NEMA
// at center distance, drawn with the drum axis at the local origin
// (joint axis = Y); `out` is the direction (deg in XZ from +X) from the
// drum toward the pinion/motor — radially away from the sector
module drive_unit(out = 180) {
  rx(90) rz(out) {
    color("steelblue") tz(-gear_w - 14) {
      cylinder(d = gear_od, h = gear_w);            // wheel
      tz(gear_w) cylinder(d = drum_od, h = 26);     // drum + flanges
    }
    color("silver") tz(-70) cylinder(d = 8, h = 140, $fn = 24);
    tx(cd) {
      color("tomato") tz(-gear_w - 14) cylinder(d = 28, h = gear_w);
      color("dimgray") tz(-gear_w - 16 - motor_len)
        cub([motor_w, motor_w, motor_len], [1, 1, 0]);
    }
  }
}

// ---- preloaded joint bearing station ----
// Shared by the shoulder and elbow; see bearing_station.scad for the
// annotated standalone diagram (sketch palette: orchid arm bushing,
// yellowgreen fixed bushing, red split pin, deepskyblue tee washer).
// Local frame: axis = Y, y = 0 at the MOVING plate's inner face, +y
// toward the FIXED board; `gap` = moving plate outer face to fixed
// board inner face (8 at the shoulder, 3 at the elbow — the main
// bearing sits proud of the board's inner face when the gap allows,
// flush when it doesn't). Preload loop is internal, never through
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
