// Shoulder drive housings — annotated standalone diagram + the shared
// modules. The assembly draws THESE modules (placed with ry(-dd)):
// the same no-drift rule as the drivetrain parts. Three views:
// assembled with the staggered screws, exploded along the axle in
// INSTALL ORDER, and a section on the plane of BOTH axles.
//
// Local frame = the boom plan frame the params stations are written
// in: +x radial out the boom (the drum axle crosses at x = da, the
// pinion/motor at da + cd), y = the arm's lateral axis — so the
// y-lane zoning numbers in params read verbatim (motor -30..18, slab
// 18..26, wall + bosses 26..43, boom plate 43..55, shear walls
// 55..96, bridge plate 96..104) — and the plan's lateral spreads
// in z.
//
// INBOARD housing (one print, y 18..43), printed slab-down, no
// overhangs: the 8-thick slab 1 under the gear plane carries the
// axle bolt's wheel end (d 8 bore) and takes the motor face (NEMA
// pilot boss through the d 24 hole, four M3 face screws) — so the
// mesh center distance is printed-exact and the separating force
// loops close inside the print, never through wood. The slab is
// nothing but the box wall's floor — flush with the wall's outer
// edge everywhere, no flange, no nose — plus a foot under each
// drum-side screw boss; a d 13 ring stands 1 proud at the axle as
// the CLAMP SHOULDER, touching the wheel-end 608's INNER race only
// (inside the pocket's 15.5 relief), so no static face ever rubs
// the rotating wheel and no surface touches both races. A 6-thick
// shear wall tracing the kidney — foot 1 outside the ply edge, 4
// over the wheel tips, swung wide around the pinion so the face
// screws stay inside its bay — rises to the plate's inner face: a
// closed box where loose standoffs would stand. Four d 13 bosses
// merged into the wall take the hs_in wood screws driven from the
// OUTBOARD face (d 3 pilots in the boss ends). Every hs_out driver
// line passes the slab in free air (the spine station clears its
// end by 1); the d 10 subtractions remain, clipping the ~1 the
// boss-foot webs encroach at the drum-side pair.
//
// OUTBOARD housing (one print, y 55..104), printed plate-down, also
// support-free: the bridge plate over the drum's bearing boss (the
// rig idiom: the dead axle ends up simply supported — here it is an
// M8 THROUGH-BOLT, head inboard of the slab, nut outboard of this
// plate, clamping the two housings toward each other; a d 31 x 1.2
// running recess in the plate's inner face, with a d 13 inner-race
// ring left standing flush inside it, routes that compression
// through the bearing stack on the INNER races alone — slab
// shoulder -> wheel-end 608 -> drum -> boss-end 608 -> this ring — a
// light preload set by feel, the bearing_station recipe, while the
// rotating boss end and both outer-race faces keep 1.2 clear of the
// static plate), carried by a WIDE-Y of shear walls: two ARMS and
// the SPINE meet at a vertex 22 past the drum axis (inner face 4
// over the flanges) — support right at the bearing, instead of a
// roof cantilevered from distant blades — and the bay between the
// arms OPENS TOWARD THE SHOULDER for the fixed band and both cable
// take-off corridors (the ghosted arc in the assembled view); the
// spine runs out to its boss past the pinion, so the footprint
// still triangulates in plan. The roof spans only the Y's upper bay
// (bearing cover + vertex + the two foot pads); the stem runs bare.
// Where walls cross the kidney they hang 1 over the wheel face (the
// plate's own margin); the arm lines hold shoulder r >= 262 (258 at
// the foot caps) vs the band's 240 crest. The arm FEET land exactly
// where the Y meets the kidney ring's ply band — the arms' mid
// spans cross the open cutout with nothing to screw into — so
// hs_out drops to three screws: one per foot + the spine boss,
// driven from the INBOARD side into d 3 pilots; the roof is drilled
// d 9 over the drum-side hs_in pair so the whole stack stays
// serviceable from outside.
//
// STAGGERED SCREWS: the two sets alternate faces, so every station
// clamps the ply between a printed part and a screw head from the
// far side — d 4 clearance in the ply, d 3 pilot bored into the
// printed end, head landing on open ply over the far housing's bay.
// No screw threads into wood-side plastic.
//
// INSTALL ORDER (= the exploded view, bottom to top): motor onto the
// slab, inboard housing onto the plate (hs_in, driven against a bare
// outboard face), wheel + drum in through the kidney from outboard,
// 608s into their pockets, bridge over the boss (hs_out), then the
// M8 bolt in from the inboard side and its nut snugged outboard —
// the clamp preloads the bearing pair through the inner-race
// shoulders, set by feel. Only the drum-side hs_in pair ever needs
// the cable slacked to retighten (the driver passes the near span
// by ~1 there).

include <params.scad>
use <../lib/helpers.scad>
use <joints.scad>        // ycyl/ytube/pie
use <gear_drum.scad>
use <pinion.scad>

$fn = 64;

// ---- the housings (shared modules; the assembly wraps khaki) ----

module inboard_housing() {
  // motor-face slab, y 18..26 — nothing but the box wall's floor,
  // flush with its outer edge everywhere (r 62 at the drum, r 32
  // past the pinion: no nose beyond the box), plus a hulled foot
  // under each drum-side hs_in boss (they stand outside the wall
  // ring). Every hs_out driver line now runs in free air — the
  // spine station clears the slab end by 1 — so no station truly
  // pierces; the d 10 subtractions stay and just clip the ~1 the
  // boss-foot webs encroach at the drum-side pair
  ty(26) rx(90) linear_extrude(8) difference() {
    union() {
      hull() { tx(da) circle(62); tx(da + cd) circle(32); }
      my([0, 1]) hull() { txy(hs_in[0]) circle(d = 13); tx(da) circle(56); }
    }
    tx(da) circle(d = 8);          // axle-bolt bore, close slide
    tx(da + cd) circle(12);        // NEMA pilot boss clearance
    tx(da + cd) mx([0, 1]) my([0, 1]) txy([15.5, 15.5])
      circle(d = 3.4);             // M3 motor face screws
    txy(hs_out) circle(d = 10);    // outboard-set driver clearance
  }
  // clamp shoulder, 1 proud of the slab against the wheel-end 608's
  // INNER race only (d 13: over the 8 bore, under the pocket's 15.5
  // relief) — the through-bolt's compression enters the bearing
  // stack here, and the static slab can never touch the rotating
  // wheel face or pocket mouth
  tx(da) ytube(13, 8, 26, 27);
  // kidney-tracing shear wall + hs_in screw bosses, y 26..43; d 3
  // screw pilots down the boss ends, floor 2 past the screw tips
  ty(upper_w / 2 - ply_t) rx(90) difference() {
    linear_extrude(upper_w / 2 - ply_t - 26) {
      difference() {
        hull() { tx(da) circle(62); tx(da + cd) circle(32); }
        hull() { tx(da) circle(56); tx(da + cd) circle(26); }
      }
      txy(hs_in) circle(d = 13);   // bosses
    }
    txy(hs_in) tz(-0.5) cylinder(d = 3, h = 15.5);
  }
}

module outboard_housing() {
  ty(drum_y1 + 8) rx(90) {
    // the roof, y 96..104: a rounded triangle spanning only the Y's
    // upper bay — the bearing cover, the two arm-foot pads and the
    // vertex land — carrying the axle-bolt seat, the clamp-ring
    // recess and the nut. The stem runs bare: nothing to cover there
    difference() {
      linear_extrude(8) difference() {
        hull() {
          tx(da) circle(17.5);
          my([0, 1]) txy(hf) circle(12);
          tx(hv_x) circle(9);
        }
        tx(da) circle(d = 8);      // axle-bolt bore, close slide
        txy([hs_in[0], hs_in[1]]) circle(d = 9);  // service drills
      }
      // d 31 x 1.2 running recess in the inner face, a d 13 ring
      // left standing flush inside it: the through-bolt's clamp
      // crosses the housings on the INNER races only (slab shoulder
      // -> bearing stack -> this ring), so no amount of squeeze can
      // land the plate on both races or on the rotating boss end
      // (d 28) — those keep the 1.2 everywhere else
      tz(6.8) tx(da) difference() {
        cylinder(d = 31, h = 1.5);
        tz(-0.5) cylinder(d = 13, h = 2.5);
      }
    }
    // the Y walls, y 55..104: two arms from the vertex to the feet
    // plus the spine out to its boss, all 8 wide — the bay between
    // the arms opens toward the shoulder for the fixed band and both
    // cable take-offs. d 3 screw pilots up the feet + boss from the
    // ply face, floor ~4 past the screw tips
    difference() {
      linear_extrude(drum_y1 + 8 - upper_w / 2) {
        my([0, 1]) hull() txy([[hv_x, 0], hf]) circle(4);
        hull() txy([[hv_x, 0], hs_out[2]]) circle(4);
        txy(hs_out[2]) circle(d = 16);
      }
      txy(hs_out) tz(drum_y1 + 8 - upper_w / 2 - 16.5)
        cylinder(d = 3, h = 17);
    }
  }
}

// ---- diagram ----

// joints.scad's part() idiom, but the $section cut removes the z > 0
// half: the z = 0 plane holds BOTH axles, so one cut reads the mesh,
// the axle stack, and every wall/plate/boss profile at once
module dpart(col) color(col)
  if (!is_undef($section) && $section)
    difference() { children(); tx(da) cub([700, 700, 200], [1, 1, 0]); }
  else children();

// 608 (joints.scad's b608, redrawn through dpart so the section cut
// stays coplanar with everything else's)
module d608(y0) {
  dpart("silver") { ytube(22, 18, y0, y0 + 7); ytube(13.5, 8, y0, y0 + 7); }
  dpart("dimgray") ytube(17.5, 14, y0 + 1, y0 + 6);
}

// boom-plate proxy: the real plate's drive end (assembly
// boom_plate_2d: strip + ring around the kidney + the d 4 screw
// stations), broken off square at x = da - 145
module boom_ply() dpart("burlywood")
  ty(upper_w / 2) rx(90) linear_extrude(ply_t) difference() {
    union() {
      tx(da - 145) sq([cd + 200, 110], [0, 1], 16);
      hull() { tx(da) circle(88); tx(da + cd) circle(35); }
    }
    hull() { tx(da) circle(55); tx(da + cd) circle(13); }  // the kidney
    txy(concat(hs_out, hs_in)) circle(d = 4);
  }

// the fixed sector band's lane, ghosted at mid-travel (an 80-deg
// stretch: the boom points at the sector bisector there, so the arc
// is centered on +x) — what the outboard Y's bay opens toward, and
// what its arms hold shoulder r >= 258 against
module band_ghost() %ty(cab_y0 + cab_w) rx(90) linear_extrude(cab_w)
  difference() { pie(240, 80); circle(213); }

// e = 1 explodes along the axle in install order; 0 = assembled,
// with the staggered screws (drawn here, not in the modules)
module station(e = 0) {
  boom_ply();
  // motor with its pressed-on pinion — first onto the slab, flats
  // square to the boom (the slab's M3 pattern)
  ty(-e * 110) tx(da + cd) {
    dpart("dimgray") ty(18 - motor_len) rx(-90)
      cub([motor_w, motor_w, motor_len], [1, 1, 0]);
    dpart("silver") ycyl(5, 18, 42);
    dpart("tomato") ty(whl_y0) rx(-90) pinion();
  }
  ty(-e * 55) dpart("khaki") inboard_housing();
  // the gear+drum (the real print) with its two pocketed 608s
  ty(e * 75) tx(da) {
    dpart("steelblue") ty(whl_y0) rx(-90) gear_drum();
    d608(whl_y0);
    d608(drum_y1 - bearing_w);
  }
  ty(e * 160) dpart("khaki") outboard_housing();
  // the M8 THROUGH-BOLT (head inboard, nut outboard): the dead axle,
  // now also clamping the housings across the inner-race shoulders —
  // a light bearing preload, set by feel
  ty(e * 255) dpart("silver") tx(da) {
    ycyl(8, 18, drum_y1 + 8 + 7.5);
    ty(12.7) rx(-90) cylinder(d = 15, h = 5.3, $fn = 6);
  }
  ty(e * 320) dpart("silver") tx(da) ty(drum_y1 + 8 + 0.2)
    rx(-90) cylinder(d = 15, h = 6.5, $fn = 6);
  if (e == 0) dpart("silver") {
    // the staggered sets: hs_in from the outboard face into the
    // inboard housing's bosses, hs_out from the inboard face into
    // the outboard housing's blade feet + spine boss
    txz(hs_in) { ycyl(3.5, 30, 55); ycyl(7, 55, 57.5); }
    txz(hs_out) { ycyl(3.5, 43, 67); ycyl(7, 40.5, 43); }
  }
}

// -D 'piece="inboard"' / -D 'piece="outboard"' emits ONE housing in
// print orientation (slab / bridge plate on the bed — both print
// support-free) for STL export; the default draws the diagram.
piece = "diagram";

if (piece == "inboard") tz(-18) rx(90) tx(-da) inboard_housing();
else if (piece == "outboard") tz(104) rx(-90) tx(-da) outboard_housing();
else {
  // top: assembled, screws in, the band's lane ghosted (preview only —
  // F6 drops % parts); middle: exploded along the axle in install
  // order; bottom: section on the two-axle plane — the removed half
  // faces +z, so the cut reads face-on from above. Each view turned 45
  // about z so the default camera sees the axle direction half-sideways
  // (face-on it stacks the exploded parts behind each other)
  tz(300) rz(-45) tx(-da) { station(); band_ghost(); }
  rz(-45) tx(-da) station(1);
  tz(-240) rz(-45) tx(-da) station($section = true);
}
