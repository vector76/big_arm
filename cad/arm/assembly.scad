// Full-arm concept assembly, iteration 5. Bench plate at z = 0, yaw
// axis = Z, pitch axes along Y. Pose via params or -D overrides.
//
// Color key: burlywood = truss side plates + boom plate, sienna =
// truss chords, navajowhite = base boards (the fixed sector web is
// part of the left one), rosybrown = yaw slew disc, steelblue = drive wheels,
// tomato = pinions/worms, dimgray = motors, seagreen = joint sensor,
// slategray = counterweights, khaki = printed fittings, silver =
// axles/bearings. The shoulder/elbow joint stations keep the
// bearing_station.scad sketch palette: orchid arm bushing, yellowgreen
// fixed bushing, red split pin, deepskyblue tee washer.
//
// Iteration-5 architecture — the shoulder capstan is INVERTED:
// - The SECTOR IS FIXED, coplanar/integral with the LEFT base board
//   (one CNC ply piece or a face-bolted stack): full joint torque
//   grounds straight into the base, no bracket, no pylon. Fan bisector
//   at base angle 180 - shoulder_bend + mid-travel.
// - The DRIVE RIDES THE ARM: the +y truss plate grows a boom at arm
//   angle 180 - shoulder_bend carrying, outboard of itself, the drum
//   (on the sector cable plane y 56..82), the wheel + pinion (82..109)
//   and the motor plunged through the plate (34..82, prototype1
//   idiom); a printed bridge (109..117) picks up both axle ends so
//   they're simply supported. The drive mass behind the joint is free
//   counterweight, and the gear mesh is entirely arm-internal.
// - COUNTERWEIGHT: the drive boom plate is a SOLID FAN reaching from
//   the boom down past straight-back (left side only), and the ~4 kg
//   block bolts to its inboard face just BELOW the arm centerline —
//   under the drive stack's above-centerline mass, so the combined
//   CG lands on the shoulder axis. At full-up the fan sweeps down
//   the well between the boards; the slew disc and the front board
//   cap its reach (arc r 338, lower corner at arm angle 200), which
//   is the price of parallel vs. the drive-direction boom's 400 mm
//   lever. The
//   ELBOW counterweight is an in-plane top boom + hook on the forearm
//   center plane: its CG sits on the forearm axis extended through
//   the elbow (zero gravity torque at every pose); the down-only bend
//   sweeps it up and away, and at full extension the hook parks in a
//   slot in the upper arm's top board.
// - BASE: a DOUBLED two-ply slew disc (r 200, 24 thick) rides support
//   rollers under its rim and hold-downs over it; printed herringbone
//   gear segments wrap 200 deg of the rim and a bench-standing motor
//   drives them directly with the m2 12T pinion (the same pinion as
//   the shoulder primary) — single stage, ~17:1, yaw +-90. The pinion
//   sits at bench azimuth 315, out of every swept corridor (the arm's
//   drive boom owns azimuths 90..270 at full-up; the front board
//   corners sweep r 161 vs the pinion's 219). On the disc, the stiff
//   U of three boards: left = sector host; right = near-twin carrying
//   the unloaded joint-angle sensor (sleeve turning with the arm hub,
//   ring reader on the outer face — no drivetrain compliance in the
//   measurement); front board runs disc-top-to-275 (limited only by
//   the arm truss at shoulder_min). All three boards tab straight
//   into the disc through mortises in both ply layers — the U plus
//   disc make one torsion box, no angle blocks.

include <params.scad>
use <../lib/helpers.scad>
use <truss.scad>
use <joints.scad>

sr = sector_r(shoulder_ratio);   // 238.2
sh_mid = (shoulder_min + shoulder_max) / 2;   // 40
yoke_y = col_w / 2 - ply_t;      // 63: side board inner faces
dd = 180 - shoulder_bend;        // drive boom direction, ARM frame (135)
sector_bis = dd + sh_mid;        // fixed sector bisector, BASE frame (175)
drum_a = (sr + 25) * [cos(dd), sin(dd)];       // drum axle, arm frame
pin_a = (sr + 25 + cd) * [cos(dd), sin(dd)];   // pinion/motor, arm frame

// ---- bench plate, center post, roller stations ----
color("wheat") tz(-ply_t) linear_extrude(ply_t)
  sq([base_plate, base_plate], [1, 1], 12);
color("silver") tz(-18) cylinder(d = 8, h = 94, $fn = 24);
// support rollers under the disc rim (stations dodge the 315 deg lane
// where the pinion lives)
rz([30, 90, 150, 210, 270, 330]) tx(roller_r) {
  color("khaki") cub([24, 30, 30], [1, 1, 0]);
  color("silver") tz(41) ry(90) cylinder(d = 22, h = 7, center = true);
}
// hold-down stations: riser outside the gear band, arm in over the rim
rz([30, 150, 270]) {
  color("khaki") tx(yaw_disc_r + 20) cub([14, 30, 104], [0, 1, 0]);
  color("khaki") tx(roller_r + 6) tz(92) cub([36, 30, 12], [0, 1, 0]);
  color("silver") tx(roller_r) tz(88) ry(90)
    cylinder(d = 22, h = 7, center = true);
}
// yaw drive: the m2 12T herringbone pinion (the shoulder primary
// pinion, reused) straight on a bench-standing motor, up into the
// segment band. Azimuth 315: out of the arm's swept corridors.
rz(135) tx(-(yaw_pitch_r + 12)) {
  color("dimgray") cub([motor_w, motor_w, motor_len], [1, 1, 0]);
  color("silver") tz(motor_len) cylinder(d = 5, h = 26, $fn = 24);
  color("tomato") tz(motor_len + 1) cylinder(d = 28, h = gear_w);
}

// ---- everything from here yaws together ----
rz(pose_yaw) {
  // the base: two-layer ply slew disc; printed herringbone gear
  // segments clip over the rim through yaw_seg_arc, centered on the
  // pinion's disc-frame azimuth
  color("rosybrown") tz([disc_z0, disc_z0 + ply_t]) linear_extrude(ply_t)
    difference() {
      circle(r = yaw_disc_r);
      circle(d = 40);
      board_slots_2d();
    }
  color("khaki") tz(disc_z0) linear_extrude(2 * ply_t) rz(-45)
    difference() {
      pie(yaw_pitch_r + 7, yaw_seg_arc);
      circle(r = yaw_pitch_r - 12);
    }
  // central 608 pair housing through the disc bore (axis location
  // only), flush with the disc top: the shoulder counterweight passes
  // 6 mm over it at full-up
  color("khaki") tz(disc_z0 - 10) tube(40, 22, 34);

  // ... and the three boards: near-twins left/right plus the FRONT
  // board, ALL tabbed straight into the disc (mortises through both
  // ply layers, shoulders landing on the disc top — no angle blocks).
  // The front board panel runs from the disc top to front_z1, closing
  // the U into a torsion box with the disc as its floor.
  color("navajowhite") {
    ty(yoke_y + ply_t) rx(90) linear_extrude(ply_t) left_board_2d();
    my(1) ty(yoke_y + ply_t) rx(90) linear_extrude(ply_t) sensor_board_2d();
    tx(front_x) {
      tz(disc_z0 + 2 * ply_t)
        cub([ply_t, col_w, front_z1 - disc_z0 - 2 * ply_t], [0, 1, 0]);
      ty([-60, 20]) tz(disc_z0) cub([ply_t, 40, 2 * ply_t + 2]);
    }
  }

  // the FIXED shoulder sector web is drawn as part of left_board_2d
  // (one CNC piece); only its rim cable channel is a separate part
  tz(shoulder_h)
    sector_channel(sr, shoulder_max - shoulder_min + 10, sector_bis,
                   sector_plane_y);
  // paired preloaded bearing stations (joints.scad bearing_station;
  // annotated diagram in bearing_station.scad): pink bushing + roll
  // pin turn with the arm plates, green bushing + M3 bolt fixed to
  // each board. The preload loop is internal, so board drift can't
  // unload the bearings, and the bolts see zero shear
  tz(shoulder_h) {
    my([0, 1]) ty(upper_w / 2 - ply_t)
      bearing_station(yoke_y - upper_w / 2);
    // the joint-angle sensor is OPTICAL and unloaded: a printed
    // adhesive scale strip glued around the sensor-board lobe's rim
    // (r 80), read by a high-res closeup camera riding the arm (drawn
    // in the arm frame below). Strip arc 140 deg centered on top: the
    // camera's world azimuth runs 30..150 over travel -20..100, and
    // the strip overshoots 10 deg past each extreme so the camera
    // never reads off its end
    color("white") ty(-yoke_y) rx(90) linear_extrude(ply_t)
      difference() { rz(90) pie(80.8, 140); circle(r = 80); }
  }

  // ---- upper arm ----
  tz(shoulder_h) ry(-pose_shoulder) {
    // bottom chord relieved elbow_d/2 + 6 about the elbow — the
    // folding forearm root's plate corners sweep r = elbow_d/2, and
    // the full-length chord interpenetrated that circle (relief radius
    // computed at the chord's inner face; slight overcut at the outer
    // face is extra clearance). Hook slot in the TOP board only, where
    // the elbow counterweight parks at full extension.
    difference() {
      // plates solid through the joint zones: the whole stub + 80 past
      // the shoulder axis (the camera bracket mounts at x 59..66), and
      // the last 45 at the elbow fork
      box_truss(-upper_stub, upper_len, upper_w,
                link_d(upper_len + upper_stub), elbow_d,
                sqrt(pow(elbow_d / 2 + 6, 2) - pow(elbow_d / 2 - ply_t, 2)),
                upper_stub + 80, 45);
      tx(elbow_cw_slot_x)
        tz(link_d(upper_len - elbow_cw_slot_x) / 2 - ply_t - 8)
        linear_extrude(28) sq(elbow_cw_slot, [1, 1], 8);
    }
    // the +y plate grows the drive boom at arm angle dd (lap-jointed
    // over the truss plate at concept level)
    color("burlywood") ty(upper_w / 2) rx(90) linear_extrude(ply_t)
      boom_plate_2d();
    // drive hardware, all outboard of the boom plate: drum on the fixed
    // sector's cable plane (y 56..82), wheel above it (82..109), pinion
    // alongside, motor plunged through the plate (34..82) — its mass is
    // free counterweight. The mesh is entirely arm-internal.
    txz(drum_a) {
      color("silver") ty(upper_w / 2 - ply_t) rx(-90)
        cylinder(d = 8, h = 78, $fn = 24);
      color("steelblue") ty(sector_plane_y - 13) rx(-90)
        cylinder(d = drum_od, h = 26);
      color("steelblue") ty(sector_plane_y + 13) rx(-90)
        cylinder(d = gear_od, h = gear_w);
    }
    txz(pin_a) {
      color("tomato") ty(sector_plane_y + 13) rx(-90)
        cylinder(d = 28, h = gear_w);
      color("dimgray") ty(sector_plane_y - 35) rx(-90)
        cub([motor_w, motor_w, motor_len], [1, 1, 0]);
    }
    // printed bridge over both axle ends (prototype1 idiom: the axles
    // end up simply supported); legs flank the wheels, clear of the
    // cable runs
    color("khaki") {
      ty(sector_plane_y + 48) rx(90) linear_extrude(8) rz(dd)
        tx(sr - 15) sq([cd + 80, 172], [0, 1], 16);
      txz([for (s = [-72, 72])
           [(sr + 25 + cd / 2) * cos(dd) - s * sin(dd),
            (sr + 25 + cd / 2) * sin(dd) + s * cos(dd)]])
        ty(upper_w / 2) rx(-90) cylinder(d = 14, h = 54);
    }
    // upper-arm counterweight: the block bolts to the INBOARD face of
    // the boom plate's fan (no separate boom), centered just BELOW the
    // straight-back line — the drive stack sits above the centerline,
    // so the closing weight goes under it. y 1..43 keeps it inside the
    // base boards and under the drum/motor/bridge lanes; the worst
    // corner sweeps r 325, passing z 95 over the disc top and x 121
    // at the front board at full-up
    color("slategray") ry(-(180 - cw_bend))
      tx(cw_r - cw_mass[0] / 2) ty(43) cub(cw_mass, [0, -1, 1]);

    // the scale-reading camera, arm-fixed at arm azimuth 50 deg, r 92:
    // bracket off the (solid) -y plate reaches over the 8 mm gap; the
    // lens sits 6 mm off the strip on the lobe rim. Azimuth 50 is
    // forced: world azimuth = 50 + pose, so the sweep is 30 (full
    // down) .. 150 (full up) — the only mount that stays on the
    // lobe's top arc at both ends of the travel
    ry(-50) tx(92) {
      color("seagreen") ty(-75) cub([10, 14, 14], [0, 0, 1]);
      color("dimgray") ty(-68) ry(-90) cylinder(d = 6, h = 5);
      color("khaki") ty(-61) cub([10, 6, 14], [0, 0, 1]);
    }

    // elbow worm + motor, entirely inside the truss hollow
    tx(upper_len) worm_motor(elbow_wheel_d);

    // ---- elbow ----
    tx(upper_len) {
      // paired stations again: forearm plates are the moving side,
      // upper-arm plates the fixed boards (gap 3, so the main bearing
      // sits flush with the fixed plate's inner face instead of
      // proud). Fork lobes give the plates a full ply ring around the
      // 28.5 pilot bore — the truss plates end exactly at the axis —
      // and with the green bushings carrying the bearings, the old
      // khaki fork doublers are superseded
      color("burlywood") my([0, 1]) ty(upper_w / 2) rx(90)
        linear_extrude(ply_t) difference() {
          circle(r = 35);
          circle(d = 28.5);
        }
      my([0, 1]) ty(fore_w / 2 - ply_t)
        bearing_station(upper_w / 2 - ply_t - fore_w / 2);

      ry(pose_elbow) {   // downward bend only
        // the wheel is a RING so the station hardware inboard of the
        // forearm plates (r <= 20) passes through its bore; tabs tie
        // it to the forearm's root lobes
        worm_wheel_ring(elbow_wheel_d, fore_w / 2 - ply_t);
        box_truss(0, fore_len, fore_w, elbow_d, link_d(-fore_len),
                  0, 45, 45);
        color("burlywood") my([0, 1]) ty(fore_w / 2) rx(90)
          linear_extrude(ply_t) difference() {
            circle(r = 36);
            circle(d = 15.5);
          }
        // the LEFT forearm plate grows a FIN back over the elbow (one
        // CNC piece, replacing the bolted-on boom + riser)
        color("burlywood") ty(fore_w / 2) rx(90) linear_extrude(ply_t)
          fore_cw_fin_2d();
        // elbow counterweight, CENTERED for lateral symmetry: a
        // dog-leg hanger crosses from the fin's inboard face (y 28)
        // to the center plane, then drops through the upper arm's
        // CENTERED top-board slot to the block, whose CG sits on the
        // forearm axis extended back through the elbow — so gravity
        // torque vanishes at every pose. At full extension the hanger
        // parks in the slot (near-vertical entry: arc r ~245)
        color("slategray") {
          tx(elbow_cw_x0) ty(-20) tz(88)
            cub([25, 48, 24], [0, 0, 0]);                  // dog-leg
          tx(elbow_cw_x0) tz(-45)
            cub([25, 40, link_d(-elbow_cw_x0) / 2 + 82], [0, 1, 0]);
          tx(elbow_cw_x0 - 28) tz(-45) cub(elbow_cw_blk, [0, 1, 0]);
        }
        // wrist worm + motor inside the forearm hollow
        tx(fore_len) worm_motor(wrist_wheel_d);

        // ---- wrist ----
        tx(fore_len) {
          joint_axle(fore_w + 40);
          ry(-pose_wrist) {
            worm_wheel(wrist_wheel_d);
            color("burlywood") cub([ee_len, 44, 64], [0, 1, 1]);
            color("navajowhite") tx(ee_len) ry(90) cylinder(d = 85, h = 12);
            %tx(ee_len + 75) ry(90) cylinder(d = 70, h = 125, center = true);
          }
        }
      }
    }
  }
}

// shared side board core: full-height body from the disc top to the
// shoulder (its front edge at front_x carries the front board), a
// bearing lobe at the axis, and two tabs that mortise through both
// disc layers. Keeping material x >= -80 up high matters: the arm's
// drive boom sweeps the back fan (base angles 115..235) at r > 250 in
// the board's own y-lane.
module board_core_2d() {
  txy([-80, disc_z0 + 2 * ply_t])
    sq([front_x + 80, shoulder_h - disc_z0 - 2 * ply_t], [0, 0], 10);
  txy([0, shoulder_h]) circle(r = 80);
  txy([-60, disc_z0]) sq([40, 2 * ply_t + 2], [0, 0]);
  txy([20, disc_z0]) sq([40, 2 * ply_t + 2], [0, 0]);
}

// the mortise pattern cut through both slew-disc layers: two slots per
// side board (at the board planes y 63..75) and two for the front
// board (at x 130..142)
module board_slots_2d() {
  my([0, 1]) ty(yoke_y) tx([-60, 20]) sq([40, ply_t], [0, 0]);
  tx(front_x) ty([-60, 20]) sq([ply_t, 40], [0, 0]);
}

// LEFT board: grows the FIXED shoulder sector as a SOLID web —
// literally one CNC piece, so it's drawn here in the board color. A
// gusset triangle blends the sector's lower tip back into the board's
// rear edge (fills the notch where the lower edge crossed x -80,
// stiffening the cantilevered tip); it lives at base angles 240..253,
// outside the drive fan's 115..235 sweep, so the radial rule holds.
// Only the rim cable channel (sector_channel) is a separate part
module left_board_2d() {
  ang = shoulder_max - shoulder_min + 10;
  a0 = sector_bis + ang / 2;               // lower sector edge (240)
  difference() {
    union() {
      board_core_2d();
      txy([0, shoulder_h]) rz(sector_bis) pie(sr, ang);
      polygon([[-80, shoulder_h - 80 * tan(a0 - 180)],
               [sr * cos(a0), shoulder_h + sr * sin(a0)],
               [-80, shoulder_h + sr * sin(a0) - 40]]);
    }
    txy([0, shoulder_h]) circle(d = 28.5);   // green snout pilot bore
  }
}

// RIGHT sensor board: near-twin; same pilot bore — its green bushing
// mounts the same way, the sensor rings ride the arm/board gap
module sensor_board_2d() difference() {
  board_core_2d();
  txy([0, shoulder_h]) circle(d = 28.5);   // green snout pilot bore
}

// the arm's drive boom plate, drawn in the +y truss plate's plane:
// a strip at arm angle dd carrying the drum dead axle bore and the
// motor plunge cutout (prototype1 idiom: the motor hangs from a
// slotted plate at its face; mesh set by press-and-clamp)
// the forearm's LEFT plate fin, drawn in the forearm frame (elbow at
// the origin): bottom edge 2 mm above the shared taper line behind
// the axis — clears the upper arm's top chord at full extension, and
// since the elbow bends DOWN only, every fin point's line clearance
// only grows through travel until it has swung forward past the
// upper arm's end. Ahead of the axis it laps down onto the plate's
// solid top margin band (dipping below the line is fine there: the
// upper arm ends at the elbow). The closest approach to the elbow
// axis is r ~40, clearing the r 37.5 worm wheel ring
module fore_cw_fin_2d() {
  t = tan(arm_taper);
  polygon([[70, elbow_d / 2 - 70 * t - 26],
           [2, elbow_d / 2 - 2 * t - 26],
           [0, elbow_d / 2 + 2],
           [elbow_cw_x0, elbow_d / 2 - elbow_cw_x0 * t + 2],
           [elbow_cw_x0, elbow_d / 2 - elbow_cw_x0 * t + 52],
           [30, elbow_d / 2 - 30 * t + 50]]);
}

module boom_plate_2d() rz(dd) difference() {
  union() {
    sq([sr + 25 + cd + 55, 110], [0, 1], 16);
    // SOLID fan below the boom, as far down as travel allows: the
    // upper-arm counterweight bolts to its inboard face BELOW the arm
    // centerline (the drive stack rides above it). Boundary = the two
    // binding constraints: an arc r 338 about the shoulder (any point
    // past arm angle 170 passes straight down at some pose, height
    // 420 - r, so 338 keeps 6 over the z 76 disc top), then, past arm
    // angle ~191 where the FRONT board takes over at full-up
    // (x = r*cos(angle+100) <= 124 vs the x 130 face), a chord to the
    // lower corner at arm angle 200, r 248. Local frame: +x' = arm
    // angle dd (135), so local angle = arm angle - 135
    polygon(concat([[0, 0]],
      [for (a = [8 : 4 : 56]) 338 * [cos(a), sin(a)]],
      [[104.8, 224.8]]));
  }
  tx(sr + 25) circle(d = 8.4);
  tx(sr + 25 + cd) circle(d = 46);
}

module tube(od, id, h) difference() {
  cylinder(d = od, h = h);
  tz(-0.5) cylinder(d = id, h = h + 1);
}
