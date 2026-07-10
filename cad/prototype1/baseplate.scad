// Test-stand structure (CNC 12 mm ply): vertical board carrying the whole
// mechanism, horizontal base that clamps flat to the bench, two gussets.
// Tab-and-slot, self-jigging; add wood screws or glue after squaring.
//
// Board coordinates: sector pivot at the origin, +Y up. The board stands
// at the bench edge, mechanism side facing out, so the arm (which rides
// ~124 mm proud of the board) swings freely past the bench face; at -25
// deg the weights hang ~340 mm below bench level. CLAMP THE BASE WELL:
// 6 kg at the 450 mm hole puts ~27 N*m of roll on the base when the arm
// is horizontal.
//
// Export DXFs:
//   openscad -o build/rig_board.dxf      -D layer=1 baseplate.scad
//   openscad -o build/rig_base.dxf       -D layer=2 baseplate.scad
//   openscad -o build/rig_gusset.dxf     -D layer=3 baseplate.scad  (cut 2)
//   openscad -o build/rig_pivot_beam.dxf -D layer=4 baseplate.scad

include <params.scad>
use <../lib/helpers.scad>

layer = 0;

slot = 0.2;                   // extra on slot widths for the ply fit
gusset_tab_y = [[-65, 25], [-30, 25]];   // [y0, height] through-board tabs

module slot_2d(l, w) hull() tx([-l / 2, l / 2]) circle(d = w);

// ---- vertical board ----
module board_2d() {
  difference() {
    union() {
      txy([board_x0, board_y0])
        sq([board_x1 - board_x0, board_y1 - board_y0], [0, 0], board_corner_r);
      // tabs into the base
      tx(board_tabs_x) txy([0, board_y0 - board_t + 1])
        sq([board_tab_w, board_t + 1], [1, 0]);
    }
    // sector axle + standoff foot bolts
    circle(d = axle_hole_d);
    rz([45, 135, 225, 315]) tx(sector_standoff_bolt_r) circle(d = 4.5);
    // drum axle + foot bolts (match drum_standoff: 2 bolts along the
    // tangent, perpendicular to the flange flat toward the pinion)
    txy(drum_pos) {
      circle(d = axle_hole_d);
      rz([travel_mid, travel_mid + 180])
        tx(drum_standoff_bolt_r) circle(d = 4.5);
    }
    // motor cutout (body plunges through, with mesh-slide clearance) and
    // mount plate foot bolts; local x = radial/mesh direction
    txy(pinion_pos) rz(90 + travel_mid) {
      sq([nema17_body + 2 * motor_slide + 2, nema17_body + 3], [1, 1]);
      txy(motor_feet) circle(d = 4.5);
    }
    // drum bridge feet, along the tangent through the drum
    txy(drum_pos) rz(travel_mid) mx([0, 1])
      tx([for (b = bridge_foot_bolts) bridge_half_span + b])
        ty(bridge_offset) circle(d = 4.5);
    // travel stop posts
    rz([90 + travel_mid - stop_beta, 90 + travel_mid + stop_beta])
      tx(stop_r) circle(d = axle_hole_d);
    // gusset tabs pass through the board
    tx(gusset_x) for (t = gusset_tab_y)
      txy([0, t[0] - slot / 2]) sq([board_t + slot, t[1] + slot], [1, 0]);
  }
}

// ---- bench base (local coords: x as the board, y = depth from front edge) ----
module base_2d() {
  // depth of the board's back face measured from the base's front edge
  front_to_board = rig_base_front_z - board_face_z + board_t;
  difference() {
    txy([rig_base_x0, 0]) sq([rig_base_w, rig_base_d], [0, 0], board_corner_r);
    // board tab slots (board back face sits at depth front_to_board)
    tx(board_tabs_x) txy([0, front_to_board - board_t - slot / 2])
      sq([board_tab_w + slot, board_t + slot], [1, 0]);
    // gusset tab slots, behind the board
    tx(gusset_x) txy([0, front_to_board + 30])
      sq([board_t + slot, 40 + slot], [1, 0]);
  }
}

// ---- pivot bridge beam: a boomerang across the two stop-post tops and
//      the sector axle, simply supporting the pivot ----
module pivot_beam_2d() {
  difference() {
    hull_seq() {
      rz(90 + travel_mid - stop_beta) tx(stop_r) circle(r = pivot_beam_end_r);
      circle(r = pivot_beam_hub_r);
      rz(90 + travel_mid + stop_beta) tx(stop_r) circle(r = pivot_beam_end_r);
    }
    circle(d = axle_hole_d);
    rz([90 + travel_mid - stop_beta, 90 + travel_mid + stop_beta])
      tx(stop_r) circle(d = axle_hole_d);
  }
}

// ---- gusset (local coords: x = depth behind the board back, y = height
//      above the base top; cut two) ----
module gusset_2d() {
  difference() {
    union() {
      polygon([[0, 0], [gusset_d, 0], [gusset_d, 12], [12, gusset_h],
               [0, gusset_h]]);
      // tabs through the board
      for (t = gusset_tab_y) txy([-board_t, t[0] - board_y0])
        sq([board_t + 1, t[1]], [0, 0]);
      // tab into the base
      txy([30, -board_t]) sq([40, board_t + 1], [0, 0]);
    }
  }
}

if (layer == 1) board_2d();
else if (layer == 2) base_2d();
else if (layer == 3) gusset_2d();
else if (layer == 4) pivot_beam_2d();
else {
  color("wheat") linear_extrude(board_t) board_2d();
  color("tan") tx(400) linear_extrude(board_t) base_2d();
  color("peru") tx(400) ty(300) linear_extrude(board_t) gusset_2d();
  color("navajowhite") tx(800) linear_extrude(board_t) pivot_beam_2d();
}
