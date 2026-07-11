// Full-arm CONCEPT model parameters. Deliberately coarse: correct major
// dimensions and architecture (v0 design point: 0.45 m links, ratios
// 60/150/90/40, counterweights), placeholder detail. Premises:
//   - plywood box-truss links, wide sections preferred
//   - shoulder + elbow are PAIRED PRELOADED BEARING STATIONS (see
//     bearing_station.scad / joints.scad): internal preload loop, wood
//     never in a precision fit; wrist still a 608 dead-axle proxy
//   - the shoulder is the prototype1 capstan INVERTED: the sector is
//     fixed (integral with the left base board) and the drum/wheel/
//     motor ride the arm on a boom bent shoulder_bend up from
//     straight-back. The YAW is a single-stage herringbone ring:
//     printed gear segments on a doubled two-ply slew disc, driven
//     directly by the m2 12T pinion (the shoulder primary pinion).
//     Elbow + wrist are worms (the trade-study lean for those joints),
//     which tuck entirely inside the parent truss and free the joint
//     plane
//
// Y-LANE ZONING (why nothing collides), y in mm at the shoulder:
// truss chords 0..43, counterweight boom 0..25 (its mass 0..43), link
// side plates 43..55 (the +y one grows the drive boom plate), drum
// 56..82 (cable plane 69), wheel + pinion 82..109, motor 34..82
// (plunged through the boom plate), bridge 109..117 — all riding the
// arm. Static: base boards 63..75, fixed sector core 63..75 (= the
// left board's plane; rim ring 59..79), green joint bushings + bolt
// heads |y| 58.5..83 at the axis; the joint-angle sensor is a camera
// on the arm (-55..-75 lane, r 92 about the axis) reading a printed
// scale strip on the sensor-board lobe rim (r 80).
// The radial rule that makes the lane crossings safe: every moving
// part that enters y > 55 lives at r > 250 from the shoulder axis —
// outside the fixed sector rim (r 244) — and the base boards have no
// material beyond x = -80 up high, which is the only region the swept
// drive fan (base angles 115..235) reaches.

ply_t = 12;

// ---- reduction architecture ----
primary_ratio = 51 / 12;      // 4.25 (capstan joints)
drum_eff_r = 6.75;
gear_od = 107;                // 51T m2 wheel envelope
gear_w = 27;
drum_od = 26;
motor_w = 42.3;               // NEMA 17
motor_len = 48;
cd = 63;                      // primary center distance
function sector_r(ratio) = ratio / primary_ratio * drum_eff_r;

yaw_travel = 180;     // +-90, single-stage herringbone ring drive
yaw_disc_r = 200;     // slew disc: DOUBLED, two ply layers (24 thick)
yaw_pitch_r = yaw_disc_r + 7;   // gear-segment pitch radius; with the
                                // m2 12T pinion (pitch r 12) the yaw
                                // ratio is ~17:1 — plenty for a
                                // gravity-neutral vertical axis
yaw_seg_arc = yaw_travel + 20;  // segment arc: travel + mesh margin
shoulder_ratio = 150; shoulder_min = -20; shoulder_max = 100;  // capstan
elbow_travel = 135;   elbow_wheel_d = 75;  // 90:1 worm, downward bend only
wrist_travel = 180;   wrist_wheel_d = 60;  // 40:1 worm, +-90
worm_d = 20;

// ---- links ----
upper_len = 450;
upper_stub = 120;     // SHORT: just closes the box; the drive boom and
                      // counterweight take over behind the joint
upper_w = 110;        // side plates clear the drive wheel (y 14..41) by 2
fore_len = 450;
fore_w = 80;          // roots inside the upper arm's elbow fork
ee_len = 90;

// ---- link taper ----
// Both links TAPER at the same angle and share the same depth at the
// elbow, so at full extension the top and bottom edges read as one
// continuous taper from the shoulder stub to the wrist. link_d() gives
// the local depth anywhere on that shared line (`back` = distance
// behind the elbow: positive up the upper arm, negative down the
// forearm). ANCHORED AT THE SHOULDER: the depth at the shoulder axis
// stays at the original 165 box depth, and the taper thins everything
// distal of it — elbow ~132, wrist ~99 (2.1 deg is what connects 165
// to ~100 over the 900 mm arm). KNOWN OPEN ITEMS, deferred to detail
// design: both worm MOTORS now outgrow their hollows — the elbow's (z
// to -68) passes through the upper arm's bottom chord near the elbow,
// and the wrist's pokes ~24 below the forearm's bottom edge.
shoulder_d = 165;     // depth at the shoulder axis (the original)
arm_taper = 2.1;      // deg per edge
elbow_d = shoulder_d - 2 * upper_len * tan(arm_taper);   // ~132
function link_d(back) = elbow_d + 2 * back * tan(arm_taper);

// ---- counterweights ----
// Shoulder: a SINGLE central boom in the |y| < 25 lane (y-clear of the
// fixed sector, drum, motor and bridge alike), pointing just cw_bend
// above straight-back — nearly parallel to the arm, decoupled from the
// drive direction. The price of parallel: at full-up the boom hangs
// straight down the well center (base angle 280 - cw_bend = 270), so
// cw_r is capped by the slew disc (mass bottoms at z 82 over the z 76
// disc top; plan radius < 53 stays far inside the r 167+ hold-down
// ring). Sized for ~1.05 kg.m: the ~1.2 needed less what the motor +
// wheel + drum already contribute at r 263..326.
// Elbow: an IN-PLANE boom + hook, forearm-fixed on the center plane.
// The CW assembly's CG lies on the forearm axis extended back through
// the elbow, so the combined forearm+CW CG sits AT the elbow axis and
// gravity torque is zero at every pose (a top boom alone would put it
// ~80 above that line; the downward hook at its end brings it back).
// The elbow bends down only, so the boom only ever sweeps up and away
// from the upper arm — and at FULL EXTENSION the hook parks inside the
// upper arm through a slot in its top board (it enters nearly
// vertically: arc r ~245, vertical tangent at 0 deg).
cw_bend = 10;
cw_r = 295;
cw_mass = [85, 85, 62];        // ~3.5 kg steel
elbow_cw_x0 = -252;            // boom tail; hook and block hang there
elbow_cw_blk = [70, 40, 80];   // placeholder block, center near the axis line
elbow_cw_slot = [88, 48];      // in the upper arm's top board only...
elbow_cw_slot_x = 205;         // ...centered at upper_len - 245

// ---- base: slew disc + THREE boards ----
// (0) the slew disc: a plain TWO-LAYER ply disc (24 thick) riding
//     support rollers under its rim and hold-downs over it (the roller
//     ring reacts the overturning moment; the central 608 pair only
//     locates the axis). Printed herringbone gear segments wrap
//     yaw_seg_arc of the rim; a bench-standing motor drives them
//     directly with the m2 12T pinion at azimuth 315 — out of every
//     swept corridor (the arm's drive boom owns azimuths 90..270 at
//     full-up; the front board corners sweep r 161 vs the pinion's 219)
// (1) LEFT (+y) board: grows the FIXED shoulder sector — one CNC ply
//     piece (or face-bolted stack), so joint torque grounds straight
//     into the base with no bracket or pylon
// (2) RIGHT (-y) board: near-twin of the left minus the sector; its
//     r 80 lobe rim carries a printed adhesive scale strip, read by a
//     high-res closeup camera riding the arm — optical, unloaded, no
//     drivetrain compliance in the measurement
// (3) FRONT board tying the two into a stiff U. With the sector static,
//     only the ARM truss sweeps the front: at shoulder_min its bottom
//     edge passes z~291 at the board plane (the taper is anchored at
//     the shoulder, so this matches the old box), top rises to 275.
//     The arm swings between the side boards (110 wide in a 126 gap).
// ALL THREE boards tab straight into the disc — mortises through both
// ply layers, panel shoulders landing on the disc top (no angle
// blocks); the front board runs disc-top-to-front_z1, closing the U
// into a torsion box with the disc as its floor.
base_plate = 520;
col_w = 150;          // side board spacing (inner faces at +-63)
shoulder_h = 420;
front_x = 130;        // side boards' front edge; the front board spans it
front_z1 = 275;       // 16 mm under the truss bottom at shoulder_min
disc_z0 = 52;         // disc bottom: leaves room for the bench motor
                      // under the rim (body z 0..48, pinion up into the
                      // gear band z 52..76)
roller_r = 185;       // support/hold-down roller stations

// ---- inverted shoulder capstan ----
// The sector is FIXED and coplanar/integral with the LEFT base board.
// The drive rides the ARM: a boom plate grown from the +y truss plate
// at arm angle 180 - shoulder_bend carries the drum dead axle and the
// plunged-through motor (prototype1 idiom); a printed bridge picks up
// both axle ends outboard so they are simply supported. The bend is
// the packaging knob: at full-up the drive bottoms out at base angle
// 280 - shoulder_bend (235: clear of the well between the boards), at
// full-down it parks up-back at 160 - shoulder_bend where nothing
// lives. With the sector out of every arm plane, the bend is
// otherwise free.
shoulder_bend = 45;
sector_plane_y = col_w / 2 - ply_t / 2;   // 69: the left board mid-plane

// ---- sector construction (as prototype1: 3-layer ply, hollow) ----
sector_core_t = 12;
sector_flange_t = 6;
sector_band = 40;
sector_hub_r = 38;

// ---- pose ----
pose_yaw = 0;
pose_shoulder = 40;
pose_elbow = 70;      // 0..135 downward
pose_wrist = -10;     // +-90

$fn = 48;
