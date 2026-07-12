// The elbow NOSE, folded into the board's thickness: the +y fork cap
// grows a CNC LOBE to el_lobe_r (77, cut with the plate — see
// upper_arm() in assembly.scad), and this part is the slim printed
// groove LINER riding its rim — a C-channel inside the plate slab
// (y 43.5..54.5), cable centerline el_nose_r = 80, with ONE shared
// V-channel in the plate's mid-plane carrying BOTH cables as
// complementary seated arcs (see the elbow section in params.scad:
// the crossed sheaves make the seats tile the arc with a constant
// ~6.7-deg bare gap that sweeps with the pose). The cable's radial
// load presses liner onto the wood rim dead-center in the board's
// plane — the screws never see a peel moment.
// Both cable ends anchor HERE: tangential feed holes at the arc
// ends (knot recesses and the screw tensioner land at detail time —
// the dn run ties off at the LOW end, the up run at the HIGH end).
// Three thin TABS lap onto the plate's outer face (y 55..58, the
// only material outboard of the board): the two arc-end tabs carry
// the anchors' ~166 N tangential pull into the wood through two
// screws each, the middle one is retention. Tab undersides get
// 45-deg chamfers (or a dab of support) at detail time; the V's
// 2.2 roof bridges fine printing on the inboard face.
// Drawn in the UPPER-ARM frame at the elbow origin (pitch axis = y,
// +y = the drive side); the assembly places it unposed.

include <params.scad>
use <../lib/helpers.scad>

enl_y0 = upper_w / 2 - ply_t + 0.5;   // 43.5: inboard face, 0.5 shy
                                      // of the plate's (running-safe
                                      // vs the 3 mm forearm gap)
enl_y1 = upper_w / 2 - 0.5;           // 54.5: outboard face
enl_out_r = el_crest_r + 1.5;         // 82.9: outer wall
enl_span = el_arc[1] - el_arc[0];     // 151.7
tab_t = 3;                            // tab plate on the 55 face
tab_az = [el_arc[0] + 4, (el_arc[0] + el_arc[1]) / 2, el_arc[1] - 4];

module elbow_nose() difference() {
  union() {
    // the C-channel body, seated on the lobe rim inside the slab
    ry(-el_arc[1]) rx(-90) rotate_extrude(angle = enl_span, $fn = 240)
      polygon([[el_lobe_r, enl_y0], [enl_out_r, enl_y0],
               [enl_out_r, enl_y1], [el_lobe_r, enl_y1]]);
    // three 16-deg screw tabs on the plate's outer face, each
    // lapping from the wood (r 62..lobe) over the body's end face
    for (a = tab_az) ry(-(a + 8)) rx(-90) rotate_extrude(angle = 16, $fn = 240)
      polygon([[62, upper_w / 2], [el_lobe_r, upper_w / 2],
               [el_lobe_r, enl_y1], [enl_out_r, enl_y1],
               [enl_out_r, upper_w / 2 + tab_t],
               [62, upper_w / 2 + tab_t]]);
  }
  // the shared V channel: apex at el_apex_r, 45-deg walls, cut clear
  // through the outer wall (the cord stays captive between the
  // flanking wall rings at 43.5..45.3 / 52.7..54.5)
  ty(el_cab_y) rx(-90) rotate_extrude($fn = 240)
    polygon([[el_apex_r, 0],
             [el_apex_r + 5, 5],
             [el_apex_r + 5, -5]]);
  // tangential anchor feed holes at the arc ends, in the channel
  ry(-el_arc[1]) tx(el_nose_r) ty(el_cab_y)
    cylinder(d = 2.2, h = 24, center = true, $fn = 24);
  ry(-el_arc[0]) tx(el_nose_r) ty(el_cab_y)
    cylinder(d = 2.2, h = 24, center = true, $fn = 24);
  // two wood screws per tab, into the lobe face
  for (a = tab_az, da = [-4.5, 4.5]) ry(-(a + da)) tx(69.5)
    ty(upper_w / 2 - 1) rx(-90)
      cylinder(d = leg_screw_d, h = 8, $fn = 24);
}

elbow_nose();
