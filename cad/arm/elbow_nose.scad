// The elbow NOSE: the shoulder's fixed sector shrunk to a ~150-deg
// printed arc around the upper arm's +y fork cap — the capstan's
// standing surface, cable centerline el_nose_r = 80, and BOTH cable
// ends anchor HERE (tangential feed holes at the arc ends; knot
// recesses and the screw tensioner land at detail time). TWO PLAIN
// circular V-tracks at el_cab_y / + track_sep: the forearm's idler
// sheaves pin the span planes, so the drum's march never reaches the
// nose and the ramped-track machinery stays at the shoulder (see the
// elbow section in params.scad).
// Construction is the sector-segment language bent around the cap:
// a FOOT ring (y 43..55) seats flush on the cap rim — cable tension
// presses print onto wood, the ply edge takes the radial load — its
// inner boundary following the PLATE'S OWN OUTLINE (circle + straight
// top edge, subtracted with 0.3 clearance), and outboard of the
// plate face the section fills SOLID from the track band down to
// r 46, landing on the plate's outer face. Radial zoning: the solid
// stops at r 46, clearing the bearing station's green flange (r 24)
// and its screw heads (r 23) by 20+. Seven wood screws on the r 56
// circle reach the ply through deep counterbores from the outboard
// face — the sector-segment idiom verbatim.
// Prints on the outboard (y 70.2) face: band, solid fill, foot ring
// and counterbores rise straight off the bed; the 45-deg V walls
// print support-free.
// Drawn in the UPPER-ARM frame at the elbow origin (pitch axis = y,
// +y = the drive side); the assembly places it unposed.

include <params.scad>
use <../lib/helpers.scad>

en_y1 = el_cab_y + track_sep + 2.2 + 2;   // 70.2: outboard face (V
                                          // mouth edge 68.2 + wall)
en_leg_r = 46;              // solid fill's inner radius (on the plate)
en_span = el_arc[1] - el_arc[0];          // 149.8
en_screw_n = 7;

// the cap plate's 2D outline (assembly.scad's hull, at the elbow
// origin), for carving the foot's rim-hugging inner boundary
module en_plate_2d() hull() {
  circle(r = elbow_d / 2 * cos(arm_taper));
  tx(-2) sq([2, elbow_d], [0, 1]);
}

module elbow_nose() difference() {
  // L-section swept over the arc: foot ring (rim..crest x 43..55)
  // + solid band body (46..crest x 55..70.2)
  ry(-el_arc[1]) rx(-90) rotate_extrude(angle = en_span, $fn = 180)
    polygon([[elbow_d / 2 * cos(arm_taper) - 2, 43],
             [el_crest_r, 43],
             [el_crest_r, en_y1],
             [en_leg_r, en_y1],
             [en_leg_r, upper_w / 2],
             [elbow_d / 2 * cos(arm_taper) - 2, upper_w / 2]]);
  // the plate itself (+ 0.3 running clearance) carves the foot's
  // inner face — a circular rim seat around the cap, following the
  // straight top edge where the arc's high end passes the hull line
  ty(upper_w / 2 + 0.3) rx(90) linear_extrude(ply_t + 0.6)
    offset(delta = 0.3) en_plate_2d();
  // the two V-tracks, revolved triangles about the axis (wrist-drum
  // idiom): apex at el_apex_r, 45-deg walls, mouth +-2.2 at the crest
  for (i = [0, 1]) ty(el_cab_y + i * track_sep) rx(-90)
    rotate_extrude($fn = 180)
      polygon([[el_apex_r, 0],
               [el_apex_r + 4, 4],
               [el_apex_r + 4, -4]]);
  // seven wood screws into the plate's outer face: shank + deep head
  // counterbore reaching in from the print/outboard face
  for (k = [0 : en_screw_n - 1])
    ry(-(el_arc[0] + 12 + (en_span - 24) * k / (en_screw_n - 1)))
      tx(56) {
        ty(upper_w / 2 - 1) rx(-90) cylinder(d = leg_screw_d, h = 8, $fn = 24);
        ty(upper_w / 2 + 5) rx(-90)
          cylinder(d = cb_d, h = en_y1 - upper_w / 2 - 3, $fn = 24);
      }
  // cable anchors: a tangential 2.2 feed hole at each arc end, in
  // line with its run's track — run A (inboard track) knots at the
  // +end, run B (outboard) at the -end; VERIFY the pairing against
  // the drum groove hand at detail time
  ry(-el_arc[1]) tx(el_nose_r) ty(el_cab_y)
    cylinder(d = 2.2, h = 24, center = true, $fn = 24);
  ry(-el_arc[0]) tx(el_nose_r) ty(el_cab_y + track_sep)
    cylinder(d = 2.2, h = 24, center = true, $fn = 24);
}

elbow_nose();
