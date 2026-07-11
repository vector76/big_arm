// Shoulder/elbow bearing station — annotated standalone diagram.
// The station hardware itself is the shared module
// bearing_station(gap) in joints.scad (drawn here at gap = 8, the
// shoulder value; the elbow uses gap = 3, which pulls the main bearing
// flush with the fixed board's inner face instead of 4.5 proud).
// Assembled view on the left, axis cross-section on the right.
//
// Colors follow the sketch of 2026-07-11 so parts keep their names:
//   salmon      = arm side plate   (darker) / fixed board (lighter)
//   orchid/pink = arm bushing, ONE PRINT: flange on the arm plate,
//                 sleeve out to the main bearing (presses the inner
//                 race), inboard face pressing the 2nd bearing's outer
//                 ring with a tapered central relief
//   yellowgreen = fixed-side bushing: flange on the board's outer face,
//                 snout piloting the oversized board hole and standing
//                 slightly proud of the inner face, bearing pocket
//   red         = split roll-pin (radial precision: snug in the pink
//                 bore and the main bearing bore)
//   deepskyblue = washer between the 2nd bearing and the jam nuts
//   gold        = temporary centering sheath (installation tool)
//   silver/dimgray = 608s (x2), M3 bolt + jam nuts, wood screws
//
// Architecture: the preload loop is entirely internal — it never
// touches wood, so board position/drift cannot change it. Bolt tension
// compresses, in series: green web -> green shoulder -> main outer race
// -> balls -> main inner race -> pink (sleeve, flange, inboard face) ->
// 2nd outer race -> balls -> 2nd inner race -> blue washer -> jam
// nuts. M3 bolt; TWO nuts jammed fix the stack length tightly even at
// modest preload, set by feel.
//
// Rotation assignment (no rubbing anywhere): pink, red pin, main INNER
// race and 2nd OUTER race turn with the arm; green, bolt, nuts, blue
// washer, main OUTER race and 2nd INNER race stand still. The 2nd
// bearing exists so the stationary bolt can clamp across the rotating
// interface; it carries thrust only and floats radially.
//
// Radial load path: arm ply -> pink (screwed flange + large-dia hole)
// -> pin -> main inner race -> balls -> outer race -> green pocket ->
// green snout piloting the 28.5 board hole + flange screws -> board.
// The bolt sees pure tension, zero shear, no unsupported span — the
// pin gives it 1 mm radial clearance so nothing twists it (twist would
// drag at the head and wear green's web).
//
// Race-contact rule: these 608s have recessed faces, so oversize inner
// contact / undersize outer contact is fine — but no single piece may
// bridge BOTH rings of one bearing (it would friction-couple the
// stationary and rotating sides). Hence pink's relief taper, the blue
// washer's OD 16 (< outer ring ID 18) and green's shoulder ID 17.
//
// Axis = Y. y 0..12 arm plate (SOLID in the joint zone — no truss
// cutouts), 12..20 running gap, 20..32 fixed board, main 608 at
// 16.5..23.5 (centered on the board's inner face; green's snout
// reaches to 15.5, leaving 3.5 running clearance to the arm plate),
// second 608 inboard at -13..-6 against the 6-thick pink flange.

include <params.scad>
use <../lib/helpers.scad>
use <joints.scad>

$fn = 64;

// arm side plate — solid here; its hole (15.5) passes the pink sleeve.
// Not a precision fit: pink registers by its screwed flange, and the
// precision lives in the pin
module arm_plate() part("darksalmon") difference() {
  cub([56, ply_t, 56], [1, 0, 1]);
  ycyl(15.5, -1, 13);
}

// fixed board: hole (28.5) is LARGER than the bearing OD — the bearing
// passes through; the green snout pilots this hole for radial shear
module fixed_board() part("salmon") difference() {
  ty(20) cub([64, ply_t, 64], [1, 0, 1]);
  ycyl(28.5, 19, 33);
}

// gold: temporary centering sheath, installed only while snugging the
// jam nuts, then removed. It slips LOOSELY over the pink flange OD and
// the 2nd bearing OD (both rotate together, so it ties the bearing
// concentric to pink and thus the bolt concentric inside the pin).
// Open at the bottom hole so the blue washer passes through and the
// nuts stay reachable; the large bore also swallows the pink screw
// heads. Cup shape prints closed-end-down with zero overhangs — the
// bore only ever steps LARGER going up from the bed
module sheath() part("gold") difference() {
  ycyl(44, -15.5, -0.5);
  ycyl(40.6, -9, 0);
  ycyl(22.3, -14, -8.9);
  ycyl(18, -16.5, -13.9);
}

module station() {
  arm_plate();
  fixed_board();
  bearing_station(8);
  sheath();
}

// left: assembled (turned for a 3/4 view); right: cross-section — the
// removed half faces the camera, so the section plane reads face-on
ty(40) rz(65) station();
ty(-72) station($section = true);
