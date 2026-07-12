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
//   angle 180 - shoulder_bend. The stack is FLIPPED (wheel INBOARD):
//   the 51T wheel + 8T pinion straddle the boom plate through its
//   kidney cutout (y 27..54), the drum's grooved band spans the
//   sector band's lane (62..87) ending in a bearing boss (..96),
//   and the motor points back into the arm side (-30..18), its face
//   on the printed inboard support slab that also seats the drum
//   axle's wheel end — so the mesh center distance is printed-exact
//   and the separating force loops close inside the print; the
//   outboard housing's bridge plate (96..104) picks up the boss end:
//   the dead axle is simply supported. Both supports are walled
//   HOUSINGS, wood-screwed to the boom plate from opposite faces
//   through staggered stations. The drive mass behind the joint is free
//   counterweight, and the gear mesh is entirely arm-internal,
//   guarded inside the cutout.
// - COUNTERWEIGHT: the drive boom plate is a SOLID FAN reaching from
//   the boom down past straight-back (left side only), and the ~4 kg
//   block bolts to its inboard face just BELOW the arm centerline —
//   under the drive stack's above-centerline mass, so the combined
//   CG lands on the shoulder axis. At full-up the fan sweeps down
//   the well between the boards; the slew disc and the front board
//   cap its reach (arc r 338, lower corner at arm angle 200), which
//   is the price of parallel vs. the drive-direction boom's 400 mm
//   lever. The
//   ELBOW counterweight block is TEMPORARILY not drawn: the fin now
//   carries BOTH remote drive stacks (wrist + elbow, ~1.5 kg between
//   them, above the axis line) — block, hanger and fin outline get
//   resized together at the next mass audit.
// - ELBOW DRIVE: the shoulder recipe with the sector shrunk to a
//   NOSE folded into the board's own thickness — the +y fork cap
//   grows a CNC lobe to r 77 and a slim printed groove LINER rides
//   its rim (cable centerline r 80, ONE shared V-channel in the
//   plate's mid-plane carrying both cables as complementary seated
//   arcs; ends anchored at the liner's arc ends, zero slip). A third
//   8T primary with the wheel grown to 66T + the shoulder-size
//   grooved drum rides the fin (el_axle, high enough that the Ø134
//   wheel clears the top chord at full extension), and two CROSSED
//   608-cored idler sheaves sitting +-1 mm astride the channel plane
//   drop the runs into it with a constant ~6.7-deg bare gap between
//   the seats — the liner is travel-sized, its channel is a PLAIN
//   circle, and the drum's march is eaten as fleet in the
//   drum->sheave spans. ~65:1 total, margin ~1.67. Nothing at the
//   elbow stands outboard of the 55 face but three thin liner tabs
//   (<= 58), so the wrist cable plane hugs back in (wr_cab_y 61.5).
// - BASE: a DOUBLED two-ply slew disc (r 200, 24 thick) rides bare-608
//   support rollers under its rim (each on a 5/16" bolt at z 13
//   spanning a pair of printed lugs: crowns at the z 24 disc bottom)
//   and hold-downs over it.
//   The HUB is the joint bearing-station idiom FLIPPED onto the
//   baseplate (hub_station in joints.scad, diagram hub_station.scad):
//   a preloaded 608 pair locates the axis — and the yaw gear mesh —
//   with no baseplate through-hole, so the plate bottom stays flat
//   for clamping. Printed herringbone gear segments wrap 182 deg of
//   the rim and the motor hangs INVERTED from a printed pylon,
//   driving them directly with the m2 8T pinion (the same pinion as
//   the shoulder primary) — single stage, ~26:1, yaw +-85. The bare
//   178 deg of rim bulges into the READOUT LOBE (the rim is an exact
//   360 budget, band + lobe): white angle strip on its face, crest
//   flush with the gear band's outer radius, read by the base-fixed
//   camera at azimuth 135 — one rim cylinder, so the camera can
//   never be struck at any overtravel. The pinion
//   sits at bench azimuth 315, out of every swept corridor (the arm's
//   drive boom owns azimuths 90..270 at full-up; the front board
//   corners sweep r 161 vs the pinion's 215). On the disc, the stiff
//   U of three boards: left = sector host; right = near-twin carrying
//   the unloaded joint-angle sensor (sleeve turning with the arm hub,
//   ring reader on the outer face — no drivetrain compliance in the
//   measurement); front board runs disc-top-to-247 (limited only by
//   the arm truss at shoulder_min). All three boards tab straight
//   into the disc through mortises in both ply layers — the U plus
//   disc make one torsion box, no angle blocks. Rear HEELS widen
//   both side boards' feet down-back over a third disc tab (the
//   left one notched around the drive-blade corridor), and a
//   perpendicular GUSSET outboard of each board ties face to disc —
//   lateral stiffness above front_z1, where the boards' own bending
//   was previously all that backed up the front board.
//
// STRUCTURE: the machine is a module kit of RIGID BODIES — bench_env()
// (final bench hardware only), slew_base() (disc + boards + fixed
// sector + shoulder stations), upper_arm() (truss + boom drive + CW +
// camera), elbow_stations() (upper-arm-fixed), forearm() (everything
// that bends at the elbow) and end_effector() (wrist-mounted) — each
// drawn in its own joint frame, with ALL pose transforms in the
// top-level composition below and nowhere else. So testbench.scad can
// compose the SAME parts into the shoulder test rig (real base + upper
// arm, disc clamped flat to the desk, forearm replaced by a hung
// weight), and export.scad can emit each body as a mesh the three.js
// twin viewer poses with the four joint angles alone. This file's top
// level is the final configuration.

include <params.scad>
use <../lib/helpers.scad>
use <truss.scad>
use <joints.scad>
use <pinion.scad>      // the REAL drivetrain parts, verbatim from
use <gear_drum.scad>   // the detail files — same params.scad
use <drive_housing.scad>  // the two printed drive housings (annotated
                          // standalone diagram in the same file)
use <sector_segment.scad>
use <wrist_drive.scad> // wrist gear+capstan (rides the forearm fin)
use <wrist_drum.scad>  // wrist drum ring (rides the EE fork)
use <elbow_drive.scad> // elbow gear+capstan (rides the fin, 66T)
use <elbow_nose.scad>  // elbow nose arc (fixed on the upper fork cap)

// the boom direction dd, the drum/pinion stations (da, drum_a, pin_a)
// and the housing plan stations (hv_x/hf/hs_out/hs_in) live in
// params.scad with the rest of the shoulder-drive layout; the printed
// housings themselves are drive_housing.scad
sh_mid = (shoulder_min + shoulder_max) / 2;   // 40
yoke_y = col_w / 2 - ply_t;      // 63: side board inner faces
gus_x = -60;     // perpendicular base-gusset plane (x -60..-48): BACK,
                 // where the boards lack the front plate's bracing.
                 // Deepest sweep into this quadrant (bend 55) is the
                 // drive's outboard Y: the roof reaches base angles
                 // ~243 only at shoulder r >= 269, and the arms (to
                 // ~241 at r 254..282) clear by 15 deg — the old full
                 // bridge plate's 245-at-r-213 case went with it.
                 // Behind -80 there is no full-height board
                 // face to glue to
sector_bis = dd + sh_mid;        // fixed sector bisector, BASE frame (165)

// ---- the machine, final configuration ----
// The kinematic tree, whole and in one place: every pose transform
// lives HERE, between rigid bodies drawn in their own joint frames.
bench_env();
rz(pose_yaw) {                   // everything from here yaws together
  slew_base();
  tz(shoulder_h) ry(-pose_shoulder) {
    upper_arm();
    tx(upper_len) {
      elbow_stations();
      ry(pose_elbow) {           // downward bend only
        forearm();
        tx(fore_len) ry(-pose_wrist) end_effector();
      }
    }
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
  // support rollers under the disc rim: bare 608s at z 13 — crowns at
  // 24 = the disc bottom, 2 mm of ground clearance under each bearing.
  // Stations dodge the 315 deg lane where the pinion lives; more are
  // cheap if rim loads ask for them
  rz([30, 90, 150, 210, 270, 330]) tx(roller_r) roller_stand();
  // hold-down stations: a 608 crown-DOWN kissing the disc top at
  // roller_r, hung from a post whose riser stands 6 outside the r 214
  // rim envelope (band + lobe — the clearance params.scad promises)
  rz([30, 150, 270]) tx(roller_r) holddown_post();
  // yaw drive: the m2 8T herringbone pinion (the shoulder primary
  // pinion, reused — drawn real) hangs INVERTED over the rim so the
  // gear band can sit low: the motor face bolts down onto a printed
  // pylon's top plate 2 over the band, the shaft drops through its
  // clearance hole and the pinion spans the full band with margin.
  // Azimuth 315: out of the arm's swept corridors.
  rz(135) tx(-(yaw_pitch_r + gear_module * pinion_teeth / 2)) {
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
  // the yaw joint-angle camera, base-fixed at azimuth 135 — the strip
  // fills the whole readout lobe, so the read heading is forced
  // diametrically opposite the pinion (the same forcing as the wrist
  // camera's dead-aft 180). Lens ~6 off the strip crest (r 214) at
  // band mid-height (z 36), body outboard, khaki pylon down to the
  // plate; nearest fixed neighbor is the 150-deg hold-down riser,
  // ~36 clear. The lobe puts the crest AT the gear band's outer
  // radius, so nothing the disc carries can ever reach the camera —
  // overtravel reads gear instead of strip, a data fault, not a crash
  rz(135) {
    color("khaki") tx(229) cub([10, 14, 29], [0, 1, 0]);
    color("seagreen") tx(225) tz(29) cub([14, 14, 14], [0, 1, 0]);
    color("dimgray") tx(220) tz(36) ry(90) cylinder(d = 6, h = 5);
  }
}

// one under-rim support-roller stand, drawn at the origin with the
// roller axis along +x (radial once tx(roller_r) places it): a bare
// 608 rides a 5/16" bolt (8 mm bores) spanning a PAIR of printed lugs
// — head against the inboard lug, nut outboard under the rim edge —
// so the axle is simply supported, not a stub. The lug gap is 8
// (0.5 slop each side of the 7-wide bearing) and the base floor is
// cut away beneath it, keeping the 2 mm ground clearance; lug tops at
// 21 keep 3 under the disc. The base spreads into two tangential ears
// clear of the bearing well, one wood screw each into the plate
// (driven from above, before the disc goes on) — vertical loads go
// straight down the lugs, the screws just keep the stand put
module roller_stand() {
  color("khaki") difference() {
    union() {
      tx([-12, 4]) cub([8, 22, 21], [0, 1, 0]);    // the lug pair
      cub([24, 48, 6], [1, 1, 0]);                 // base + screw ears
    }
    tz(13) ry(90) cylinder(d = 8, h = 26, center = true);  // axle bore
    tz(-0.1) cub([8, 24, 6.3], [1, 1, 0]);   // bearing well in the base
    ty([-18, 18]) tz(-0.1) cylinder(d = 4, h = 6.3);       // screw holes
  }
  // the axle: 5/16 x 1.25" hex bolt through both lugs, nut outboard
  color("silver") tz(13) ry(90) {
    tz(-12) cylinder(d = 7.9, h = 31.75);
    rz(30) {   // hex flats down: the corners would graze the base edge
      tz(-17.5) cylinder(d = 14.7, h = 5.5, $fn = 6);
      tz(12) cylinder(d = 14.7, h = 6.7, $fn = 6);
    }
  }
  color("silver") tz(13) ry(90)                    // the bare 608
    cylinder(d = 22, h = 7, center = true);
  color("silver") ty([-18, 18]) {                  // anchor wood screws
    tz(-6) cylinder(d = 3, h = 12);
    tz(6) cylinder(d = 5.5, h = 2);
  }
}

// one hold-down post, the roller stand's lug-pair idiom hung over the
// rim (same local frame: origin at the bearing, +x radial). Everything
// is forced by the disc: bolt at z 59 puts the crown ON the z 48 disc
// top, lug bottoms at 50 keep 2 over the top surface and the flush
// band, the arm bottom at 67 clears the nut's corners (65.4) so a
// wrench works in the open bay between nut and riser, and the riser
// stands at r 220..232 — 6 outside the r 214 band/lobe envelope. The
// bolt slides in from inboard over the disc; its head face sits at
// r 167.5, and the board heels' bottom corners (x -150, y 70) sweep
// r 165.5 past it — 2 mm is the TIGHTEST swept clearance in the base,
// so any heel growth must nibble that corner. NOTE the load path:
// uplift goes bolt -> lugs -> arm in bending -> riser -> the two ear
// screws in WITHDRAWAL — fine against roller-preload and gust loads,
// but if a mass audit finds real overturning moment, the ears want
// more/longer screws, not a thicker arm
module holddown_post() {
  color("khaki") difference() {
    union() {
      tz(50) tx([-12, 4]) cub([8, 22, 17], [0, 1, 0]);   // the lug pair
      tz(67) tx(-12) cub([59, 22, 12], [0, 1, 0]);       // arm, in over the rim
      tx(35) cub([12, 22, 67], [0, 1, 0]);               // riser
      tx(29) cub([24, 48, 6], [0, 1, 0]);                // foot + screw ears
    }
    tz(59) ry(90) cylinder(d = 8, h = 26, center = true);    // axle bore
    tx(41) ty([-18, 18]) tz(-0.1) cylinder(d = 4, h = 6.3);  // screw holes
  }
  // the axle: the rollers' 5/16 x 1.25" hex bolt again, nut in the bay
  color("silver") tz(59) ry(90) {
    tz(-12) cylinder(d = 7.9, h = 31.75);
    rz(30) {
      tz(-17.5) cylinder(d = 14.7, h = 5.5, $fn = 6);
      tz(12) cylinder(d = 14.7, h = 6.7, $fn = 6);
    }
  }
  color("silver") tz(59) ry(90)                    // the bare 608
    cylinder(d = 22, h = 7, center = true);
  color("silver") tx(41) ty([-18, 18]) {           // anchor wood screws
    tz(-6) cylinder(d = 3, h = 12);
    tz(6) cylinder(d = 5.5, h = 2);
  }
}

// ---- slew disc + boards + fixed sector + shoulder stations ----
// segs: the printed gear segments AND the rim angle strip are
// install-at-graduation parts — the testbench clamps the disc dead
// and omits them (the hub station lives in bench_env, which the
// testbench never draws).
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
      disc_blank_2d();
      circle(d = 15.5);
      board_slots_2d();
    }
    tz(disc_z0 + ply_t) linear_extrude(ply_t) difference() {
      disc_blank_2d();
      circle(d = 48);
      board_slots_2d();
    }
  }
  if (segs) {
    color("khaki") tz(disc_z0) linear_extrude(2 * ply_t) rz(-45)
      difference() {
        pie(yaw_pitch_r + 7, yaw_seg_arc);
        circle(r = yaw_pitch_r - 12);
      }
    // the YAW angle strip on the readout lobe's face (the arc budget
    // is exact: seg + strip = 360, ends butting the band against the
    // lobe's steps): a printed adhesive band 0.8 proud over the full
    // 24 band height — crest flush with the gear band's outer radius,
    // see params — centered opposite the gear, read by the base-fixed
    // camera at azimuth 135 (bench_env). The pitch-axis idiom brought
    // down to the base: strip on the moving link, camera on the fixed
    // one; install-at-graduation like the segments
    color("white") tz(disc_z0) linear_extrude(2 * ply_t) rz(135)
      difference() {
        pie(yaw_lobe_r + 0.8, yaw_strip_arc);
        circle(r = yaw_lobe_r);
      }
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
    // ... and the perpendicular gussets, one outboard of each side
    // board (base_gusset_2d)
    my([0, 1]) tx(gus_x) rz(90) rx(90) linear_extrude(ply_t)
      base_gusset_2d();
  }

  // the FIXED shoulder sector web is drawn as part of left_board_2d
  // (one CNC piece); the wedge-backed segment band on its rim is the
  // REAL print (sector_segment.scad — the same no-drift rule as the
  // drivetrain parts), three segments, the end ones carrying the
  // anchors. rx(-90) maps local station a to base angle
  // sector_bis - a, landing run A's end-face knot at the lower
  // (gusset) end, 230 — where the nick note applies
  color("khaki") tz(shoulder_h) ty(cab_y0 + sector_core_t / 2) rx(-90)
    for (i = [0 : seg_n - 1])
      rz(seg_bis(i) - sector_bis)
        sector_segment(i, i == 0 ? -1 : i == seg_n - 1 ? 1 : 0);
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
// housings = false omits the two printed drive housings, leaving the
// motor/wheel/drum floating on their stations: the twin viewer's
// export (export.scad "upper") uses it so the covers don't hide the
// mesh and capstan — illustration only, never a build configuration.
module upper_arm(housings = true) {
  // bottom chord cut STRAIGHT fold_cut behind the elbow — the folded
  // forearm's bottom face (the 45-deg offset plane, see params) ran
  // through the full-length chord ~150 out, and the old circular
  // root-sweep relief only handled the root corners, not the folded
  // body. The fold-clearance CROSS BOARD below restores the box
  // closure. Hook slot in the TOP board only, where the elbow
  // counterweight parks at full extension.
  difference() {
    union() {
      // plates solid through the joint zones: the whole stub + 80 past
      // the shoulder axis (the camera bracket mounts at x 59..66), and
      // the whole fold-clearance zone at the elbow, so the cross board
      // and the cut chord's end both land on solid plate
      box_truss(-upper_stub, upper_len, upper_w,
                link_d(upper_len + upper_stub), elbow_d, 0,
                upper_stub + 80, fold_cut + ply_t, bot_short = fold_cut);
      // the +y plate grows the drive boom at arm angle dd (lap-jointed
      // over the truss plate at concept level)
      color("burlywood") ty(upper_w / 2) rx(90) linear_extrude(ply_t)
        boom_plate_2d();
      // elbow fork end: the plates end in a FULL CIRCULAR CAP about
      // the axis, radius elbow_d/2 * cos(arm_taper) — tangent to both
      // taper edges, so the outline flows straight into the arc (the
      // folding forearm stays inside |y| 40, under these plates'
      // 43..55 lane). The -y cap's rim doubles as the elbow angle
      // scale lobe: a printed strip wraps it (below), read by the
      // camera tab on the forearm's right plate — the shoulder
      // sensing idiom re-used
      color("burlywood") tx(upper_len) my([0, 1]) ty(upper_w / 2) rx(90)
        linear_extrude(ply_t) hull() {
          circle(r = elbow_d / 2 * cos(arm_taper));
          tx(-2) sq([2, elbow_d], [0, 1]);
        }
      // ... and the +y cap alone grows the LINER LOBE: wood out to
      // el_lobe_r under the elbow drive's groove liner and its three
      // screw tabs (the liner arc + 8 deg each end). One CNC outline
      // change; the -y cap keeps r 66 for the scale strip
      color("burlywood") tx(upper_len) ty(upper_w / 2) rx(90)
        linear_extrude(ply_t) rz((el_arc[0] + el_arc[1]) / 2)
          pie(el_lobe_r, el_arc[1] - el_arc[0] + 16);
    }
    tx(elbow_cw_slot_x)
      tz(link_d(upper_len - elbow_cw_slot_x) / 2 - ply_t - 8)
      linear_extrude(28) sq(elbow_cw_slot, [1, 1], 8);
    // joint bores cut through EVERYTHING in the plate planes — the
    // plates run through/past both axes (and the boom plate's corner
    // touches the shoulder axis), so a bore cut only in the lobe
    // pieces stays blocked and the stations can't assemble. Shoulder:
    // d 15.5 passes pink's sleeve (moving side); elbow: d 28.5 pilots
    // green's snout (fixed side)
    ty(-upper_w / 2 - 1) rx(-90) cylinder(d = 15.5, h = upper_w + 2);
    tx(upper_len) ty(-upper_w / 2 - 1) rx(-90)
      cylinder(d = 28.5, h = upper_w + 2);
  }
  // the fold-clearance CROSS BOARD: a chord-width plank between the
  // (solid) side plates, its inner face lying ON the 45-deg offset
  // plane — parallel to the fully folded forearm's bottom face,
  // fold_gap clear of it — with thickness going away from the fold.
  // Local frame: at the elbow, ry(-45) points +x up the plane toward
  // the joint and +z along its outward normal; s = plane coordinate
  // from the perpendicular foot. The foot corner meets the cut
  // chord's end-top corner, the head's outer corner just kisses the
  // top chord's underside — square plank ends, both
  fb_s = [(-(elbow_d / 2 - ply_t) * sqrt(2)
           - fold_off * (1 + tan(arm_taper))) / (1 - tan(arm_taper)),
          ((elbow_d / 2 - ply_t) * sqrt(2)
           - (fold_off + ply_t) * (1 - tan(arm_taper)))
          / (1 + tan(arm_taper))];
  color("sienna") tx(upper_len) ry(-45) tz(fold_off) tx(fb_s[0])
    cub([fb_s[1] - fb_s[0], upper_w - 2 * ply_t, ply_t], [0, 1, 0]);
  // the ELBOW joint-angle scale: a printed adhesive strip around the
  // -y fork cap's rim, read by the camera on the forearm's tab (the
  // shoulder idiom re-used, roles swapped: here the strip rides the
  // parent link and the camera the child). Camera forearm azimuth 60:
  // rim angle = 60 - bend, so the read head runs +60 (extension) to
  // -75 (full fold); the strip overshoots 10 past each extreme — 155
  // deg centered at -7.5 — and stays ~3 inside the cap arc's +-87.9
  // tangent span
  color("white") tx(upper_len) ty(-(upper_w / 2 - ply_t)) rx(90)
    linear_extrude(ply_t) difference() {
      rz(-7.5) pie(elbow_d / 2 * cos(arm_taper) + 0.8, 155);
      circle(r = elbow_d / 2 * cos(arm_taper));
    }
  // drive hardware — REAL parts (the detail-file modules, so the
  // concept can't drift from the prints). FLIPPED stack: gear_drum's
  // herringbone wheel sits INBOARD (27..54), straddling the boom
  // plate through its kidney cutout, its grooved core lays across the
  // fixed band's lane (62..87) and the part ends outboard in a
  // bearing boss (..96); the 8T pinion meshes at cd in the wheel's
  // plane, its motor hung under the inboard support slab, body
  // pointing back into the arm side (-30..18) — its mass is free
  // counterweight. The mesh is entirely arm-internal, guarded inside
  // the cutout.
  txz(drum_a) {
    // M8 THROUGH-BOLT dead axle (head inboard, nut outboard),
    // clamping the two housings across their inner-race shoulders —
    // a light bearing preload, set by feel (drive_housing.scad). The
    // nut pillar (y to ~111 at r 256) sweeps in the blade corridor
    // class: 15 deg in hand at the base woodwork
    color("silver") {
      ty(18) rx(-90) cylinder(d = 8, h = drum_y1 + 8 - 18 + 7.5, $fn = 24);
      ty(12.7) rx(-90) cylinder(d = 15, h = 5.3, $fn = 6);
      ty(drum_y1 + 8 + 0.2) rx(-90) cylinder(d = 15, h = 6.5, $fn = 6);
    }
    color("steelblue") ty(whl_y0) rx(-90) gear_drum();
  }
  txz(pin_a) {
    color("tomato") ty(whl_y0) rx(-90) pinion();
    color("silver") ty(18) rx(-90) cylinder(d = 5, h = 24, $fn = 24);
    // flats square to the boom, matching the slab's M3 face-screw
    // pattern (drive_housing.scad)
    color("dimgray") ry(-dd) ty(18 - motor_len) rx(-90)
      cub([motor_w, motor_w, motor_len], [1, 1, 0]);
  }
  // the two printed drive housings — REAL parts (drive_housing.scad,
  // where the construction rationale and the annotated standalone
  // diagram live), drawn in the boom frame and swung up to arm angle
  // dd. INBOARD (y 18..43): motor-face slab seating the axle's wheel
  // end (mesh center distance printed-exact) + kidney-tracing shear
  // wall + four hs_in screw bosses. OUTBOARD (y 55..104): a wide-Y
  // of walls — two arms + the spine meeting just past the drum, bay
  // open toward the shoulder — under a triangular roof picking up
  // the axle's boss end. Screw sets staggered (see params).
  if (housings) color("khaki") ry(-dd) {
    inboard_housing();
    outboard_housing();
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

}

// ---- elbow stations: the upper-arm-fixed side of the joint ----
// Drawn at the elbow origin in the upper-arm frame. The testbench
// leaves the stations AND everything distal out and hangs its test
// weight in the empty pilot bores instead.
module elbow_stations() {
  // paired stations again: forearm plates are the moving side,
  // upper-arm plates the fixed boards (gap 3, so the main bearing
  // sits flush with the fixed plate's inner face instead of proud)
  my([0, 1]) ty(fore_w / 2 - ply_t)
    bearing_station(upper_w / 2 - ply_t - fore_w / 2);
  // the elbow NOSE — the drive's fixed capstan surface (the REAL
  // print, elbow_nose.scad): a slim groove LINER riding the +y cap's
  // CNC lobe inside the board's thickness, one shared channel, both
  // cable ends anchored at its arc ends. Upper-arm-fixed, so it
  // lives here with the stations (and stays off the testbench)
  color("steelblue") elbow_nose();
}

// ---- forearm: truss + fin + elbow CW + wrist fork end ----
// Drawn at the elbow origin in its OWN (elbow-bent) frame.
module forearm() {
  difference() {
    union() {
      // cut0 = 36: the root's lower-rear corner is truncated on the
      // 45-deg line tangent to the r 36 lobe (the lobe circle itself
      // is untouched), and the bottom chord is square-shortened so
      // its low edge stops at the same line — see box_truss
      box_truss(0, fore_len, fore_w, elbow_d, link_d(-fore_len),
                0, 45, 45, 36);
      // root lobes at the elbow axis
      color("burlywood") my([0, 1]) ty(fore_w / 2) rx(90)
        linear_extrude(ply_t) circle(r = 36);
      // the LEFT forearm plate grows a FIN back over the elbow (one
      // CNC piece, replacing the bolted-on boom + riser)
      color("burlywood") ty(fore_w / 2) rx(90) linear_extrude(ply_t)
        fore_cw_fin_2d();
      // ... and the RIGHT plate a small SENSOR TAB at forearm azimuth
      // 60, reaching r 88: the footing for the camera that reads the
      // elbow scale strip on the upper fork cap's rim. Azimuth 60 is
      // what keeps the read head on the cap arc (+-87.9) through the
      // whole 0..135 bend: rim angle runs +60 down to -75, and the
      // sweep stays ahead of the elbow (never over the upper arm's
      // chords, which share the tab's y lane)
      color("burlywood") my(1) ty(fore_w / 2) rx(90) linear_extrude(ply_t)
        rz(60) tx(50) sq([38, 24], [0, 1], 8);
      // wrist end: the plates end in a FULL CIRCULAR CAP about the
      // wrist axis, tangent to both taper edges — the upper arm's
      // elbow-fork idiom one joint down. The payoff is the end
      // effector's flat end plate clearing this end by ee_clear at
      // EVERY wrist angle: constant radius about the axis makes the
      // clearance pose-invariant
      color("burlywood") tx(fore_len) my([0, 1]) ty(fore_w / 2) rx(90)
        linear_extrude(ply_t) hull() {
          circle(r = wrist_d / 2 * cos(arm_taper));
          tx(-2) sq([2, wrist_d], [0, 1]);
        }
    }
    // joint bores cut through plates AND lobes together — the plates
    // start at the elbow axis and end at the wrist axis, so a bore cut
    // only in the lobe pieces stays half-blocked. BOTH ends take
    // d 15.5 for pink's sleeve: the forearm carries the pink side at
    // both its joints — moving at the elbow, fixed at the wrist (the
    // station doesn't care; see joints.scad)
    tx([0, fore_len]) ty(-fore_w / 2 - 1) rx(-90)
      cylinder(d = 15.5, h = fore_w + 2);
  }
  // the elbow scale camera on the tab: bracket bridges the 3 mm gap,
  // body straddles the strip's y lane (the fork plate's 43..55), lens
  // ~6 off the strip crest at r 66.7 — the shoulder camera verbatim,
  // one joint down
  ry(-60) tx(78) {
    color("seagreen") ty(-(fore_w / 2 + 4)) cub([10, 14, 14], [0, -1, 1]);
    color("dimgray") ty(-(fore_w / 2 + 9)) ry(-90) cylinder(d = 6, h = 5);
    color("khaki") ty(-(fore_w / 2 + 4)) cub([10, 6, 14], [0, 0, 1]);
  }
  // elbow counterweight: TEMPORARILY NOT DRAWN (block + dog-leg
  // hanger). The wrist drive stack (~0.6 kg) now rides the enlarged
  // fin behind the elbow, above the axis line — block, hanger and
  // fin outline all get resized together at the next mass audit
  // (re-add + trim; the parking slot in the upper arm stays)

  // ---- wrist capstan drive (see the params section; ratio ~19.9) ----
  // The shoulder's flipped-stack idiom on the enlarged fin: wheel +
  // pinion straddle the fin plate (28..40) through its kidney cutout
  // (lane 27..54), the grooved capstan core sits out at the cable
  // plane (grooves wr_cab_y / + band, OUTBOARD of the elbow drive's
  // 55..70.2 claim — joint hardware still cleared RADIALLY, see the
  // lane notes in params), and the part ends in a bearing boss
  // picked up by a slim TANGENTIAL BRIDGE: a strap across the boss
  // aligned with the tangent about the SHOULDER at full extension —
  // the old plate + rear-wall cover swept 3.6 over the fixed sector
  // crest at full-up and barred moving the stack back; the strap's
  // ends hold the axle's own shoulder-radius, its feet drop to the
  // fin outside the wheel's swept tips (nearest post corners 54.7
  // off the axle), and the bar crosses ~12 over the departing runs.
  // To be
  // detailed as walled housings with staggered screws, the shoulder
  // treatment.
  txz(wr_axle) {
    color("silver") ty(18) rx(-90)
      cylinder(d = 8, h = wr_y1 + 6 - 18, $fn = 24);
    color("steelblue") ty(wr_whl_y0) rx(-90) wrist_gear_capstan();
  }
  txz(wr_pin) {
    color("tomato") ty(wr_whl_y0) rx(-90) pinion();
    color("silver") ty(18) rx(-90) cylinder(d = 5, h = 24, $fn = 24);
    color("dimgray") ty(18 - motor_len) rx(-90)
      cub([motor_w, motor_w, motor_len], [1, 1, 0]);
  }
  color("khaki") {
    // inboard support slab (y 18..26): motor face + axle wheel end,
    // mesh center distance printed-exact — the shoulder idiom
    ty(26) rx(90) linear_extrude(8) difference() {
      hull() { txy(wr_axle) circle(64); txy(wr_pin) circle(30); }
      txy(wr_pin) circle(12);
    }
    // ring wall closing the slab to the fin's inner face (26..28)
    ty(28) rx(90) linear_extrude(2) difference() {
      hull() { txy(wr_axle) circle(62); txy(wr_pin) circle(32); }
      hull() { txy(wr_axle) circle(56); txy(wr_pin) circle(26); }
    }
    // outboard support: the slim tangential bridge — feet posts on
    // the fin (y 40) outside the wheel's tips, bar over the boss
    for (s = [-1, 1]) txz(wr_axle + s * wr_str_l * wr_str_n)
      ty(40) cub([16, wr_y1 + 2 - 40, 16], [1, 0, 1]);
    hull() txz([wr_axle + wr_str_l * wr_str_n,
                wr_axle - wr_str_l * wr_str_n])
      ty(wr_y1 + 1) rx(-90) cylinder(d = 16, h = 8);
  }
  // the cable runs' STRAIGHT portions, drawn as rods for clearance
  // eyeballing: external common tangents of the r 50 drum and r 16
  // capstan (converging ~3 deg). Upper run in the first groove
  // (wr_cab_y), lower in the second; the wrapped arcs live in the
  // grooves and aren't drawn
  color("orangered") for (i = [0, 1])
    ty(wr_cab_y + i * wr_band) hull()
      txz([wr_tan_p1(i == 0 ? -1 : 1), wr_tan_p2(i == 0 ? -1 : 1)])
        sphere(d = cable_d, $fn = 16);

  // ---- elbow capstan drive (see the params section; ratio ~65) ----
  // The third flipped stack on the fin, one bay closer to the joint
  // than the wrist's: the 66T wheel + pinion straddle the fin through
  // their own kidney (lane 10..37 — the axle rides HIGH, el_axle,
  // so the Ø134 wheel obeys the fin's taper-line rule at full
  // extension), the grooved core sits astride the liner's channel
  // plane (take-offs 46 / 52), boss + concept bridge beyond
  // (in-plane clear of the wrist runs). The cables drop to the two
  // CROSSED idler sheaves and land in the liner's ONE shared channel
  // — see the elbow section in params for the seat-tiling and
  // sweep-safety arguments.
  txz(el_axle) {
    color("silver") ty(1) rx(-90)
      cylinder(d = 8, h = el_y1 + 6 - 1, $fn = 24);
    color("steelblue") ty(el_whl_y0) rx(-90) elbow_gear_capstan();
  }
  txz(el_pin) {
    color("tomato") ty(el_whl_y0) rx(-90) pinion();
    color("silver") ty(1) rx(-90) cylinder(d = 5, h = 24, $fn = 24);
    color("dimgray") ty(1 - motor_len) rx(-90)
      cub([motor_w, motor_w, motor_len], [1, 1, 0]);
  }
  color("khaki") {
    // inboard support slab (y 1..9): motor face + axle wheel end
    ty(9) rx(90) linear_extrude(8) difference() {
      hull() { txy(el_axle) circle(78); txy(el_pin) circle(30); }
      txy(el_pin) circle(12);
    }
    // ring wall closing the slab to the fin's inner face (9..28),
    // ringing OUTSIDE the wheel's kidney (r 70..76 vs tips at 67);
    // clipped where the wrist stack's slab hull passes 2 away
    ty(28) rx(90) linear_extrude(19) difference() {
      hull() { txy(el_axle) circle(76); txy(el_pin) circle(30); }
      hull() { txy(el_axle) circle(70); txy(el_pin) circle(24); }
      txy(wr_axle) circle(66);
    }
    // outboard bridge: plate over the boss + rear wall to the fin
    txz(el_axle) {
      ty(el_y1 + 1) tx(-72) cub([122, 8, 70], [0, 0, 1]);
      ty(40) tx(-72) cub([8, el_y1 + 1 - 40, 70], [0, 0, 1]);
    }
  }
  // the two idler sheaves (608-cored printed spools) astride the
  // channel plane, with concept brackets. dn roots on the fin
  // strip straight above it at (-2, 110) — its plate-lane crossing
  // holds azimuth ~91, 48 deg inside the shadow limit, sweeping
  // away — and takes the axle from an arm outboard of the spool;
  // up roots on the +y plate's solid top margin ahead of the joint
  // (whole sweep -86..49, never near the shadow), arm outboard
  // likewise (the up bracket is the loaded one: ~155 deg of wrap,
  // ~2T on its axle)
  for (i = [0, 1]) txz(el_pul_p(i)) ty(el_shv_y[i]) {
    color("silver") ty(-5) rx(-90) cylinder(d = 8, h = 14, $fn = 24);
    color("steelblue") {
      ty(-4.2) rx(-90) cylinder(d = 31, h = 1.6);
      ty(-2.6) rx(-90) cylinder(d = 26.1, h = 5.2);
      ty(2.6) rx(-90) cylinder(d = 31, h = 1.6);
    }
  }
  color("khaki") {
    // bracket dn: fin pad + riser + arm over the spool's outboard face
    txz([-2, 110]) ty(40) cub([14, 17, 8], [1, 0, 1]);
    hull() txz([[-2, 110], el_pul_p(0)]) ty(52.5) rx(-90)
      cylinder(d = 12, h = 4.5);
    // bracket up: pad on the plate's top margin + riser + arm
    txz([58, 52]) ty(40) cub([18, 18, 12], [0, 0, 0]);
    hull() txz([[67, 60], el_pul_p(1)]) ty(54) rx(-90)
      cylinder(d = 12, h = 4);
  }
  // cable spans, straight portions as rods (wrapped arcs live in the
  // grooves). Drum -> sheave: EXTERNAL tangents, the two runs
  // leaving OPPOSITE drum sides (dn its left, s = -1; up its right,
  // s = +1 — opposite winding hands, so the drum reels one in as it
  // pays the other out); the march's fleet + the 2 mm plane bridge
  // live in these spans. Sheave -> channel: CROSSED tangents (the
  // sheave wrap reverses hand relative to the nose seat), sheave
  // point on the FAR side of n. The two runs CROSS between the
  // sheaves and the liner, passing ~0.9 clear on the +-1 split
  color("orangered") {
    // dn run: inboard take-off (46) -> sheave dn (48) -> channel (49)
    hull() { let (n = cab_tan_n(el_axle, drum_eff_r, el_pul_p(0),
                                el_pul_r, -1)) {
      txz(el_axle + drum_eff_r * n) ty(el_cab_y - track_sep / 2)
        sphere(d = cable_d, $fn = 16);
      txz(el_pul_p(0) + el_pul_r * n) ty(el_shv_y[0])
        sphere(d = cable_d, $fn = 16); } }
    hull() { let (n = [cos(el_touch[0]), sin(el_touch[0])]) {
      txz(el_pul_p(0) - el_pul_r * n) ty(el_shv_y[0])
        sphere(d = cable_d, $fn = 16);
      txz(el_nose_r * n) ty(el_cab_y)
        sphere(d = cable_d, $fn = 16); } }
    // up run: outboard take-off (52) -> sheave up (50) -> channel
    hull() { let (n = cab_tan_n(el_axle, drum_eff_r, el_pul_p(1),
                                el_pul_r, 1)) {
      txz(el_axle + drum_eff_r * n) ty(el_cab_y + track_sep / 2)
        sphere(d = cable_d, $fn = 16);
      txz(el_pul_p(1) + el_pul_r * n) ty(el_shv_y[1])
        sphere(d = cable_d, $fn = 16); } }
    hull() { let (n = [cos(el_touch[1]), sin(el_touch[1])]) {
      txz(el_pul_p(1) - el_pul_r * n) ty(el_shv_y[1])
        sphere(d = cable_d, $fn = 16);
      txz(el_nose_r * n) ty(el_cab_y)
        sphere(d = cable_d, $fn = 16); } }
  }
  // the wrist scale camera, forearm-fixed DEAD-AFT of the wrist axis:
  // the symmetric +-90 travel forces azimuth 180 (the only heading
  // that keeps the read head on the EE strip at both extremes — the
  // same forcing as the shoulder camera's 50). Bracket on the right
  // plate's outer face, where the plate is solid (truss cutouts stop
  // 73 behind the axis; the bracket sits 379..389); body straddles
  // the strip lane, lens ~6 off the strip crest (r ~50.3) on the EE's
  // right side plate rim. The EE's strap corners sweep azimuths
  // +-118 at most, 60 deg short of the camera hardware
  tx(fore_len) ry(180) tx(61) {
    color("seagreen") ty(-(fore_w / 2 + 4)) cub([10, 14, 14], [0, -1, 1]);
    color("dimgray") ty(-(fore_w / 2 + 9)) ry(-90) cylinder(d = 6, h = 5);
    color("khaki") ty(-(fore_w / 2 + 4)) cub([10, 6, 14], [0, 0, 1]);
  }
}

// ---- end effector: everything that pitches at the wrist ----
// Drawn at the wrist origin in its own frame. A U-FORK straddling
// OUTSIDE the forearm: side plates in the upper arm's 43..55 lane
// (ee_w = upper_w — the elbow's lateral zoning repeats one joint
// down, nesting flipped), each a DISC about the wrist axis matching
// the forearm cap's diameter, extended forward as an ee_strap-deep
// strap to the end plate ee_clear past the forearm end. The wrist is
// the THIRD paired bearing station — the elbow's placement line
// verbatim, roles mirrored: pink + tail stack ride the (inner, here
// fixed) forearm plates, green + bolt head these (outer, moving)
// sides. The straps leave the cap circle at azimuth +-46.7, so the
// rim stays circular through the scale strip's 200-deg arc. Sweep
// note: the strap corners reach r ~76 about the axis — past the
// elbow fold plane's 74 — but only 430+ mm from the elbow, far
// beyond any upper-arm material (the plane only guards fold_cut's
// ~177 reach); everything else stays inside the cap radius + gap.
module end_effector() {
  rcap = wrist_d / 2 * cos(arm_taper);
  // side plates: disc + forward strap, one CNC piece each; d 28.5
  // pilots green's snout (this joint's fixed-BUSHING side, though
  // the EE is the moving link — the station doesn't care)
  color("burlywood") my([0, 1]) ty(ee_w / 2) rx(90) linear_extrude(ply_t)
    difference() {
      union() { circle(r = rcap); sq([ee_len, ee_strap], [0, 1]); }
      circle(d = 28.5);
    }
  // end plate between the straps, full forearm depth: its inner face
  // clears the forearm's circular end by ee_clear at every wrist angle
  color("sienna") tx(ee_len - ply_t)
    cub([ply_t, ee_w - 2 * ply_t, wrist_d], [0, 1, 1]);
  // paired stations: same lanes, same 3 mm gap, same print as the
  // shoulder's and elbow's
  my([0, 1]) ty(fore_w / 2 - ply_t)
    bearing_station(ee_w / 2 - ply_t - fore_w / 2);
  // wrist joint-angle scale strip around the RIGHT side plate's rim
  // (the right-side convention of the other two): travel + 2x10
  // overshoot = 200 deg centered dead-aft, read by the camera on the
  // forearm's right plate — strip on child, camera on parent
  color("white") ty(-(ee_w / 2 - ply_t)) rx(90) linear_extrude(ply_t)
    difference() {
      rz(180) pie(rcap + 0.8, wrist_travel + 20);
      circle(r = rcap);
    }
  // the wrist DRUM ring on the +y side plate (the strip owns the -y
  // rim): the REAL print, wrist_drum.scad — cable grooves at r 50,
  // foot around the green flange, screws into the ply disc
  color("steelblue") wrist_drum();
  // tool flange on the end plate's front face; the ghosted volume is
  // a reference envelope, not a part
  color("navajowhite") tx(ee_len) ry(90) cylinder(d = 85, h = 12);
  %tx(ee_len + 75) ry(90) cylinder(d = 70, h = 125, center = true);
}

// shared side board core: full-height body from the disc top to the
// shoulder (its front edge at front_x carries the front board), a
// bearing lobe at the axis, and three tabs that mortise through both
// disc layers (the rearmost sits under each board's HEEL — the
// per-board foot extension down-back that widens the stance against
// fore-aft racking). Keeping material x >= -80 up high matters: the
// outboard drive housing sweeps the board's own y-lane down to base
// angle ~241 at shoulder r >= 254 (bend 55), and the rear edge's
// r-242 crossing sits at base angle ~251 — 10 deg in hand.
module board_core_2d() {
  txy([-80, disc_z0 + 2 * ply_t])
    sq([front_x + 80, shoulder_h - disc_z0 - 2 * ply_t], [0, 0], 10);
  txy([0, shoulder_h]) circle(r = 80);
  tx([-140, -60, 20]) ty(disc_z0) sq([40, 2 * ply_t + 2], [0, 0]);
}

// the slew-disc blank, shared by both ply layers: the base circle
// plus the READOUT LOBE — the bare arc bulged out so the angle
// strip's crest rides at the gear band's outer radius (see params)
module disc_blank_2d() {
  circle(r = yaw_disc_r);
  rz(135) pie(yaw_lobe_r, yaw_strip_arc);
}

// the mortise pattern cut through both slew-disc layers: three slots
// per side board (the rearmost under the heel), two for the front
// board (at x 130..142), and one per perpendicular gusset outboard of
// each side board plane
module board_slots_2d() {
  my([0, 1]) ty(yoke_y) tx([-140, -60, 20]) sq([40, ply_t], [0, 0]);
  tx(front_x) ty([-60, 20]) sq([ply_t, 40], [0, 0]);
  my([0, 1]) txy([gus_x, yoke_y + ply_t + 10]) sq([ply_t, 48], [0, 0]);
}

// perpendicular base gusset, drawn in its own (y, z) plane: a
// triangular ply rib standing on the disc against the side board's
// OUTER face (the arm owns the inside with only the 3 mm running
// gap), glued + screwed to the board and tabbed through both disc
// layers like the boards themselves. It braces the board against
// out-of-plane lean: above the front board's top edge (front_z1) the
// boards' own bending was all that resisted lateral racking — and the
// front plate braces the front, so the rib stands BACK (see gus_x).
// Apex z 340 keeps ~79 off the axis hardware; the foot's far corner
// holds yaw r <= 153 vs the hold-down arms reaching in to r 191.
// (At bend 45 the bridge plate's corridor reached base angle ~255
// and forced a knee in this profile; bend 55 lifted it clear — the
// corridor numbers live at gus_x.)
module base_gusset_2d() {
  polygon([[yoke_y + ply_t, disc_z0 + 2 * ply_t],
           [yoke_y + ply_t + 70, disc_z0 + 2 * ply_t],
           [yoke_y + ply_t, 340]]);
  txy([yoke_y + ply_t + 10, disc_z0]) sq([48, 2 * ply_t + 2], [0, 0]);
}

// LEFT board: grows the FIXED shoulder sector as a SOLID web —
// literally one CNC piece, so it's drawn here in the board color. Its
// circular rim stops at rim_r: the printed segment bands seat on it
// and carry the cable out to crest_r, held by wood screws in the
// pilot circle (three per segment, matching the legs). A gusset
// triangle blends the sector's lower tip back into the board's rear
// edge (fills the notch where the lower edge crossed x -80,
// stiffening the cantilevered tip); at bend 55 it spans base angles
// 230..250 and holds r <= rim_r throughout — under the drum/blade
// annuli (r >= 242), so the radial rule holds with room to spare.
// (The lower end's cable knot pokes past the arc end within the board
// plane — nick this gusset's corner to clear it.)
module left_board_2d() {
  a0 = sector_bis + sector_angle / 2;      // lower sector edge (230)
  difference() {
    union() {
      board_core_2d();
      txy([0, shoulder_h]) rz(sector_bis) pie(rim_r, sector_angle);
      polygon([[-80, shoulder_h - 80 * tan(a0 - 180)],
               [rim_r * cos(a0), shoulder_h + rim_r * sin(a0)],
               [-80, shoulder_h + rim_r * sin(a0) - 40]]);
      // rear HEEL over the third disc tab. On THIS side the outboard
      // housing's Y arms sweep base angles up to ~241 at shoulder
      // r 254..282 (bend 55; a foot cap passes (-127, 163) at
      // full-up), so the heel's upper boundary is the 244 ray out to
      // r 315, past the arms' reach: the shallow V it leaves
      // against the sector gusset's chord IS the arm corridor,
      // not waste
      polygon([[-80, shoulder_h - 80 * tan(244 - 180)],
               [315 * cos(244), shoulder_h + 315 * sin(244)],
               [-150, disc_z0 + 2 * ply_t],
               [-80, disc_z0 + 2 * ply_t]]);
    }
    txy([0, shoulder_h]) circle(d = 28.5);   // green snout pilot bore
    // segment leg screw pilots
    txy([0, shoulder_h])
      rz([for (k = [0 : seg_n - 1], dk = [-14, 0, 14])
          sector_bis - sector_angle / 2 + (k + 0.5) * seg_ang + dk])
        tx(leg_screw_r) circle(d = 2.5);
  }
}

// RIGHT sensor board: near-twin; same pilot bore — its green bushing
// mounts the same way, the sensor rings ride the arm/board gap
module sensor_board_2d() difference() {
  union() {
    board_core_2d();
    // rear HEEL, full triangle: nothing sweeps this side's board
    // lane (the scale camera never drops below z ~424), so the foot
    // extension runs straight up the rear edge to z 320
    polygon([[-80, 320],
             [-150, disc_z0 + 2 * ply_t],
             [-80, disc_z0 + 2 * ply_t]]);
  }
  txy([0, shoulder_h]) circle(d = 28.5);   // green snout pilot bore
}

// the arm's drive boom plate, drawn in the +y truss plate's plane:
// a strip at arm angle dd, widened into a RING around the kidney
// cutout the wheel + pinion straddle the plate through (mesh inside
// it); the ring is also the footing for both housings — the inboard
// wall + bosses on its inner face, the outboard blade feet on its
// outer — and it carries the staggered screw stations (hs_out driven
// from inboard, hs_in from outboard). The dead axle no longer
// pierces the plate — it crosses inside the kidney, carried by the
// printed housings on either face
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
// ENLARGED (deliberately generous — to be trimmed when the elbow CW
// comes back): the old strip fin plus TWO DRIVE BLOBS — the wrist
// capstan stack's and, one bay closer to the joint, the elbow
// drive's — each a ring of ply around the kidney its wheel + pinion
// straddle through (the boom-plate treatment), hulled down to the
// old fin's top edge. The two kidneys leave a ~17 web between them
// (el wheel tips 67 + wrist tips 52.4 pass 17 apart in the gap).
// Clipped hard against the taper line + 2 behind the arm, so the
// full-extension clearance rule survives whatever the hulls do.
module fore_cw_fin_2d() {
  t = tan(arm_taper);
  difference() {
    union() {
      polygon([[70, elbow_d / 2 - 70 * t - 26],
               [2, elbow_d / 2 - 2 * t - 26],
               [0, elbow_d / 2 + 2],
               [elbow_cw_x0, elbow_d / 2 - elbow_cw_x0 * t + 2],
               [elbow_cw_x0, elbow_d / 2 - elbow_cw_x0 * t + 52],
               [30, elbow_d / 2 - 30 * t + 50]]);
      hull() {
        txy(wr_axle) circle(84);
        txy(wr_pin) circle(35);
        txy([elbow_cw_x0, elbow_d / 2 - elbow_cw_x0 * t + 50]) circle(2);
        txy([30, elbow_d / 2 - 30 * t + 48]) circle(2);
      }
      // the elbow drive's blob: >= 25 of ply around its kidney (the
      // dn sheave's bracket pad roots on the strip at (-2, 110))
      hull() {
        txy(el_axle) circle(94);
        txy(el_pin) circle(35);
        txy([30, elbow_d / 2 - 30 * t + 48]) circle(2);
      }
    }
    // nothing below the shared taper line + 2 behind the arm (the
    // old polygon respects it by construction; the blobs are clipped)
    polygon([[-80, elbow_d / 2 + 80 * t + 2],
             [-330, elbow_d / 2 + 330 * t + 2],
             [-330, elbow_d / 2 + 330 * t - 200],
             [-80, elbow_d / 2 + 80 * t - 200]]);
    // the kidneys: wheel + pinion clearance — wrist Ø110 blended into
    // Ø26, elbow Ø138 (tips r 67) into Ø26
    hull() { txy(wr_axle) circle(55); txy(wr_pin) circle(13); }
    hull() { txy(el_axle) circle(69); txy(el_pin) circle(13); }
  }
}

module boom_plate_2d() rz(dd) difference() {
  union() {
    sq([da + cd + 55, 110], [0, 1], 16);
    // the kidney would sever the 110 strip: widen it into a ring
    // (>= 25 of ply all around the cutout; 88 also gives the arm
    // feet and every screw hole 7+ of edge distance)
    hull() { tx(da) circle(88); tx(da + cd) circle(35); }
    // SOLID fan below the boom, as far down as travel allows: the
    // upper-arm counterweight bolts to its inboard face BELOW the arm
    // centerline (the drive stack rides above it). Boundary = the two
    // binding constraints: an arc r 338 about the shoulder (any point
    // past arm angle 170 passes straight down at some pose, height
    // 392 - r, so 338 keeps 6 over the z 48 disc top), then, past arm
    // angle ~185 where the FRONT board takes over at full-up
    // (x = r*cos(angle+100) <= 124 vs the x 130 face), a chord to the
    // lower corner at arm angle 200, r 248. Both constraints are
    // ARM-angle anchored, so the local stations moved when the bend
    // went 45 -> 55. Local frame: +x' = arm angle dd (125), so local
    // angle = arm angle - 125; the arc starts at 8 where the boom
    // strip's edge takes over.
    polygon(concat([[0, 0]],
      [for (a = [8 : 4 : 60]) 338 * [cos(a), sin(a)]],
      [[64.2, 239.6]]));
  }
  // the kidney: wheel + pinion clearance, Ø110 blended into Ø26
  hull() { tx(da) circle(55); tx(da + cd) circle(13); }
  // housing screw stations, d 4 clearance through the ply: hs_out
  // driven from the inboard face, hs_in from the outboard — staggered
  // so every head lands on open ply over the far housing's bay
  txy(concat(hs_out, hs_in)) circle(d = 4);
}

module tube(od, id, h) difference() {
  cylinder(d = od, h = h);
  tz(-0.5) cylinder(d = id, h = h + 1);
}
