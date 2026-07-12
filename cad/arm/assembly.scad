// Full-arm concept assembly, iteration 5. Bench plate at z = 0, yaw
// axis = Z, pitch axes along Y. Pose via params or -D overrides.
//
// Color key: burlywood = truss side plates + boom plate, sienna =
// truss chords, navajowhite = base boards (the fixed sector web is
// part of the left one), rosybrown = yaw slew disc, steelblue = drive wheels,
// tomato = pinions, dimgray = motors, seagreen = joint sensor,
// slategray = counterweights, khaki = printed fittings, silver =
// axles/bearings. The shoulder/elbow joint stations AND the yaw hub
// keep the bearing_station.scad sketch palette: orchid arm bushing,
// yellowgreen fixed bushing, red split pin, deepskyblue tee washer.
//
// Iteration-5 architecture — the shoulder capstan is INVERTED:
// - The SECTOR IS FIXED, coplanar/integral with the LEFT base board
//   (one CNC ply piece or a face-bolted stack): full joint torque
//   grounds straight into the base, no bracket, no pylon. Fan bisector
//   at base angle 180 - shoulder_bend + mid-travel.
// - The DRIVE RIDES THE ARM: the +y truss plate grows a boom at arm
//   angle 180 - shoulder_bend carrying, outboard of itself, the drum
//   (its grooved band spanning the sector band's lane, y 58..103),
//   the wheel + pinion outboard of the band's end (108.5..135.5) and
//   the motor sleeved off the plate, face 4 under the gear plane
//   (56.5..104.5 — the old rig's plunge idiom died when the stack
//   moved outboard); a printed bridge (137.5..145.5) picks up both
//   axle ends so they're simply supported. The drive mass behind the
//   joint is free counterweight, and the gear mesh is entirely
//   arm-internal.
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
// - BASE: a DOUBLED two-ply slew disc (r 200, 24 thick) rides bare-608
//   support rollers under its rim (stub axles at z 13 off small
//   blocks: crowns at the z 24 disc bottom) and hold-downs over it.
//   The HUB is the joint bearing-station idiom FLIPPED onto the
//   baseplate (hub_station in joints.scad, diagram hub_station.scad):
//   a preloaded 608 pair locates the axis — and the yaw gear mesh —
//   with no baseplate through-hole, so the plate bottom stays flat
//   for clamping. Printed herringbone gear segments wrap 200 deg of
//   the rim and the motor hangs INVERTED from a printed pylon,
//   driving them directly with the m2 12T pinion (the same pinion as
//   the shoulder primary) — single stage, ~17:1, yaw +-90. The pinion
//   sits at bench azimuth 315, out of every swept corridor (the arm's
//   drive boom owns azimuths 90..270 at full-up; the front board
//   corners sweep r 161 vs the pinion's 219). On the disc, the stiff
//   U of three boards: left = sector host; right = near-twin carrying
//   the unloaded joint-angle sensor (sleeve turning with the arm hub,
//   ring reader on the outer face — no drivetrain compliance in the
//   measurement); front board runs disc-top-to-247 (limited only by
//   the arm truss at shoulder_min). All three boards tab straight
//   into the disc through mortises in both ply layers — the U plus
//   disc make one torsion box, no angle blocks.
//
// STRUCTURE: the machine is a module kit — bench_env() (final bench
// hardware only), slew_base() (disc + boards + fixed sector + shoulder
// stations), upper_arm() (truss + boom drive + CW + camera) and
// forearm_install() (elbow stations + everything distal) —
// so testbench.scad can compose the SAME parts into the shoulder test
// rig: real base + upper arm, disc clamped flat to the desk, forearm
// replaced by a hung weight. This file's top level is the final
// configuration.

include <params.scad>
use <../lib/helpers.scad>
use <truss.scad>
use <joints.scad>
use <pinion.scad>      // the REAL drivetrain parts, verbatim from
use <gear_drum.scad>   // the detail files — same params.scad

sr = sector_r(shoulder_ratio);   // 238.2
sh_mid = (shoulder_min + shoulder_max) / 2;   // 40
yoke_y = col_w / 2 - ply_t;      // 63: side board inner faces
dd = 180 - shoulder_bend;        // drive boom direction, ARM frame (135)
sector_bis = dd + sh_mid;        // fixed sector bisector, BASE frame (175)
drum_a = (sr + 25) * [cos(dd), sin(dd)];       // drum axle, arm frame
pin_a = (sr + 25 + cd) * [cos(dd), sin(dd)];   // pinion/motor, arm frame

// ---- the machine, final configuration ----
bench_env();
rz(pose_yaw) {                   // everything from here yaws together
  slew_base();
  tz(shoulder_h) ry(-pose_shoulder) {
    upper_arm();
    tx(upper_len) forearm_install();
  }
}

// ---- bench plate, hub station, roller stations, yaw motor ----
module bench_env() {
  // the baseplate is a PLAIN FLAT slab (clampable): nothing pierces
  // or pockets it — the hub's green foot sits flat on top
  color("wheat") tz(-ply_t) linear_extrude(ply_t)
    sq([base_plate, base_plate], [1, 1], 12);
  // the hub: bearing_station flipped onto the plate (hub_station in
  // joints.scad; annotated diagram hub_station.scad). Drawn unposed:
  // pink, the pin and the disc-side races actually turn with the disc
  hub_station();
  // support rollers under the disc rim: bare 608s on stub axles held
  // at z 13 by small inboard blocks — crowns at 24 = the disc bottom,
  // 2 mm of ground clearance under each bearing. Stations dodge the
  // 315 deg lane where the pinion lives; more are cheap if rim loads
  // ask for them
  rz([30, 90, 150, 210, 270, 330]) tx(roller_r) {
    color("khaki") tx(-15) cub([20, 24, 22], [1, 1, 0]);
    color("silver") tz(13) ry(90) {
      cylinder(d = 8, h = 28, center = true);
      cylinder(d = 22, h = 7, center = true);
    }
  }
  // hold-down stations: riser outside the gear band, arm in over the rim
  rz([30, 150, 270]) {
    color("khaki") tx(yaw_disc_r + 20) cub([14, 30, 76], [0, 1, 0]);
    color("khaki") tx(roller_r + 6) tz(64) cub([36, 30, 12], [0, 1, 0]);
    color("silver") tx(roller_r) tz(60) ry(90)
      cylinder(d = 22, h = 7, center = true);
  }
  // yaw drive: the m2 12T herringbone pinion (the shoulder primary
  // pinion, reused — drawn real) hangs INVERTED over the rim so the
  // gear band can sit low: the motor face bolts down onto a printed
  // pylon's top plate 2 over the band, the shaft drops through its
  // clearance hole and the pinion spans the full band with margin.
  // Azimuth 315: out of the arm's swept corridors.
  rz(135) tx(-(yaw_pitch_r + 12)) {
    color("khaki") {
      tx(-38) cub([12, 50, 50], [1, 1, 0]);
      tz(50) difference() {
        tx(-44) cub([68, 50, 4], [0, 1, 0]);
        tz(-0.5) cylinder(d = 32, h = 5);
      }
    }
    color("dimgray") tz(54) cub([motor_w, motor_w, motor_len], [1, 1, 0]);
    color("silver") tz(23) cylinder(d = 5, h = 31, $fn = 24);
    color("tomato") tz(22) pinion();
  }
}

// ---- slew disc + boards + fixed sector + shoulder stations ----
// segs: the printed gear segments are install-at-graduation parts —
// the testbench clamps the disc dead and omits them (the hub station
// lives in bench_env, which the testbench never draws).
module slew_base(segs = true) {
  // the base: two-layer ply slew disc; printed herringbone gear
  // segments clip over the rim through yaw_seg_arc, centered on the
  // pinion's disc-frame azimuth. The sheets differ at the bore: the
  // LOWER one is the hub station's moving plate (15.5 bore passing
  // pink's sleeve, flange screwed to its top face), the UPPER one's
  // 48 cutout swallows the flange + 2nd bearing + centering sheath —
  // only the washer/jam-nut/bolt-tip pillar stands proud of the disc
  color("rosybrown") {
    tz(disc_z0) linear_extrude(ply_t) difference() {
      circle(r = yaw_disc_r);
      circle(d = 15.5);
      board_slots_2d();
    }
    tz(disc_z0 + ply_t) linear_extrude(ply_t) difference() {
      circle(r = yaw_disc_r);
      circle(d = 48);
      board_slots_2d();
    }
  }
  if (segs)
    color("khaki") tz(disc_z0) linear_extrude(2 * ply_t) rz(-45)
      difference() {
        pie(yaw_pitch_r + 7, yaw_seg_arc);
        circle(r = yaw_pitch_r - 12);
      }

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
  // (one CNC piece); only its rim cable channel — the wedge-backed
  // segment band, flush on the board's inner face — is separate
  tz(shoulder_h)
    sector_channel(sector_angle, sector_bis);
  // paired preloaded bearing stations (joints.scad bearing_station;
  // annotated diagram in bearing_station.scad): pink bushing + roll
  // pin turn with the arm plates, green bushing + M3 bolt fixed to
  // each board, gap 3 — the SAME station as the elbow's. The preload
  // loop is internal, so board drift can't unload the bearings, and
  // the bolts see zero shear
  tz(shoulder_h) {
    my([0, 1]) ty(upper_w / 2 - ply_t)
      bearing_station(yoke_y - upper_w / 2);
    // the joint-angle sensor is OPTICAL and unloaded: a printed
    // adhesive scale strip glued around the sensor-board lobe's rim
    // (r 80), read by a high-res closeup camera riding the arm (drawn
    // in the arm frame in upper_arm). Strip arc 140 deg centered on
    // top: the camera's world azimuth runs 30..150 over travel
    // -20..100, and the strip overshoots 10 deg past each extreme so
    // the camera never reads off its end
    color("white") ty(-yoke_y) rx(90) linear_extrude(ply_t)
      difference() { rz(90) pie(80.8, 140); circle(r = 80); }
  }
}

// ---- upper arm: truss + boom drive + CW + camera ----
// Drawn about the shoulder axis in the arm frame; the elbow fork
// lobes at tx(upper_len) are part of this link's plates — the elbow
// STATIONS and everything distal are forearm_install().
module upper_arm() {
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
  // drive hardware, all outboard of the boom plate — REAL parts (the
  // detail-file modules, so the concept can't drift from the prints):
  // gear_drum lays its grooved core across the fixed band's lane
  // (62..103) and its herringbone wheel outboard of the band's end
  // (108.5..135.5, a short neck spanning the band's outboard wall);
  // the 12T pinion meshes at cd, its motor sleeved off the plate with
  // its face 4 under the gear plane (56.5..104.5) — its mass is free
  // counterweight. The mesh is entirely arm-internal.
  txz(drum_a) {
    color("silver") ty(upper_w / 2 - ply_t) rx(-90)
      cylinder(d = 8, h = 108, $fn = 24);
    color("steelblue") ty(cab_y0 + 2) rx(-90) gear_drum();
  }
  txz(pin_a) {
    color("tomato") ty(whl_y0) rx(-90) pinion();
    // the motor rides in a printed SLEEVE box off the plate; its face
    // stops 4 under the gear plane (the rig idiom: the gear sweeps
    // over the mounting plane), the pinion floating on the shaft
    // above it. Mesh set by press-and-clamp of the sleeve's slotted
    // feet — detail deferred
    color("khaki") ty(upper_w / 2) rx(-90) difference() {
      cub([motor_w + 12, motor_w + 12, whl_y0 - 4 - upper_w / 2],
          [1, 1, 0]);
      tz(-0.5) cub([motor_w + 1, motor_w + 1, whl_y0], [1, 1, 0]);
    }
    color("dimgray") ty(whl_y0 - 4 - motor_len) rx(-90)
      cub([motor_w, motor_w, motor_len], [1, 1, 0]);
  }
  // printed bridge over both axle ends (the rig idiom: the axles end
  // up simply supported); legs flank the wheels, clear of the cable
  // runs
  color("khaki") {
    ty(whl_y0 + gear_width + 10) rx(90) linear_extrude(8) rz(dd)
      tx(sr - 15) sq([cd + 80, 172], [0, 1], 16);
    txz([for (s = [-72, 72])
         [(sr + 25 + cd / 2) * cos(dd) - s * sin(dd),
          (sr + 25 + cd / 2) * sin(dd) + s * cos(dd)]])
      ty(upper_w / 2) rx(-90) cylinder(d = 14, h = whl_y0 + gear_width + 6
                                       - upper_w / 2);
  }
  // upper-arm counterweight: the block bolts to the INBOARD face of
  // the boom plate's fan (no separate boom), centered just BELOW the
  // straight-back line — the drive stack sits above the centerline,
  // so the closing weight goes under it. y 1..43 keeps it inside the
  // base boards and under the drum/motor/bridge lanes; the worst
  // corner sweeps r 325, passing z 67 over the disc top (8 over the
  // hub pillar's bolt tip) and x 121 at the front board at full-up
  color("slategray") ry(-(180 - cw_bend))
    tx(cw_r - cw_mass[0] / 2) ty(43) cub(cw_mass, [0, -1, 1]);

  // the scale-reading camera, arm-fixed at arm azimuth 50 deg, r 92:
  // bracket off the (solid) -y plate reaches over the 3 mm gap; the
  // lens sits 6 mm off the strip on the lobe rim. Azimuth 50 is
  // forced: world azimuth = 50 + pose, so the sweep is 30 (full
  // down) .. 150 (full up) — the only mount that stays on the
  // lobe's top arc at both ends of the travel
  ry(-50) tx(92) {
    color("seagreen") ty(-(yoke_y + 12)) cub([10, 14, 14], [0, 0, 1]);
    color("dimgray") ty(-(yoke_y + 5)) ry(-90) cylinder(d = 6, h = 5);
    color("khaki") ty(-(yoke_y - 2)) cub([10, 6, 14], [0, 0, 1]);
  }

  // elbow fork lobes: full ply rings around the 28.5 pilot bores —
  // the truss plates end exactly at the axis — and with the green
  // bushings carrying the bearings, the old khaki fork doublers are
  // superseded
  color("burlywood") tx(upper_len) my([0, 1]) ty(upper_w / 2) rx(90)
    linear_extrude(ply_t) difference() {
      circle(r = 35);
      circle(d = 28.5);
    }
}

// ---- elbow stations + forearm + wrist + end effector ----
// Drawn at the elbow origin in the upper-arm frame. The testbench
// leaves ALL of this out and hangs its test weight in the empty
// pilot bores instead.
module forearm_install() {
  // paired stations again: forearm plates are the moving side,
  // upper-arm plates the fixed boards (gap 3, so the main bearing
  // sits flush with the fixed plate's inner face instead of proud)
  my([0, 1]) ty(fore_w / 2 - ply_t)
    bearing_station(upper_w / 2 - ply_t - fore_w / 2);

  ry(pose_elbow) {   // downward bend only
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
    // ---- wrist ----
    tx(fore_len) {
      joint_axle(fore_w + 40);
      ry(-pose_wrist) {
        color("burlywood") cub([ee_len, 44, 64], [0, 1, 1]);
        color("navajowhite") tx(ee_len) ry(90) cylinder(d = 85, h = 12);
        %tx(ee_len + 75) ry(90) cylinder(d = 70, h = 125, center = true);
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
// literally one CNC piece, so it's drawn here in the board color. Its
// circular rim stops at rim_r: the printed segment bands seat on it
// and carry the cable out to crest_r, held by wood screws in the
// pilot circle (three per segment, matching the legs). A gusset
// triangle blends the sector's lower tip back into the board's rear
// edge (fills the notch where the lower edge crossed x -80,
// stiffening the cantilevered tip); it lives at base angles 240..253,
// outside the drive fan's 115..235 sweep, so the radial rule holds.
// (The lower end's cable knot pokes past the arc end within the board
// plane — nick this gusset's corner to clear it.)
module left_board_2d() {
  a0 = sector_bis + sector_angle / 2;      // lower sector edge (240)
  difference() {
    union() {
      board_core_2d();
      txy([0, shoulder_h]) rz(sector_bis) pie(rim_r, sector_angle);
      polygon([[-80, shoulder_h - 80 * tan(a0 - 180)],
               [rim_r * cos(a0), shoulder_h + rim_r * sin(a0)],
               [-80, shoulder_h + rim_r * sin(a0) - 40]]);
    }
    txy([0, shoulder_h]) circle(d = 28.5);   // green snout pilot bore
    // segment leg screw pilots
    txy([0, shoulder_h])
      rz([for (k = [0 : seg_n - 1], da = [-14, 0, 14])
          sector_bis - sector_angle / 2 + (k + 0.5) * seg_ang + da])
        tx(leg_screw_r) circle(d = 2.5);
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
// motor standoff's mounting circle (the motor rides outboard on a
// printed standoff; mesh set by press-and-clamp of its slotted feet)
// the forearm's LEFT plate fin, drawn in the forearm frame (elbow at
// the origin): bottom edge 2 mm above the shared taper line behind
// the axis — clears the upper arm's top chord at full extension, and
// since the elbow bends DOWN only, every fin point's line clearance
// only grows through travel until it has swung forward past the
// upper arm's end. Ahead of the axis it laps down onto the plate's
// solid top margin band (dipping below the line is fine there: the
// upper arm ends at the elbow). The closest approach to the elbow
// axis is r ~40 — clearance held for whatever drive wheel the elbow
// redesign puts at the joint (the old worm ring reached r 37.5)
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
    // 392 - r, so 338 keeps 6 over the z 48 disc top), then, past arm
    // angle ~191 where the FRONT board takes over at full-up
    // (x = r*cos(angle+100) <= 124 vs the x 130 face), a chord to the
    // lower corner at arm angle 200, r 248. Local frame: +x' = arm
    // angle dd (135), so local angle = arm angle - 135
    polygon(concat([[0, 0]],
      [for (a = [8 : 4 : 56]) 338 * [cos(a), sin(a)]],
      [[104.8, 224.8]]));
  }
  tx(sr + 25) circle(d = 8.4);
  tx(sr + 25 + cd) circle(d = 30);   // wiring pass / standoff locator
}

module tube(od, id, h) difference() {
  cylinder(d = od, h = h);
  tz(-0.5) cylinder(d = id, h = h + 1);
}
