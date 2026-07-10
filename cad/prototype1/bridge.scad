// Drum bridge: spans the gear+drum tangent to the sector arc and picks up
// the top of the M8 dead axle, turning it from cantilevered into simply
// supported. The axle is dead, so no bearing lives here — the nyloc on
// top clamps board, standoff, bearings (via the inner-race spacers), and
// bridge into one preloaded column.
//
// Local coords: drum axis at the origin, +X along the tangent, +Y
// outboard (away from the sector), z = 0 at the board face. Legs sit
// bridge_offset outboard so the cable runs (~7 mm inboard of the tangent
// line, up to ~z 69) pass clear; the beam's underside flares to full
// depth at 45 deg well above them. Print lying on its outboard back —
// the flare makes it support-free.
//
// Radial cable load bends the beam about its strong axis: ~0.05 mm at
// full torque.

include <params.scad>
use <../lib/helpers.scad>

leg_h = gear_z + drum_z_top + 2 - board_face_z;  // underside: race + 2 mm pilot
bw = 2 * bridge_half_span + bridge_leg[0];       // beam length
y1 = bridge_offset + bridge_leg[1] / 2;          // outboard face

module bridge() {
  difference() {
    union() {
      difference() {
        union() {
          mx([0, 1]) tx(bridge_half_span) {
            // leg + foot pad
            ty(bridge_offset) cub([bridge_leg[0], bridge_leg[1], leg_h + 1], [1, 1, 0]);
            ty(bridge_offset) cub([30, bridge_leg[1], 8], [0, 1, 0]);
          }
          // beam: full-depth plate on top, flaring at 45 deg down to leg depth
          hull() {
            tz(leg_h) txy([-bw / 2, y1 - bridge_beam_d])
              cub([bw, bridge_beam_d, bridge_beam_t]);
            tz(leg_h - (bridge_beam_d - bridge_leg[1]))
              txy([-bw / 2, y1 - bridge_leg[1]])
                cub([bw, bridge_leg[1],
                     bridge_beam_t + bridge_beam_d - bridge_leg[1]]);
          }
        }
        // clearance pocket: the flare would otherwise descend into the
        // spinning top boss (r15 to z+29) and upper flange; hollow the
        // underside to r17 so only the top slab spans the drum
        tz(leg_h - 20.5) cylinder(d = 34, h = 20.5, $fn = 96);
      }
      // race pilot: bears only on the top 608's inner race, so the nyloc
      // puts slight axial preload through races and inner spacers while
      // the gear+drum spins clear of the pocket
      tz(leg_h - 2) cylinder(d = race_tip_d, h = 2.1, $fn = 48);
    }
    // axle hole through the beam and pilot
    tz(leg_h - 20) cylinder(d = axle_hole_d, h = bridge_beam_t + 21, $fn = 32);
    // foot bolts
    mx([0, 1]) tx([for (b = bridge_foot_bolts) bridge_half_span + b])
      ty(bridge_offset) tz(-0.5) cylinder(d = 4.5, h = 9, $fn = 24);
  }
}

bridge();
